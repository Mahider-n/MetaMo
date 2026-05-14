(= (calculateBlendFactor $state)
    (let* (
      ($gInd (getGoal $state gInd))
      ($gTrans (getGoal $state gTrans))
      ($alpha (+ (* (ALPHA_0) (- 1.0 $gInd)) (* (BETA_0) $gTrans)))
    )
     (npClip $alpha 0.0 1.0) 
    )
)


(= (checkSelfModelDrift $currentState $nextState $lipschitzConstant $maxAllowedDrift)
    (let* (
       ($distanceMoved (motivationStateDistance $currentState $nextState))
       ($approximatedDrift (* $lipschitzConstant $distanceMoved))
    )
      (<= $approximatedDrift $maxAllowedDrift)
    )
)

(= (nextStateCalculator $currState $alpha)
    (let* (
        ((motivation $goals $modulators) $currState)
        ($nAlpha (- 1 $alpha))
        ($nGoals (scaleArray $goals $nAlpha))
        ($alphaGoals (scaleArray $goals $alpha))
        ($nModulators (scaleArray $modulators $nAlpha))
        ($alphaModulators (scaleArray $modulators $alpha))
        ($newGoals (vectorAdd $nGoals $alphaGoals))
        ($newModulators (vectorAdd $nModulators $alphaModulators))
    )
        (motivation $newGoals $newModulators)
    )
)


(= (blendStatesHelper $currentState $nextState $targetState $alpha $minAlpha $lipschitzConstant $maxAllowedDrift)
    (let* (
                
        ($selfModelDrift (checkSelfModelDrift $currentState $targetState $lipschitzConstant $maxAllowedDrift))
        ($nextState' (nextStateCalculator $nextState $alpha))
    )
        (if (or $selfModelDrift (<= $alpha $minAlpha))
            $nextState
            (blendStatesHelper $currentState $nextState' $targetState $alpha $minAlpha $lipschitzConstant $maxAllowedDrift)
        )  
    )
    
)


(= (blendStates $currentState $targetState $lipschitzConstant $maxAllowedDrift $minAlphaScale)
    (let* (
        ($baseAlpha (calculateBlendFactor $currentState))
        ($alpha $baseAlpha)
        ($minAlpha (* $minAlphaScale $baseAlpha))
    )
        (blendStatesHelper $currentState $currentState $targetState $alpha $minAlpha $lipschitzConstant $maxAllowedDrift)
    )
)
