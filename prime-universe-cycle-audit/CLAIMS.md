# Source claims, formal statements, and limits

Chapter numbers and equation numbers refer to the manuscript identified in
[PROVENANCE.md](PROVENANCE.md). All theorem names below have the prefix
`PrimeUniverse.`. The Lean statements, rather than this prose, specify the
precise quantifiers and assumptions.

| Source | Formal entry point | What is established |
|---|---|---|
| Chapter 146, cycle Laplacian | `CycleLaplacian.graph_laplacian_is_cycle_operator` | The local difference operator agrees with mathlib's simple cycle graph Laplacian for `n≥3`. |
| Chapter 146, Fourier modes | `CycleLaplacian.fourier_diagonalizes_cycle` and `eigenvalue_is_chord_squared` | A complete, invertible coordinate transform diagonalizes the operator; the eigenvalues are squared chord lengths. |
| Chapter 146, zero-mode removal | `CycleDeterminant.zero_modes_are_exactly_constants`, `fourier_average_projection`, and `average_projection_is_idempotent` | The only kernel is the constants; the mean projection keeps exactly the zero Fourier coefficient. |
| Chapter 146, (146.18)--(146.22) | `CycleDeterminant.simple_cycle_matrix_determinant` | The determinant of the actual graph matrix `L+J/n` equals `n²`. |
| Chapters 146 and 149, (149.5) | `Bridge.concrete_cycle_action_matches_modular_gap` | The half-log of the concrete matrix determinant equals the gap of the specified cell. |
| Chapter 149, (149.2)--(149.25) | `ModularCell.modular_gap`, `wave_structure_complementarity`, and `entropy_derivative_negative` | Exact state normalization, gap, complementarity, and monotonicity within the prescribed family. |
| Chapters 145 and 149, two generators | [PairedClocks.lean](PrimeUniverse/PairedClocks.lean) | Paired-state difference-clock cancellation, doubled sum-clock energy labels, and reduced-state identities. |
| Chapters 1 and 40, Möbius identity | [Arithmetic.lean](PrimeUniverse/Arithmetic.lean) | Special values, the divisor cancellation identity, and a uniqueness consequence. |
| Chapters 66 and 145, finite products | [Arithmetic.lean](PrimeUniverse/Arithmetic.lean) | Product expansion over subsets and exact subset cardinality. |
| Chapter 143, (143.30)--(143.41) | [HorizonDuality.lean](PrimeUniverse/HorizonDuality.lean) | Reciprocal-radius involution, its fixed point, exchange of two supplied energy formulas, and the supplied horizon identity. |
| Chapter 150, (150.1)--(150.5) | [ClockScale.lean](PrimeUniverse/ClockScale.lean) | Finite Gibbs states do not fix an absolute energy scale. |
| Chapters 59 and 85, Bell mechanism | [BellAudit.lean](PrimeUniverse/BellAudit.lean) | Conditional correlation, the missing-conditional obstruction, marginal behavior, finite local CHSH bound, and a CHSH=4 conditional sampler. |

**What changed after the initial audit**

The original cycle result evaluated a spectral product. That left a genuine
formalization gap between the product and a concrete graph operator. This
extension defines the operator independently, identifies it with a graph
Laplacian, proves Fourier conjugation, identifies its exact kernel, and computes
an ordinary matrix determinant after replacing the constant zero mode by one.
No graph spectrum is assumed as an extra axiom.

The implementation uses `n=extraVertices+3` to state the ordinary graph result
without repeatedly carrying a lower-bound hypothesis. The local cyclic
difference operator and its regularized determinant also make sense for `n=1`
and `n=2`. Those small operators are not asserted to be the Laplacians of the
corresponding ordinary simple cycle graphs.

The primitive-root product is an existing mathlib theorem. The code supplies
an explicit primitive root, proves the connection to the Fourier character,
and transports the product through squared norms and the matrix determinant.
Neither graph primality nor a physical assumption is needed.

**The Bell distinction**

Writing `q=P(A=+1)`, `f=P(B=+1|A=+1)`, and `g=P(B=+1|A=−1)` gives

\[
E=q(2f-1)+(1-q)(1-2g).
\]

Independence from `q` with the value `2f−1` requires the complementary second
conditional `g=1−f`. The manuscript's sine/cosine example supplies it; a claim
about arbitrary updates must also carry it. The explicit counterexample uses
`q=1/2`, `f=g=0`, so neither conditional branch is a probability-zero event.

The local CHSH result assumes a finite hidden-state space, a single
setting-independent normalized nonnegative distribution, and four local ±1
response functions. Under those hypotheses Lean proves the bound 2. The
conditional sampler can prescribe a value 4, but its joint specification is
not proved to factor into those local response functions. Uniform marginals
alone do not supply that factorization. General measure-theoretic hidden-state
spaces are outside this particular formalization.

**Inputs that remain inputs**

- The graph has uniform unit couplings. Changing a physical coupling or the
  integration measure requires a new calculation; `log n` alone fixes neither.
- The cell probabilities `p/(p+1)` and `1/(p+1)` are definitions of the model.
  Their equality of gap with the graph action does not derive state preparation.
- Matching-energy paired states and diagonal local Hamiltonians are supplied.
  The finite coefficient model does not construct interacting matter.
- The horizon relations are mathematical expressions supplied to the radius
  calculation. Their algebraic compatibility does not construct a spacetime.
- A normalized Gaussian integral on the mean-zero subspace is not formalized.
  The concrete determinant theorem is complete without that integration step.
- No physical clock is calibrated by these dimensionless identities. The
  scale ambiguity is itself a proved obstruction to doing so from the state
  alone.

The package does not attempt a proof of RH, a derivation of physical forces,
the cosmological constant, a gravitational bounce, or a quantum computational
advantage. Those are unformalized claims here, not propositions declared false
because a proof tactic failed.
