
; Changes Qwestor's 7 cognitive actions into MetaMo's action format:
;
;   (action $id $goalCorrelations $riskEstimate $deltaG)
;
; Goal vector index mapping:
;   0  gInd   – individuation 
;   1  gTrans – transcendence 
;   2  gHelp  – helpfulness
;   3  gCurio – curiosity
;   4  gNovel – novelty seeking
;   5  gSelf  – self-improvement
;   6  gEthic – ethical alignment
;   7  gSoc   – social alignment
;

;  act_respond  
; High on helpfulness and social, risks hallucination on complex topics
(QwestorAction act_respond
  (action act_respond
    (0.30  0.10  0.85  0.10  0.05  0.15  0.45  0.75)
    0.35
    (0.00  0.00  0.04 -0.02 -0.02  0.00  0.02  0.04)
  )
)

;  act_search  
; High on curiosity, novelty, and knowledge growth; low risk
(QwestorAction act_search
  (action act_search
    (0.10  0.65  0.60  0.80  0.70  0.50  0.55  0.30)
    0.10
    (0.00  0.04  0.02  0.05  0.04  0.03  0.02  0.01)
  )
)

; act_verify  
; High on ethics and individuation (self-checking), low novelty
(QwestorAction act_verify
  (action act_verify
    (0.65  0.10  0.45  0.10 -0.10  0.40  0.85  0.50)
    0.05
    (0.03  0.00  0.01  0.00 -0.01  0.02  0.05  0.01)
  )
)

; act_clarify  
; High on social and helpfulness,  moderate individuation
(QwestorAction act_clarify
  (action act_clarify
    (0.40  0.05  0.65  0.05 -0.05  0.20  0.50  0.80)
    0.08
    (0.01  0.00  0.03  0.00 -0.01  0.01  0.02  0.04)
  )
)

; act_decompose 
; High on transcendence and curiosity, moderate ethics
(QwestorAction act_decompose
  (action act_decompose
    (0.20  0.75  0.55  0.70  0.60  0.65  0.40  0.35)
    0.15
    (0.00  0.05  0.02  0.04  0.03  0.04  0.01  0.01)
  )
)

; act_think  
; High on transcendence, novelty, and self-improvement
(QwestorAction act_think
  (action act_think
    (0.25  0.80  0.35  0.75  0.80  0.75  0.35  0.25)
    0.20
    (0.01  0.06  0.00  0.05  0.05  0.05  0.01  0.00)
  )
)

; act_synthesize  
; Balanced across growth dimensions; moderate ethics and social
(QwestorAction act_synthesize
  (action act_synthesize
    (0.20  0.70  0.50  0.65  0.65  0.60  0.45  0.45)
    0.18
    (0.00  0.04  0.02  0.03  0.03  0.03  0.02  0.02)
  )
)

;  convenience accessor  
; Returns the MetaMo action atom for a given Qwestor action symbol
;
; Example:
;   (qwestorActionAtom act_search)
;   → (action act_search (0.10 0.65 ...) 0.10 (...))
(= (getQwestorActionValue $name)
  (match &self (QwestorAction $name $atom) $atom)
)

; full candidate list 
; Returns all 7 action atoms which will be used in magusDecide 
(= (qwestorCandidates)
  (
    (getQwestorActionValue act_respond)
    (getQwestorActionValue act_search)
    (getQwestorActionValue act_verify)
    (getQwestorActionValue act_clarify)
    (getQwestorActionValue act_decompose)
    (getQwestorActionValue act_think)
    (getQwestorActionValue act_synthesize)
  )
)
