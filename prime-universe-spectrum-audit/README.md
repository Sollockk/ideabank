# Prime Universe: spectral action and its limits

A Lean 4 research note testing ambitious mathematical claims from
*The Prime Universe: A Theory of Everything from μ(1) = +1*.
The central chain is

**cycle spectrum → logarithmic action → modular cell → thermal response**,

alongside precise obstructions to the proposed Bell, critical-line thermal,
clock-calibration, and cosmological interpretations. The folder is a standalone
Lake project and can be copied into another repository's `ideas/` directory.
The original manuscript is not needed to build it.

**Verified 2026-09-29.** The package contains **88 locally declared theorems**, including supporting
lemmas and negative results. It carries forward the original 57-theorem audit
and adds 31 theorems on heat capacity, certified logarithm bounds, and the
geometric response of a determinant. The compilation and axiom-audit result is
recorded in [`verification.json`](verification.json); the accompanying
[compiler log](verification.compile.log) and [axiom log](verification.axioms.log)
are part of the evidence. A conventional `lake build` also passed in a fresh
temporary copy using the pinned cached dependencies; its output is recorded in
[`verification.lake.log`](verification.lake.log).

## The strongest new positive result: 11 wins without a primality assumption

For the two-level family with energy gap `log(p)`, Chapter 149 gives the
dimensionless heat capacity

\[
C(p)=\frac{p(\log p)^2}{(p+1)^2}.
\]

[`HeatCapacity.lean`](PrimeUniverse/HeatCapacity.lean) first defines the canonical
mean energy for levels `0` and `E`,

\[
U_E(\beta)=\frac{E}{1+e^{\beta E}},
\]

and proves that `-U_E'(1) = C(p)` when `E=log(p)` and `p>0`.
The energy gap is held fixed in that thermal derivative. The subsequent
derivative with respect to `p` compares members of the family.

Lean then proves the stronger statement

\[
\boxed{n\in\mathbb N,\quad n\ge2,\quad n\ne11
\quad\Longrightarrow\quad C(n)<C(11).}
\]

The theorem `eleven_unique_integer_maximum` is not a finite numerical scan.
Its proof combines:

- strict increase on `(1,11]`;
- strict decrease on `[12,∞)`;
- the certified comparison `C(12)<C(11)`.

[`LogBounds.lean`](PrimeUniverse/LogBounds.lean) supplies rational inequalities
from finite sums and a proved remainder bound for the logarithm. Floating-point
evaluation is not used. The prime-only claim follows immediately in
`eleven_unique_prime_maximum`.

The file also proves `C'(11)>0`. Thus 11 is the integer maximizer, while the
continuous maximum lies elsewhere. The exact location and uniqueness of that
continuous maximum are not formalized here.

**Interpretation:** Chapter 149's stated prime-11 result survives. The stronger
theorem shows that primality is unnecessary for this winning integer label.
This is a property of the specified two-level response, not a derivation of
a new force or a universal physical constant. The manuscript itself identifies
the response as the ordinary Schottky peak.

## The strongest new obstruction: determinant weight is not scale response

[`CycleSpectrum.lean`](PrimeUniverse/CycleSpectrum.lean) constructs the finite
Fourier modes of an `n`-cycle, proves that they form a complete basis, and checks
their cyclic Laplacian eigenvalues. Exactly one mode is zero, and the product
of the remaining eigenvalues is `n²`. Consequently, half its logarithm is
`log(n)`. This holds for composite lengths as well as prime lengths.

[`DeterminantResponse.lean`](PrimeUniverse/DeterminantResponse.lean) continues
from those actual eigenvalues. It divides each nonzero eigenvalue by
`(a μ)²`, where `a>0` is the physical scale and `μ>0` the reference scale.
The half-logarithm of that product is proved to be

\[
\frac{\Gamma_n(a)}{\hbar}
=\log n-(n-1)(\log a+\log\mu).
\]

Differentiating the spectral product's action gives

\[
\boxed{a\frac{d(\Gamma_n/\hbar)}{da}=-(n-1).}
\]

The finite `log(n)` term has zero derivative with respect to size. Changing the
reference scale changes the action by a constant in `a`, so it leaves this
response unchanged. A finite-family theorem adds the individual mode counts.

[`PrimeCutoff.lean`](PrimeUniverse/PrimeCutoff.lean) proves
`157 < 16π² < 158`, and proves that the primes selected by this geometric
cutoff are exactly the primes below 158. The factor `16π²` is the specified
input; its physical selection is not derived.

For all primes below 158, Lean checks a count of **37** and a total of **2547**
nonzero modes. The manuscript reserves the primes 2 and 3; its seam therefore
contains **35** primes and **2544** nonzero modes. The seam's dimensionless
logarithmic scale response is exactly **−2544**. These finite computations use
Lean's kernel-checked `decide`. The exclusion of 2 and 3 is a specified modeling
choice, not a consequence of the determinant calculation.

**Interpretation:** the manuscript's proposed finite determinant normalization
does not by itself supply the asserted cosmological curvature. In this scaling
model the response is controlled by the number of modes. The formal theorem
is a derivative under uniform scaling; it does not construct a covariant
stress tensor or rule out every possible gravitational embedding.

## What else is checked

