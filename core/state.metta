;; Core state definitions for MetaMo

(: MotivationalState Type)
(: motivation (-> Expression Expression MotivationalState))

(: StimulusState Type)
(: stimulus (-> Number Number Number Number StimulusState))

(: ActionType Type)
(: action (-> Symbol Expression Number Expression ActionType))

(= (motivationGoals (motivation $goals $modulators))
    $goals
)

(= (motivationModulators (motivation $goals $modulators))
    $modulators
)

(= (stimulusNovelty (stimulus $novelty $conduciveness $risk $effort))
    $novelty
)

(= (stimulusConduciveness (stimulus $novelty $conduciveness $risk $effort))
    $conduciveness
)

(= (stimulusRisk (stimulus $novelty $conduciveness $risk $effort))
    $risk
)

(= (stimulusEffort (stimulus $novelty $conduciveness $risk $effort))
    $effort
)

(= (actionId (action $actionId $goalCorrelations $riskEstimate $deltaG))
    $actionId
)

(= (actionGoalCorrelations (action $actionId $goalCorrelations $riskEstimate $deltaG))
    $goalCorrelations
)

(= (actionRiskEstimate (action $actionId $goalCorrelations $riskEstimate $deltaG))
    $riskEstimate
)

(= (actionDeltaG (action $actionId $goalCorrelations $riskEstimate $deltaG))
    $deltaG
)

(= (copyMotivationState (motivation $goals $modulators))
    (motivation $goals $modulators)
)

(= (validateMotivationState (motivation $goals $modulators) $numGoals $numModulators)
    (if (and (== (size-atom $goals) $numGoals) (== (size-atom $modulators) $numModulators))
        True
        False
    )
)

(= (validateMotivationalStateShape $motivationState)
    (validateMotivationState $motivationState (eval (NUM_GOALS)) (eval (NUM_MODULATORS))))


(= (validateActionState (action $actionId $goalCorrelations $riskEstimate $deltaG) $numGoals)
    (if (and (== (size-atom $goalCorrelations) $numGoals) (== (size-atom $deltaG) $numGoals))
        True
        False
    )
)

(= (validateActionShape $actionState)
    (validateActionState $actionState (eval (NUM_GOALS)))
)

(= (motivationStateDistance (motivation $goals $modulators) (motivation $goals2 $modulators2))
    (+ (eval (norm (listDifference $goals $goals2)))
       (eval (norm (listDifference $modulators $modulators2))))
)

(= (motivationStateDiff (motivation $goals $modulators) (motivation $goals2 $modulators2))
    (eval
        (roundNum
            (+ (calculateNormDifference $goals $goals2)
               (calculateNormDifference $modulators $modulators2))
            2
        )
    )
)
