# Tasks From Critique Validation

This plan validates the claims in `docs/critique.md` against the current repository
and turns the valid gaps into implementation work. The existing code should be
treated as a faithful OpenPsi/MAGUS prototype first, then extended into a more
general MetaMo kernel.

## Validation Summary

| Critique claim | Verdict | Code evidence | Action |
| --- | --- | --- | --- |
| The repo is best read as an OpenPsi/MAGUS MetaMo implementation, not a general plugin platform. | Valid. | `README.md` says the project integrates MAGUS and OpenPsi. `main/main.metta:207` wires `openPsiAppraisal`, `magusDecision`, `applyHomeostaticDamping`, `raiseBoundaryCaution`, `projectToSafeRegion`, `checkContractiveUpdateLaw`, and `isInSafeRegion` as the default bimonad. | Preserve this default instantiation while extracting kernel contracts around it. |
| The state model preserves `G x M`. | Valid. | `core/state.metta:3` defines `MotivationalState`; `core/state.metta:4` defines `motivation(goals, modulators)`; `core/state.metta:44` validates counts. | Keep this representation as the kernel state shape. |
| Current abstractions are function slots, not full plugin boundaries. | Valid. | `category/functors.metta:2` and `category/functors.metta:5` define appraisal and decision records around function symbols. `category/bimonad.metta:8` stores symbols for damping, boundary, projection, contractivity, and safety. No manifest, lifecycle, proposal, compatibility, or rollback APIs exist. | Add plugin/proposal contracts after schema metadata is in place. |
| There is no vector schema registry. | Valid. | `openpsi/config.metta:3` fixes counts. `openpsi/config.metta:9`, `openpsi/config.metta:20`, and `openpsi/config.metta:29` define name-to-index atoms only. `core/state_accessors.metta:7`, `core/state_accessors.metta:16`, and `core/state_accessors.metta:25` read by index lookup. | Add first-class dimension metadata and compatibility checks. |
| OpenPsi and MAGUS are not isolated as replaceable instantiations. | Valid. | `openpsi/appraisal.metta:30` through `openpsi/appraisal.metta:45` reads concrete OpenPsi/MAGUS names. `magus/decision.metta:5` through `magus/decision.metta:23` declares concrete MAGUS mappings. `magus/decision.metta:115` through `magus/decision.metta:137` scores with `gInd`, `gTrans`, `threshold`, `securing`, `arousal`, `approach`, `gEthic`, and `gCurio`. | Package OpenPsi/MAGUS as the default registered instantiation. |
| Safety is concrete rather than schema-neutral. | Valid. | `dynamics/stability.metta:6` checks `gInd` and goal norm. `dynamics/stability.metta:64` boosts `OPENPSI_CAUTION_MOD_IDX`. `dynamics/stability.metta:104` projects through `OPENPSI_GOAL_WEIGHT_IDX` and `OPENPSI_CAUTION_MOD_IDX`. | Replace direct index assumptions with schema role queries while keeping OpenPsi role metadata. |
| Incremental embodiment is incomplete. | Valid, with nuance. | `dynamics/coherence.metta:100` defines `nextStateCalculator`, which recombines the same current state. `dynamics/tests/coherence-test.metta:74` explicitly tests that no-op behavior. The main cycle does not call this helper, but `blendStates` starts with the full target at `dynamics/coherence.metta:187` and only backs off if drift fails. | Fix the coherence API so the active path starts from `(1 - alpha) * current + alpha * target`. |
| Schema versioning and migration are absent. | Valid. | Repository search finds no schema-version or migration API outside the critique. | Add versioned schemas and migration rules once schema metadata exists. |
| Neural adapters are underdeveloped. | Valid, but out of scope for now. | Repository search finds no encoder, mask, neural adapter, or tokenization API. `requirements.txt` only lists `numpy`. | Defer until a learning/model-integration use case requires them. |
| Verification is mostly procedural. | Valid. | Runtime checks exist in `category/bimonad.metta:229` and `dynamics/stability.metta:127`. Tests cover deterministic examples, including coherence, stability, bimonad, and integration, but not property-style invariants, migration replay, or schema compatibility. | Add a focused verification harness by phase. |

## Implementation Principles

- Do not replace OpenPsi/MAGUS. Register it as the default instantiation.
- Keep `motivation(goals, modulators)` and current `GoalIndex`, `ModulatorIndex`, and `StimulusIndex` atoms available during migration.
- Make schema metadata additive first, then refactor safety, merge, appraisal, and decision logic to consume it.
- Land each phase with tests before starting the next phase.