| Thread | Formal result | Remaining qualification |
|---|---|---|
| Cycle action, Chapters 146–147 | A complete Fourier basis, the nonzero spectral product `n²`, and action `log(n)` | No rule selecting prime cycles; no Gaussian quotient integral is formalized. Length two uses the double-edge convention. |
| Modular cells, Chapters 145 and 149 | A normalized entangled paired state, explicit partial trace, modular gap `log(p)`, `P²+V²=1`, and decreasing entropy | The state is constructed. A horizon or cycle has not been shown to generate it dynamically. |
| Counteracted time | The difference generator annihilates the paired state; the sum generator is not merely a common phase when the gap and both amplitudes are nonzero | These are finite state-vector statements. They do not establish a new physical time dimension. |
| Thermal/zeta bridge | The infinite prime orbit product equals zeta in `Re(s)>1`; the arithmetic thermal amplitudes are square summable exactly when their real exponent exceeds 1 | Nonzero finite rescaling and arbitrary unit-modulus phases cannot normalize the critical-line family. Finite Euler products are nonzero in `Re(s)>0`. |
| Bell correlation, Chapters 59 and 85 | The conditional update gives `−cos(angle)` and CHSH `2√2`; allowing other updates permits value 4; finite local mixtures satisfy CHSH `≤2` | The update uses both settings. Bob's marginal is independent of every allowed update parameter exactly when the effective initial bias is `1/2`. |
| Conformal pulse, Chapter 140 | Flat endpoint slopes imply `∫(S''+κ(S')²)=κ∫(S')²`, strictly positive for a nontrivial continuous slope and `κ>0` | An explicit profile has negative source at its center but positive total source. This does not construct a complete smooth spacetime. |
| Clock calibration, Chapter 150 | Rescaling energy and inverse temperature inversely preserves every finite Gibbs probability; the normalized state alone cannot recover all physical temperatures | A geometric or other physical calibration is still required. |
| Horizon action, Chapters 134 and 143 | Positive-radius inversion, exchange of the stipulated energy branches, inherited-action seed algebra, and the stipulated free-action/entropy equality | The energy, period, and Schwarzschild identifications are premises. Einstein's equation and a physical seam are not derived. |

The entry point [`PrimeUniverse.lean`](PrimeUniverse.lean) adds two cross-chapter
equalities connecting the actual cycle action to the modular gap and to the
arithmetic Boltzmann weight. Equal numerical gaps alone do not prove a common
dynamical origin.

## Reproduce

Prerequisites: Git, Python 3, and Lean's
[`elan` toolchain manager](https://github.com/leanprover/elan).
The files pin **Lean 4.34.0** and mathlib commit
**`5ed2965256430c3649e86755f9576b54eca72435`**, with a dependency lock file.

Run inside this folder:

```sh
lake update
python3 fetch_cache.py
python3 check.py
```

`fetch_cache.py` downloads mathlib's compiled cache for the imported modules
and their dependencies. `lake exe cache get` is an alternative if the complete
mathlib cache is wanted. Dependency downloads require network access.

The ordinary Lake build is also available:

```sh
lake build
```

For an existing standalone mathlib checkout at the pinned revision, with its
dependencies and compiled cache already present:

```sh
python3 check.py --mathlib /absolute/path/to/mathlib
```

For development, `python3 check.py --only HeatCapacity` builds that module and
its local imports. This does **not** produce a complete axiom audit; use the
full command before reporting a verified package.

## What the verification means

The complete checker removes local compiled objects, builds local modules in
dependency order with warnings treated as errors, inventories every locally
declared theorem, and runs `#print axioms` on each theorem. It rejects proof
placeholders, custom axiom declarations, and native decision shortcuts. The
only permitted foundational axioms are `propext`, `Classical.choice`, and
`Quot.sound`, the usual Lean/mathlib foundations.

The JSON report records source hashes, configuration hashes, dependency
revisions, the compiler version, the checker hash, and per-theorem axiom lists.
The build uses pinned compiled mathlib objects; it does not rebuild the entire
imported library from source. Source-to-formula translation is a manual review
step, not an automatic guarantee provided by Lean.

A passing theorem certifies its displayed statement under its definitions
and hypotheses. These results do not prove RH, a cosmological constant, a
physical bounce, or the manuscript's full theory. Nor does the absence of a
proof here refute a claim that was not formalized. The useful outcome is a
precise mathematical core and explicit places where extra physics is needed.

## Provenance and dependencies

[`SOURCE_NOTES.md`](SOURCE_NOTES.md) maps the claims to manuscript chapters and
records interpretation choices. [`provenance.json`](provenance.json) identifies
the original manuscript snapshots by SHA-256. The 57 original proofs are
preserved from the preceding audit; this continuation adds four proof modules.

Much of the underlying mathematics is established. In particular, the project
uses mathlib's
[`IsPrimitiveRoot.prod_one_sub_pow_eq_order`](https://github.com/leanprover-community/mathlib4/blob/5ed2965256430c3649e86755f9576b54eca72435/Mathlib/RingTheory/RootsOfUnity/Lemmas.lean),
[`Matrix.det_vandermonde_ne_zero_iff`](https://github.com/leanprover-community/mathlib4/blob/5ed2965256430c3649e86755f9576b54eca72435/Mathlib/LinearAlgebra/Vandermonde.lean),
the [proved logarithm bounds](https://github.com/leanprover-community/mathlib4/blob/5ed2965256430c3649e86755f9576b54eca72435/Mathlib/Analysis/SpecialFunctions/Log/Deriv.lean),
the [p-series summability theorem](https://github.com/leanprover-community/mathlib4/blob/5ed2965256430c3649e86755f9576b54eca72435/Mathlib/Analysis/PSeries.lean),
and the [Riemann zeta Euler product](https://github.com/leanprover-community/mathlib4/blob/5ed2965256430c3649e86755f9576b54eca72435/Mathlib/NumberTheory/EulerProduct/DirichletLSeries.lean).
These are credited dependencies, not new discoveries claimed by this project.

The folder retains the host repository's [MIT license](LICENSE). Imported
dependencies retain their own licenses; mathlib is Apache-2.0. Build outputs
and local dependency links are excluded by `.gitignore`.
