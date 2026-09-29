# Source-to-proof map

The source is the author's `PRIME_UNIVERSE_THEORY.md`, originally under the host
repository's `experiments/` directory. The document contains successive
revisions and corrections. Chapter and section names are more stable than
line numbers. Snapshot hashes are recorded in `provenance.json`; the manuscript
is not bundled or required by the build.

## Continuation

| Source passage | Lean statements | Translation choices |
|---|---|---|
| Chapter 144, “The Breakthrough Candidate”, equations 144.3–144.5 | `PrimeCutoff.geometric_cutoff_bounds`, `horizon_membership_is_geometric_cutoff`, `seam_membership_is_geometric_cutoff` | Proves `157 < 16π² < 158` and identifies the full and reserved prime sets. The factor `16π²` and the exclusion of 2 and 3 remain specified inputs. |
| Chapter 149, “Temperature Selects Prime 11”, equations 149.26–149.29 | `HeatCapacity.response_is_canonical_thermal_derivative`, `eleven_unique_integer_maximum`, `eleven_unique_prime_maximum` | Dimensionless heat capacity at inverse temperature 1, with two levels 0 and `log(p)`. The derivative in inverse temperature holds the gap fixed. The integer maximum is stronger than the source's prime restriction. |
| Same passage, the continuous maximum | `eleven_still_on_increasing_continuous_branch` | Certifies the distinction between the integer and continuous questions. The quoted continuous critical point, hyperbolic-tangent equation, and uniqueness of the continuous peak are not proved here. |
| Chapter 146, “The Remaining Curvature No-Go”, equations 146.52–146.54 | `DeterminantResponse.scaled_spectral_product`, `scaled_action`, `action_derivative`, `logarithmic_scale_response` | Every nonzero eigenvalue scales by `1/(a μ)²`. The formal action is `Γ/ℏ`; both scales are strictly positive. The existing Fourier completeness theorem supplies the full spectrum. |
| Same passage, equation 146.55 | `family_action_derivative`, `horizon_prime_count`, `horizon_nonzero_mode_count`, `seam_prime_count`, `seam_nonzero_mode_count`, `seam_logarithmic_response` | The full cutoff includes all natural primes less than 158. The seam excludes 2 and 3 as specified in equation 146.23. Lean checks both counts and mode sums in its kernel; no list or total is assumed. |
| Same passage, the cosmological conclusion | `determinant_normalization_has_zero_response`, `reference_scale_shift` | Formalizes uniform scale differentiation and a constant action shift. General metric variations, a stress tensor, defect measures, and Einstein's equation are outside the model. |

All names above have the prefix `PrimeUniverse.`. `LogBounds.lean` contains the
rational certificates used in the maximum proof, derived from established
mathlib bounds. Those lemmas are proof infrastructure, not new physical claims.

## Inherited proof threads

| Module | Manuscript chapters | Checked content |
|---|---|---|
| `CycleSpectrum` | 146–147 | Complete finite cyclic Fourier modes, eigenvalues, zero mode, spectral product, and logarithmic action. |
| `ModularCell` | 145, 149 | Two-level paired state, partial trace, entanglement, modular gap, complementarity, entropy derivative, and the two time generators. |
| `ThermalZeta` | 145, 147 | Arithmetic thermal norm, its convergence boundary, finite product nonvanishing, and the infinite Euler product in its convergence region. |
| `Bell` | 59, 85 | The proposed conditional update, its correlations and marginal, and the local CHSH inequality with a common distribution. |
| `ConformalPulse` | 140 | A source with the specified derivative-plus-square form cannot have zero integrated source under flat endpoint slopes and a nontrivial continuous profile. |
| `ScaleAndHorizon` | 134, 143, 150 | Action/radius identities under the stipulated horizon formulas, and the scale degeneracy of finite Gibbs states. |
| `Connections` in the entry file | 146–147, 149 | Equality of cycle and modular gaps, and conversion of cycle action to an arithmetic Boltzmann factor. |

## Boundaries of the model

Primality is not a hypothesis of the cycle determinant, modular-state, or
complementarity theorems. It enters the infinite Euler product and the explicit
cutoff and seam sums. The integer heat-capacity theorem deliberately demonstrates
where it is unnecessary.

The Bell update is interpreted as a joint probability rule. Its conditional
parameter may depend on both settings; it is not silently assumed to be a
local response. The no-signalling equivalence fixes the effective initial bias
and quantifies over all update parameters in `[0,1]`. It does not require each
component of a hidden-variable decomposition to be individually unbiased.

The conformal pulse theorem assumes the source equation, regularity, and
boundary conditions as explicit hypotheses. Strict positivity is derived from
a nonzero continuous slope, not assumed as positivity of an integral. Its
polynomial example describes an interval profile, not a global conformal state.

The horizon formulas are algebraic inputs to the formal model. Their asserted
origin in gravitational field equations is not imported as a new Lean axiom.
The axiom audit does not replace a review of these inputs.

The relation `μ(1)=+1` is not used to derive the formalized results. The project
tests the manuscript's concrete mathematical constructions and deductions.
