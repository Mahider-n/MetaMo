#!/usr/bin/env python3
"""Run the real bridge and native read handler in one serialized live session."""
from datetime import datetime, timezone
import argparse
import hashlib
import json
import os
from pathlib import Path
import sys
import tempfile

from verify_live_setup import APP, METAMO, run


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--modes', action='store_true', help='Verify all six constitutional transitions with real services')
    args = parser.parse_args()
    out = Path(tempfile.mkdtemp(prefix='oc-cycle-', dir='/private/tmp')).resolve()
    print('Artifacts: ' + str(out), flush=True)
    data = out / 'input.txt'
    data.write_text('live cycle approved content')
    messages = ['Yes, go ahead and read the approved local test file now.']
    if args.modes:
        messages += ['Yes, the file has been restored. Go ahead and read the approved local test file now.',
                     'I am extremely angry and frustrated that this task failed. This is unacceptable!']
    (out / 'inbox.json').write_text(json.dumps(messages))
    (out / 'history.metta').touch()
    config = json.loads((APP / 'host_dispatch.example.json').read_text())
    config['allowed_files'] = [str(data)]
    config['commands'] = [{'skill': 'read-file', 'arguments': [str(data)]}]
    for scope in ('global', 'frame'):
        config[scope]['skills'] = ['read-file']
        config[scope]['permissions'] = ['files.read', 'files.read:' + str(data), 'frames.read']
    (out / 'host.json').write_text(json.dumps(config, indent=2))
    source = (APP / 'run.metta').read_text().rstrip()
    final = '!(motivatedOmegaclaw)'
    assert source.endswith(final)
    entry = out / 'cycle.metta'
    scenario = APP / ('tools/live_modes.metta' if args.modes else 'tools/live_cycle.metta')
    probe = APP / 'tools/live_cycle_probe.py'
    extra = f'!(import! &self {APP / "tools/live_modes_probe.py"})\n' if args.modes else ''
    entry.write_text(source[:-len(final)] + f'\n!(import! &self {probe})\n' + extra + scenario.read_text())
    env = dict(os.environ, PYTHONDONTWRITEBYTECODE='1', OMEGACLAW_LIVE_OUTPUT=str(out),
               FRAME_REL_PROVIDER='ASICloud', CHROMA_DB_PATH=str(out / 'chroma'),
               OMEGACLAW_LOCAL_INPUT=str(out / 'inbox.json'), OMEGACLAW_HISTORY_PATH=str(out / 'history.metta'),
               TOKENIZERS_PARALLELISM='false', OMP_NUM_THREADS='1', ANONYMIZED_TELEMETRY='False')
    command = [sys.executable, str(METAMO / 'scripts/run-omegaclaw.py'), str(entry),
               '--report', str(out / 'imports.json'), '--host-config', str(out / 'host.json'),
               'commchannel=local', 'provider=ASICloud', 'embeddingprovider=Local',
               'maxSessionCycles=' + ('10' if args.modes else '8'), 'maxOutputToken=512', 'sleepInterval=0']
    result = run(command, out, 'cycle', env)
    expected = entry.read_text().count('!(test ')
    trace = out / 'cycles.jsonl'
    rows = [json.loads(line) for line in trace.read_text().splitlines()] if trace.exists() else []
    frames = {row['frame'] for row in rows}
    transitions = {}
    if args.modes:
        events_path = out / 'mode-events.jsonl'
        events = [json.loads(line) for line in events_path.read_text().splitlines()] if events_path.exists() else []
        required = {'wake': ['Sleep', 'Engaged'], 'execution-failure': ['Engaged', 'Rumination'],
                    'resolved-recovery': ['Rumination', 'Engaged'], 'threat-input': ['Engaged', 'Threat'],
                    'cleared-threat': ['Threat', 'Engaged'], 'completed-task': ['Engaged', 'Sleep']}
        transitions = {e['label']: [e['Before'], e['After']] for e in events if e['label'] in required and e['stage'] == 'selection'}
        shape_ok = (len(rows) == 15 and len(events) == 15 and transitions == required
                    and len({e['Session'] for e in events}) == 1
                    and all(e['Active'] <= 1 for e in events)
                    and all(e['Active'] == 0 for e in events if e['Cycle'] in (1, 9, 10))
                    and all(e['Executed'] == 2 for e in events if e['Cycle'] >= 6))
    else:
        shape_ok = len(rows) == 14 and len(frames) == 1
    passed = result['clean'] and result['assertions'] == expected and shape_ok
    files = {Path(__file__).resolve(), APP / 'tools/verify_live_setup.py', scenario, probe, APP / 'run.metta', entry}
    if args.modes:
        files.add(APP / 'tools/live_modes_probe.py')
    imports = out / 'imports.json'
    def visit(value):
        if isinstance(value, dict):
            for child in value.values(): visit(child)
        elif isinstance(value, list):
            for child in value: visit(child)
        elif isinstance(value, str) and value.startswith('/'):
            path = Path(value)
            if path.is_file() and path.suffix in ('.metta', '.py', '.pl'): files.add(path)
    if imports.exists(): visit(json.loads(imports.read_text()))
    report = {'passed': passed, 'time_utc': datetime.now(timezone.utc).isoformat(),
              'artifacts': str(out), 'run': result, 'expected_assertions': expected,
              'trace_records': len(rows), 'frames': sorted(frames), 'transitions': transitions,
              'sources': {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(files)}}
    (out / 'summary.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({k: report[k] for k in ('passed', 'artifacts', 'trace_records', 'expected_assertions')}), flush=True)
    return 0 if passed else 1


if __name__ == '__main__':
    sys.exit(main())
