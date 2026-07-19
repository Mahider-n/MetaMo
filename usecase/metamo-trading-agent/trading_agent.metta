;; MetaMo trading agent.
;;
;; Every decision this agent makes goes through the MetaMo framework. The
;; OpenPSI appraisal turns each market observation into modulator updates,
;; the MAGUS scorer picks between the trade candidates, the two subsystems
;; (prudence and ambition) agree on one action through the consensus
;; transition, the stability dynamics damp and project every update, and
;; the emotion layer reads the state after every step.
;;
;; This file only wires the framework calls together. The adapters live in
;; trading_core.metta and the market world in trading_market.metta.
;;
;; Run:
;;   sh /path/to/PeTTa/run.sh usecase/metamo-trading-agent/trading_agent.metta

!(import! &self ../../core/helper)
!(import! &self "../../core/helpers.py")
!(import! &self ../../core/state)
!(import! &self ../../core/state_accessors)
!(import! &self ../../core/config)
!(import! &self ../../openpsi/config)
!(import! &self ../../category/functors)
!(import! &self ../../category/bimonad)
!(import! &self ../../openpsi/appraisal)
!(import! &self ../../openpsi/appraisal_helpers)
!(import! &self ../../openpsi/feeling)
!(import! &self ../../magus/decision)
!(import! &self ../../dynamics/stability)
!(import! &self ../../dynamics/coherence)
!(import! &self ../../main/main)
!(import! &self trading_market)
!(import! &self trading_core)

;; Builds the identity TranslationFunctor for the peer simulation line,
;; same as the research assistant does. Identity matrices mean each
;; subsystem sees the other one as it really is.
;; Example: (createIdentityTranslator)
(= (createIdentityTranslator)
    (let* (
        ($numGoals (eval (NUM_GOALS)))
        ($numMods  (eval (NUM_MODULATORS)))
        ($goalMatrix (py-call (helpers.identity_matrix $numGoals)))
        ($modMatrix  (py-call (helpers.identity_matrix $numMods)))
    )
        (translationFunctor $goalMatrix $modMatrix)
    )
)

;; Prints one step of the run as one atom that a script can parse later.
;; The emotion is the dominant emotion from the OpenPSI feeling layer on
;; the cycle's merged state, and feelings holds all four intensities in
;; the framework's (happy sad angry fear) order.
;; Example: (logTradingStep vshape 5 12.5 buy merged (portfolio 0.0 8.0))
(= (logTradingStep $scenario $step $price $actionId $merged $portfolio)
    (let* (
        ($value    (roundNum (portfolioValue $portfolio $price) 2))
        ($emotion  (dominantEmotion $merged))
        ($fHappy   (roundNum (emotionIntensity $merged happy) 3))
        ($fSad     (roundNum (emotionIntensity $merged sad) 3))
        ($fAngry   (roundNum (emotionIntensity $merged angry) 3))
        ($fFear    (roundNum (emotionIntensity $merged fear) 3))
        ($valence  (roundNum (getModulator $merged valence) 3))
        ($securing (roundNum (getModulator $merged securing) 3))
        ($gInd     (roundNum (getGoal $merged gInd) 3))
        ($gTrans   (roundNum (getGoal $merged gTrans) 3))
    )
        (println! (TRADER scenario $scenario step $step price $price action $actionId emotion $emotion feelings ($fHappy $fSad $fAngry $fFear) valence $valence securing $securing gInd $gInd gTrans $gTrans value $value))
    )
)

;; One trading step. It reads the market through the stimulus adapter,
;; runs one full MetaMo cycle (appraise, decide, consensus, stabilize,
;; blend), executes the agreed action on the portfolio, logs the step and
;; then calls itself with the next states from the framework.
;; Example: (tradingLoop vshape bimonad translator states (initialPortfolio) 0.0 1)
(= (tradingLoop $scenario $bimonad $translator $states $portfolio $turbulence $step)
    (if (>= $step (scenarioPriceCount $scenario))
        (let* (
            ($lastPrice  (scenarioPriceAt $scenario (- (scenarioPriceCount $scenario) 1)))
            ($finalValue (roundNum (portfolioValue $portfolio $lastPrice) 2))
        )
            (println! (TRADER FINAL scenario $scenario value $finalValue))
        )
        (let* (
            ($price      (scenarioPriceAt $scenario $step))
            ($return     (scenarioReturn $scenario $step))
            ($holding    (isHolding $portfolio))
            ($nextTurbulence (decayedTurbulence $return $turbulence))
            ($stimulus   (marketStimulus $return $holding $nextTurbulence))
            ($candidates (tradingCandidates $nextTurbulence $holding))
            ($result (runMetaMoCycleDefault
                $bimonad
                $states
                $stimulus
                $candidates
                ()
                $translator))
            ($actionId      (actionId (cycleFinalAction $result)))
            ($merged        (cycleMergedTarget $result))
            ($nextStates    (cycleNextStates $result))
            ($nextPortfolio (executeTrade $portfolio $actionId $price))
            ($_ (logTradingStep $scenario $step $price $actionId $merged $nextPortfolio))
        )
            (tradingLoop $scenario $bimonad $translator $nextStates $nextPortfolio $nextTurbulence (+ $step 1))
        )
    )
)

;; Runs the agent on one named scenario with fresh subsystems, a fresh
;; portfolio and the default MetaMo bimonad. The one peer line at the start
;; uses the TranslationFunctor path to show how prudence sees ambition's
;; securing modulator.
;; Example: (startTrader vshape)
(= (startTrader $scenario)
    (let* (
        ($_ (println! (MetaMo Trading Agent starting scenario $scenario)))
        ($bimonad    (defaultMetaMoBimonad))
        ($states     (tradingSubsystems))
        ($translator (createIdentityTranslator))
        ($peerView   (simulatePeer $translator (ambitionState)))
        ($peerSecuring (roundNum (getModulator $peerView securing) 3))
        ($_ (println! (PEER prudence simulates ambition securing $peerSecuring)))
    )
        (tradingLoop $scenario $bimonad $translator $states (initialPortfolio) 0.0 1)
    )
)

!(startTrader vshape)
!(startTrader choppy)
!(startTrader downtrend)
!(startTrader realistic)
