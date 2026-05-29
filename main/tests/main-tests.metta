!(import! &self ../..core/helper)
!(import! &self ../main)
!(import! &self "../../core/helpers.py")
!(import! &self ../../core/state)
!(import! &self ../../core/state_accessors)
!(import! &self ../../core/config)
!(import! &self ../../openpsi/config)
!(import! &self ../../openpsi/appraisal_helpers)
!(import! &self ../../openpsi/appraisal)
!(import! &self ../../category/functors)
!(import! &self ../../category/bimonad)
!(import! &self ../../magus/decision)
!(import! &self ../../dynamics/stability)
!(import! &self ../../dynamics/coherence)


!(test
    (cycleFinalAction (eval (integrationCycleNoBlend)))
    (action act2
        (0.5 0.75 0.0 0.0 0.0 0.0 0.0 0.0)
        0.25
        (-0.125 0.125 0.0 0.0 0.0 0.0 0.0 0.0))
)

!(test
    (cycleMergedCurrent (eval (integrationCycleNoBlend)))
    (eval (integrationState))
)

!(test
    (cycleMergedTarget (eval (integrationCycleNoBlend)))
    (eval (integrationExpectedConsensusTarget))
)

!(test
    (cycleNextStates (eval (integrationCycleNoBlend)))
    (
        (subsystemState curiosity (eval (integrationExpectedLocalTarget)))
        (subsystemState ethics (eval (integrationExpectedLocalTarget)))
    )
)

!(test
    (cycleLocalActions (eval (integrationCycleNoBlend)))
    (
        (namedAction curiosity
            (action act1
                (0.25 0.25 0.0 0.0 0.0 0.0 0.0 0.0)
                0.25
                (0.125 0.125 0.0 0.0 0.0 0.0 0.0 0.0)))
        (namedAction ethics
            (action act1
                (0.25 0.25 0.0 0.0 0.0 0.0 0.0 0.0)
                0.25
                (0.125 0.125 0.0 0.0 0.0 0.0 0.0 0.0)))
    )
)

!(test
    (cycleLocalTargets (eval (integrationCycleNoBlend)))
    (
        (namedMotivation curiosity (eval (integrationExpectedLocalTarget)))
        (namedMotivation ethics (eval (integrationExpectedLocalTarget)))
    )
)

!(test
    (cyclePeerSimulations
        (runMetaMoCycle
            (eval (integrationBimonad))
            (eval (integrationStates))
            (eval (integrationStimulus))
            (eval (integrationCandidates))
            ()
            (integrationIdentityTranslator)
            False
            0.05))
    (
        (namedMotivation curiosity (eval (integrationState))) 
        (namedMotivation ethics (eval (integrationState)))
    )
)

!(test
    (cycleFinalAction
        (runMetaMoCycleDefault
            (eval (integrationBimonad))
            (eval (integrationStates))
            (eval (integrationStimulus))
            (eval (integrationCandidates))
            ()
            ()))
    (action act2
        (0.5 0.75 0.0 0.0 0.0 0.0 0.0 0.0)
        0.25
        (-0.125 0.125 0.0 0.0 0.0 0.0 0.0 0.0))
)

!(test
    (cycleFinalAction
        (runMetaMoCycle
            (integrationBimonad)
            ((subsystemState curiosity (eval (integrationState))))
            (integrationStimulus)
            (integrationCandidates)
            ()
            ()
            False
            0.05))
    (action act1
        (0.25 0.25 0.0 0.0 0.0 0.0 0.0 0.0)
        0.25
        (0.125 0.125 0.0 0.0 0.0 0.0 0.0 0.0))
)

!(test
    (validateActionShape
        (cycleFinalAction
            (runMetaMoCycle
                (eval (defaultMetaMoBimonad))
                (eval (integrationStates))
                (eval (integrationStimulus)) 
                (eval (integrationCandidates)) 
                ()
                ()
                False
                0.05)))
    True
)

!(test
    (validateMotivationalStateShape
        (cycleMergedTarget
            (runMetaMoCycle
                (eval (defaultMetaMoBimonad))
                (eval (integrationStates))
                (eval (integrationStimulus))
                (eval (integrationCandidates)) 
                ()
                ()
                False
                0.05)))
    True
)

