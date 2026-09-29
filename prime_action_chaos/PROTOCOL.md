# External benchmark protocol

Specified before running the external benchmark on 2026-09-29.

## Questions

1. Does accumulated conditional action, including the invariant-density
   boundary term, recover the stretching of a separately defined nonlinear
   map? The exact control is `f(x)=4x(1-x)`.
2. Does past symbolic context improve future-label probabilities on
   independently defined chaotic dynamics?
3. Does restricting conditional odds to the manuscript's prime-cell values
   improve those forecasts over an ordinary conditional model or an equally
   large, equally ranged nonprime grid?

The third question is a specific operational test of prime-cell odds. It
does not test every possible use of primes or establish a physical theory.

## Data and observation

- Logistic maps: parameters 4.0 and 3.9, initial coordinates
  0.123456789, 0.314159265, and 0.271828182. Discard 2,000 iterations, then
  record 100,000 binary observations `x >= 1/2`. Split chronologically into
  60,000 training, 20,000 validation, and 20,000 test observations. Record
  tangent stretching and check for repeated floating-point states.
- Lorenz equations: sigma=10, rho=28, beta=8/3. Record the sign of `x` on
  upward crossings of `z=27`, with linear interpolation of crossing time.
  Discard 100 time units. Record 10,000 crossings and split them 6,000 /
  2,000 / 2,000. Runs use `(1,1,1)` and `(1.001,1,1)` with RK4 step 0.01;
  a numerical refinement run uses `(1,1,1)` with step 0.005. Integrate the
  tangent equation as well, normalizing every ten steps.

The observation alphabet is fixed before fitting. Models receive binary
history only, not exact coordinates, derivatives, return times, or the
equations. A solver supplied with exact state and equations has more
information and is not the forecast comparison here.

## Models and selection

Use context depths 0 through 10 for all models. Estimate each context's
next-label probability from training counts with symmetric pseudocount
1/2. Use the same training target indices for every depth.

- Continuous: the estimated probability without quantization.
- Prime odds: probabilities `1/(p+1)` and `p/(p+1)` for the 37 primes up
  to 157, plus the neutral probability 1/2. The neutral entry is not prime.
- Nonprime grid: the same number of log-odds magnitudes, uniformly spaced
  from zero to `log(157)`, with both signs. It has the same probability
  range and 75 unique entries as the prime grid.

Quantization minimizes cross-entropy with the smoothed training estimate.
Choose depth separately for each model by one-step validation log loss;
break ties toward shorter context. Do not refit on validation or test data.
Also report both quantized models at the continuous model's chosen depth,
so the effect of quantization can be isolated at matched context size.

The depth-zero continuous model is the marginal-only baseline.

## Forecasts and metrics

Report test log loss in nats and Brier score. Report validation curves and
training counts for the selected contexts. For horizons 1, 2, 4, 8, 16,
and 32, propagate the selected finite-context transition model without
intermediate observations. At each forecast origin, only observations
strictly before its first target are available; future observations are
used only to score the forecast.

Overlapping forecast origins are permitted and are reported as rolling
ensemble forecasts, not an exact long-horizon trajectory reconstruction.
Estimate uncertainty of paired one-step loss differences from contiguous
test-block means (block length 1,000 for logistic and 200 for Lorenz).
Intervals are descriptive normal approximations, not independence proofs
or multiple-comparison-adjusted significance tests.

For Lorenz, compare the two step sizes statistically; chaotic trajectories
are not expected to agree pointwise for long times. A short-time RK4
refinement check and finite-difference tangent check test the integrator.
The sign partition is not assumed proved generating. Its predictive loss
must not automatically be equated to the system's full metric entropy.

## Interpretation fixed in advance

- Reduced held-out loss relative to the marginal baseline supports useful
  temporal organization at this observation resolution.
- Prime-specific support requires an improvement over the continuous and
  matched-grid controls, with the same observation access. A tie, an
  isolated run, or a training-only gain is insufficient.
- The logistic parameter-4 control has Bernoulli binary coding in exact
  arithmetic. A substantial reproducible memory advantage there would
  require investigation of the implementation and finite precision.
- Local stretching equals conditional inverse-branch information plus a
  density boundary term. A constant one-step stretch is not assumed for
  nonlinear maps.
- No result in this benchmark establishes a universal physical substrate,
  a solution of the three-body problem, or an escape from initial-state
  uncertainty.

## Reproduction

Run `python benchmark.py --output results/benchmark.json` from this folder.
`--quick` is a reduced smoke run and must not be substituted for the
recorded full benchmark. The code requires only the Python standard library.
