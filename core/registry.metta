;; MetaMo Registry

;; Reads module declarations from config and wires them
;; into a MetaMoPseudoBimonad.  

;;   Internal readers    

;; Read the appraisal constructor symbol from config.
(= (metaMoAppraisalModuleSymbol)
    (match &self (MetaMoAppraisalModule $sym) $sym)
)

;; Read the decision constructor symbol from config
(= (metaMoDecisionModuleSymbol)
    (match &self (MetaMoDecisionModule $sym) $sym)
)

;; Read each dynamics / safety function symbol from config
(= (metaMoDampingSymbol)
    (match &self (MetaMoDampingFn $sym) $sym)
)
(= (metaMoBoundarySymbol)
    (match &self (MetaMoBoundaryFn $sym) $sym)
)
(= (metaMoProjectSymbol)
    (match &self (MetaMoProjectFn $sym) $sym)
)
(= (metaMoContractiveSymbol)
    (match &self (MetaMoContractiveFn $sym) $sym)
)
(= (metaMoSafeRegionSymbol)
    (match &self (MetaMoSafeRegionFn $sym) $sym)
)

;;   Assembly  

;; buildMetaMo
;;
;; Constructs a MetaMoPseudoBimonad by calling the zero-argument
;; constructor functions named in config
;;
;; To override individual slots at call-site can
;; call metaMoPseudoBimonad directly; this function is the
;; config-driven convenience path.
;;
;; Example: (buildMetaMo)
(= (buildMetaMo)
    (metaMoPseudoBimonad
        (eval ((metaMoAppraisalModuleSymbol)))   ;; AppraisalComonad
        (eval ((metaMoDecisionModuleSymbol)))     ;; DecisionMonad
        (metaMoDampingSymbol)                    ;; damping fn symbol
        (metaMoBoundarySymbol)                   ;; boundary fn symbol
        (metaMoProjectSymbol)                    ;; projection fn symbol
        (metaMoContractiveSymbol)                ;; contractivity fn symbol
        (metaMoSafeRegionSymbol)                 ;; safe-region fn symbol
    )
)

;; defaultMetaMo
;;
;; Cached-style accessor: builds a bimonad from the current config.
;; Call this instead of (buildMetaMo) when a single shared
;; instance per run is wanted.   .
;;
;; Example: (step (defaultMetaMo) currState stimulus candidates)
(= (defaultMetaMo)
    (buildMetaMo)
)