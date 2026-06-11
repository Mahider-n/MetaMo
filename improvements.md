# Incremental Codebase Improvements

This is a practical backlog for improving the current MetaMo repository one
small change at a time. It complements the deeper architectural plan in
`docs/tasks.md`; the focus here is on changes that are easy to review, easy to
test, and useful even before the larger schema/plugin work lands.

## Current Snapshot

- The repository is primarily a MeTTa implementation of a MetaMo motivation
  system integrating OpenPsi appraisal and MAGUS decision logic.
- The core state shape is `motivation(goals, modulators)`.
- OpenPsi dimensions are currently fixed in `openpsi/config.metta` as 8 goals,
  6 modulators, and 4 stimulus values.
- The Python layer is a thin helper and LLM bridge around the MeTTa runtime.
- Tests exist across `core`, `category`, `dynamics`, `openpsi`, `magus`, and
  `main`, but the README does not yet document how to run them.

## P0: Small Correctness And Maintenance Wins

### 1. Fix the first `blendStates` candidate

Current issue:

- `dynamics/coherence.metta` computes a base alpha from the current state.
- `blendStates` then calls `blendStatesHelper` with the full target as the
  first candidate.
- This means the active default cycle can jump straight to the target whenever
  the drift check allows it, instead of first trying
  `(1 - alpha) * current + alpha * target`.

Incremental change:

- In `blendStates`, compute:

  ```text
  ($initialCandidate (stateTowardTarget $currentState $targetState $baseAlpha))
  ```

- Pass `$initialCandidate` to `blendStatesHelper`.
- Add a test in `dynamics/tests/coherence-test.metta` proving that
  `blendStates (coherenceState) (coherenceTarget) ...` moves by alpha first.
- Add a `main/tests/main-tests.metta` assertion for the default cycle when
  `blend=True`.

Why first:

- This is a narrow behavior fix.
- It directly affects the repository's incremental objective embodiment claim.
- It is already described as a P0 issue in `docs/tasks.md`.

### 2. Document setup and test commands in `README.md`

Current issue:

- `README.md` only has a one-line project description.
- There is no contributor path for installing dependencies, setting up an LLM
  key, or running the MeTTa tests.

Incremental change:

- Add sections for:
  - repository purpose
  - directory overview
  - Python environment setup
  - environment variables, especially `GEMINI_API_KEY`
  - how to run each MeTTa test file
  - how to run the research assistant demo

Acceptance check:

- A new contributor can clone the repo and run at least one core test without
  reading source files first.

### 3. Add a simple project test runner

Current issue:

- Tests are spread across multiple directories.
- There is no single command in the repo for running all known tests.

Incremental change:

- Add a `Makefile` or `scripts/test.sh` with explicit commands for:
  - `core/tests/*.metta`
  - `category/tests/*.metta`
  - `dynamics/tests/*.metta`
  - `openpsi/tests/*.metta`
  - `magus/tests/*.metta`
  - `main/tests/*.metta`

Acceptance check:

- `make test` or `./scripts/test.sh` runs the full current suite and exits
  nonzero on failure.

### 4. Tighten `requirements.txt`

Current issue:

- `requirements.txt` contains `dotenv`, but the code imports
  `from dotenv import load_dotenv`, which is normally provided by
  `python-dotenv`.
- Dependency versions are not pinned or bounded.

Incremental change:

- Replace `dotenv` with `python-dotenv`.
- Add reasonable version bounds for `numpy`, `google-genai`, and
  `python-dotenv`.
- Optionally split runtime and dev dependencies if Python tests or linters are
  added later.

Acceptance check:

- A fresh virtual environment can install dependencies and import
  `llm.client` without dependency-name confusion.

### 5. Replace magic Python dimensions with shared constants

Current issue:

- `llm/parser.py` falls back to `np.zeros(8)` in multiple places.
- `llm/state_types.py` defines `NUM_GOALS = 8`, but not all Python code uses
  it.

Incremental change:

- Import `NUM_GOALS` from `llm.state_types` in `llm/parser.py`.
- Use `np.zeros(NUM_GOALS)` consistently.
- Add `NUM_STIMULUS` if parser validation starts checking stimulus length.

Acceptance check:

- No Python file hard-codes `8` as the goal-vector length except the constants
  module or tests that intentionally assert the OpenPsi layout.

### 6. Validate parsed LLM actions before returning them

Current issue:

- `parse_actions` trusts that every candidate has the expected vector lengths.
- Bad JSON can produce arrays with the wrong shape and fail later in MeTTa/Python
  bridge code.

Incremental change:

