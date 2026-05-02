

;; Creates an OpenPSI appraisal comonad using a custom appraisal function.
;; Example: (openPsiAppraisalWith customAppraiseFn)
(= (openPsiAppraisalWith $appraiseFn)
    (appraisalComonad openPsiExtract $appraiseFn)
)

;; Creates a default OpenPSI appraisal comonad using the standard openPsiAppraise function.
;; Example: (openPsiAppraisal)
(= (openPsiAppraisal)
    (openPsiAppraisalWith openPsiAppraise)
)

;; Extracts the current motivation state from the comonad.
;; Example: (openPsiExtract (motivation (goals) (modulators)))
(= (openPsiExtract $state)
    $state
)

;; Performs the core OpenPSI appraisal by updating the motivation state based on a stimulus.
;; This function calculates new modulator values (valence, arousal, etc.) using the stimulus properties.
;; Example:
;;   (openPsiAppraise
;;     (motivation (0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5) (0.5 0.5 0.5 0.5 0.5 0.5))
;;     (stimulus 0.2 0.8 0.1 0.2)
;;   )
(= (openPsiAppraise
        (motivation
            ($gInd $gTrans $gHelp $gCurio $gNovel $gSelf $gEthic $gSoc)
            ($valence $arousal $approach $resolution $threshold $securing)
        )
        (stimulus $novelty $conduciveness $risk $effort)
    )
    (let* (
        ($arousalFeedback (eval (openPsiArousalFeedback $arousal)))
        ($transScale (eval (openPsiTransScale $gTrans)))
        ($indScale (eval (openPsiIndScale $gInd)))
        ($benignNovelty (eval (openPsiBenignNovelty $novelty $risk)))
        ($demandingContext (eval (openPsiDemandingContext $effort $risk)))

        ($deltaValence (eval (openPsiDeltaValence $conduciveness $benignNovelty $risk $effort)))
        ($deltaArousal (eval (openPsiDeltaArousal $novelty $arousalFeedback $risk $effort)))
        ($deltaApproach (eval (openPsiDeltaApproach $benignNovelty $conduciveness $risk)))
        ($deltaResolution (eval (openPsiDeltaResolution $conduciveness $effort $risk)))
        ($deltaThreshold (eval (openPsiDeltaThreshold $risk $demandingContext $conduciveness)))
        ($deltaSecuring (eval (openPsiDeltaSecuring $risk $effort $benignNovelty $conduciveness)))

        ($nextValence (eval (openPsiNextValence $valence $deltaValence)))
        ($nextArousal (eval (openPsiNextArousal $arousal $deltaArousal $transScale)))
        ($nextApproach (eval (openPsiNextApproach $approach $deltaApproach $transScale)))
        ($nextResolution (eval (openPsiNextResolution $resolution $deltaResolution)))
        ($nextThreshold (eval (openPsiNextThreshold $threshold $deltaThreshold $indScale)))
        ($nextSecuring (eval (openPsiNextSecuring $securing $deltaSecuring $indScale)))
    )
        (motivation
            ($gInd $gTrans $gHelp $gCurio $gNovel $gSelf $gEthic $gSoc)
            ($nextValence $nextArousal $nextApproach $nextResolution $nextThreshold $nextSecuring)
        )
    )
)
