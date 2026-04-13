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
    (let* (
        ((motivation $goals $modulators) $motivation)
        ($goalsLen (size-atom $goals))
        ($modsLen (size-atom $modulators))
    )
        (if (and (== $goalsLen $numGoals) (== $modsLen $numModulators))
            True
            False
        )
)
)











