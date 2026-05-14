!(import! &self ../../core/helper)
!(import! &self "../../core/helpers.py")
!(import! &self ../../core/state)
!(import! &self ../../core/state_accessors)
!(import! &self ../../core/config)
!(import! &self ../../openpsi/config)
!(import! &self ../coherence)

;; Shared OpenPSI-shaped states for coherence tests.
(= (coherenceState)
    (motivation
        (0.2 0.8 0.5 0.5 0.5 0.5 0.5 0.5)
        (0.1 0.2 0.3 0.4 0.5 0.6)
    )
)

(= (coherenceTarget)
    (motivation
        (0.4 0.6 0.5 0.5 0.5 0.5 0.5 0.5)
        (0.2 0.3 0.3 0.4 0.5 0.6)
    )
)

;; calculateBlendFactor: alpha = ALPHA_0 * (1 - gInd) + BETA_0 * gTrans.
!(test
    (roundNum (calculateBlendFactor (coherenceState)) 6)
    0.2
)

;; calculateBlendFactor clips values below 0.0.
!(test
    (calculateBlendFactor
        (motivation
            (20.0 0.0 0.5 0.5 0.5 0.5 0.5 0.5)
            (0.1 0.2 0.3 0.4 0.5 0.6)
        )
    )
    0.0
)

;; calculateBlendFactor clips values above 1.0.
!(test
    (calculateBlendFactor
        (motivation
            (-10.0 10.0 0.5 0.5 0.5 0.5 0.5 0.5)
            (0.1 0.2 0.3 0.4 0.5 0.6)
        )
    )
    1.0
)

;; checkSelfModelDrift accepts drift at the threshold.
!(test
    (checkSelfModelDrift
        (motivation (0.0 0.0) (0.0 0.0))
        (motivation (0.3 0.4) (0.0 0.0))
        2.0
        1.0
    )
    True
)

;; checkSelfModelDrift rejects drift over the threshold.
!(test
    (checkSelfModelDrift
        (motivation (0.0 0.0) (0.0 0.0))
        (motivation (0.6 0.8) (0.0 0.0))
        1.1
        1.0
    )
    False
)

;; nextStateCalculator preserves the state under its current alpha-weighted formula.
!(test
    (nextStateCalculator (coherenceState) 0.35)
    (coherenceState)
)

;; blendStatesHelper returns the provided next state when the target drift is allowed.
!(test
    (blendStatesHelper
        (coherenceState)
        (coherenceTarget)
        (coherenceTarget)
        0.2
        0.02
        1.0
        10.0
    )
    (coherenceTarget)
)

;; blendStatesHelper also returns the provided next state once alpha reaches minAlpha.
!(test
    (blendStatesHelper
        (coherenceState)
        (coherenceTarget)
        (motivation
            (1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)
            (1.0 1.0 1.0 1.0 1.0 1.0)
        )
        0.02
        0.02
        1.0
        0.0
    )
    (coherenceTarget)
)

;; blendStates is stable for an already-identical current and target state.
!(test
    (blendStates (coherenceState) (coherenceState) 1.0 0.0 0.5)
    (coherenceState)
)
