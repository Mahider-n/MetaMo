
; Bridges Qwestor's space and MetaMo's (motivation goals modulators) state type.
;
; PROJECTION (Qwestor → MetaMo)

; MetaMo's OpenPSI motivation state has:
;   8 goals:      gInd gTrans gHelp gCurio gNovel gSelf gEthic gSoc
;   6 modulators: valence arousal approach resolution threshold securing
;
; These are derived from Qwestor's running modulators and goal weights;

; Goal mapping (Qwestor → OpenPSI):
;   gInd   ← over_safety  (self-preservation / ethical constraint)
;   gTrans ← (novelty + success_breakthrough) / 2  (growth)
;   gHelp  ← (help_short + help_long) / 2           (helpfulness)
;   gCurio ← knowledge                              (curiosity)
;   gNovel ← novelty                                (novelty)
;   gSelf  ← success_moderate                       (competence)
;   gEthic ← over_honesty                           (honesty / ethics)
;   gSoc   ← social                                 (social alignment)
;
; Modulator mapping (Qwestor → OpenPSI):
;   valence    ← m_valence   (direct, same semantics)
;   arousal    ← m_arousal   (direct)
;   approach   ← m_approach  (direct)
;   resolution ← m_resolution (direct)
;   threshold  ← m_threshold  (direct)
;   securing   ← m_securing   (direct)
;
; INJECTION (MetaMo → Qwestor space)



; projectToMotivation: reads the current Qwestor space and returns a MetaMo motivation state.
; Example:
;   (projectToMotivation &space)
;   → (motivation (0.65 0.44 0.55 0.52 0.46 0.62 0.65 0.58)
;                 (0.00 0.40 0.40 0.40 0.30 0.10))

(= (projectToMotivation $space)
  (let*
    (
      ; read goal weights from Qwestor space  
      ($over_safety        (getGoalQwestor $space over_safety))
      ($novelty_g          (getGoalQwestor $space novelty))
      ($breakthrough_g     (getGoalQwestor $space success_breakthrough))
      ($help_short_g       (getGoalQwestor $space help_short))
      ($help_long_g        (getGoalQwestor $space help_long))
      ($knowledge_g        (getGoalQwestor $space knowledge))
      ($success_moderate_g (getGoalQwestor $space success_moderate))
      ($over_honesty_g     (getGoalQwestor $space over_honesty))
      ($social_g           (getGoalQwestor $space social))

      ; read modulators from Qwestor space  
      ($m_val  (getMod $space m_valence))
      ($m_ar   (getMod $space m_arousal))
      ($m_app  (getMod $space m_approach))
      ($m_res  (getMod $space m_resolution))
      ($m_thr  (getMod $space m_threshold))
      ($m_sec  (getMod $space m_securing))

      ; build OpenPSI goal vector  
      ($gInd   (eval (clampToUnitInterval $over_safety)))
      ($gTrans (eval (clampToUnitInterval (/ (+ $novelty_g $breakthrough_g) 2.0))))
      ($gHelp  (eval (clampToUnitInterval (/ (+ $help_short_g $help_long_g) 2.0))))
      ($gCurio (eval (clampToUnitInterval $knowledge_g)))
      ($gNovel (eval (clampToUnitInterval $novelty_g)))
      ($gSelf  (eval (clampToUnitInterval $success_moderate_g)))
      ($gEthic (eval (clampToUnitInterval $over_honesty_g)))
      ($gSoc   (eval (clampToUnitInterval $social_g)))

      ; build OpenPSI modulator vector  
      ; valence: map Qwestor's [-1,1] to OpenPSI's [0,1]
      ($val_openpsi (eval (clampToUnitInterval (* (+ $m_val 1.0) 0.5))))
    )
    (motivation
      ($gInd $gTrans $gHelp $gCurio $gNovel $gSelf $gEthic $gSoc)
      ($val_openpsi $m_ar $m_app $m_res $m_thr $m_sec)
    )
  )
)

; motivationSummary  
; Returns a human-readable pair-list of the MetaMo motivation state for logging

(= (motivationSummary (motivation $goals $mods))
  (let*
    (
      ($gInd   (index-atom $goals 0))
      ($gTrans (index-atom $goals 1))
      ($gHelp  (index-atom $goals 2))
      ($gCurio (index-atom $goals 3))
      ($gNovel (index-atom $goals 4))
      ($gSelf  (index-atom $goals 5))
      ($gEthic (index-atom $goals 6))
      ($gSoc   (index-atom $goals 7))
      ($val    (index-atom $mods 0))
      ($ar     (index-atom $mods 1))
      ($app    (index-atom $mods 2))
      ($res    (index-atom $mods 3))
      ($thr    (index-atom $mods 4))
      ($sec    (index-atom $mods 5))
    )

    (
      (gInd $gInd) (gTrans $gTrans) (gHelp $gHelp) (gCurio $gCurio)
      (gNovel $gNovel) (gSelf $gSelf) (gEthic $gEthic) (gSoc $gSoc)
      (valence $val) (arousal $ar) (approach $app) (resolution $res)
      (threshold $thr) (securing $sec)
    )
    
  )
)
