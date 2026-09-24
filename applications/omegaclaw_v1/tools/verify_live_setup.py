#!/usr/bin/env python3
"""Verify the bounded Task 6 setup using real services. Makes ASICloud requests."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import signal
import subprocess
import sys
import tempfile
import time

APP = Path(__file__).resolve().parents[1]
METAMO = APP.parents[1]
WORKSPACE = METAMO.parent


def run(command, output, name, environment):
    started = time.monotonic()
    with (output / (name + '.log')).open('w') as log:
        process = subprocess.Popen(command, cwd=WORKSPACE, env=environment,
                                   stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
        timed_out = False
        try:
            code = process.wait(timeout=180)
        except subprocess.TimeoutExpired:
            timed_out = True
            os.killpg(process.pid, signal.SIGTERM)
            try:
                code = process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                os.killpg(process.pid, signal.SIGKILL)
                code = process.wait()
    text = (output / (name + '.log')).read_text(errors='replace')
    passed = len(re.findall(r'^is .*?, should .*?\. ✅\s*$', text, re.MULTILINE))
    errors = bool(re.search(r'^\s*(?:ERROR:|Traceback \(most recent call last\):|\(Error(?:\s|\)))', text, re.MULTILINE))
    return {'command': command, 'exit_code': code, 'timeout': timed_out,
            'seconds': round(time.monotonic() - started, 3), 'assertions': passed,
            'clean': code == 0 and not timed_out and not errors and '❌' not in text}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=Path('/private/tmp'))
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    out = Path(tempfile.mkdtemp(prefix='oc-setup-', dir=args.output)).resolve()
    print('Artifacts: ' + str(out), flush=True)
    data = out / 'input.txt'
    data.write_text('OmegaClaw readiness approved content')
    (out / 'inbox.json').write_text(json.dumps(['Please inspect the approved local test file.']))
    (out / 'history.metta').touch()
    config = json.loads((APP / 'host_dispatch.example.json').read_text())
    config['allowed_files'] = [str(data)]
    config['commands'][0]['arguments'] = [str(data)]
    for scope in ('global', 'frame'):
        config[scope]['permissions'] = ['files.read', 'files.read:' + str(data), 'frames.read']
    (out / 'host.json').write_text(json.dumps(config, indent=2))
    env = dict(os.environ, PYTHONDONTWRITEBYTECODE='1', OMEGACLAW_LIVE_OUTPUT=str(out),
               FRAME_REL_PROVIDER='ASICloud', CHROMA_DB_PATH=str(out / 'chroma'),
               OMEGACLAW_LOCAL_INPUT=str(out / 'inbox.json'),
               OMEGACLAW_HISTORY_PATH=str(out / 'history.metta'),
               TOKENIZERS_PARALLELISM='false', OMP_NUM_THREADS='1', ANONYMIZED_TELEMETRY='False')
    # Load the exact production startup graph, then explicitly probe components
    # instead of starting the autonomous loop. No service or handler is doubled.
    source = (APP / 'run.metta').read_text()
    final = '!(motivatedOmegaclaw)'
    if not source.rstrip().endswith(final):
        raise RuntimeError('Production startup changed; review readiness entry construction')
    prefix = source.rstrip()[:-len(final)]
    probe = APP / 'tools/live_setup_probe.py'
    checks = f'''
!(import! &self {probe})
!(test (py-call (live_setup_probe.runtime)) 1)
!(initLoop)
!(initMemory)
!(initChannels)
!(initContextFrame)
!(initOperationSession)
!(initOmegaClawMotivation)
!(test (provider) ASICloud)
!(test (embeddingprovider) Local)
!(test (commchannel) local)
!(test (py-call (live_setup_probe.memory)) 1)
!(test (py-call (live_setup_probe.channel_input (receive) 0)) 1)
!(test (py-call (live_setup_probe.channel_input (receive) 1)) 1)
!(test (py-call (live_setup_probe.channel_output)) 1)
!(ctx-ingest-user-message "Please inspect the approved local test file.")
!(cfv2-load-frame (get-state &cfv2-last-admitted-frame-id))
!(test (coreLoopPrepare) 1)
!(test (!= (cfv2-root-current-frame-id) ()) True)
;; Trusted handler readiness checks, independent of motivational selection.
;; This mode setup is not evidence of a mode transition or a full live cycle.
!(setConstitutionalMode Engaged)
(= (readinessReadTicket) (coreDispatchCapture (AdmissionRequest propose-candidate current-frame execute-skill)))
(= (readinessFrameTicket) (coreDispatchCapture (AdmissionRequest propose-candidate current-frame search-knowledge)))
!(test (coreDispatchCommand (readinessReadTicket) (quote (read-file {json.dumps(str(data))})))
   (DispatchResult Executed Feasible "OmegaClaw readiness approved content"))
!(test (coreDispatchCommand (readinessFrameTicket) (quote (show-current-frame)))
   (DispatchResult Executed Feasible (cfv2-current-frame)))
!(test (coreDispatchCommand (readinessReadTicket) (quote (read-file "/unregistered/path")))
   (DispatchResult Blocked UnsupportedOperation none))
!(test (coreDispatchCommand (readinessReadTicket) (quote (shell "pwd")))
   (DispatchResult Blocked UnsupportedOperation none))
!(test (py-call (live_setup_probe.config_variant "permission")) 1)
!(test (coreDispatchCommand (readinessReadTicket) (quote (read-file {json.dumps(str(data))})))
   (DispatchResult Blocked PermissionDenied none))
!(test (py-call (live_setup_probe.config_variant "budget")) 1)
!(test (coreDispatchCommand (readinessReadTicket) (quote (read-file {json.dumps(str(data))})))
   (DispatchResult Blocked BudgetExhausted none))
!(test (py-call (live_setup_probe.config_variant "cost")) 1)
!(test (coreDispatchCommand (readinessReadTicket) (quote (read-file {json.dumps(str(data))})))
   (DispatchResult Blocked ConstraintDenied none))
!(test (py-call (live_setup_probe.config_variant "allowed")) 1)
!(test (py-call (live_setup_probe.provider)) 1)
'''
    entry = out / 'setup.metta'
    entry.write_text(prefix + checks)
    reopen = out / 'reopen.metta'
    reopen.write_text(prefix + f'!(import! &self {probe})\n!(test (py-call (live_setup_probe.reopen_memory)) 1)\n')
    base = [sys.executable, str(METAMO / 'scripts/run-omegaclaw.py')]
    runtime_args = ['--host-config', str(out / 'host.json'), 'commchannel=local',
                    'provider=ASICloud', 'embeddingprovider=Local', 'maxSessionCycles=1',
                    'maxOutputToken=512', 'sleepInterval=0']
    reports = []
    for name, path in [('setup', entry), ('reopen', reopen)]:
        report = run(base + [str(path), '--report', str(out / (name + '-imports.json'))] + runtime_args, out, name, env)
        report['expected_assertions'] = path.read_text().count('!(test ')
        report['passed'] = report['clean'] and report['assertions'] == report['expected_assertions']
        reports.append(report)
        print(name + ': ' + ('PASS' if report['passed'] else 'FAIL'), flush=True)
        if not report['passed']:
            break
    files = {APP / 'run.metta', Path(__file__).resolve(), probe}
    for path in out.glob('*-imports.json'):
        # Fingerprint every resolved source, including Python and Prolog overlays.
        def visit(value):
            if isinstance(value, dict):
                for child in value.values():
                    visit(child)
            elif isinstance(value, list):
                for child in value:
                    visit(child)
            elif isinstance(value, str) and value.startswith('/'):
                candidate = Path(value)
                if candidate.is_file() and candidate.suffix in ('.metta', '.pl', '.py'):
                    files.add(candidate)
        visit(json.loads(path.read_text()))
    summary = {'time_utc': datetime.now(timezone.utc).isoformat(), 'passed': len(reports) == 2 and all(r['passed'] for r in reports),
               'scope': 'Task 6 setup only; no autonomous-loop or mode-transition acceptance',
               'runs': reports, 'sources': {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(files)},
               'swipl': subprocess.check_output(['swipl', '--version'], text=True).strip()}
    (out / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    print('PASS' if summary['passed'] else 'FAIL', flush=True)
    return 0 if summary['passed'] else 1


if __name__ == '__main__':
    sys.exit(main())
