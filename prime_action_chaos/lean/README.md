# Lean proofs supporting the prime action and chaos note

This subproject collects applicable existing proofs from the repository's
cycle and spectrum audits. The seven proof modules are copied unchanged;
the entry point selects their imports and adapts the two bridge theorems
to the included modular-cell naming. [provenance.json](provenance.json)
records the original repository paths, SHA-256 hashes, and adaptations.

These files formalize mathematical foundations used in the
[research note](../README.md). They do not certify the entire note or the
physical Prime Universe interpretation.

## Included proofs and their scope

| File | Applicable result | Qualification |
|---|---|---|
| [CycleProduct.lean](PrimeUniverse/CycleProduct.lean) | The roots-of-unity/sine product is `n²`; its half-logarithm is `log n`, and its reciprocal square root is `1/n`. | Primality is unnecessary. This module alone concerns a spectral product. |
| [CycleLaplacian.lean](PrimeUniverse/CycleLaplacian.lean) | The independently defined local cycle operator is Fourier diagonalized; only the constant mode has zero eigenvalue. | Identification with the ordinary simple cycle graph applies to `n ≥ 3`. |
| [CycleDeterminant.lean](PrimeUniverse/CycleDeterminant.lean) | The concrete matrix `L + J/n` has determinant `n²`; its half-logarithm is `log n`. The actual simple-graph matrix is included. | The mean projection replaces the sole zero eigenvalue with one. The local two-vertex convention has two parallel contributions. This does not derive chaotic dynamics from a graph. |
| [ModularCell.lean](PrimeUniverse/ModularCell.lean) | The cell weights normalize, its modular gap is `log p`, and its entropy is `log(p+1) − p log(p)/(p+1)`. Entropy strictly decreases for `p > 1`. | The parameter is real and need not be prime. Paired-state and complementarity results are also retained with the original module. |
| [ThermalZeta.lean](PrimeUniverse/ThermalZeta.lean) | Arithmetic thermal amplitudes have finite squared norm exactly above exponent one; prime orbit weights give the convergent Euler product. | Analytic continuation and unit-modulus phases do not normalize a divergent state. This does not prove the weighted dynamical-cycle formula or the Riemann hypothesis. |
| [ClockScale.lean](PrimeUniverse/ClockScale.lean) | Rescaling energy and inverse temperature oppositely preserves the finite Gibbs distribution. A dimensionless gap alone cannot determine energy. | A physical clock needs an additional calibration. |
| [Arithmetic.lean](PrimeUniverse/Arithmetic.lean) | Möbius divisor cancellation and the finite Euler subset expansion. | Background arithmetic; the primitive-necklace and ordered transition-determinant formulas are not formalized here. |
| [PrimeUniverse.lean](PrimeUniverse.lean) | The spectral and concrete-matrix actions both equal the specified modular-cell gap. | Equality of explicit quantities does not derive a state or a physical evolution law. |

The detailed connections appear in [THEORY.md](../THEORY.md), particularly
the cycle-action comparison, the normalizable Gibbs domain, the prime-cell
entropy correction, and the need for a separately supplied clock.

The finite Markov baker dynamics, Lyapunov/metric-entropy identities,
nonlinear invariant-density formula, Bernoulli observation limit, and
prime-grid forecast obstruction in [NONLINEAR_ACTION.md](../NONLINEAR_ACTION.md)
remain prose derivations with Python checks. The forecast benchmarks are
numerical experiments. Including foundational Lean modules does not turn
those additional results into machine-checked theorems.

## Build and audit

The project pins:

- Lean **4.34.0** in [lean-toolchain](lean-toolchain).
- Mathlib commit `5ed2965256430c3649e86755f9576b54eca72435` in
  [lakefile.toml](lakefile.toml).
- Transitive dependencies in [lake-manifest.json](lake-manifest.json).

With Elan/Lake and Python installed, run from this `lean/` directory:

```bash
lake update
python fetch_cache.py
lake build
python check.py
```

The first two commands obtain the pinned dependencies and the needed
compiled Mathlib cache; network access is required on a fresh machine.
The Python experiments in the parent folder continue to use only the
standard library and do not require Lean.

If a checkout of the exact pinned Mathlib and its compiled dependencies is
already available, the proof audit can run without fetching another copy:

```bash
python check.py --mathlib /path/to/pinned/mathlib
```

The checker verifies the compiler, Mathlib revision, and dependency
revisions; recompiles every local proof module with warnings treated as
errors; then asks Lean for every named theorem's transitive axiom
dependencies. Only `propext`, `Classical.choice`, and `Quot.sound` are
allowed. It rejects proof placeholders, unchecked native decision proofs,
and additional axioms. Mathlib dependencies use compiled library objects;
the audit does not rebuild all of Mathlib from source.

## Verification record

The packaged selection passed a fresh compilation and axiom audit on
2026-09-29: **68 named theorems**, with warnings treated as errors and
every transitive axiom dependency in the allowed set above. The independent
`lake build` invocation also completed successfully using the pinned local
dependency cache.

The local run's [verification.json](verification.json) records the theorem
inventory, per-theorem axioms, compiler version, source hashes, and
configuration hashes. The [compilation log](verification.compile.log) and
[axiom log](verification.axioms.log) are retained beside it. Re-running
`check.py` refreshes the receipt for the supplied environment.

Keep the source, lockfile, provenance, and receipts when sharing this
folder. The local `.gitignore` permits those JSON/log files even if a
parent repository excludes them. Build products and dependency caches in
`build/` and `.lake/` are excluded from the distributable package.

The [MIT license](LICENSE) is retained from the originating proof package.