- Check that `goal_correlations` and `delta_g` each have length `NUM_GOALS`.
- Clip or reject `risk_estimate` outside `[0.0, 1.0]`.
- Normalize unknown action ids through the existing `normalize_action_id`.
- Return the safe default action if all candidates are invalid.

Acceptance check:

- Unit tests cover malformed JSON, empty candidate lists, short vectors, long
  vectors, and valid candidates.

### 7. Replace library `print` fallbacks with structured logging

Current issue:

- `llm/client.py`, `llm/parser.py`, and `applications/io_bridge.py` print
  errors directly.
- Direct prints make tests noisy and make application embedding harder.

Incremental change:

- Use the Python `logging` module in library code.
- Keep `applications/io_bridge.py` responsible for user-facing output.
- Add clear log levels: `warning` for fallback behavior, `exception` for
  unexpected parse failures.

Acceptance check:

- Parser and client tests can assert fallback behavior without scraping stdout.

### 8. Make the LLM model configurable

Current issue:

- `llm/client.py` and `llm/conversation.py` hard-code
  `gemini-3.1-flash-lite`.

Incremental change:

- Read model names from environment variables, for example:
  - `METAMO_GEMINI_JSON_MODEL`
  - `METAMO_GEMINI_CHAT_MODEL`
- Keep the current model as the default.
- Document the variables in `README.md`.

Acceptance check:

- Tests can instantiate the client with a fake or configured model value
  without editing source.

## P1: Testability And Developer Experience

### 9. Add Python unit tests for helper behavior

Current issue:

- Python helper functions are mostly tested indirectly through MeTTa tests.
- Shape errors, empty vectors, and numerical clipping are easier to test
  directly in Python.

Incremental change:

- Add `pytest`.
- Cover `core/helpers.py` functions that are used by safety, merge, and
  coherence logic:
  - `blend_arrays`
  - `project_goals_to_safe`
  - `parallel_merge_goals`
  - `parallel_merge_modulators`
  - `probe_vector`

Acceptance check:

- Python tests can run without a Gemini key or network access.

### 10. Add CI for install, lint, and tests

Current issue:

- There is no automated check that the repo installs or that tests still pass.

Incremental change:

- Add a small GitHub Actions workflow that:
  - creates a Python environment
  - installs dependencies
  - runs Python tests, once added
  - runs the MeTTa test runner

Acceptance check:

- Pull requests get a green/red signal before manual review.

### 11. Add formatting and linting for Python

Current issue:

- Python formatting is mostly consistent but not enforced.
- Broad exception handling and import ordering are easy to regress.

Incremental change:

- Add `ruff` for linting and import sorting.
- Add `black` or use Ruff formatting.
- Keep initial rules modest so adoption does not turn into a large style PR.

Acceptance check:

- `ruff check .` and the formatter run cleanly on current Python files.

### 12. Add type checks around the Python boundary

Current issue:

- Dataclasses in `llm/state_types.py` are typed, but NumPy arrays are not
  validated at construction.
- Bridge functions return nested lists for MeTTa without explicit shape checks.

Incremental change:

- Add lightweight validation helpers on `Stimulus`, `Action`, and
  `MotivationalState`.
- Validate list shapes in `llm/metta_bridge.py` before returning them.
- Consider `numpy.typing.NDArray[np.float64]` annotations once a type checker is
  introduced.

Acceptance check:

- Invalid dimensions fail close to the Python boundary with clear messages.

### 13. Split LLM side effects from fallback heuristics

Current issue:

- `llm/client.py` mixes API calls, retry policy, prompt use, and local fallback
  heuristics in one module.

Incremental change:

- Extract pure fallback functions into a separate module such as
  `llm/fallbacks.py`.
- Keep API retry and client initialization in `llm/client.py`.
- Add tests for fallback classification without requiring the Gemini client.

Acceptance check:

- Local fallback behavior can be tested offline and changed without touching API
  wiring.

## P2: MeTTa Architecture Improvements

### 14. Introduce a dimension schema registry

Current issue:

- Dimension facts are currently only name-to-index atoms plus count constants.
- Bounds, defaults, roles, and versions are not first-class.

Incremental change:

- Add `core/schema.metta` with dimension facts such as:

  ```text
  (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version)
  ```

- Register the existing OpenPsi layout in `openpsi/schema.metta`.
- Keep existing `GoalIndex`, `ModulatorIndex`, and `StimulusIndex` atoms as
  compatibility aliases.

Acceptance check:

- Existing tests still pass.
- New schema tests prove the OpenPsi schema has 8 goals, 6 modulators, and 4
  stimulus dimensions.

### 15. Move generic safety functions away from OpenPsi names

Current issue:

