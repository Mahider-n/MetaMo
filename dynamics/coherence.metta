;; Coherence and Self-Model Drift Dynamics
;; Implements state blending with adaptive step-size and self-model drift validation.

;; Blend Factor Calculation
;; Calculates the dynamic blend factor (α) based on current overgoals.
;; Formula: α = α₀(1 - g_over^Ind) + β₀ * g_over^Trans
;; Individuation reduces alpha (slowing change), Transcendence increases it (speeding growth).
;; Uses ALPHA_0 and BETA_0 from core/config.metta.
;; Example: (calculateBlendFactor $state)
(= (calculateBlendFactor $state)
    (let* (
        ($gInd (getGoal $state gInd))
        ($gTrans (getGoal $state gTrans))
        ($raw (+ (* (eval (ALPHA_0)) (- 1.0 $gInd))
                 (* (eval (BETA_0)) $gTrans)))
    )
        (if (< $raw 0.0) 0.0 (if (> $raw 1.0) 1.0 $raw))
    )
)

;; Self-Model Drift Check
;; Validates that the change in state does not shatter the agent's internal self-model.
;; Based on: d_M(H(x), H(y)) <= L_H * d_X(x, y)
;; Returns True if drift is within bounds, False otherwise.
;; Example: (checkSelfModelDrift $currentState $nextState 1.0 0.1)
(= (checkSelfModelDrift $currentState $nextState $lipschitzConstant $maxAllowedDrift)
    (let* (
        ($distanceMoved (motivationStateDistance $currentState $nextState))
        ($approximatedDrift (* $lipschitzConstant $distanceMoved))
    )
        (<= $approximatedDrift $maxAllowedDrift)
    )
)

;; Blend States (Recursive Adaptive Step-Size)
;; Smoothly interpolates between current state (x_t) and proposed target state (x*).
;; Formula: x_{t+1} = (1 - α)x_t + α * x*
;; Automatically halves α if the proposed blend violates the self-model drift bound.
;; Example: (blendStates $currentState $targetState 1.0 0.1 0.125)
(= (blendStates $currentState $targetState $lipschitzConstant $maxDrift $minAlphaScale)
    (let $baseAlpha (calculateBlendFactor $currentState)
        (blendStatesLoop $currentState $targetState $baseAlpha
            (* $baseAlpha $minAlphaScale) $lipschitzConstant $maxDrift)
    )
)

;; Default-parameter wrapper for blendStates
;; Example: (blendStatesDefault $currentState $targetState)
(= (blendStatesDefault $currentState $targetState)
    (blendStates $currentState $targetState 1.0 0.1 0.125)
)

;; Internal recursive loop for adaptive blending
;; Halves alpha until drift is within bounds or alpha drops below minimum.
;; Example: (blendStatesLoop $current $target 0.1 0.0125 1.0 0.1)
(= (blendStatesLoop $currentState $targetState $alpha $minAlpha $lipschitzConstant $maxDrift)
    (let* (
        ($nextGoals (blendArrays (motivationGoals $currentState) (motivationGoals $targetState) $alpha))
        ($nextMods (blendArrays (motivationModulators $currentState) (motivationModulators $targetState) $alpha))
        ($nextState (motivation $nextGoals $nextMods))
        ($driftOk (checkSelfModelDrift $currentState $nextState $lipschitzConstant $maxDrift))
    )
        (if (or $driftOk (<= $alpha $minAlpha))
            $nextState
            (blendStatesLoop $currentState $targetState (* $alpha 0.5) $minAlpha $lipschitzConstant $maxDrift)
        )
    )
)
