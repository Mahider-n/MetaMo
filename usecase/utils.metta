; Map a modulator name to the element at its canonical index.
(= (matchValue $modulator-name $mod-list)
    (case $modulator-name
          (
            (m_urgency           (index-atom $mod-list 0))
            (m_resolution        (index-atom $mod-list 1))
            (m_user_expertise    (index-atom $mod-list 2))
            (m_threshold         (index-atom $mod-list 3))
            (m_topic_familiarity (index-atom $mod-list 4))
            (m_failure_wariness  (index-atom $mod-list 5))
            (m_securing          (index-atom $mod-list 6))
            (m_approach          (index-atom $mod-list 7))
            (m_arousal           (index-atom $mod-list 8))
            (m_risk_aversion     (index-atom $mod-list 9))
            (m_error_tolerance   (index-atom $mod-list 10))
            (m_creativity        (index-atom $mod-list 11))
            (m_valence           (index-atom $mod-list 12))
            ($_ "value not found")
          )
      )
)

(= (getMod $space $modulator-name)
    (let*
      (
        ($mod-vec   (match $space ($goals $modulators $anti-goals) $modulators))
        ($mod-list  (cdr-atom $mod-vec))
        ($pair      (matchValue $modulator-name $mod-list))
      )
      (index-atom $pair 1)
    )
)
; Clamp a value to [0, 1] 
; this corresponds to the python clamp_to_unit_interval function 
(= (_clamp01 $x)
  (if (and (< $x 1) (> $x 0))
     $x
     (if (>= $x 1)
      1
      0
      )
   )
)

(= (find_by_key $key $dic_list)
(if (== $dic_list ())
     ()
        (let* (
                (($pair $next) (decons $dic_list))
                ($k (car-atom $pair))
                ($v (cdr-atom $pair))
            )
            (if (== $k $key)
                (superpose $v)
                (find_by_key $key $next)
            )
        )

)
)
 
(= (get-goal $space $goal-name)
 (let*
  (
    ($goal-vec  (match $space ($goals $modulators $anti-goals) $goals))
    ($goal-list (cdr-atom $goal-vec))
    ($pair
      (case $goal-name
        (
          (efficiency           (index-atom $goal-list 0))
          (accuracy             (index-atom $goal-list 1))
          (success_moderate     (index-atom $goal-list 2))
          (knowledge            (index-atom $goal-list 3))
          (novelty              (index-atom $goal-list 4))
          (success_breakthrough (index-atom $goal-list 5))
          (coherence            (index-atom $goal-list 6))
          (originality          (index-atom $goal-list 7))
          (social               (index-atom $goal-list 8))
          (help_short           (index-atom $goal-list 9))
          (help_long            (index-atom $goal-list 10))
          (over_beneficial      (index-atom $goal-list 11))
          (over_safety          (index-atom $goal-list 12))
          (over_honesty         (index-atom $goal-list 13))
        )
      )
    )
  )
  (index-atom $pair 1)
 )
)
(= (getGoal $space $goal-name)
   (get-goal $space $goal-name)
)

(= (remove-state-app $space)
 (let $state (getState $space) (remove-atom $space $state))
)
; we don't need this this should be done by the appraisal 

; (= (update-mods $space $mods)
;       (let* (
;          ($goal     (getGoals $space))
;          ($t   (match $space (state $turn  $x $y $z $alpha) $turn))
;          ($alpha    (match $space (state $turn  $x $y $z $alpha) $alpha))
;          ($anti  (match $space (state $turn  $x $y $z $alpha) $z))
;          ($_ (remove-state-app $space))
;          ($updated  (state  $t $goal (cons modulator-vector $mods) $anti $alpha))
;          ($_ (addState $space $updated))          
;          )
;          (println! (mods update success 🎉))
;    )
; )
(= (addItems $baseCase $space $items)
   (if (== $items ())
        $baseCase
        (let* (
               ($h (car-atom $items))
               ($t (cdr-atom $items))
               ($_ (add-atom $space $h))
               )
          (addItems $baseCase $space $t)
          )
     )
)

(= (getGoals $space) (match $space ($goals $modulators $anti-goals) $goals))
(= (addState $space $state)
    (add-atom $space $state)
)
(= (addAlpha $space $list)    (addItems () $space $list))
