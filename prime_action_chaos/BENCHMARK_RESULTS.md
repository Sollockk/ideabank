# Recorded external benchmark results

Generated from [results/benchmark.json](results/benchmark.json) by
[report.py](report.py). Protocol and benchmark source hashes are verified
before rendering. This report does not select new models or rerun fitting.

**Result:** Past binary observations improve one-step forecasts for
logistic parameter 3.9 and give a smaller improvement for Lorenz return
labels. Restricting the conditional odds to the tested prime-cell values
does not improve prediction. It performs worse than both controls in all
six runs with temporal structure; uncertainty varies by run.

## Design and scope

The [protocol](PROTOCOL.md) was specified before the full run on
2026-09-29. Six logistic trajectories each supply 100,000 symbols, split
60,000 / 20,000 / 20,000 into chronological training / validation / test
sets. Three Lorenz trajectories each supply 10,000 return labels, split
6,000 / 2,000 / 2,000. Models observe only past binary labels.

All models choose context depth from 0 through 10 by validation loss.
Their probabilities are fit on training data only. The prime-odds and
nonprime grids both have 75 values and the same probability range.
The nonprime grid is uniformly spaced in log odds; its endpoints and
neutral value intentionally coincide with the prime grid. Its defining
spacing does not use the intervening primes.

The recorded run used Python 3.14.4 and the standard library only.
Floating-point chaotic trajectories can differ across platforms and
evaluation orders. Data hashes identify this run; statistical replication
is more meaningful than requiring long trajectories to agree pointwise.
The protocol is a local record, not an independently timestamped public
preregistration. These are synthetic dynamical benchmarks, not laboratory
measurements or a comprehensive comparison with forecasting methods.

## One-step test loss

Loss is in nats per observed label; lower is better. Each cell in the
first table is an unweighted mean of the three specified runs. The Lorenz
mean combines two initial conditions and a step-refinement run; it is not
a confidence estimate from three independent experimental replicates.

| System | Marginal baseline | Continuous history | Prime odds | Nonprime grid | Relative history gain |
|---|---:|---:|---:|---:|---:|
| Logistic 4.0 | 0.693186 | 0.693186 | 0.693147 | 0.693147 | 0.00% |
| Logistic 3.9 | 0.683175 | 0.504589 | 0.507685 | 0.505377 | 26.14% |
| Lorenz returns | 0.693342 | 0.682077 | 0.690229 | 0.681749 | 1.62% |

The full per-run results prevent a favorable mean from hiding a failed run.

| Run | Marginal | Continuous | Prime odds | Nonprime grid | Selected depths: continuous / prime / grid |
|---|---:|---:|---:|---:|---|
| Logistic 4.0, x0=0.123456789 | 0.693154 | 0.693154 | 0.693147 | 0.693147 | 0 / 0 / 0 |
| Logistic 4.0, x0=0.314159265 | 0.693240 | 0.693240 | 0.693147 | 0.693147 | 0 / 0 / 0 |
| Logistic 4.0, x0=0.271828182 | 0.693164 | 0.693164 | 0.693147 | 0.693147 | 0 / 0 / 0 |
| Logistic 3.9, x0=0.123456789 | 0.682577 | 0.505676 | 0.508954 | 0.506662 | 10 / 10 / 10 |
| Logistic 3.9, x0=0.314159265 | 0.683161 | 0.504314 | 0.508556 | 0.505057 | 10 / 10 / 10 |
| Logistic 3.9, x0=0.271828182 | 0.683788 | 0.503777 | 0.505546 | 0.504411 | 10 / 10 / 10 |
| Lorenz x0=1.0, dt=0.01 | 0.693277 | 0.677371 | 0.688387 | 0.677086 | 5 / 6 / 5 |
| Lorenz x0=1.001, dt=0.01 | 0.693265 | 0.686257 | 0.696033 | 0.685719 | 2 / 2 / 2 |
| Lorenz x0=1.0, dt=0.005 | 0.693483 | 0.682603 | 0.686268 | 0.682443 | 3 / 3 / 3 |

