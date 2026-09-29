# From a cycle graph to logarithmic action: a Lean audit

A self-contained mathematical note inspired by selected claims in
`PRIME_UNIVERSE_THEORY.md`. The main result connects an actual cycle graph
Laplacian to a logarithmic action and the gap of a specified two-level modular
state. It also records exact complementarity identities, paired-clock
identities, and proved limits on Bell locality and clock calibration.

The package contains **84 named theorems**, with the full inventory and axiom
dependencies recorded in the verification receipt below.

This is suitable for an **ideas / formalization** repository. The accepted
statements certify mathematical consequences of explicit definitions and
assumptions. They do not validate the manuscript's proposed physical theory.
The mathematics used here is established; this package claims no new discovery
of the cycle spectrum, Fourier transform, Möbius identity, or CHSH inequality.

**The main result**

Let `L` be the ordinary graph Laplacian of the cycle on `n ≥ 3` vertices, and
let `J` be the matrix with every entry equal to one. Lean proves

\[
\boxed{\det\left(L+\frac{1}{n}J\right)=n^2.}
\]

The proof starts from the local rule

\[
(Lv)_j=2v_j-v_{j+1}-v_{j-1},
\]

with indices taken modulo `n`. It then proves that the invertible discrete
Fourier transform diagonalizes this operator. The eigenvalues are

\[
\lambda_k=2-e^{2\pi i k/n}-e^{-2\pi i k/n}
          =|1-e^{2\pi i k/n}|^2.
\]

Only `k=0` has eigenvalue zero, and the operator's kernel consists exactly of
constant vectors. The matrix `J/n` is the projection onto those constants.
Adding it replaces the single zero eigenvalue with one and preserves the
remaining eigenvalues. The determinant therefore equals the product of the
nonzero eigenvalues of `L`, often called its *pseudodeterminant*.

The implementation uses complex matrices and proves that the determinant is
the positive real number `n²`. It does not define the matrix determinant to be
the desired spectral product: their equality follows from Fourier conjugation
and matrix determinant theorems.

Consequently,

\[
\frac12\log\det\left(L+\frac1nJ\right)=\log n.
\]

For the explicitly specified two-level probabilities
`r₀=n/(n+1)` and `r₁=1/(n+1)`, Lean independently proves

\[
(-\log r_1)-(-\log r_0)=\log n.
\]

The [entry-point bridge theorem](PrimeUniverse.lean) equates these two
quantities. That is a concrete mathematical connection worth retaining from
Chapters 146 and 149. A dynamical mechanism producing the two-level state
from the graph remains to be supplied. The construction works for composite
`n` as well; the explicit `n=4` determinant is 16. It cannot select primes by
itself.

**Other checked results**

| Construction | Result | Scope |
|---|---|---|
| Two-level modular cell | `P²+V²=1`; increasing population predictability; decreasing visibility, variance, and entropy for `p>1` | The probabilities are specified, and the parameter need not be prime. |
| Matching-energy paired state | The difference generator annihilates the state; the sum generator doubles its energy labels | Finite diagonal generators; a nonstationary sum-clock state requires occupied unequal energies. |
| Möbius cancellation | The divisor sum of `μ` is one at 1 and zero elsewhere | Established arithmetic, with no identification of arithmetic with physical energy. |
| Finite Euler expansion | A product of `K` factors `1+w` expands over `2^K` subsets | The expansion does not provide arbitrary independent quantum amplitudes. |
| Reciprocal radius map | `R ↦ q/R` is an order-reversing positive involution with unique positive fixed point `√q` | The horizon formulas used in the additional algebraic identity are supplied assumptions. |
| Gibbs scale ambiguity | Scaling all energies by `λ` and inverse temperature by `1/λ` preserves every probability | The state does not determine an absolute energy or time calibration. |
| Conditional Bell sampler | Complementary conditional probabilities give the cosine correlation; a finite local hidden-state model obeys `|CHSH|≤2` | Prescribing a setting-dependent joint sampler is not a local implementation. |

The Bell audit includes a counterexample with both conditioning events having
positive probability. For `q=P(A=+1)=1/2` and both conditional probabilities
`P(B=+1|A=±1)=0`, the actual correlation is zero. A formula using only the
first conditional would incorrectly give −1. The second conditional matters.

See [CLAIMS.md](CLAIMS.md) for source anchors, theorem names, and remaining
gaps. A proof attempt failing is not evidence that a proposition is false;
the negative results here are proved counterexamples or impossibility
statements.

**Read the proof**

1. [CycleLaplacian.lean](PrimeUniverse/CycleLaplacian.lean): local operator,
   graph identification, Fourier diagonalization, and the sole zero frequency.
2. [CycleDeterminant.lean](PrimeUniverse/CycleDeterminant.lean): constant-mode
   projection, exact kernel, concrete matrix determinant, and graph theorem.
3. [CycleProduct.lean](PrimeUniverse/CycleProduct.lean): root-of-unity product
   and its sine-product form.
4. [ModularCell.lean](PrimeUniverse/ModularCell.lean) and
   [PrimeUniverse.lean](PrimeUniverse.lean): the state family and the final bridge.

The other modules are independently readable. All local modules are imported
by the entry point and covered by the verifier.

**Reproduce**

Install [elan](https://github.com/leanprover/elan), Python 3.10 or later, and
Git. From this folder:

```bash
python3 fetch_cache.py
lake build
python3 check.py
```

The first command needs network access. It asks Lake to use the committed
lockfile and fetch the mathlib caches for this package's imports. Lean is
pinned to **4.34.0** and mathlib to
`5ed2965256430c3649e86755f9576b54eca72435`; the dependency lockfile is included.

An existing, cached mathlib checkout at that exact revision also works:

```bash
python3 check.py --mathlib /absolute/path/to/mathlib
```

`check.py` rebuilds every local Lean module in dependency order with warnings
treated as errors. It rejects proof placeholders and custom axiom declarations,
runs `#print axioms` on every named theorem, and permits only `propext`,
`Classical.choice`, and `Quot.sound`. These are ordinary Lean foundations;
none is a postulate of the proposed physical theory. The verifier checks
dependency revisions and records source, configuration, and log hashes.
Imported mathlib uses cached compiled objects; the audit does not rebuild all
of mathlib from source.

The checked inventory and count are in [verification.json](verification.json).
The [compile log](verification.compile.log) and
[per-theorem axiom log](verification.axioms.log) are included. The theorem count
includes supporting lemmas, standard-theorem applications, and counterexamples;
it is not a count of independent discoveries.

`python3 check.py --only CycleDeterminant --mathlib /path/to/mathlib` is a
development command: it compiles that module and its local dependencies, but
does not issue a full verification receipt.

**Sharing and next steps**

Copy this entire folder into an `ideas/` directory. It contains the sources,
configuration, pinned lockfile, verifier, proof receipts, provenance, and MIT
license. Build products, dependency caches, and the large manuscript are not
required. [PROVENANCE.md](PROVENANCE.md) records the originating document and
distinguishes established mathematics from the proposed interpretation.

The next mathematical extension could formalize the normalized Gaussian
integral and its measure on the mean-zero subspace. The next physical step
would require an independently justified coupling, measure, state preparation,
and clock calibration. None of those inputs follows merely from the determinant
identity.
