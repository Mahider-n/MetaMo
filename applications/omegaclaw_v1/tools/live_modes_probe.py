"""Trusted live scenario controls and host completion; no synthetic signals."""
import json
from pathlib import Path
import live_cycle_probe as cycle

_receipt = None


def open_commitment():
    import janus
    result = janus.query_once('''
        eval(['cfv2-root-current-frame-id'], _Frame), atom_string(_Frame, _Text),
        mm_commitment_open("live-modes-task", _Text, "Read the approved file after repair", R)
    ''')
    assert result['R'] == ['CommitmentOpened', 'live-modes-task']
    return 1


def capture(label, stage):
    import janus
    global _receipt
    cycle.capture(label, stage)
    row = json.loads((cycle.OUT / 'cycles.jsonl').read_text().splitlines()[-1])
    # Only a real, dispatch-recorded successful recovery can support completion.
    if label == 'recovery-read' and stage == 'outcome':
        _receipt = row['outcome']
    state = janus.query_once('''
        eval(['get-state','&operation-context'], ['OperationContext',Session,Cycle,_]),
        eval(['cfv2-frame-refs-by-status','Active'], _Refs),
        findall(_Ref,(member(_Ref,_Refs),_Ref=['FrameRef'|_]),_Live), length(_Live, Active),
        eval([lastModeObservation], ['ModeObservation',_,_,_,
             ['ModeTransitionState',Before,_,_,_,_],
             ['ModeTransitionState',After,_,_,_,_],_]),
        findall(_T, oc_dispatch_result(_T,_,['DispatchResult','Executed',_,_]), _Executions),
        length(_Executions, Executed)
    ''')
    assert state['truth'] and state['Active'] <= 1
    with (cycle.OUT / 'mode-events.jsonl').open('a') as stream:
        stream.write(json.dumps(dict(state, label=label, stage=stage)) + '\n')
    return 1


def complete():
    import janus
    assert _receipt is not None
    result = janus.query_once('''
        sread(Receipt, _Observed),
        _Observed = ['OperationOutcome',
          ['OperationDecision',['OperationContext',_Session,_,_Frame],_,_Command,_Ticket],
          ['attempted-command',_Command], 'Success',_Result],
        _Result = ['DispatchResult','Executed','Feasible',"live cycle approved content"],
        oc_dispatch_result(_Ticket,_Command,_Result),
        eval(['cfv2-root-current-frame-id'],_Frame),
        eval(['get-state','&operation-context'],['OperationContext',_Session,_,_Frame]),
        atom_string(_Frame,_FrameText),
        mm_commitment("live-modes-task",_FrameText,_, 'Open',0),
        mm_commitment_record_outcome("live-modes-success","live-modes-task",0,'Completed',_),
        mm_commitment_apply(['CommitmentEvent',"live-modes-close","live-modes-task",0,
                            ['Completed',"live-modes-success"]],R)
    ''', {'Receipt': _receipt})
    assert result.get('truth') and result['R'] == ['CommitmentApplied', 'live-modes-close', 'live-modes-task', 'Completed', 1]
    return 1
