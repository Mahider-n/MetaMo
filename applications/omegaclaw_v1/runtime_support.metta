;; Provider-independent string construction for live prompts and persistence.
;; Importing lib_llm solely for py-str would eagerly require an OpenAI key.
(= (py-str-helper $items $outp)
   (if (== $items ()) $outp
       (let* (($head (car-atom $items))
              ($tail (cdr-atom $items))
              ($next (string_concat $outp (py-call (str $head)))))
          (py-str-helper $tail $next))))
(= (py-str $items) (py-str-helper $items ""))
