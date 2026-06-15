
; Qwestor Main Loop
;
; Full pipeline:
;   1. Parse the user query into a structured context (Python wrap_parser)
;   2. Project the Qwestor space into a MetaMo motivation state (state_bridge)
;   3. Convert context list into a MetaMo stimulus (stimulus_adapter)
;   4. Run the MetaMo cycle to select the optimal action
;   5. Re-score all candidate actions against merged target
;   6. Return a comprehensive result including selected action, scores,
;      next motivation state, and stimulus values
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


; Initialize a new reasoning space for Qwestor

!(bind! &space (new-space))
!(addState &space ((default-goals) (default-mods) (default-anti-goals)))

 

; runQwestor
; Main function: full pipeline from user query to ranked actions and
; next motivation state.

(= (runQwestor $space $query)
  (let*
    (
      ; Step 1 ─ Parse the user query using Python context_parser
      ; Converts free-text query into structured list of context features

      ($context-list (py-call (context_parser.wrap_parser $query)))
      ($_ (println! ("[STEP 1] context-list: " $context-list)))

      ; Step 2 ─ Project Qwestor space into MetaMo motivation state
      ; This initializes the agent's internal motivational state

      ($current-motiv (eval (projectToMotivation $space)))
      
      ($_ (println! ("[STEP 2] current motivation: " $current-motiv)))

      ; Step 3 ─ Convert context list into MetaMo stimulus
      ; Maps contextual information to stimulus values usable by the cycle

      ($stimulus-vals (eval (projectStimulus $context-list)))
      ($stimulus-atom (stimulus $stimulus-vals))
      ($stimulus-final (eval (getStimulusValues $stimulus-atom)))
      ($_ (println! ("[STEP 3] stimulus: " $stimulus-final)))

      ; Step 4 ─ Wrap motivation state in subsystemStates for cycle
      ; Prepares input for MetaMo bimonad cycle

      ; this can be extended to multiple subsystems with different motivations if needed 
      ($states ((subsystemState qwestor $current-motiv) (subsystemState ethics $current-motiv)))
      ($_ (println! ("[STEP 4] state: " $states)))

      ; Step 5 ─ Retrieve candidate actions for Qwestor

      ($candidates (qwestorCandidates))
      ($_ (println! ("[STEP 5] candidates: " $candidates)))

      ; Step 6 ─ Execute full MetaMo cycle

      ($cycle-result
        (runMetaMoCycleDefault
          (eval (defaultMetaMoBimonad))
          ; Single subsystem (Qwestor) for now, but can be extended to multiple
          ((subsystemState qwestor $current-motiv))
          (eval (integrationStimulus $stimulus-final))
          (eval (qwestorCandidates))
          ()  
          ())
      )

      ($_ (println! ("[STEP 6] cycle-result: " $cycle-result)))

      ; Step 7 ─ Extract winning action and action identifier

      ($selected-action (cycleFinalAction $cycle-result))
      ($_ (println! ("[STEP 7] selected-action: " $selected-action)))
      ($action-name (actionId $selected-action))
      ($_ (println! ("[STEP 7] action-name: " $action-name)))
      
      ; Step 8 ─ Extract next motivation states from cycle result

      ($next-states (cycleNextStates $cycle-result))
      ($_ (println! ("[STEP 8] next-states: " $next-states)))

      ; Step 9 ─ Extract the next motivation for the Qwestor subsystem

      ($next-motiv (subsystemMotivation (car-atom $next-states)))
      ($_ (println! ("[STEP 9] next-motiv: " $next-motiv)))

      ; Step 10 ─ Compute merged target for candidate re-scoring
      ; Needed for transparency / ranked scoring of all candidates

      ($merged-target (cycleMergedTarget $cycle-result))
      ($_ (println! ("[STEP 10] merged-target: " $merged-target)))

      ; Step 11 ─ Construct final Qwestor result object

      ($result (qwestor-result
          (selected         $action-name)
          (candidates       $candidates)
          (next-motivation  $next-motiv)
          (stimulus         $stimulus-vals)
      ))

    )
    
    ; Print the full Qwestor decision report
    (printQwestorResult $result)
  )
)




; Example execution: process a query 
!(runQwestor &space "What are the most promising approaches to aligning superintelligent AI systems that don't rely on RLHF?")