All logistic-4 models select depth zero. Both grids return exactly 1/2,
so they tie. Their slight advantage over the fitted marginal frequency
is shared shrinkage to the true fair-bit probability, not evidence for
primes. All logistic-3.9 models select the maximum tested depth, ten; the
experiment does not establish that ten is sufficient or optimal among
longer contexts.

## Paired loss differences

Each entry gives mean difference [descriptive approximate 95% interval].
Negative favors the first model named. Intervals use contiguous block
means, with 20 blocks for each logistic run and 10 for each Lorenz run.
They are normal approximations, not independence guarantees or adjusted
tests across all comparisons. The refined Lorenz run's prime-versus-grid
interval includes zero; its point estimate is still unfavorable to primes.

| Run | Continuous minus marginal | Prime minus continuous | Prime minus nonprime grid |
|---|---:|---:|---:|
| Logistic 3.9, x0=0.123456789 | -0.176901 [-0.183593, -0.170208] | +0.003277 [+0.002002, +0.004552] | +0.002292 [+0.001031, +0.003553] |
| Logistic 3.9, x0=0.314159265 | -0.178847 [-0.186255, -0.171438] | +0.004242 [+0.003108, +0.005376] | +0.003499 [+0.002332, +0.004666] |
| Logistic 3.9, x0=0.271828182 | -0.180011 [-0.186190, -0.173832] | +0.001769 [+0.000993, +0.002545] | +0.001135 [+0.000380, +0.001890] |
| Lorenz x0=1.0, dt=0.01 | -0.015906 [-0.024299, -0.007512] | +0.011016 [+0.008582, +0.013450] | +0.011301 [+0.008837, +0.013764] |
| Lorenz x0=1.001, dt=0.01 | -0.007008 [-0.016873, +0.002857] | +0.009776 [+0.003935, +0.015617] | +0.010314 [+0.004441, +0.016188] |
| Lorenz x0=1.0, dt=0.005 | -0.010880 [-0.021273, -0.000487] | +0.003665 [-0.000600, +0.007930] | +0.003825 [-0.000628, +0.008277] |

## Quantization at the same context depth

Both grids below use the continuous model's selected context depth. This
removes a possible explanation based only on different selected depths.
For logistic 3.9 these coincide with the main table because every model
selects ten. The matched controls remain unfavorable to the prime grid.

| Lorenz run | Depth | Continuous | Prime at same depth | Nonprime at same depth |
|---|---:|---:|---:|---:|
| Lorenz x0=1.0, dt=0.01 | 5 | 0.677371 | 0.686285 | 0.677086 |
| Lorenz x0=1.001, dt=0.01 | 2 | 0.686257 | 0.696033 | 0.685719 |
| Lorenz x0=1.0, dt=0.005 | 3 | 0.682603 | 0.686268 | 0.682443 |

## Forecast horizon

These are rolling forecasts of the label at the indicated horizon. The
model propagates its own distribution between origin and target without
receiving intervening observations. A later forecast origin can use the
past newly observed by that origin. This is not exact future trajectory
reconstruction or a claim of predicting all intervening symbols.

The table shows the continuous history model's mean test loss. Horizon
units are map iterations or Lorenz return events, not a shared physical
second. All model and Brier-score curves are retained in the JSON.

| System | 1 | 2 | 4 | 8 | 16 | 32 | Marginal at 1 |
|---|---:|---:|---:|---:|---:|---:|---:|
| Logistic 4.0 | 0.693186 | 0.693186 | 0.693186 | 0.693187 | 0.693187 | 0.693187 | 0.693186 |
| Logistic 3.9 | 0.504589 | 0.556505 | 0.650289 | 0.675843 | 0.683172 | 0.683168 | 0.683175 |
| Lorenz returns | 0.682077 | 0.690563 | 0.693085 | 0.693364 | 0.693353 | 0.693334 | 0.693342 |

