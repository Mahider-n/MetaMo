; Translates Qwestor's 14-signal context list  into MetaMo's OpenPSI stimulus format:
;
;   (stimulus novelty conduciveness risk effort)
;
; Mapping rationale:
;
;   novelty       ← How unexpected, unfamiliar, or complex is a specific query
;                   high when topic_familiarity is low and complexity is high.
;                   Also boosted by reflective_intent and needs_external_evidence.
;                   
;
;   conduciveness ← how likely the current context leads to a good outcome.
;                   High when topic_familiarity is high, ambiguity is low,
;                   and valence is positive. Penalised by failure_signal.
;
;   risk          ← how likely the action causes harm or error.
;                   Driven by threshold and failure_signal. Boosted when
;                   verify_request=1 or ambiguity is high.
;
;   effort        ← cognitive cost of the current request.
;                   driven by complexity and needs_multi_source_integration.
;                   Boosted by needs_task_plan and ambiguity.
;


; ── contextToStimulus ────────────────────────────────────────────────────────
; Takes the context result list (as returned by context_parser) and
; returns a MetaMo stimulus atom.
;
; $context-list – the flat pair-list from context parser , e.g.
;   ((urgency 0.2) (complexity 0.6) (ambiguity 0.1) …)
;
; Returns: (stimulus novelty conduciveness risk effort)


(= (contextToStimulus $context-list)
  (let*
    (
      ; extract signals  
      ($complexity   (find_by_key complexity               $context-list))
      ($ambiguity  (find_by_key ambiguity                $context-list))
      ($threshold  (find_by_key threshold                $context-list))
      ($familiarity_signal  (find_by_key topic_familiarity       $context-list))
      ($failure_signal   (find_by_key failure_signal           $context-list))
      ($reflective_intent   (find_by_key reflective_intent        $context-list))
      ($valence  (find_by_key valence                  $context-list))
      ($needs_external_evidence  (find_by_key needs_external_evidence  $context-list))
      ($task (find_by_key needs_task_plan          $context-list))
      ($ms   (find_by_key needs_multi_source_integration $context-list))
      ($verify_request   (find_by_key verify_request           $context-list))
      ($urgency  (find_by_key urgent                  $context-list))

      ; Novelty  
      ; High novelty = unfamiliar + complex + reflective + externally-driven
      ($novelty
        (eval (_clamp01
          (+  (* 0.40 (- 1.0 $familiarity_signal))
            (+ (* 0.25 $complexity)
              (+ (* 0.20 $reflective_intent)
                 (* 0.15 $needs_external_evidence))))
        )))

      ; Conduciveness  
      ; High conduciveness = familiar territory, low ambiguity, positive mood
      ($val_norm (eval (_clamp01 (* (+ $valence 1.0) 0.5))))
      ($conduciveness
        (eval (_clamp01
          (+  (* 0.40 $familiarity_signal)
            (+ (* 0.30 (- 1.0 $ambiguity))
              (+ (* 0.20 $val_norm)
                 (* -0.20 $failure_signal))))
        )))

      ; Risk  
      ; Risk = safety threshold + failure history + ambiguity
      ; verify_request hard-boosts risk (user suspects something is wrong)
      ($vr_boost (if (== $verify_request 1.0) 0.15 0.0))
      ($risk
        (eval (_clamp01
          (+ (* 0.40 $threshold)
            (+ (* 0.30 $failure_signal)
              (+ (* 0.20 $ambiguity)
                 (+ (* 0.10 (- 1.0 $familiarity_signal))
                    $vr_boost))))
        )))

      ; Effort  
      ; Effort = complexity + multi-source + planning + ambiguity
      ($effort
        (eval (_clamp01
          (+ (* 0.40 $complexity)
            (+ (* 0.25 $ms)
              (+ (* 0.20 $task)
                 (* 0.15 $ambiguity))))
        )))
    )
    
    (stimulus ((novelty $novelty) (conduciveness $conduciveness) (risk $risk) (effort $effort)))
  )
)

(= (projectStimulus $context-list)
  (let (stimulus $vals) (contextToStimulus $context-list) $vals)
)
 
 