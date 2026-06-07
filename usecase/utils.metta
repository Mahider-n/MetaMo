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
        ($mod-vec   (match $space (state $turn  $x $y $z $alpha) $y))
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