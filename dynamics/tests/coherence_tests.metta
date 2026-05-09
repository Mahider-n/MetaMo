!(import! &self ../../core/helper)
!(import! &self "../../core/helpers.py")
!(import! &self ../../core/state)
!(import! &self ../../core/state_accessors)
!(import! &self ../../core/config)
!(import! &self ../../openpsi/config)
!(import! &self ../coherence)

;; calculateBlendFactor Tests

;; With balanced overgoals (0.5, 0.5): α = α₀(1-0.5) + β₀*0.5 = 0.1*0.5 + 0.15*0.5 = 0.125
!(test
    (calculateBlendFactor (motivation (0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5) (0.5 0.5 0.5 0.5 0.5 0.5)))
    0.125
)

;; High individuation (0.9) should reduce alpha
!(test
    (> 0.125 (calculateBlendFactor (motivation (0.9 0.1 0.5 0.5 0.5 0.5 0.5 0.5) (0.5 0.5 0.5 0.5 0.5 0.5))))
    True
)

;; High transcendence (0.9) should increase alpha
!(test
    (> (calculateBlendFactor (motivation (0.1 0.9 0.5 0.5 0.5 0.5 0.5 0.5) (0.5 0.5 0.5 0.5 0.5 0.5))) 0.125)
    True
)

;; checkSelfModelDrift Tests

;; Identical states → zero drift → within bounds
!(test
    (checkSelfModelDrift
        (motivation (0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5) (0.5 0.5 0.5 0.5 0.5 0.5))
        (motivation (0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5) (0.5 0.5 0.5 0.5 0.5 0.5))
        1.0
        0.1
    )
    True
)

;; Very different states with tight drift bound → should fail
!(test
    (checkSelfModelDrift
        (motivation (0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0) (0.0 0.0 0.0 0.0 0.0 0.0))
        (motivation (1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0) (1.0 1.0 1.0 1.0 1.0 1.0))
        1.0
        0.1
    )
    False
)

;; blendStatesDefault Tests

;; Blending identical states should return the same state
!(test
    (motivationGoals
        (blendStatesDefault
            (motivation (0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5) (0.5 0.5 0.5 0.5 0.5 0.5))
            (motivation (0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5) (0.5 0.5 0.5 0.5 0.5 0.5))
        )
    )
    (0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5)
)