## P0 - Correctness And Schema Foundation

### P0.1 Fix incremental state blending

Problem:

- `nextStateCalculator(current, alpha)` is a no-op for any alpha because it blends `current` with itself.
- `blendStates(current, target, ...)` computes `baseAlpha`, but its initial candidate is `target`, not the alpha-weighted partial target.
- `main/main.metta:370` uses `blendStates` for default cycle updates, so the active update path can jump directly to the target whenever the drift check allows it.

Tasks:

1. Replace or deprecate `nextStateCalculator`.
   - Preferred shape: `(nextStateCalculator $currentState $targetState $alpha)`.
   - Implementation should delegate to `stateTowardTarget`.
   - Keep the old one-argument targetless behavior only if a compatibility test proves callers still need it. Current search shows no production call sites.
2. Change `blendStates` to create its first candidate with:

   ```text
   (stateTowardTarget $currentState $targetState $alpha)
   ```

   Then pass that candidate into `blendStatesHelper`.
3. Keep `blendStatesHelper` as the backoff loop, but make the initial drift check evaluate the alpha-weighted candidate rather than the full target.
4. Update `dynamics/tests/coherence-test.metta`.
   - Replace the no-op `nextStateCalculator` test with an alpha-blend test.
   - Add a `blendStates` test where `coherenceState` moves toward `coherenceTarget` by alpha `0.2`.
   - Expected goals for the first two dimensions: `(0.24 0.76 ...)`.
   - Expected modulators for the first two dimensions: `(0.12 0.22 ...)`.
5. Add or update a main-cycle test in `main/tests/main-tests.metta` proving `runMetaMoCycleDefault` returns partial next states when blending is enabled.

Acceptance criteria:

- `nextStateCalculator` no longer returns the unchanged current state when target differs and alpha is greater than `0`.
- `blendStates` performs `(1 - alpha) * current + alpha * target` before drift backoff.
- Existing no-blend integration behavior remains unchanged.

### P0.2 Add a dimension schema registry

Problem:

- The current config stores only counts and name-to-index atoms.
- There is no place to attach bounds, defaults, roles, update limits, decay policy, or schema version.

Tasks:

1. Add a new schema module, for example `core/schema.metta`.
2. Define a dimension fact shape. A workable MeTTa representation:

   ```text
   (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version)
   ```

   Where `$kind` is one of `goal`, `modulator`, `stimulus`, or `actionFeature`.
3. Add schema accessors:
   - `dimensionIndex`
   - `dimensionBounds`
   - `dimensionDefault`
   - `dimensionRoles`
   - `dimensionsByKind`
   - `dimensionsByRole`
   - `schemaDimensionCount`
4. Add validators:
   - unique dimension ids per schema and kind
   - unique indices per schema and kind
   - contiguous indices from `0` to `count - 1`
   - state vector lengths match schema counts
   - values are within dimension bounds
5. Register the current OpenPsi/MAGUS layout in a new module such as `openpsi/schema.metta`.
6. Generate or mirror existing `GoalIndex`, `ModulatorIndex`, and `StimulusIndex` atoms from the registered OpenPsi schema so old accessors keep working.
7. Add tests for:
   - OpenPsi schema count is 8 goals, 6 modulators, 4 stimuli
   - `gInd` has role `safety-overgoal`
   - `threshold` and `securing` have role `caution-modulator`
   - invalid duplicate indices fail validation
   - out-of-bounds states fail schema validation

Acceptance criteria:

- Existing OpenPsi tests still pass.
- New schema tests can validate the current OpenPsi state shape without relying only on `NUM_GOALS`, `NUM_MODULATORS`, and `NUM_STIMULUS`.
- Role lookup can return the indices now hardcoded in `OPENPSI_*_IDX` constants.

## P1 - Kernel And Instantiation Separation

### P1.1 Package OpenPsi/MAGUS as a registered instantiation

Tasks:

1. Add an instantiation module, for example `instantiations/openpsi_magus.metta`.
2. Move default wiring responsibilities into that module:
   - OpenPsi schema id
   - OpenPsi appraisal
   - MAGUS decision
   - role-based safety functions
   - role-based merge settings
   - default bimonad factory
3. Keep `defaultMetaMoBimonad` as a compatibility wrapper that delegates to the registered OpenPsi/MAGUS factory.
4. Update imports in tests so kernel tests do not need OpenPsi config unless they are testing the OpenPsi/MAGUS instantiation.

