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
; What each action represents:- 
;   - act_respond: raised gHelp and gSoc; these should now win when
;     familiarity is high (gCurio/gNovel suppressed by bridge)
;   - act_search:  gCurio and gNovel remain high but will be modulator-
;     suppressed at projection time, so score drops when familiar
;   - act_verify:  raised gEthic and gInd significantly; wins when
;     m_failure_wariness is high (gEthic boosted in bridge)
;   - act_clarify: raised gSoc; wins when user is novice (gSoc boosted)
;   - act_decompose/think/synthesize: moderate across growth goals

(QwestorAction act_respond
  (action act_respond
    (0.25  0.10  0.90  0.10  0.05  0.20  0.40  0.85)
    0.30
    (0.00  0.00  0.05 -0.02 -0.02  0.00  0.02  0.05)
  )
)

(QwestorAction act_search
  (action act_search
    (0.10  0.60  0.50  0.85  0.75  0.45  0.45  0.25)
    0.10
    (0.00  0.03  0.01  0.06  0.05  0.02  0.01  0.00)
  )
)

(QwestorAction act_verify
  (action act_verify
    (0.75  0.10  0.40  0.10 -0.10  0.35  0.90  0.45)
    0.05
    (0.04  0.00  0.01  0.00 -0.01  0.02  0.06  0.01)
  )
)

(QwestorAction act_clarify
  (action act_clarify
    (0.35  0.05  0.70  0.05 -0.05  0.15  0.45  0.90)
    0.06
    (0.01  0.00  0.04  0.00 -0.01  0.01  0.02  0.05)
  )
)

(QwestorAction act_decompose
  (action act_decompose
    (0.20  0.80  0.55  0.65  0.55  0.70  0.35  0.30)
    0.15
    (0.00  0.06  0.02  0.04  0.03  0.05  0.01  0.01)
  )
)

(QwestorAction act_think
  (action act_think
    (0.25  0.85  0.30  0.70  0.80  0.80  0.30  0.20)
    0.20
    (0.01  0.07  0.00  0.04  0.05  0.06  0.01  0.00)
  )
)

(QwestorAction act_synthesize
  (action act_synthesize
    (0.20  0.72  0.50  0.62  0.60  0.62  0.45  0.45)
    0.17
    (0.00  0.05  0.02  0.03  0.03  0.04  0.02  0.02)
  )
)

; convenience accessor  
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