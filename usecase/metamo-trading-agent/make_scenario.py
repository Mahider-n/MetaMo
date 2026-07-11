#!/usr/bin/env python3
"""Makes price scenarios for the trading applications.

Two modes:

1. Seeded realistic series (how the committed `realistic` scenario was made):

     python3 usecase/metamo-trading-agent/make_scenario.py generate

   Prints a `(= (scenarioPrices realistic) (...))` equation made by a
   seeded random walk with three phases: a gentle uptrend, a crash phase
   with two panic days (real crashes have single days far worse than the
   normal noise), and a choppy recovery. The seed is fixed, so the output
   is the same on every run and the tests stay deterministic.

2. Real historical data (recommended for demos):

     python3 usecase/metamo-trading-agent/make_scenario.py csv prices.csv myscenario [column]

   Reads a CSV exported from e.g. Yahoo Finance, takes the close column
   (default "Close"), normalizes the first price to 100, and prints a
   scenario equation you can paste into usecase/metamo-trading-agent/trading_market.metta.
   Add a matching `!(startTrader myscenario)` line to trading_agent.metta
   and the MetaMo agent runs genuinely on the real series.
"""

import csv
import random
import sys

SEED = 11
START_PRICE = 100.0


def generateRealistic():
    """Random walk with three phases: uptrend, crash with panic days, recovery."""
    rng = random.Random(SEED)
    prices = [START_PRICE]

    # Regime 1: gentle uptrend (18 steps), drift +0.5%, noise 1.1%
    for _ in range(18):
        move = rng.gauss(0.005, 0.011)
        prices.append(prices[-1] * (1.0 + move))

    # Regime 2: crash (11 steps), drift -2.2%, noise 1.8%, with two
    # fat-tail panic days injected the way real crashes have them.
    panicSteps = {3: -0.095, 6: -0.12}
    for i in range(11):
        move = panicSteps.get(i, rng.gauss(-0.022, 0.018))
        prices.append(prices[-1] * (1.0 + move))

    # Regime 3: choppy recovery (20 steps), drift +0.9%, noise 1.9%
    for _ in range(20):
        move = rng.gauss(0.009, 0.019)
        prices.append(prices[-1] * (1.0 + move))

    return [round(p, 2) for p in prices]


def readCsvCloses(path, column):
    """Reads the close column from a CSV and scales the first price to 100."""
    closes = []
    with open(path, newline="") as handle:
        for row in csv.DictReader(handle):
            value = row.get(column, "").strip()
            if value:
                closes.append(float(value))
    if not closes:
        raise SystemExit(f"no values found in column '{column}' of {path}")
    scale = START_PRICE / closes[0]
    return [round(c * scale, 2) for c in closes]


def formatScenario(name, prices):
    """Formats a price list as a scenarioPrices equation."""
    joined = " ".join(f"{p}" for p in prices)
    return f"(= (scenarioPrices {name})\n    ({joined})\n)"


def main():
    if len(sys.argv) >= 2 and sys.argv[1] == "generate":
        print(formatScenario("realistic", generateRealistic()))
    elif len(sys.argv) >= 4 and sys.argv[1] == "csv":
        column = sys.argv[4] if len(sys.argv) > 4 else "Close"
        prices = readCsvCloses(sys.argv[2], column)
        print(formatScenario(sys.argv[3], prices))
    else:
        print(__doc__)
        sys.exit(1)


if __name__ == "__main__":
    main()
