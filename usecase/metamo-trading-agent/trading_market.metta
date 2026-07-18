;; The market world used by both the MetaMo agent and the baseline.
;;
;; This file only holds the environment: the price scenarios, the
;; portfolio and the trade rules. It knows nothing about MetaMo, so both
;; agents trade in exactly the same world and only their decision making
;; is different.
;;
;; There are four scenarios, and adding a new one only takes one new
;; (scenarioPrices <name>) equation:
;;   vshape    - calm start, steady rally, sharp crash and slow recovery.
;;               Good for watching the motivation change with the market.
;;   choppy    - a whipsaw market that jumps up and down a few percent with
;;               no trend until a final pop. This is where fixed momentum
;;               rules lose, because they buy every pop and sell every dip.
;;   downtrend - a bleeding market that keeps falling with small bounces.
;;               Hard for both agents, nobody profits going long here.
;;   realistic - a 50 step series that looks like a real market chart:
;;               uptrend, a crash with two panic days, then a choppy
;;               recovery. Generated once by make_scenario.py with a fixed
;;               seed. The same script can also turn real historical CSV
;;               data into new scenarios.
;; All series are fixed instead of random at runtime so the tests and CI
;; give the same result every run.

;; The cash every agent starts with.
(= (INITIAL_CASH) 100.0)

;; The scenario used by the older zero-argument accessors below.
(= (DEFAULT_SCENARIO) vshape)

;; Prices for the rally, crash and recovery scenario (20 prices).
;; Example: (scenarioPrices vshape)
(= (scenarioPrices vshape)
    (10.0 10.2 10.5 11.0 11.8 12.5 13.0 12.2 10.8 9.6 9.0 9.3 9.8 10.4 10.9 11.3 11.6 11.8 12.0 12.1)
)

;; Prices for the whipsaw scenario (20 prices). It swings about 4 to 5
;; percent up and down around 10 and ends with a pop.
;; Example: (scenarioPrices choppy)
(= (scenarioPrices choppy)
    (10.0 10.4 9.9 10.35 9.85 10.3 9.8 10.25 9.75 10.2 9.7 10.15 9.65 10.1 9.6 10.05 9.55 10.0 9.5 10.5)
)

;; Prices for the bleeding scenario (20 prices). It falls about 3.5
;; percent per leg with small 1.5 percent bounces in between.
;; Example: (scenarioPrices downtrend)
(= (scenarioPrices downtrend)
    (10.0 9.7 9.85 9.5 9.65 9.3 9.44 9.1 9.24 8.9 9.03 8.7 8.83 8.5 8.63 8.3 8.42 8.1 8.22 8.0)
)

;; Prices for the realistic scenario (50 prices), generated once by
;; make_scenario.py with seed 11. A gentle uptrend, then a crash with two
;; panic days of -9.5 and -12 percent (real crashes have days like that),
;; then a choppy recovery.
;; Example: (scenarioPrices realistic)
(= (scenarioPrices realistic)
    (100.0 99.15 100.06 101.66 101.59 100.61 101.04 102.08 103.82 102.95 102.01 103.31 104.36 106.65 108.33 108.75 108.97 112.59 112.8 108.72 104.1 101.99 92.3 89.7 87.63 77.11 76.38 76.2 74.81 70.76 72.34 71.04 71.45 70.09 70.72 70.31 71.23 76.34 76.95 78.88 77.61 77.88 79.56 80.14 81.42 82.31 81.48 83.09 82.55 86.23)
)

;; How many prices a scenario has.
;; Example: (scenarioPriceCount vshape) -> 20
(= (scenarioPriceCount $scenario)
    (size-atom (scenarioPrices $scenario))
)

;; The price at one step of a scenario.
;; Example: (scenarioPriceAt vshape 0) -> 10.0
(= (scenarioPriceAt $scenario $step)
    (index-atom (scenarioPrices $scenario) $step)
)

;; The return from the previous step to this step. Step must be 1 or more.
;; Example: (scenarioReturn vshape 1) -> 0.02
(= (scenarioReturn $scenario $step)
    (let* (
        ($current  (scenarioPriceAt $scenario $step))
        ($previous (scenarioPriceAt $scenario (- $step 1)))
    )
        (/ (- $current $previous) $previous)
    )
)

;; Older zero-argument accessors. They just call the default scenario so
;; code that used them before still works.

;; Example: (priceSeries)
(= (priceSeries)
    (scenarioPrices (DEFAULT_SCENARIO))
)

;; Example: (priceCount) -> 20
(= (priceCount)
    (scenarioPriceCount (DEFAULT_SCENARIO))
)

;; Example: (priceAt 0) -> 10.0
(= (priceAt $step)
    (scenarioPriceAt (DEFAULT_SCENARIO) $step)
)

;; Example: (marketReturn 1) -> 0.02
(= (marketReturn $step)
    (scenarioReturn (DEFAULT_SCENARIO) $step)
)

;; The portfolio: how much cash and how many units the agent has.
(: PortfolioState Type)
(: portfolio (-> Number Number PortfolioState))

;; The cash part of a portfolio.
;; Example: (portfolioCash (portfolio 100.0 0.0)) -> 100.0
(= (portfolioCash (portfolio $cash $units))
    $cash
)

;; The units part of a portfolio.
;; Example: (portfolioUnits (portfolio 100.0 0.0)) -> 0.0
(= (portfolioUnits (portfolio $cash $units))
    $units
)

;; The starting portfolio: all cash, no position.
;; Example: (initialPortfolio) -> (portfolio 100.0 0.0)
(= (initialPortfolio)
    (portfolio (INITIAL_CASH) 0.0)
)

;; What the whole portfolio is worth at a given price.
;; Example: (portfolioValue (portfolio 0.0 10.0) 12.0) -> 120.0
(= (portfolioValue (portfolio $cash $units) $price)
    (+ $cash (* $units $price))
)

;; True when the portfolio is holding the asset right now.
;; Example: (isHolding (portfolio 0.0 10.0)) -> True
(= (isHolding (portfolio $cash $units))
    (> $units 0.0)
)

;; Applies one trade to the portfolio at the given price.
;; Buy when flat puts all cash into units, sell when holding turns all
;; units back into cash. Anything else (hold, buy while already holding,
;; sell with nothing to sell) leaves the portfolio the same.
;; Example: (executeTrade (portfolio 100.0 0.0) buy 10.0) -> (portfolio 0.0 10.0)
(= (executeTrade (portfolio $cash $units) $actionId $price)
    (if (and (== $actionId buy) (== $units 0.0))
        (portfolio 0.0 (/ $cash $price))
        (if (and (== $actionId sell) (> $units 0.0))
            (portfolio (* $units $price) 0.0)
            (portfolio $cash $units)
        )
    )
)