The history advantage largely disappears with horizon. The measured
temporal structure improves near-term probability forecasts; it does not
remove the unpredictability associated with incomplete state information.

## Post-benchmark explanation of the prime-grid failure

The [exact derivation](NONLINEAR_ACTION.md) shows that the nearest allowed
prime-odds values to 1/2 are 1/3 and 2/3. Cross-entropy quantization maps
every probability between 0.415037499 and 0.584962501 to 1/2. This interval
cannot be filled by increasing the maximum prime in this model.

The following diagnostic was added after seeing the benchmark. It uses
training counts and the already selected continuous probabilities; it
did not change the protocol, models, or held-out scores. The fraction is
training-context mass whose fitted probabilities fall in this interval,
not the mass of known true conditional probabilities.

| Lorenz run | Training-context mass rounded to neutral odds |
|---|---:|
| Lorenz x0=1.0, dt=0.01 | 59.70% |
| Lorenz x0=1.001, dt=0.01 | 42.47% |
| Lorenz x0=1.0, dt=0.005 | 66.21% |

This supplies a specific approximation error mechanism. It does not
exclude mixtures, products, or other dynamical uses of primes that were
not tested. Allowing those models would require a new fixed protocol and
appropriate complexity controls.

## Dynamics and numerical checks

The logistic finite-time Lyapunov exponents are about 0.69313–0.69315
at parameter 4 and 0.49524–0.49554 at 3.9, in nats per iteration. No
logistic machine state repeated within any recorded trajectory. That
check does not turn finite-precision arithmetic into an exact real orbit.

The Lorenz equations and their motivation originate in
[Lorenz (1963), Deterministic Nonperiodic Flow](https://samizdat.co/works/do-while/lorenz-1963.pdf).
The following values are results of this implementation, not values
quoted from that paper.

| Lorenz run | Tangent exponent / time | Mean return time | Product |
|---|---:|---:|---:|
| Lorenz x0=1.0, dt=0.01 | 0.905483 | 0.751055 | 0.680068 |
| Lorenz x0=1.001, dt=0.01 | 0.904859 | 0.750874 | 0.679435 |
| Lorenz x0=1.0, dt=0.005 | 0.905471 | 0.751211 | 0.680200 |

The similar tangent rates under step refinement support numerical
consistency. The return-sign partition is not proved generating, so the
product in the last column must not be identified with forecast loss or
a verified metric-entropy estimate.

The RK4 short-time refinement error ratio is 16.929983
at time 0.5, near the fourth-order expectation of 16. The independently
checked tangent derivative has residual 6.7e-10.
The nonlinear action identity's maximum residual is 4.68e-11
over 999 interior points.

Before the full benchmark, the short-time integrator check was moved
from time 2 to time 0.5 after its endpoint error ratio failed the chosen
8–24 check window. This is disclosed as numerical-test development; the
benchmark equations, steps, initial states, observations, splits, models,
and scoring protocol were not adjusted in response to forecast results.

## Reproduce or inspect

```bash
python tests.py
python report.py --check
python benchmark.py --output /tmp/prime_action_benchmark.json
```

The tests compare multi-step forecasts with direct path enumeration,
change test futures to check that model selection and fitted parameters
remain fixed, check each origin's information access, verify exact
Bernoulli cylinder widths, and check the grid obstruction. The separate
`audit.py` covers the earlier arithmetic and reversible constructions.

Recorded source SHA-256: `8025fc26f9ed6f9961e601a1cd6a5054d48fe44d0b860488bcb9a1fa765190a3`.

Recorded protocol SHA-256: `a4d79746329da1b172a22a45ea0480c5072fecd0dffb66c225193fa2df8ca7a6`.

**Interpretation:** This is evidence for ordinary conditional predictive
structure at the chosen observation resolution and evidence against an
advantage for the particular prime-odds restriction tested here. It is
not a validation of a universal prime substrate, an autonomous prediction
of three-body coordinates, or a new law of nature.
