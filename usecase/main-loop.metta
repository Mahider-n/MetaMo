
; Qwestor Main Loop
;
; Full pipeline:
;   Python context_parser (wrap_parser)
;     → projectToMotivation   (state_bridge)
;     → contextToStimulus     (stimulus_adapter)
;     → runMetaMoCycleDefault (MetaMo / main)
;     → scoreAllCandidates    (transparency)
;     → ranked action report
;
; Entry point:
;   (qwestorCycle &space context-list)
;
; Returns:
;   (qwestor-result
;     (selected  <action-atom>)
;     (scores    (<ranked score+action pairs>))
;     (next-motivation <motivation-atom>)
;     (stimulus  <stimulus-values>)
;   )


!(import! &self utils)
!(import! &self config)
!(import! &self "context_parser.py")
!(import! &self adapters/state_bridge)
!(import! &self adapters/stimulus_adapter)
!(import! &self adapters/qwestor_actions)

!(import! &self "../core/helpers.py")
!(import! &self ../core/helper)
!(import! &self ../core/state)
!(import! &self ../core/state_accessors)
!(import! &self ../core/config)
!(import! &self ../openpsi/config)
!(import! &self ../openpsi/appraisal_helpers)
!(import! &self ../openpsi/appraisal)
!(import! &self ../category/functors)
!(import! &self ../category/bimonad)
!(import! &self ../magus/decision)
!(import! &self ../dynamics/stability)
!(import! &self ../dynamics/coherence)
!(import! &self ../main/main)



!(bind! &space (new-space))
!(addState &space ((default-goals) (default-mods) (default-anti-goals)))

(= (runQwestor $space $query)
  (let*
    (
      ; Step 1 ─ Parse query → context list
      ($context-list (py-call (context_parser.wrap_parser $query)))
      ($_ (println! ("[STEP 1] context-list: " $context-list)))

      ; Step 2 ─ project Qwestor space → MetaMo motivation state
      ($current-motiv (eval (projectToMotivation $space)))
      
      ($_ (println! ("[STEP 2] current motivation: " $current-motiv)))

      ; Step 3 ─ translate context list → MetaMo stimulus
      ($stimulus-vals (eval (projectStimulus $context-list)))
      ($stimulus-atom (stimulus $stimulus-vals))
      ($stimulus-final (eval (getStimulusValues $stimulus-atom)))
      ($_ (println! ("[STEP 3] stimulus: " $stimulus-final)))

      ; Step 4 ─ single subsystemState wrapper
      ($states ((subsystemState qwestor $current-motiv) (subsystemState ethics $current-motiv)))
      ($_ (println! ("[STEP 4] state: " $states)))

      ; Step 5 ─ candidate actions
      ($candidates (qwestorCandidates))
      ($_ (println! ("[STEP 5] candidates: " $candidates)))

      ; Step 6 ─ full MetaMo cycle
      ($cycle-result
        (runMetaMoCycleDefault
          (eval (defaultMetaMoBimonad))
          (eval (integrationStates qwestor ethics (eval (integrationState $current-motiv))))
          (eval (integrationStimulus $stimulus-final))
          (eval (qwestorCandidates))
          ()  
          ())
      )

      ($_ (println! ("[STEP 6] cycle-result: " $cycle-result)))

      ; Step 7 ─ extract winning action and next state
      ($selected-action (cycleFinalAction $cycle-result))
      ($_ (println! ("[STEP 7] selected-action: " $selected-action)))

      ($next-states (cycleNextStates $cycle-result))
      ($_ (println! ("[STEP 8] next-states: " $next-states)))

      ($next-motiv (subsystemMotivation (car-atom $next-states)))
      ($_ (println! ("[STEP 9] next-motiv: " $next-motiv)))

      ; Step 8 ─ re-score candidates against merged target
      ($merged-target (cycleMergedTarget $cycle-result))
      ($_ (println! ("[STEP 10] merged-target: " $merged-target)))
    )
    $merged-target
  )
)
 
!(runQwestor &space "What are the most promising approaches to aligning superintelligent AI systems that don't rely on RLHF?")
 