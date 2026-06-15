!(import! &self ../../utils)  
!(import! &self ../qwestor_actions)


; Test getQwestorActionValue returns correct action atom for each action
!(test (getQwestorActionValue act_respond)
  (action act_respond (0.30 0.10 0.85 0.10 0.05 0.15 0.45 0.75) 0.35 (0.00 0.00 0.04 -0.02 -0.02 0.00 0.02 0.04))
)

!(test (getQwestorActionValue act_search)
  (action act_search (0.10 0.65 0.60 0.80 0.70 0.50 0.55 0.30) 0.10 (0.00 0.04 0.02 0.05 0.04 0.03 0.02 0.01))
)

!(test (getQwestorActionValue act_verify)
  (action act_verify (0.65 0.10 0.45 0.10 -0.10 0.40 0.85 0.50) 0.05 (0.03 0.00 0.01 0.00 -0.01 0.02 0.05 0.01))
)

!(test (getQwestorActionValue act_clarify)
  (action act_clarify (0.40 0.05 0.65 0.05 -0.05 0.20 0.50 0.80) 0.08 (0.01 0.00 0.03 0.00 -0.01 0.01 0.02 0.04))
)

!(test (getQwestorActionValue act_decompose)
  (action act_decompose (0.20 0.75 0.55 0.70 0.60 0.65 0.40 0.35) 0.15 (0.00 0.05 0.02 0.04 0.03 0.04 0.01 0.01))
)

!(test (getQwestorActionValue act_think)
  (action act_think (0.25 0.80 0.35 0.75 0.80 0.75 0.35 0.25) 0.20 (0.01 0.06 0.00 0.05 0.05 0.05 0.01 0.00))
)

!(test (getQwestorActionValue act_synthesize)
  (action act_synthesize (0.20 0.70 0.50 0.65 0.65 0.60 0.45 0.45) 0.18 (0.00 0.04 0.02 0.03 0.03 0.03 0.02 0.02))
)