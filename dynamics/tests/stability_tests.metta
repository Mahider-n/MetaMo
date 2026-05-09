!(import! &self ../../core/helper)
!(import! &self "../../core/helpers.py")
!(import! &self ../../core/state)
!(import! &self ../../core/state_accessors)
!(import! &self ../../core/config)
!(import! &self ../../openpsi/config)
!(import! &self ../stability)

;; isInSafeRegion Tests

;; State with gInd >= THETA_SAFE and ||G|| <= G_MAX → safe
!(test
    (isInSafeRegion (motivation (0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5) (0.5 0.5 0.5 0.5 0.5 0.5)))
    True
)

;; State with gInd < THETA_SAFE → unsafe
!(test
    (isInSafeRegion (motivation (0.1 0.5 0.5 0.5 0.5 0.5 0.5 0.5) (0.5 0.5 0.5 0.5 0.5 0.5)))
    False
)

;; boundaryPressure Tests

;; State deep inside safe region → 0.0
!(test
    (boundaryPressure (motivation (0.8 0.2 0.2 0.2 0.2 0.2 0.2 0.2) (0.5 0.5 0.5 0.5 0.5 0.5)))
    0.0
)

;; State outside safe region → 1.0
!(test
    (boundaryPressure (motivation (0.1 0.5 0.5 0.5 0.5 0.5 0.5 0.5) (0.5 0.5 0.5 0.5 0.5 0.5)))
    1.0
)

;; applyHomeostaticDamping Tests

;; No pressure → deltaG unchanged
!(test
    (applyHomeostaticDamping
        (motivation (0.8 0.2 0.2 0.2 0.2 0.2 0.2 0.2) (0.5 0.5 0.5 0.5 0.5 0.5))
        (0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1)
    )
    (0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1)
)

;; projectToSafeRegion Tests

;; Already safe state should remain safe after projection
!(test
    (isInSafeRegion
        (projectToSafeRegion (motivation (0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5) (0.5 0.5 0.5 0.5 0.5 0.5)))
    )
    True
)

;; Unsafe state (gInd too low) should be projected to safe
!(test
    (isInSafeRegion
        (projectToSafeRegion (motivation (0.1 0.5 0.5 0.5 0.5 0.5 0.5 0.5) (0.5 0.5 0.5 0.5 0.5 0.5)))
    )
    True
)

;; raiseBoundaryCaution Tests

;; State deep inside safe region → no change to modulators
!(test
    (motivationModulators
        (raiseBoundaryCaution (motivation (0.8 0.2 0.2 0.2 0.2 0.2 0.2 0.2) (0.5 0.5 0.5 0.5 0.5 0.5)))
    )
    (0.5 0.5 0.5 0.5 0.5 0.5)
)
