;; Core framework constants — NOT tied to any specific cognitive system

(= (C_CONTRACT) 0.9)
(= (EPSILON) 0.05)
(= (ETA_BOUNDARY) 0.1)

(= (ALPHA_0) 0.1)
(= (BETA_0) 0.15)

(= (LAX_DISTRIBUTIVE_DELTA) 1e-3)

;; MetaMo Configuration
;;  
;; This is the only file downstream teams need to modify.
;; Change the module atoms to swap cognitive components.
;; Change the constants to tune behavior.
 
;; Module declarations  
;; Each atom names the zero-argument constructor function that
;; returns the relevant structure.  
;;
;; Appraisal comonad constructor (must return an AppraisalComonad)
(MetaMoAppraisalModule  openPsiAppraisal)

;; Decision monad constructor (must return a DecisionMonad)
(MetaMoDecisionModule   magusDecision)

;; Dynamics function symbols, each is called as (sym ...)
(MetaMoDampingFn        defaultDamping)
(MetaMoBoundaryFn       defaultBoundaryStabilize)
(MetaMoProjectFn        defaultProject)
(MetaMoContractiveFn    defaultContractiveCheck)
(MetaMoSafeRegionFn     defaultSafeRegionCheck)


;;  OpenPSI / MAGUS constants  
(= (LAMBDA_IND)   0.5)
(= (LAMBDA_TRANS) 0.5)
(= (THETA_SAFE)   0.3)
(= (G_MAX)        2.0)