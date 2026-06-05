;; Default dynamics and safety functions for MetaMo

;; These implement the five function-slot interfaces expected by
;; MetaMoPseudoBimonad.  Provide alternative functions with the
;; same signatures and register them in config.metta to swap.
 
;; defaultDamping
;;
;; Interface: (dampingFn $decisionState $proposedDeltaG) -> DampedDeltaG
;;
;; Default: scales proposedDeltaG by C_CONTRACT so large goal
;; updates are damped toward stability.
;;
;; Example: (defaultDamping myState (0.1 -0.05 0.0 ...))
(= (defaultDamping $decisionState $proposedDeltaG)
    (eval (scaleArray $proposedDeltaG (C_CONTRACT)))
)

;; defaultBoundaryStabilize
;;
;; Interface: (boundaryFn $appraisedState) -> StabilizedState
;;
;; Default: clips all modulators by ETA_BOUNDARY from the edges
;; so the state stays away from the [0,1] boundary.
;;
;; Example: (defaultBoundaryStabilize myAppraised)
(= (defaultBoundaryStabilize $appraisedState)
    (motivation
        (motivationGoals $appraisedState)
        (eval (clipVector
            (motivationModulators $appraisedState)
            (ETA_BOUNDARY)
            (- 1.0 (ETA_BOUNDARY))
        ))
    )
)

;; defaultProject
;;
;; Interface: (projectFn $state) -> ProjectedState
;;
;; Default: projects goals into the safe region defined by
;; THETA_SAFE and G_MAX from config.metta.
;;
;; Example: (defaultProject myState)
(= (defaultProject $state)
    (motivation
        (eval (projectGoalsToSafe
            (motivationGoals $state)
            (OPENPSI_GOAL_WEIGHT_IDX)
            (THETA_SAFE)
            (G_MAX)
        ))
        (motivationModulators $state)
    )
)

;; defaultContractiveCheck
;;
;; Interface:
;;   (contractiveFn $bimonad $state $referenceState $stimulus $candidates)
;;   -> Bool
;;
;; Default: verifies the transition from $state is contractive
;; (i.e does not expand distances) by comparing the distance
;; moved to C_CONTRACT * the reference distance.
;;
;; Example: (defaultContractiveCheck myBimonad s0 sRef stim cands)
(= (defaultContractiveCheck $bimonad $state $referenceState $stimulus $candidates)
    (let* (
        ($t1 (computeTransition $bimonad $state $stimulus $candidates))
        ($t2 (computeTransition $bimonad $referenceState $stimulus $candidates))
        ($d1 (motivationStateDistance $state (transitionState $t1)))
        ($d2 (motivationStateDistance $referenceState (transitionState $t2)))
        ($refDist (motivationStateDistance $state $referenceState))
    )
        (if (<= $refDist (EPSILON))
            True
            (<= (absNumber (- $d1 $d2)) (* (C_CONTRACT) $refDist))
        )
    )
)

;; defaultSafeRegionCheck
;;
;; Interface: (safeRegionFn $state) -> Bool
;;
;; Default: checks that gInd (the individuation / weight goal)
;; stays at or above THETA_SAFE, which prevents degenerate
;; goal collapse.
;;
;; Example: (defaultSafeRegionCheck myState)
(= (defaultSafeRegionCheck $state)
    (>= (getGoal $state gInd) (THETA_SAFE))
)