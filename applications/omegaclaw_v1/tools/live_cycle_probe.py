"""Trusted controls for a bounded live run; no provider or handler replacements."""
import json
import os
from pathlib import Path

OUT = Path(os.environ['OMEGACLAW_LIVE_OUTPUT'])


def prepare():
    import lib_llm_ext as llm
    if os.environ.get('GATEWAY_URL'):
        raise RuntimeError('Unset GATEWAY_URL for the direct ASICloud profile')
    model = llm._get_provider('ASICloud')
    model._client = model._create_client().with_options(timeout=30, max_retries=0)
    return 1


def change_file(available):
    path = OUT / 'input.txt'
    if available:
        path.write_text('live cycle approved content')
    else:
        path.unlink()
    return 1


def policy(allowed):
    import host_dispatch_config as host
    value = json.loads((OUT / 'host.json').read_text())
    if not allowed:
        value['frame']['permissions'] = ['frames.read']
        value['frame']['skills'] = ['read-file']
    path = OUT / ('allowed.json' if allowed else 'denied.json')
    path.write_text(json.dumps(value, indent=2))
    host.configure_startup(str(path))
    return host.provision_startup()


def capture(label, stage):
    import janus
    expressions = {
        'context': '(get-state &operation-context)',
        'frame': '(cfv2-root-current-frame-id)',
        'active_frames': '(cfv2-frame-refs-by-status Active)',
        'snapshot': '(activeFrameBundle)',
        'current_snapshot': '(frameStateForMetaMo)',
        'mode': '(lastModeObservation)',
        'decision': '(get-state &last-motivation-decision)',
        'selected': '(get-state &selected-operation-decision)',
        'outcome': '(get-state &last-operation-outcome)',
        'rejections': '(candidateRejections)',
        'feedback': '(get-state &operation-feedback)',
    }
    row = {'label': label, 'stage': stage}
    row['host_binding_count'] = janus.query_once('findall(_C, mm_dispatch_binding(_C,_,_), _Cs), length(_Cs,N)')['N']
    for name, source in expressions.items():
        result = janus.query_once('sread(Source, E), eval(E, V), swrite(V, Text)', {'Source': source})
        if not result.get('truth'):
            raise RuntimeError('Missing trace field: ' + name)
        row[name] = result['Text']
    with (OUT / 'cycles.jsonl').open('a') as stream:
        stream.write(json.dumps(row) + '\n')
    return 1