- `dynamics/stability.metta` directly references `gInd` and OpenPsi index
  constants.
- That is valid for the current OpenPsi/MAGUS instantiation, but it prevents
  reusing the safety layer with another schema.

Incremental change:

- Add schema roles such as `safety-overgoal` and `caution-modulator`.
- Rewrite generic safety helpers to query role-derived indices.
- Keep OpenPsi constants as wrappers during migration.

Acceptance check:

- A minimal non-OpenPsi test schema can use the safety functions with different
  dimension names.

### 16. Isolate OpenPsi/MAGUS as the default instantiation

Current issue:

- `main/main.metta` wires the default bimonad directly to OpenPsi appraisal,
  MAGUS decision, and OpenPsi-specific safety functions.

Incremental change:

- Add an instantiation module, for example
  `instantiations/openpsi_magus.metta`.
- Move default schema id, appraisal, decision, safety, merge settings, and
  bimonad factory into that module.
- Keep `defaultMetaMoBimonad` as a compatibility wrapper.

Acceptance check:

- Kernel-level tests can build a bimonad without importing OpenPsi config.
- The research assistant still uses OpenPsi/MAGUS by default.

### 17. Add proposal objects before committing state changes

Current issue:

- Appraisal and decision code move quickly from scoring to state mutation.
- There is no explicit proposal/validation/merge/commit boundary.

Incremental change:

- Introduce a proposal shape such as:

  ```text
  (transitionProposal $source $kind $deltaG $deltaM $actionScores $confidence $affectedDimensions $safetyFlags $explanation)
  ```

- Add helpers for validating proposal dimensions against the schema.
- Initially wrap the current OpenPsi/MAGUS path instead of replacing it.

Acceptance check:

- Invalid proposal dimensions fail before state commit.
- A valid wrapped OpenPsi/MAGUS transition produces the same selected action as
  the existing path.

### 18. Add property-style invariant tests

Current issue:

- Tests are mostly deterministic examples.
- The core safety claims would benefit from invariant checks over many states.

Incremental change:

- Start with a small generated fixture set rather than a full property-testing
  framework.
- Check invariants such as:
  - projected states are inside the safe region
  - clipped vectors remain in `[0.0, 1.0]`
  - blended states stay between current and target values
  - conservative fallback stays no farther from current than the proposed target

Acceptance check:

- At least one positive and one negative test exists for each major MetaMo
  principle represented in the code.

## P3: Product And Application Layer Improvements

### 19. Add an offline demo mode

Current issue:

- The LLM bridge can fall back locally, but the application path still depends
  on Gemini client setup for final responses.

Incremental change:

- Add an explicit `METAMO_OFFLINE=1` mode.
- In offline mode, use local stimulus/candidate heuristics and deterministic
  final-response templates.

Acceptance check:

- The research assistant demo can run without `GEMINI_API_KEY`.

### 20. Record cycle traces for debugging

Current issue:

- The cycle result exposes final action, merged current, merged target, next
  states, local actions, local targets, and peer simulations.
- It does not expose enough intermediate scoring information to debug why an
  action won.

Incremental change:

- Add an optional trace object for:
  - appraised state
  - candidate scores
  - selected local action per subsystem
  - safety projection result
  - blend alpha and drift outcome
- Keep tracing optional so normal output remains clean.

Acceptance check:

- A failing decision test can print a structured trace without changing core
  transition semantics.

### 21. Add minimal examples for custom subsystems

Current issue:

- `main/main.metta` supports multiple subsystem states, consensus pairs, and
  optional translation functors, but examples are sparse.

Incremental change:

- Add one small example under `examples/` showing:
  - two subsystem states
  - a custom consensus pair
  - identity translator
  - blend on/off comparison

Acceptance check:

- The example can be run as part of documentation validation or a smoke test.

## Suggested Landing Order

1. Fix `blendStates` first-candidate behavior and tests.
2. Expand `README.md` and add a single test runner.
3. Clean up Python dependency names and hard-coded goal dimensions.
4. Add parser validation and Python tests around the LLM fallback path.
5. Add logging, model configuration, and offline mode.
6. Start schema registry work while preserving existing OpenPsi atoms.
7. Refactor safety/merge logic to use schema roles.
8. Isolate OpenPsi/MAGUS as a registered default instantiation.
9. Add proposal objects and broader invariant tests.

## Changes To Avoid Early

- Do not replace the OpenPsi/MAGUS implementation before the schema registry is
  in place.
- Do not rename existing dimension atoms until compatibility aliases and tests
  exist.
- Do not turn style cleanup into a large formatting-only PR before correctness
  fixes land.
- Do not make LLM network access required for the deterministic test suite.
