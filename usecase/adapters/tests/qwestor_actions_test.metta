!(import! &self ../../utils)  
!(import! &self ../qwestor_actions)

;Test getQwestorActionValue returns correct action atom for each action

!(test (getQwestorActionValue act_respond)
  (action act_respond
    (0.25 0.10 0.90 0.10 0.05 0.20 0.40 0.85)
    0.30
    (0.00 0.00 0.05 -0.02 -0.02 0.00 0.02 0.05))
)

!(test (getQwestorActionValue act_search)
  (action act_search
    (0.10 0.60 0.50 0.85 0.75 0.45 0.45 0.25)
    0.10
    (0.00 0.03 0.01 0.06 0.05 0.02 0.01 0.00))
)

!(test (getQwestorActionValue act_verify)
  (action act_verify
    (0.75 0.10 0.40 0.10 -0.10 0.35 0.90 0.45)
    0.05
    (0.04 0.00 0.01 0.00 -0.01 0.02 0.06 0.01))
)

!(test (getQwestorActionValue act_clarify)
  (action act_clarify
    (0.35 0.05 0.70 0.05 -0.05 0.15 0.45 0.90)
    0.06
    (0.01 0.00 0.04 0.00 -0.01 0.01 0.02 0.05))
)

!(test (getQwestorActionValue act_decompose)
  (action act_decompose
    (0.20 0.80 0.55 0.65 0.55 0.70 0.35 0.30)
    0.15
    (0.00 0.06 0.02 0.04 0.03 0.05 0.01 0.01))
)

!(test (getQwestorActionValue act_think)
  (action act_think
    (0.25 0.85 0.30 0.70 0.80 0.80 0.30 0.20)
    0.20
    (0.01 0.07 0.00 0.04 0.05 0.06 0.01 0.00))
)

!(test (getQwestorActionValue act_synthesize)
  (action act_synthesize
    (0.20 0.72 0.50 0.62 0.60 0.62 0.45 0.45)
    0.17
    (0.00 0.05 0.02 0.03 0.03 0.04 0.02 0.02))
)