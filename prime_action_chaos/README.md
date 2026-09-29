# Prime action and deterministic chaos

An ideas-folder research package connecting arithmetic action, symbolic
dynamics, and the information available to a forecast.

**Status, 2026-09-29:** Exact mathematical constructions and reproducible
synthetic benchmarks. Useful temporal structure is measured; a forecasting
advantage specific to the tested prime-odds model is not supported. A
physical mechanism selecting prime dynamics remains open.

## The question

Could an apparently chaotic trajectory be organized by an underlying flow
that the usual observation does not reveal? Deterministic dynamics already
allows that possibility. The sharper questions are what information the
observation discards, how much ordered history can recover, and whether
the prime representation adds anything predictive.

This package grew out of the Prime Universe manuscript. It stands alone:
neither the manuscript nor the originating model-inference repository is
required to read the proofs or run the experiments. References to chapter
numbers in `THEORY.md` describe that history, not dependencies. The folder
can be copied into another repository as `ideas/prime_action_chaos/`.

## What survived the investigation

- **An exact arithmetic realization.** Integer Fourier dilation satisfies
  $[K_0,U_m]=(\log m)U_m$ and realizes the expanding circle map
  $x\mapsto mx\bmod1$. Prime factors are irreducible generators of the
  dilation semigroup; composite factors also produce chaos.
- **An action/entropy construction.** A chosen full-branch realization
  of spectral weights $w_n$ has local action $-\log w_n$ and mean
  stretching equal to their Shannon entropy. For an ordered finite Markov
  realization, the rate is conditional entropy rather than marginal
  entropy. The same stationary state admits different flows.
- **An exact nonlinear correction.** For an interval map with an
  invariant density, local stretching equals inverse-branch information
  plus a density boundary term. This explains why the relation survives
  nonlinear coordinate changes while local slopes cease to be constant.
- **An observation-specific limit.** Logistic dynamics at parameter four
  is fully deterministic, but its past threshold labels cannot predict
  the next label better than a fair coin under the invariant measure.
  An exact coordinate contains information absent from that label history.
- **A falsifiable prime test.** Ordinary conditional models find predictive
  structure in logistic parameter 3.9 and Lorenz return labels. The tested
  prime-odds restriction loses to ordinary controls on those runs.

These results connect existing mathematics to the manuscript and constrain
its interpretation. They are not presented as newly discovered entropy
theorems or a proof that nature follows a prime generator. Primary sources
and complete assumptions accompany the derivations in
[THEORY.md](THEORY.md) and [NONLINEAR_ACTION.md](NONLINEAR_ACTION.md).

## The central identity

