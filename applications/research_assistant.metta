!(import! &self ../core/helper)
!(import! &self "../core/helpers.py")
!(import! &self ../core/state)
!(import! &self ../core/state_accessors)
!(import! &self ../core/config)
!(import! &self ../openpsi/config)
!(import! &self ../category/functors)
!(import! &self ../category/bimonad)
!(import! &self ../openpsi/appraisal)
!(import! &self ../openpsi/appraisal_helpers)
!(import! &self ../magus/decision)
!(import! &self ../dynamics/stability)
!(import! &self ../dynamics/coherence)
!(import! &self ../llm/llm)
!(import! &self "io_bridge.py")
!(import! &self "../llm/metta_bridge.py")


;; 1. Initialization Helpers
(= (createInitialState)
    (let* (
        ($gInd 0.5)
        ($gTrans 0.5)
        ($gHelp 0.8)
        ($gCurio 0.6)
        ($gNovel 0.4)
        ($gSelf 0.3)
        ($gEthic 0.9)
        ($gSoc 0.2)
        ($goals ($gInd $gTrans $gHelp $gCurio $gNovel $gSelf $gEthic $gSoc))
        ($modulators (0.5 0.5 0.5 0.5 0.5 0.5))
    )
        (motivation $goals $modulators)
    )
)

(= (createResearchBimonad)
    (metaMoPseudoBimonad
        (openPsiAppraisal)
        (magusDecision)
        applyHomeostaticDamping
        raiseBoundaryCaution
        projectToSafeRegion
        checkContractiveUpdateLaw
        isInSafeRegion
    )
)

(= (createIdentityTranslator)
    (let* (
        ($goals 8)
        ($mods 6)
        ($gMat (py-call (helpers.identity_matrix $goals)))
        ($mMat (py-call (helpers.identity_matrix $mods)))
    )
        (translationFunctor $gMat $mMat)
    )
)

;; Helper to extract float value for IO formatting
(= (formatFloat $val)
    (py-call (helpers.round_number $val 2))
)

;; 2. Interactive Loop

(= (processUserInput $bimonad $translator $stateCuriosity $stateEthics $userInput)
    (if (or (== $userInput "quit") (== $userInput "exit"))
        False
        (let* (
            ($_ (py-call (io_bridge.print_output "\n[MetaMo Internal Processing...]")))
            
            ;; 1. Perception
            ($stimulus (getStimulusFromText $userInput))
            ; ($_ (println! ("Stimulus Appraisal: " $stimulus)))
            
            ;; 2. Planning
            ($mergedCurrent (eval (parallelMerge $stateCuriosity $stateEthics 0.05)))
            ; ($_ (println! ("Merged State: " $mergedCurrent)))
            ($arousal (getModulator $mergedCurrent arousal))
            ; ($_ (println! ("Arousal: " $arousal)))
            ($caution (getModulator $mergedCurrent securing))
            ; ($_ (println! ("Caution: " $caution)))
            ($candidates (getCandidatesFromText $userInput $arousal $caution))
            ; ($_ (println! ("Candidates: " $candidates)))
            
            ;; 3. Parallel Decision
            ($transC (step $bimonad $stateCuriosity $stimulus $candidates))
            ($transE (step $bimonad $stateEthics $stimulus $candidates))
            ($actionC (transitionAction $transC))
            ($actionE (transitionAction $transE))
            ; ($_ (println! ("Transition Actions: " $actionC " | " $actionE)))
            
            ($_ (py-call (io_bridge.print_output "  > [Curiosity Subsystem] wants to: " (actionId $actionC))))
            ($_ (py-call (io_bridge.print_output "  > [Ethics Subsystem] wants to: " (actionId $actionE))))
            
            ;; 4. Peer Simulation (Optional, for logging)
            ($simEthics (simulatePeer $translator $stateCuriosity))
            ; ($_ (println! ("Simulated Ethics State from Curiosity's perspective: " $simEthics)))
            ($simInd (getGoal $simEthics gInd))
            ; ($_ (println! ("Simulated Ethics Individuation: " $simInd)))
            ($_ (py-call (io_bridge.print_output "  > [Reciprocal Simulation]: Curiosity agent predicts Ethics agent's caution is " (formatFloat $simInd))))
            
            ;; 5. Consensus Transition
            ($finalTrans (consensusTransitionDefault $bimonad $stateCuriosity $stateEthics $stimulus $candidates))
            ; ($_ (println! ("Consensus Transition: " $finalTrans)))
            ($finalAction (transitionAction $finalTrans))
            ; ($_ (println! ("Final Action after Consensus: " $finalAction)))
            ($mergedTarget (transitionState $finalTrans))
            ; ($_ (println! ("Target State after Consensus: " $mergedTarget)))
            
            ; ;; 6. Execution
            ($gInd (getGoal $mergedTarget gInd))
            ($gTrans (getGoal $mergedTarget gTrans))
            ; ($_ (println! ("Merged Target Individuation: " $gInd)))
            ; ($_ (println! ("Merged Target Transcendence: " $gTrans)))
            ($response (llmGenerateFinalResponse $userInput (actionId $finalAction) $gInd $gTrans))
            ; ($_ (println! ("Generated Response: " $response)))
            
            ;; 7. Incremental Embodiment
            ($nextStateCuriosity (blendStates $stateCuriosity (transitionState $transC) 1.0 0.1 0.125))
            ($nextStateEthics (blendStates $stateEthics (transitionState $transE) 1.0 0.1 0.125))
            ; ($_ (println! ("Next Curiosity State: " $nextStateCuriosity)))
            ; ($_ (println! ("Next Ethics State: " $nextStateEthics)))
            
            ($_ (py-call (io_bridge.print_output "\nAssistant: " $response)))
            ($_ (py-call (io_bridge.print_output "\n[Consensus State -> Individuation: " (formatFloat $gInd) " | Transcendence: " (formatFloat $gTrans) "]")))
        )
            (interactiveLoop $bimonad $translator $nextStateCuriosity $nextStateEthics)
        )
    )
)

(= (interactiveLoop $bimonad $translator $stateCuriosity $stateEthics)
    (let* (
        ($userInput (py-call (io_bridge.read_user_input "\nYou: ")))
    )
        (processUserInput $bimonad $translator $stateCuriosity $stateEthics $userInput)
    )
)

(= (startAssistant)
    (let* (
        ($_ (py-call (io_bridge.print_output "Initializing MetaMo Multi-Subsystem Chat Interface (MeTTa)...")))
        ($bimonad (createResearchBimonad))
        ($baseState (createInitialState))
        
        ;; Initialize two parallel subsystems
        ($goalsC (0.5 0.9 0.8 0.6 0.4 0.3 0.9 0.2))
        ($stateCuriosity (motivation $goalsC (motivationModulators $baseState)))
        
        ($goalsE (0.9 0.5 0.8 0.6 0.4 0.3 0.9 0.2))
        ($stateEthics (motivation $goalsE (motivationModulators $baseState)))
        
        ($translator (createIdentityTranslator))
        
        ($_ (py-call (io_bridge.print_output "\nSystem Ready. Subsystems: [Curiosity] & [Ethics]. Type 'quit' to exit.")))
        ($_ (py-call (io_bridge.print_output "------------------------------------------------------------")))
    )
        (interactiveLoop $bimonad $translator $stateCuriosity $stateEthics)
    )
)

!(startAssistant)
