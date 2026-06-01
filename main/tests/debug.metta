(transitionAction 
    (consensusTransition 
        (metaMoPseudoBimonad (appraisalComonad integrationIdentityExtract integrationRichAppraise) 
        (decisionMonad integrationIdentityExtract integrationConstantDecide integrationSimpleScore) 
        integrationIdentityDamping 
        integrationIdentityBoundary 
        integrationIdentityProject 
        integrationAlwaysContractive 
        integrationAlwaysSafe) 
        (motivation (0.25 0.75 0.5 0.5 0.5 0.5 0.5 0.5) (0.125 0.25 0.375 0.5 0.625 0.75)) 
        (motivation (0.25 0.75 0.5 0.5 0.5 0.5 0.5 0.5) (0.125 0.25 0.375 0.5 0.625 0.75)) 
        (stimulus (0.125 0.125 0.0 0.0)) 
        ((action act1 (0.25 0.25 0.0 0.0 0.0 0.0 0.0 0.0) 0.25 (0.125 0.125 0.0 0.0 0.0 0.0 0.0 0.0)) 
        (action act2 (0.5 0.75 0.0 0.0 0.0 0.0 0.0 0.0) 0.25 (-0.125 0.125 0.0 0.0 0.0 0.0 0.0 0.0))) 
        0.05
    )
)