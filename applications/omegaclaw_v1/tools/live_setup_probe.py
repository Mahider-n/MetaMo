"""Real-service readiness probes loaded by PeTTa/Janus, never by offline tests."""
import contextlib
import copy
from importlib import metadata
import io
import json
import math
import os
import platform
from pathlib import Path
import sys

OUTPUT = Path(os.environ['OMEGACLAW_LIVE_OUTPUT'])
MESSAGE = 'Please inspect the approved local test file.'
PAYLOAD = 'MOTIVOS_STATE_V1 time:2026-09-24 G:((goal progress 0.4)) AG:() M:((modulator urgency 0.2)) S:()'


def save(name, value):
    (OUTPUT / (name + '.json')).write_text(json.dumps(value, indent=2) + '\n')
    return 1


def runtime():
    names = ('numpy', 'openai', 'chromadb', 'torch', 'transformers',
             'sentence-transformers', 'python-dotenv', 'uagents', 'ddgs',
             'requests', 'websocket-client', 'tokenizers', 'huggingface-hub')
    return save('runtime', {'passed': True, 'python': sys.version, 'platform': platform.platform(),
                           'versions': {name: metadata.version(name) for name in names}})


def provider():
    import lib_llm_ext as llm
    model = llm._get_provider('ASICloud')
    # Bound the explicit diagnostic requests; no automatic transport retries.
    if os.environ.get('GATEWAY_URL'):
        raise RuntimeError('This profile verifies direct ASICloud; unset GATEWAY_URL')
    model._client = model._create_client().with_options(timeout=30, max_retries=0)
    confirmation = llm.executionConfirmationScore(
        'ASICloud', 'Yes, go ahead and read that file.', 'Read the approved local test file.')
    semantics = llm.extractSemantics('ASICloud', MESSAGE)
    response = llm.callProvider('ASICloud',
        'Return exactly the empty MeTTa command list (). No explanation.', 512, 'low')
    passed = confirmation > .75 and 'execution-request' in semantics and response.strip() == '()'
    save('provider', {'passed': passed, 'provider': 'ASICloud', 'model': model._model_name,
                      'endpoint': model._base_url, 'command_max_tokens': 512, 'confirmation': confirmation,
                      'semantics': semantics, 'command_response': response})
    return int(passed)


def memory():
    import lib_llm_ext as llm
    import lib_chromadb as memory
    import frame_relation
    vector = llm.useLocalEmbedding(PAYLOAD)
    assert len(vector) == 1024 and all(math.isfinite(x) for x in vector)
    item = memory.remember(PAYLOAD, vector, '2026-09-24')
    rows = memory.query(vector, 1)
    parsed = llm.parseMotivosState(rows)
    frames = frame_relation._get_collection('Local')
    # Verify actual frame-sketch collection IO in the same persistent store.
    frames.add(ids=['readiness-frame'], embeddings=[vector], documents=['synthetic frame'])
    assert frames.get(ids=['readiness-frame'])['documents'] == ['synthetic frame']
    assert rows == [['2026-09-24', PAYLOAD]]
    assert parsed == '((goal progress 0.4) (modulator urgency 0.2))'
    assert memory.CLIENT.get_settings().persist_directory == str(OUTPUT / 'chroma')
    assert frame_relation._chroma_client.get_settings().persist_directory == str(OUTPUT / 'chroma')
    return save('memory', {'passed': True, 'dimensions': len(vector), 'memory_id': item,
                           'shared_store_path': True, 'parsed': parsed})


def channel_output():
    import local_channel
    output = io.StringIO()
    with contextlib.redirect_stdout(output):
        local_channel.send_message('readiness reply')
    assert json.loads(output.getvalue()) == {'channel': 'local', 'message': 'readiness reply'}
    return save('channel', {'passed': True, 'channel': 'local', 'transport': 'JSON inbox / stdout'})


def channel_input(value, index):
    # Janus returns Python text as a Prolog atom; compare text at its boundary.
    return int(value == (MESSAGE if index == 0 else ''))


def config_variant(variant):
    import host_dispatch_config as host
    config = json.loads((OUTPUT / 'host.json').read_text())
    config = copy.deepcopy(config)
    if variant == 'permission':
        config['frame']['permissions'] = ['frames.read']
    elif variant == 'budget':
        config['frame']['budgets'][0]['available'] = 0
    elif variant == 'cost':
        config['global']['constraints'].append(['MaxCost', 'commands', 'units', 0])
    elif variant != 'allowed':
        raise ValueError(variant)
    path = OUTPUT / ('host-' + variant + '.json')
    path.write_text(json.dumps(config, indent=2))
    host.configure_startup(str(path))
    return host.provision_startup()


def reopen_memory():
    import lib_chromadb as memory
    import frame_relation
    saved = json.loads((OUTPUT / 'memory.json').read_text())
    assert memory.COLLECTION.get(ids=[saved['memory_id']])['documents'] == [PAYLOAD]
    assert frame_relation._get_collection('Local').get(ids=['readiness-frame'])['documents'] == ['synthetic frame']
    return save('memory-reopen', {'passed': True, 'fresh_process': True})
