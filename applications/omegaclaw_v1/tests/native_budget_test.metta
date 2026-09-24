;; Production order: ContextFrames compiles before the loop's config getters.
;; Serialize before comparison so the test cannot repair stored expressions by
;; evaluating them as part of equality. No provider or memory service is started.
!(import! &self (library OmegaClaw-Core src/utils))
!(import! &self (library OmegaClaw-Core src/helper.py))
!(import! &self (library OmegaClaw-Core src/context))
!(import! &self (library OmegaClaw-Core src/loop))
!(initLoop)
!(test (repr (cfv2-default-budget))
   "(ResourceBudget (max-output-tokens 6000) (max-command-lines 5) (wake-interval 600) (status Open))")
!(initContextFrame)
!(test (repr (get-state &cfv2-global-budget))
   "(ResourceBudget (max-output-tokens 6000) (max-command-lines 5) (wake-interval 600) (status Open))")
!(test (repr (get-state &cfv2-current-budget))
   "(ResourceBudget (max-output-tokens 6000) (max-command-lines 5) (wake-interval 600) (status Open))")