Acceptance criteria:

- Kernel tests can construct a bimonad with a small mock schema and mock functions.
- OpenPsi/MAGUS remains the default runtime behavior.

### P1.2 Make safety and merge role-based

Tasks:

1. Replace direct use of `gInd` inside generic safety functions with a role query for `safety-overgoal`.
2. Replace `OPENPSI_CAUTION_MOD_IDX`, `OPENPSI_EXPLORATORY_MOD_IDX`, `OPENPSI_SHARED_MOD_IDX`, `OPENPSI_SAFETY_GOAL_IDX`, `OPENPSI_EXPLORATORY_GOAL_IDX`, and `OPENPSI_SOCIAL_GOAL_IDX` with role-derived index lists.
3. Keep OpenPsi constants temporarily as aliases to role-query results.
4. Add tests using a minimal non-OpenPsi schema to prove:
   - safety projection finds a differently named safety overgoal
   - caution boosting finds differently named caution modulators
   - parallel merge can run from role groups rather than OpenPsi names

Acceptance criteria:

- `dynamics/stability.metta` no longer hard-codes `gInd` or OpenPsi index constants in its generic functions.
- OpenPsi/MAGUS safety behavior remains numerically equivalent for existing fixtures.

### P1.3 Introduce proposal-based plugin contracts

Tasks:

1. Add a proposal type. A minimal first version:

   ```text
   (transitionProposal $source $kind $deltaG $deltaM $actionScores $confidence $affectedDimensions $safetyFlags $explanation)
   ```

2. Add proposal helpers:
   - `proposalSource`
   - `proposalKind`
   - `proposalDeltaG`
   - `proposalDeltaM`
   - `proposalConfidence`
   - `validateProposalAgainstSchema`
3. Add adapters:
   - OpenPsi appraisal adapter emits a modulator proposal instead of directly committing modulators.
   - MAGUS decision adapter emits action scores and selected `deltaG`.
4. Add bus functions:
   - collect appraisal proposals
   - collect decision proposals
   - validate proposals
   - merge proposals
   - project merged target into safe region
   - blend current state toward projected target
   - commit final state
5. Keep the existing `step` API as a wrapper over the proposal bus once tests cover the new path.

Acceptance criteria:

- A single OpenPsi/MAGUS proposal-bus step produces the same selected action as the current step.
- State mutation happens only after validation, projection, and blending.
- Invalid proposal dimensions fail before commit.

## P2 - Evolution And Verification

### P2.1 Add schema versioning and migration

Tasks:

1. Add schema version ids to registered schemas.
2. Define migration rule facts:

   ```text
   (MigrationRule $fromSchema $toSchema $kind $sourceDimension $targetDimension $transform $lossEstimate $confidence)
   ```

3. Add migration result shape:

   ```text
   (migrationResult $state $informationLoss $confidence $notes)
   ```

4. Implement migration helpers:
   - copy unchanged dimensions by id
   - apply explicit transforms for renamed or split dimensions
   - fill new dimensions from defaults
   - report dropped dimensions as loss
5. Add replay tests for a toy schema upgrade from OpenPsi v1 to OpenPsi v2 with one added modulator.

Acceptance criteria:

- A v1 state can migrate to v2 without changing shared dimension values.
- Added dimensions receive schema defaults.
- Migration loss and confidence are visible to callers.

### P2.2 Add a verification harness for MetaMo principles

Tasks:

1. Add focused invariant tests for:
   - bounded appraisal-decision commutation error
   - safe-region invariance
   - boundary-band contractivity
   - schema-correct parallel merge
   - reciprocal translation error bounds
   - self-model drift bounds under blending
   - replay consistency under schema migration
2. Use deterministic grids first. Add randomized/property-style Python helpers only where deterministic tests are too weak.
3. Keep runtime checks, but make tests assert the principles independently of a single runtime path.

Acceptance criteria:

- Each MetaMo principle has at least one failing-negative and one passing-positive test.
- Verification tests cover both the OpenPsi/MAGUS schema and one minimal mock schema.

## Suggested Delivery Order

1. P0.1 blending fix and coherence tests.
2. P0.2 schema registry with OpenPsi metadata.
3. P1.2 role-based safety and merge.
4. P1.1 OpenPsi/MAGUS registered instantiation cleanup.
5. P1.3 proposal bus and compatibility wrapper.
6. P2.1 schema migration.
7. P2.2 verification harness expansion.

This order fixes the confirmed correctness issue first, then adds the metadata
needed to make the broader architectural work practical.
