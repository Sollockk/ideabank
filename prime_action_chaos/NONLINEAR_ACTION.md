# Conditional action, nonlinear stretching, and the information available to a forecast

**Date:** 2026-09-29. **Status:** Exact identities under stated assumptions;
an application of established dynamical and information theory. No claim
of mathematical priority or discovery of a new physical law is made.

The useful advance for the Prime Universe investigation is a distinction:
the information in a branch, the information available from past
observations, and the information required to specify an exact state are
different quantities. Their relationship can be calculated.

## 1. An exact extension beyond the constructed baker maps

Let a piecewise continuously differentiable interval map $f$ preserve a
probability measure $d\mu(x)=\rho(x)\,dx$. Assume that there are finitely
many monotone inverse branches, and work almost everywhere where the
density is positive and finite and the relevant derivative is nonzero.
The invariant-density equation is

$$
\rho(y)=\sum_{x\in f^{-1}(y)}\frac{\rho(x)}{|f'(x)|}.
\tag{N1}
$$

Consequently the **conditional probability of an inverse branch**, given
the next exact coordinate $y$, is

$$
q(x\mid y)=\frac{\rho(x)}{|f'(x)|\rho(y)},\qquad
\sum_{x\in f^{-1}(y)}q(x\mid y)=1.
\tag{N2}
$$

Here $q$ is a probability on the finite set of preimages, not a probability
mass assigned to an arbitrary point in a continuous distribution. Taking
logarithms gives the exact local identity

$$
\boxed{\log|f'(x)|=-\log q(x\mid f(x))
+\log\rho(x)-\log\rho(f(x)).}
\tag{N3}
$$

Define the dimensionless conditional action
$a(x)=-\log q(x\mid f(x))$. Along an orbit $x_{k+1}=f(x_k)$,

$$
\boxed{\log|(f^N)'(x_0)|
=\sum_{k=0}^{N-1}a(x_k)+\log\rho(x_0)-\log\rho(x_N).}
\tag{N4}
$$

This is an infinitesimal stretching identity. Finite displacements need
separate error control and can cross branch boundaries. Multiplying $a$
by $\hbar$ gives units of action but does not establish a physical action
principle or identify a microscopic clock.

If $\log\rho$ and $\log|f'|$ are integrable with respect to $\mu$,
stationarity cancels the density terms in the mean:

$$
\int\log|f'|\,d\mu=\int a\,d\mu
=\int\rho(y)H(q(\cdot\mid y))\,dy.
\tag{N5}
$$

Ergodicity then identifies this mean with the almost-everywhere Lyapunov
exponent. The integrability assumption also makes the boundary contribution
in (N4) sublinear almost everywhere. Equality with metric entropy needs
additional hypotheses, such as an appropriate generating expanding
partition. It is explicit for the full tent and logistic examples below.
One must not replace those hypotheses by a numerical resemblance between
entropy and an exponent. The relevant background is the established
entropy theory of transformations; see
[Rokhlin's original lectures](https://doi.org/10.1070/RM1967v022n05ABEH001224).

This does not extend to arbitrary systems by replacing $f'$ with a
Jacobian determinant. In an invertible volume-preserving baker map the
determinant is one while the unstable Lyapunov exponent is positive.
Stretching along unstable directions and contraction along stable
directions must be separated. Lorenz's invariant measure is not being
assumed to have a smooth three-dimensional density here.

## 2. Why this corrects the action interpretation

In [the earlier construction](THEORY.md), uniform density makes the
boundary term vanish. For full independent branches, inverse-branch
weights are the original spectral weights, giving $a_n=-\log w_n$.
For a stationary Markov construction with weights $w_i$ and transitions
$P_{ij}$, the inverse weight is instead

$$
Q_{ji}=\frac{w_iP_{ij}}{w_j},\qquad
-\log Q_{ji}=-\log P_{ij}+\log w_j-\log w_i.
\tag{N6}
$$

That is exactly the logarithmic slope of the constructed Markov interval
map. Its mean equals the forward conditional entropy because the marginal
terms cancel. Forward and backward conditional actions need not agree
pointwise.

One can encode $q(\cdot\mid y)$ as a diagonal density matrix and call
$-\log q$ its modular spectrum. This is an exact encoding after the
classical transition law has been supplied. It does not derive that law
from a quantum density matrix, or make the branch probabilities prime.

## 3. A nonlinear system where every term is explicit

For the independently defined logistic map

$$
f(x)=4x(1-x),\qquad
\rho(x)=\frac{1}{\pi\sqrt{x(1-x)}},\quad 0<x<1,
\tag{N7}
$$

both inverse branches have probability $1/2$. This follows directly from
$f(x)(1-f(x))=4x(1-x)(1-2x)^2$ and (N2). Therefore

$$
\boxed{\log|4-8x|=\log2+\log\rho(x)-\log\rho(f(x)).}
\tag{N8}
$$

The actual stretch varies, and can be negative near the critical point.
Calling it a constant $\log2$ in the physical $x$ coordinate would be
incorrect. Only the conditional inverse action is constant; the density
correction accounts for the varying local geometry. The critical orbit
and endpoints are excluded from the almost-everywhere statement.

The coordinate change

$$
x=g(u)=\sin^2\!\left(\frac{\pi u}{2}\right),\qquad
T(u)=\begin{cases}2u,&u<1/2,\\2(1-u),&u\ge1/2\end{cases}
\tag{N9}
$$

satisfies $f\circ g=g\circ T$. Lebesgue measure in $u$ becomes (N7).
The density term is precisely the correction for changing coordinates.
Tent-map conjugacies and Lyapunov exponents are established tools; see,
for example, the primary research by
[Aguirregabiria](https://arxiv.org/abs/0810.3781). The formulas here are
derived explicitly rather than inferred from the benchmark.

The executable checks (N8) at 999 interior points. The largest identity
residual is about $4.68\times10^{-11}$ in the recorded run; the largest
inverse-weight error is about $2.34\times10^{-11}$. These are floating-point
checks of an algebraic identity, not error-certified numerical proofs.

## 4. Deterministic does not imply predictable from the recorded past

For (N9), each binary itinerary cylinder of length $N$ has Lebesgue width
$2^{-N}$. A specified next symbol cuts every such cylinder into two equal
parts. Thus under the invariant measure the observed labels
$Y_k=\mathbf1[x_k\ge1/2]$ are independent fair bits:

$$
\Pr(Y_{k+1}=1\mid Y_0,\ldots,Y_k)=\frac12.
\tag{N10}
$$

The statement also holds for the full past in the stationary natural
extension. It concerns this observation process and this invariant
ensemble, not every observation of the exact state or every initial
distribution.

Any predictor restricted to past labels has Bayes error $1/2$ for the next
label and minimum expected log loss $\log2$. Increasing context length
cannot improve those population limits. Yet an exact real coordinate
determines the entire trajectory. Future itinerary bits reside in the
unresolved coordinate, not in correlations among the already recorded
labels. [tests.py](tests.py) verifies all binary cylinders through length
eight using exact rational tent-map inverse branches.

This is a concrete resolution of the initial intuition: an orbit can be
fully predetermined while an observation history contains no usable
information about its next observed bit. A claim to reveal hidden flow
must specify which additional observable exposes the missing information.

## 5. The forecast identity that the data can actually test

Let $C$ be an available history and $Y$ a future finite-alphabet label.
Write $p(\cdot\mid C)$ for the true conditional law and
$\widehat p(\cdot\mid C)$ for a fitted predictor. Whenever the predicted
probabilities are positive on the true support,

$$
\boxed{\mathbb E[-\log\widehat p(Y\mid C)]
=H(Y\mid C)
+\mathbb E_C D_{\rm KL}(p(\cdot\mid C)\Vert\widehat p(\cdot\mid C)).}
\tag{N11}
$$

Compared with the ideal marginal-only predictor, the achievable log-loss
gain is

$$
H(Y)-H(Y\mid C)=I(Y;C).
\tag{N12}
$$

The proof of (N11) is to add and subtract $-\log p(Y\mid C)$ inside
the expectation. Equation (N12) is the defining entropy identity for
mutual information. Finite-data models carry estimation and approximation
error, so their empirical gain is not automatically an unbiased estimate
of mutual information or metric entropy.

Inverse-branch information in (N3) is conditioned on an exact future
coordinate. Prediction in (N11) is conditioned on past observations.
They are not interchangeable. In particular, (N3) is a consistency law
once $f$ and $\rho$ are known; it is not an algorithm for recovering an
unknown $f$ from a static spectrum.

## 6. An exact obstruction to the tested prime-cell odds

The tested prime model restricts a binary forecast to

$$
\mathcal G=\{1/2\}\cup
\left\{\frac1{p+1},\frac p{p+1}:p\text{ prime},\ p\le157\right\}.
\tag{N13}
$$

This directly tests the two-state prime-cell odds. The cutoff fixes model
size before benchmarking; it is not asserted to be a physical constant.
Even admitting arbitrarily large primes leaves the nearest choices to
$1/2$ at $1/3$ and $2/3$.

For a true conditional probability $b$, the best grid choice is $1/2$
throughout

$$
\boxed{1-\frac{\log(3/2)}{\log2}\le b\le
\frac{\log(3/2)}{\log2}.}
\tag{N14}
$$

This is the interval $[0.415037499\ldots,\ 0.584962501\ldots]$.

To prove this, equate the cross-entropies at $1/2$ and $2/3$:
$\log2=\log3-b\log2$, and use symmetry for the other endpoint.
All more extreme grid values have still greater cross-entropy on this
interval by convexity. Endpoint ties do not affect the minimum loss.

For example, a true 58% event gets rounded to 50%. Its irreducible
excess expected loss is

$$
D_{\rm KL}(\operatorname{Ber}(0.58)\Vert\operatorname{Ber}(0.5))
=\log2-H(0.58)=0.0128551804\ldots\text{ nats}.
\tag{N15}
$$

That loss persists with unlimited training data in this restricted
model. A finite grid can still reduce sampling variance, which is why
both a continuous model and an equally large nonprime grid were tested.
Products, ratios, or mixtures of prime-cell states could define different
models; the obstruction applies to (N13), not to every arithmetic model.
Those extensions would need their own complexity controls and a physical
or dynamical reason for selecting their compositions.

## 7. What the external tests establish

The [fixed protocol](PROTOCOL.md) uses logistic and Lorenz trajectories
generated independently of the proposed prime law. Training, validation,
and test intervals are chronological; test futures affect only scoring.
The [full results](BENCHMARK_RESULTS.md) show:

- Logistic parameter 4 selects zero history depth and gives about
  $\log2$ held-out loss, agreeing with the exact observation limit.
- Logistic parameter 3.9 has useful temporal constraints: an ordinary
  history model reduces one-step log loss by about 26.1% against the
  marginal baseline, averaged over the three specified initial states.
- Lorenz return labels have a smaller mean reduction, about 1.62%, with
  variation across initial conditions and integration steps.
- The prime-odds model has worse one-step loss than both controls in all
  six runs with temporal structure. The uniform-log-odds control shows
  that quantization alone is not the explanation for the prime result.

These are forecasts of future label probabilities, not recovery of exact
future coordinates. Their advantage largely disappears over longer
horizons. The Lorenz partition is not proved generating, and its forecast
loss is not being identified with the full entropy of the flow.

## 8. The research question that survives

Find a system-derived ordered transition operator, observation map, and
clock. Test whether an arithmetic representation gives a shorter or more
accurate account of that operator than nonarithmetic alternatives at the
same observation access and complexity. The test must predict held-out
transitions or other dynamics without receiving their true future states.

The present work supplies an exact consistency identity, a sharp limit
from a deterministic Bernoulli example, and a reproducible failure of one
prime-specific prediction rule. It does not supply a uniquely selected
prime generator for nature. Those are useful constraints on the next
construction rather than evidence that the physical problem is solved.