For an invariant density $\rho$, define the probability of an inverse
branch by $q(x\mid y)=\rho(x)/(|f'(x)|\rho(y))$, with $y=f(x)$. Then

$$
\log |(f^N)'(x_0)|
=\sum_{k=0}^{N-1}-\log q(x_k\mid x_{k+1})
+\log\rho(x_0)-\log\rho(x_N).
$$

The sum describes how an infinitesimal uncertainty is stretched along the
orbit. It is a dimensionless information action. A physical action and
clock require an additional dynamical derivation. This identity alone
does not infer the unknown map or reveal an unmeasured initial state.

For forecasting, the relevant separate identity is

$$
\mathbb E[-\log\widehat p(Y\mid C)]
=H(Y\mid C)+\mathbb E_C D_{\rm KL}(p\Vert\widehat p).
$$

The best possible improvement over a marginal-only forecast is the
mutual information between future label $Y$ and available history $C$.
This gives the original intuition an operational test: identify an
observable or transition rule that exposes additional predictive
information, then measure its value on withheld futures.

## External results

The protocol was written before the full benchmark. Models receive only
past binary labels. They fit training data, select history depth on
validation data, and score chronological test data. Each grid has 75
probability values with the same range; the nonprime control uses uniform
spacing in log odds. Numbers below are means of the three specified runs
per system. Lower log loss is better.

| System | Marginal loss | Ordinary history | Prime odds | Nonprime grid |
|---|---:|---:|---:|---:|
| Logistic 4.0 | 0.693186 | 0.693186 | 0.693147 | 0.693147 |
| Logistic 3.9 | 0.683175 | 0.504589 | 0.507685 | 0.505377 |
| Lorenz return labels | 0.693342 | 0.682077 | 0.690229 | 0.681749 |

The ordinary history model reduces one-step log loss by **26.1%** for
logistic 3.9 and **1.62%** for Lorenz, averaged over the specified runs.
There is no memory gain for the exact Bernoulli control. Both grids tie
there by choosing 1/2; their small improvement over an estimated marginal
is not specific to primes.

The tested prime grid contains no probability between 1/2 and 2/3.
An exact calculation shows that log-loss fitting rounds every probability
from approximately 0.4150 to 0.5850 to 1/2. That erases weak predictive
biases. This obstruction remains if the maximum prime is increased, but
does not rule out different arithmetic models using compositions or
mixtures.

Read [BENCHMARK_RESULTS.md](BENCHMARK_RESULTS.md) for per-run scores,
uncertainty, matched-depth controls, horizon curves, integrator checks,
the disclosed numerical-test adjustment, and limitations. In particular,
Lorenz's small gains vary by run; the return-sign partition is not proved
generating. These are forecasts of label probabilities, and their advantage
largely disappears at longer horizons.

## Reproduce

For the Python experiments, use Python 3.10 or newer; the recorded run used
**Python 3.14.4**. They use only the standard library. No dependency
installation, credentials, network, or access to the original repository
is required. The optional Lean proof subproject has separate requirements
described below.

From this folder:

```bash
python audit.py --json-output /tmp/prime_action_audit.json
python tests.py
python report.py --check
python benchmark.py --output /tmp/prime_action_benchmark.json
```

The first three commands verify the constructions, forecasting logic,
and recorded report. The final command regenerates all nine benchmark
cases. It integrates more than three million Lorenz RK4 steps, so allow
longer than for the algebraic checks. For a smaller implementation check,
use `python benchmark.py --quick --output /tmp/prime_action_smoke.json`;
its results are not the reported full benchmark.

Paths under `/tmp` can be replaced with any writable output location.
Long chaotic floating-point trajectories can differ across environments;
do not interpret a different trajectory hash as a physical discrepancy.
The hashes identify this recorded implementation and run. The analysis
concerns reproducible statistical patterns and explicit algebraic checks.

## Applicable Lean proofs

The [lean/ subproject](lean/README.md) includes seven existing proof
modules and their entry point, covering cycle determinants and logarithmic
action, modular-cell entropy, arithmetic thermal normalization and Euler
products, clock-scale ambiguity, and supporting Möbius arithmetic. It pins
Lean and Mathlib, records source provenance, and includes a reproducible
compilation and axiom audit.

These are formal foundations for parts of `THEORY.md`. The newer
nonlinear-chaos identities and forecast results retain the proof and
numerical status stated in their own documents; they are not yet
formalized by these Lean files. See the [coverage table](lean/README.md)
and [verification receipt](lean/verification.json) for the exact scope.

## Files

| File | Purpose |
|---|---|
| [THEORY.md](THEORY.md) | Arithmetic operators, reversible branch maps, ordered cycle determinants, proofs, and sources |
| [NONLINEAR_ACTION.md](NONLINEAR_ACTION.md) | Density correction, deterministic observation limit, forecast identity, prime-grid obstruction |
| [PROTOCOL.md](PROTOCOL.md) | Questions, observations, data splits, models, metrics, and interpretation fixed before the benchmark |
| [BENCHMARK_RESULTS.md](BENCHMARK_RESULTS.md) | Generated report with all run summaries and limitations |
| [audit.py](audit.py) | Exact rational and numerical checks of the arithmetic constructions |
| [benchmark.py](benchmark.py) | Independent logistic/Lorenz data generation and causal forecasting |
| [tests.py](tests.py) | Independent path enumeration, information-access checks, and nonlinear identities |
| [report.py](report.py) | Regenerate or verify the report against stored results and source/protocol hashes |
| [results/audit.json](results/audit.json) | Recorded algebraic audit |
| [results/benchmark.json](results/benchmark.json) | Full metrics, validation curves, selected parameters, training counts, and hashes |
| [lean/README.md](lean/README.md) | Applicable Lean proofs, pinned build configuration, coverage, provenance, and verification receipts |
| [LICENSE](LICENSE) | MIT license retained from the originating repository |

The local `.gitignore` permits the result JSON files even when a parent
repository ignores JSON generally. Keep them with the code and documents
when copying this folder. The equations are written as GitHub math blocks.

## What would constitute the next advance?

Derive an ordered transition operator and an observation map from the
system, including its clock. Demonstrate that an arithmetic representation
predicts held-out transitions, return times, or state observables better,
or with a shorter description, than suitable nonarithmetic controls with
the same input information. A generating partition would make the relation
to full dynamical entropy sharper; its existence must not be assumed from
a match between two fitted numbers.

The present evidence does not justify a claim of solving chaos, the
three-body problem, the Riemann hypothesis, or the missing physical
generator. It does justify sharing a focused research idea with exact
statements, executable checks, and a negative result that rules out one
tempting shortcut.
