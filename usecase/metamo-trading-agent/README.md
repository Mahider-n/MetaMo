# Trading Agent Use Case

This is a trading agent built on top of the MetaMo framework. The agent
trades one asset over different market scenarios, and every single
decision it makes goes through MetaMo itself. Nothing is reimplemented
here. The OpenPSI appraisal turns each market move into modulator updates,
the MAGUS scorer picks between the trade actions, two subsystems called
prudence and ambition agree on one action through the framework's
consensus transition, the stability dynamics keep every update safe, and
the emotion layer (from PR #18) tells us how the agent feels after every
step.

There is also a simple momentum baseline that trades in the exact same
market but without any MetaMo thinking. It is there so we can compare and
see what the motivational system actually adds.

## The files

- `trading_market.metta` holds the market world: the price scenarios, the
  portfolio and the trade rules. Both agents share it.
- `trading_core.metta` holds the adapters that connect the market to
  MetaMo: the two subsystem states, the stimulus mapping and the trade
  candidates.
- `trading_agent.metta` is the entry point of the MetaMo agent. It runs
  all four scenarios and prints one log line per step.
- `trading_baseline.metta` is the momentum baseline.
- `tests/trading_agent_tests.metta` has 45 unit tests.
- `plot_trading_run.py` turns the run logs into charts.
- `make_scenario.py` generates the realistic price series and can also
  turn real historical CSV data into new scenarios.

## The market scenarios

There are four scenarios: vshape (rally, crash, recovery), choppy (a
whipsaw market that jumps up and down), downtrend (a market that keeps
bleeding) and realistic (a 50 step series that looks like a real chart,
with an uptrend, a crash with two panic days and a choppy recovery).

Adding a new scenario only takes one new `(scenarioPrices <name>)`
equation in `trading_market.metta` plus one `!(startTrader <name>)` line
in `trading_agent.metta`. To use real market data, export a CSV with a
Close column (for example from Yahoo Finance) and run:

```
python3 make_scenario.py csv prices.csv myscenario
```

Then paste the printed equation into `trading_market.metta`.

## How to run

You need PeTTa and a Python with numpy (and matplotlib for the charts).
From the repo root:

```
python3 scripts/run-tests.py --root usecase/metamo-trading-agent --petta-runner /path/to/PeTTa/run.sh
```

That should end with 45/45 tests passed. To run the agents and keep the
logs (the agent run takes a few minutes because every step is a full
MetaMo cycle):

```
cd usecase/metamo-trading-agent
sh /path/to/PeTTa/run.sh trading_baseline.metta | tee baseline_log.txt
sh /path/to/PeTTa/run.sh trading_agent.metta | tee agent_log.txt
```

Each agent prints one parseable atom per step, and the MetaMo agent's
line also carries its dominant emotion, all four feeling intensities,
valence, securing, the two overgoals and the portfolio value.

## Try the agent on your own price data

Any price history works as long as you have a CSV file with a column of closing
prices. For example, download the historical data of a stock or a cryptocurrency
from Yahoo Finance as a CSV.

Step 1. Convert the CSV into a scenario. From this folder:

    python3 make_scenario.py csv yourfile.csv mymarket Close

Replace `Close` with the real name of the price column if it differs. The script
normalizes the first price to 100 and prints a scenario equation.

Step 2. Paste the printed equation into `trading_market.metta`, next to the
existing scenarios.

Step 3. Add this line at the bottom of `trading_agent.metta`:

    !(startTrader mymarket)

And if you also want the baseline comparison, add this at the bottom of
`trading_baseline.metta`:

    !(baselineLoop mymarket (initialPortfolio) 1)

Step 4. Run and plot like any other scenario:

    sh /path/to/PeTTa/run.sh trading_agent.metta | tee agent_log.txt
    sh /path/to/PeTTa/run.sh trading_baseline.metta | tee baseline_log.txt
    python3 plot_trading_run.py agent_log.txt baseline_log.txt figures

Your market now shows up in the logs and the charts with the agent's trades,
its portfolio value and its emotions per step.

Two practical tips. Keep the series around 50 to 100 points, since every point
is a full framework cycle and longer series just take proportionally longer.
And match the risk gain to your data: the default `RISK_GAIN = 6` in
`trading_core.metta` is tuned for markets with panic sized moves of ten percent
or more per step, which fits daily cryptocurrency data. For gentler data such
as weekly stock closes, raise it to around 12 so the agent perceives danger at
the right scale. We measured this on real Apple weekly data from 2015 to 2016:
with the default gain the agent under-reacted, with `RISK_GAIN = 12` it sold
early in the decline and protected its capital while the market lost 23.6
percent.

## How to make the charts

```
python3 plot_trading_run.py agent_log.txt baseline_log.txt figures
```

This writes three charts per scenario into the figures folder:

- `trading_agent_vs_baseline_<scenario>.png` shows the price with both
  agents' trades and both portfolio value curves.
- `trading_agent_dynamics_<scenario>.png` shows the agent's modulators,
  overgoals and emotion step by step.
- `trading_agent_press_<scenario>.png` is the presentation chart with the
  agent's decisions and emotional state on one picture.

## Reading the emotional state chart

The press chart is the easiest way to see the agent's inner life. The
black line is the price. The green and red triangles are the agent's real
buy and sell decisions. The background color of every step is the
agent's dominant feeling at that moment: gold means happy and gray means
neutral. The bottom panel shows the raw intensities of all four emotions
(happy, sad, angry and fear) from the feeling layer, with the dashed line
at 0.6 marking the dominance threshold. Everything on the chart is parsed
from the agent's own run log, nothing is placed by hand.

On the realistic scenario the story goes like this: the agent buys the
uptrend and feels happy through the rally, sells on the first panic day,
sits in cash through the rest of the crash while its valence drops and
its fear intensity rises, then re-enters near the bottom once the
remembered turbulence fades, and rides the recovery feeling happy again.

## Results (every agent starts with 100)

- realistic: MetaMo agent 112.35, baseline 121.62
- vshape: MetaMo agent 137.76, baseline 155.62
- choppy: MetaMo agent 100.96, baseline 63.61
- downtrend: MetaMo agent 82.47, baseline 72.07
- total: MetaMo agent 433.54, baseline 412.92

The baseline wins the two smooth trending series because its fixed
threshold happens to time them well. The MetaMo agent wins the choppy
market by a lot, because the baseline buys every pop and sells every dip
while the agent's consensus holds through the wobbles, and it also wins
the downtrend and the total. The interesting part is not only the
numbers but that every trade comes from motivation, consensus and
emotion dynamics you can watch in the logs and charts.
