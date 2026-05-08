!(import! &self ../../core/helper)
!(import! &self ../../core/state)
!(import! &self "../../core/helpers.py")
!(import! &self ../functors)


;; Mock extraction function that returns the state unchanged.
(= (identityExtract $state)
    $state
)

;; Mock appraisal function that updates modulators based on stimulus.
(= (simpleAppraise $state (stimulus $stimValues))
    (let* (
        ($stim0 (index-atom $stimValues 0))
        ($stim1 (index-atom $stimValues 1))
    )
        (motivation
            (motivationGoals $state)
            (clipVector (vectorAdd (motivationModulators $state) ($stim0 $stim1)) 0.0 1.0)
        )
    )
)

;; Mock unit function for the decision monad (identity).
(= (identityUnit $state)
    $state
)

;; Mock decision function that always returns a constant decision result.
(= (constantDecide $state $candidates)
    (decisionResult (action act1 (0.25 0.75) 0.25 (0.125 -0.125)) (0.125 -0.125))
)

;; Mock scoring function that sums goal correlations and current goals.
(= (simpleScore $state (action $actionId $goalCorrelations $riskEstimate $deltaG))
    (+ (sum $goalCorrelations) (sum (motivationGoals $state)))
)

;; Test the 'extract' operation using an identity extraction function.
!(test
    (extract
        (appraisalComonad identityExtract simpleAppraise)
        (motivation (0.25 0.75) (0.125 0.25))
    )
    (motivation (0.25 0.75) (0.125 0.25))
)

;; Test the 'appraise' operation to ensure modulators are correctly updated by a stimulus.
!(test
    (appraise
        (appraisalComonad identityExtract simpleAppraise)
        (motivation (0.25 0.75) (0.125 0.25))
        (stimulus (0.125 0.125 0.0 0.0))
    )
    (motivation (0.25 0.75) (0.25 0.375))
)

;; Test the decision action selection process using a mock decision monad.
!(test
    (decisionAction
        (decide
            (decisionMonad identityUnit constantDecide simpleScore)
            (motivation (0.25 0.75) (0.125 0.25))
            ()
        )
    )
    (action act1 (0.25 0.75) 0.25 (0.125 -0.125))
)


;; Verify that a translation functor with square matrices is considered valid.
!(test
    (validateTranslationFunctor
        (translationFunctor
            ((1.0 0.0) (0.0 1.0))
            ((1.0 0.0) (0.0 1.0))
        )
    )
    True
)

;; Verify that simulatePeer correctly transforms a state using identity matrices.
!(test
    (simulatePeer
        (translationFunctor
            ((1.0 0.0) (0.0 1.0))
            ((1.0 0.0) (0.0 1.0))
        )
        (motivation (0.25 0.75) (0.125 0.25))
    )
    (motivation (0.25 0.75) (0.125 0.25))
)
