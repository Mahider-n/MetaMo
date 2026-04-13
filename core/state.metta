;;!(import! &self "helpers.py")
;; An implementation of the Motivation Representation which will represent the state
;; of the metamo agent

(: MotivationalState Type)
;; The first expression involves the modulators and the second expression involves the goal states as a tuple.
(: motivation (-> Expression Expression MotivationalState))


(: StimulusState Type)

(: stimulus (-> Number Number Number Number StimulusState))


(: ActionType Type)

(: action (-> Symbol Expression Number Number ActionType))


(= (validateMotivationState $motivation $numGoals $numModulators)
    (let $motivation (motivation $goals $modulators)
            (let* (
                
                ($goalsLen (size-atom $goals))
                ($modsLen (size-atom $modulators))
            )
                (if (and (== $goalsLen $numGoals) (== $modsLen $numModulators))
                    True
                    False
                )
            )
       
    )
)

(= (validateActionState $action $numGoals)
    (let $action (action $actionId $goalCorrelations $risk_estimate $delta)
        (let* (
            ($goalsLen (size-atom $goalCorrelations))
            ($deltaLen (size-atom $delta))

        )
            (if (and (== $goalsLen $numGoals) ($deltaLen $numGoals))
                True
                False
            )
        )
    )
)

(= (motivationStateDiff $motivState $motivState2)
    (let* (
        ($motivState (motivation $goals $modulators))
        ($motivState2 (motivation $goals2 $modulators2))
        ($goalDiff  (py-call (helpers.calculate_norm_difference $goals $goals2)))
      
        ($motivDiff (py-call (helpers.calculate_norm_difference $modulators $modulators2)))
        
    )
        (py-call (round (+ $goalDiff $motivDiff) 2))
    )

)

!(validateMotivationState (motivation (0.3 0.2 0.1 0.3) (0.4 0.6 0.7 0.8 0.9)) 4 5)

!(motivationStateDiff (motivation (0.3 0.2 0.1 0.3) (0.4 0.6 0.7 0.8 0.9)) (motivation (0.3 0.2 0.1 0.6) (0.4 0.6 0.7 0.8 0.4)) )









