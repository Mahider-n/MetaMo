;;; ============================================================
;;; Tests for core/state.metta
;;; ============================================================
;;; Covers: Type constructors, validateMotivationState,
;;;         validateActionState, motivationStateDiff
;;; ============================================================
!(import! &self "../helpers.py")
!(import! &self ../state)

;; ---------------------------------------------------------
;; 1. Type Construction Tests
;; ---------------------------------------------------------

;; 1a. MotivationalState – basic construction
!(test
    (motivation (0.3 0.2 0.1 0.3) (0.4 0.6 0.7 0.8 0.9))
    (motivation (0.3 0.2 0.1 0.3) (0.4 0.6 0.7 0.8 0.9))
)

;; 1b. StimulusState – basic construction
!(test
    (stimulus 1 2 3 4)
    (stimulus 1 2 3 4)
)

;; 1c. ActionType – basic construction
!(test
    (action act1 (0.1 0.2 0.3) 0.5 0.1)
    (action act1 (0.1 0.2 0.3) 0.5 0.1)
)

;; ---------------------------------------------------------
;; 2. validateMotivationState Tests
;; ---------------------------------------------------------

;; 2a. Valid motivation state – correct goal and modulator counts
!(test
    (validateMotivationState (motivation (0.3 0.2 0.1 0.3) (0.4 0.6 0.7 0.8 0.9)) 4 5)
    True
)

;; 2b. Valid motivation state – single goal, single modulator
!(test
    (validateMotivationState (motivation (0.5) (0.9)) 1 1)
    True
)

;; 2c. Invalid – wrong number of goals (expect 3, have 4)
!(test
    (validateMotivationState (motivation (0.3 0.2 0.1 0.3) (0.4 0.6 0.7 0.8 0.9)) 3 5)
    False
)

;; 2d. Invalid – wrong number of modulators (expect 4, have 5)
!(test
    (validateMotivationState (motivation (0.3 0.2 0.1 0.3) (0.4 0.6 0.7 0.8 0.9)) 4 4)
    False
)

;; 2e. Invalid – both counts wrong
!(test
    (validateMotivationState (motivation (0.3 0.2 0.1 0.3) (0.4 0.6 0.7 0.8 0.9)) 2 2)
    False
)

;; 2f. Valid – larger state (6 goals, 3 modulators)
!(test
    (validateMotivationState (motivation (0.1 0.2 0.3 0.4 0.5 0.6) (0.7 0.8 0.9)) 6 3)
    True
)

;; ---------------------------------------------------------
;; 3. motivationStateDiff Tests
;; ---------------------------------------------------------

;; 3a. Identical states – diff should be 0.0
!(test
    (motivationStateDiff
        (motivation (0.3 0.2 0.1 0.3) (0.4 0.6 0.7 0.8 0.9))
        (motivation (0.3 0.2 0.1 0.3) (0.4 0.6 0.7 0.8 0.9))
    )
0.0
)

;; 3b. Known difference – goals differ, modulators differ
;;     Goal diff: (0, 0, 0, -0.3) -> norm = 0.09 -> 0.09
;;     Mod diff:  (0, 0, 0, 0, 0.5) -> norm = 0.25 -> 0.25
;;     Total = 0.34
!(test
    (motivationStateDiff
        (motivation (0.3 0.2 0.1 0.3) (0.4 0.6 0.7 0.8 0.9))
        (motivation (0.3 0.2 0.1 0.6) (0.4 0.6 0.7 0.8 0.4))
    )
0.34
)

;; 3c. Only goals differ
;;     Goal diff: (0.1, -0.1, 0, 0) -> norm = 0.01 + 0.01 = 0.02
;;     Mod diff:  all zeros -> 0.0
;;     Total = 0.02
!(test
    (motivationStateDiff
        (motivation (0.3 0.2 0.1 0.3) (0.4 0.6 0.7))
        (motivation (0.2 0.3 0.1 0.3) (0.4 0.6 0.7))
    )
0.02
)

;; 3d. Only modulators differ
;;     Goal diff: all zeros -> 0.0
;;     Mod diff:  (0.5, 0, 0) -> norm = 0.25
;;     Total = 0.25
!(test
    (motivationStateDiff
        (motivation (0.1 0.2) (1.0 0.5 0.5))
        (motivation (0.1 0.2) (0.5 0.5 0.5))
    )
0.25
)

;; 3e. Single-element states
;;     Goal diff: (0.5) -> norm = 0.25
;;     Mod diff:  (0.3) -> norm = 0.09
;;     Total = 0.34
!(test
    (motivationStateDiff
        (motivation (1.0) (0.8))
        (motivation (0.5) (0.5))
    )
0.34
)
