
; Session persistence helpers for Qwestor's space.

; updateState: replaces the current (goals modulators anti-goals) triple
; in the space with a new one.
; Example: (updateState &space newGoals newMods newAntiGoals)

(= (updateState $space $newGoals $newMods $newAntiGoals)
    (let*
        (
            ($oldState (match $space ($g $m $a) ($g $m $a)))
            ($_ (remove-atom $space $oldState)) 
            ($_(add-atom $space ($newGoals $newMods $newAntiGoals)))
        )
        "Space updated sucessfully"
    )
)

; injectMotivation: writes a MetaMo motivation state back into Qwestor's
; space. Reverse of projectToMotivation.
; Example: (injectMotivation &space nextMotivState)

(= (injectMotivation $space (motivation $g $m))
  (let*
    (
      ; unpack the OpenPSI goal vector  
      ($gInd   (index-atom $g 0))
      ($gTrans (index-atom $g 1))
      ($gHelp  (index-atom $g 2))
      ($gCurio (index-atom $g 3))
      ($gNovel (index-atom $g 4))
      ($gSelf  (index-atom $g 5))
      ($gEthic (index-atom $g 6))
      ($gSoc   (index-atom $g 7))

      ; unpack the OpenPSI modulator vector  
      ($val_openpsi (index-atom $m 0))
      ($m_ar   (index-atom $m 1))
      ($m_app  (index-atom $m 2))
      ($m_res  (index-atom $m 3))
      ($m_thr  (index-atom $m 4))
      ($m_sec  (index-atom $m 5))

      ; goals OpenPSI doesn't carry, kept from the space  
      ($efficiency           (getGoalQwestor $space efficiency))
      ($accuracy             (getGoalQwestor $space accuracy))
      ($coherence             (getGoalQwestor $space coherence))
      ($originality           (getGoalQwestor $space originality))
      ($over_beneficial       (getGoalQwestor $space over_beneficial))

      ; modulators OpenPSI doesn't carry, kept from the space  
      ($m_urgency           (getMod $space m_urgency))
      ($m_user_expertise    (getMod $space m_user_expertise))
      ($m_topic_familiarity (getMod $space m_topic_familiarity))
      ($m_failure_wariness  (getMod $space m_failure_wariness))
      ($m_risk_aversion     (getMod $space m_risk_aversion))
      ($m_error_tolerance   (getMod $space m_error_tolerance))
      ($m_creativity        (getMod $space m_creativity))

      ($anti_goals (match $space ($gg $mm $aa) $aa))

      ; valence: map OpenPSI's [0,1] back to Qwestor's [-1,1]
      ($m_val (eval (- (* $val_openpsi 2.0) 1.0)))

      ; rebuild Qwestor's goal vector  
      ($newGoals (goal-vector
        (efficiency           $efficiency)
        (accuracy             $accuracy)
        (success_moderate     $gSelf)
        (knowledge            $gCurio)
        (novelty              $gNovel)
        (success_breakthrough $gTrans)
        (coherence            $coherence)
        (originality          $originality)
        (social               $gSoc)
        (help_short           $gHelp)
        (help_long            $gHelp)
        (over_beneficial      $over_beneficial)
        (over_safety          $gInd)
        (over_honesty         $gEthic)
      ))

      ; rebuild Qwestor's modulator vector  
      ($newMods (modulator-vector
        (m_urgency           $m_urgency)
        (m_resolution        $m_res)
        (m_user_expertise    $m_user_expertise)
        (m_threshold         $m_thr)
        (m_topic_familiarity $m_topic_familiarity)
        (m_failure_wariness  $m_failure_wariness)
        (m_securing          $m_sec)
        (m_approach          $m_app)
        (m_arousal           $m_ar)
        (m_risk_aversion     $m_risk_aversion)
        (m_error_tolerance   $m_error_tolerance)
        (m_creativity        $m_creativity)
        (m_valence           $m_val)
      ))
    )
    (updateState $space $newGoals $newMods $anti_goals)
  )
)

; sessionRetrival
;
; Retrieves the previously stored user queries for a specific
; session from the session memory backend.

(= (sessionRetrival (sessionId))
   (let* (
      ($rw_res (py-call (session_short.get_session_queries (sessionId))))
      ($final_res (parse $rw_res))
   )
   $final_res)
)
; sessionQueries
;
; Convenience wrapper around sessionRetrival.
; Automatically retrieves the query history for the
; currently active session using the sessionId atom.

(= (sessionQueries) (sessionRetrival (sessionId)))
 