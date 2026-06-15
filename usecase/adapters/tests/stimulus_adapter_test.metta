!(import! &self ../../utils)  
!(import! &self ../stimulus_adapter)


!(test (findByKey complexity ((urgent 0.0) (complexity 0.1) (ambiguity 0.0) (expertise 0.5) (threshold 0.0) (topic_familiarity 0.9) (failure_signal 0.0) (intent_type factual) (reflective_intent 0.1) (verify_request 0) (needs_external_evidence 0.0) (needs_task_plan 0.0) (needs_multi_source_integration 0.0) (valence 0.0))) 0.1)
!(test (findByKey ambiguity ((urgent 0.0) (complexity 0.1) (ambiguity 0.08) (expertise 0.5) (threshold 0.0) (topic_familiarity 0.9) (failure_signal 0.0) (intent_type factual) (reflective_intent 0.1) (verify_request 0) (needs_external_evidence 0.0) (needs_task_plan 0.0) (needs_multi_source_integration 0.0) (valence 0.0))) 0.08)
!(test (findByKey needs_multi_source_integration ((urgent 0.0) (complexity 0.1) (ambiguity 0.0) (expertise 0.5) (threshold 0.0) (topic_familiarity 0.9) (failure_signal 0.0) (intent_type factual) (reflective_intent 0.1) (verify_request 0) (needs_external_evidence 0.0) (needs_task_plan 0.0) (needs_multi_source_integration 0.7) (valence 0.0))) 0.7)

!(test
  (projectStimulus (
    (urgent 0.0) (complexity 0.1) (ambiguity 0.0) (expertise 0.5) 
    (threshold 0.0) (topic_familiarity 0.9) (failure_signal 0.0) 
    (intent_type factual) (reflective_intent 0.1) (verify_request 0.0) 
    (needs_external_evidence 0.0) (needs_task_plan 0.0) 
    (needs_multi_source_integration 0.0) (valence 0.0)
  ))
  ((novelty 0.08499999999999999) (conduciveness 0.76) (risk 0.009999999999999998) (effort 0.04000000000000001))
)

!(test
  (projectStimulus (
    (urgent 0.0) (complexity 0.0) (ambiguity 0.0) (expertise 0.0) 
    (threshold 0.0) (topic_familiarity 0.0) (failure_signal 0.0) 
    (intent_type factual) (reflective_intent 0.0) (verify_request 0.0) 
    (needs_external_evidence 0.0) (needs_task_plan 0.0) 
    (needs_multi_source_integration 0.0) (valence -1.0)
  ))
  ((novelty 0.4) (conduciveness 0.3) (risk 0.1) (effort 0))
)

!(test
  (projectStimulus (
    (urgent 1.0) (complexity 1.0) (ambiguity 1.0) (expertise 1.0) 
    (threshold 1.0) (topic_familiarity 1.0) (failure_signal 1.0) 
    (intent_type factual) (reflective_intent 1.0) (verify_request 1.0) 
    (needs_external_evidence 1.0) (needs_task_plan 1.0) 
    (needs_multi_source_integration 1.0) (valence 1.0)
  ))
  ((novelty 0.6) (conduciveness 0.4) (risk 1) (effort 1))
)

!(test
  (projectStimulus (
    (urgent 0.0) (complexity 0.0) (ambiguity 0.0) (expertise 1.0) 
    (threshold 0.0) (topic_familiarity 1.0) (failure_signal 0.0) 
    (intent_type factual) (reflective_intent 0.0) (verify_request 0.0) 
    (needs_external_evidence 0.0) (needs_task_plan 0.0) 
    (needs_multi_source_integration 0.0) (valence 1.0)
  ))
  ((novelty 0) (conduciveness 0.9) (risk 0) (effort 0))
)

!(test
  (getStimulusValues
    (stimulus
      ((novelty 0.52) (conduciveness 0.52) (risk 0.53) (effort 0.68))))
  (stimulus (0.52 0.52 0.53 0.68))
)
