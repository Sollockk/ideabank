# Euclidean Action as a Modular Gap

## An exact two-level wave--predictability theorem with determinant-prime inputs

**Research note — 2026-08-09**

## Abstract

This note records an elementary but useful synthesis of four standard
structures: graph Laplacian determinants, Gibbs purification, modular flow,
and two-path complementarity.

For a cycle of prime order `p`, the nonzero Laplacian determinant is `p^2`.
Its normalized logarithmic action is therefore

```math
a_p=\frac12\log\det{}'\Delta_{C_p}=\log p.
```

Define the two-level state

```math
\sigma_p=\frac{\mathrm{diag}(p,1)}{p+1}.
```

Then the modular Hamiltonian `K_p=-log sigma_p` has spectral gap `log p`.
The state has an explicit thermofield purification with Schmidt-amplitude
ratio `p^-1/2`.  For that purification, branch predictability `P` and maximum
interference visibility `V` obey

```math
P_p=\frac{p-1}{p+1}=\tanh\frac{\log p}{2},
\qquad
V_p=\frac{2\sqrt p}{p+1}=\mathrm{sech}\,\frac{\log p}{2},
```

and hence

```math
P_p^2+V_p^2=1.
```

The construction gives a complete finite example in which Euclidean action
sets structural bias while Lorentzian phase evolution carries the remaining
wave visibility.  More generally, relative entropy obeys

```math
D(\rho\|\sigma)=\Delta\langle-\log\sigma\rangle-\Delta S,
```

so modular action and entropy cancel at first order around a reference state,
leaving a second-order distinguishability resource.  This provides an
operational alternative to claims that a low-action quantum object
intermittently ceases to exist.

All finite-dimensional identities below are proved exactly.  The proposal
that a physical causal boundary realizes these prime-labelled cells is a
conjecture.  No claim about the Riemann hypothesis is made.

---

## 1. A determinant action equal to `log p`

Let `C_n` be the cycle graph on `n>=3` vertices and let `Delta_Cn` be its
combinatorial Laplacian.  The Matrix--Tree theorem gives

```math
\det{}'\Delta_G=|V(G)|\,\tau(G),
```

where `tau(G)` is the number of spanning trees.  A cycle `C_n` has `n`
spanning trees, since deleting any one edge produces a tree.  Therefore

```math
\boxed{\det{}'\Delta_{C_n}=n^2.}
\tag{1}
```

For `n=2`, use the two-vertex multigraph with two parallel edges.  It has two
spanning trees and again `det' Delta=4`.  This is the cycle convention needed
to include the prime 2.

For a rational prime `p`, define the normalized determinant action

```math
\boxed{
a_p:=\frac12\log\det{}'\Delta_{C_p}=\log p.}
\tag{2}
```

Primality is not required for (1)--(2).  It becomes relevant when the cells
are used as primitive factors in an Euler product.  This note studies one
cell at a time.

---

## 2. The determinant action is an exact modular gap

For any real `p>1`, define

```math
\sigma_p
=\frac1{p+1}
\begin{pmatrix}
p&0\\
0&1
\end{pmatrix}.
\tag{3}
```

This is a faithful density matrix with eigenvalues

```math
q_0=\frac p{p+1},
\qquad
q_1=\frac1{p+1}.
\tag{4}
```

Its modular Hamiltonian is

```math
K_p:=-\log\sigma_p.
\tag{5}
```

Therefore

```math
\begin{aligned}
\mathrm{gap}(K_p)
&=(-\log q_1)-(-\log q_0)\\
&=\log\frac{q_0}{q_1}\\
&=\log p.
\end{aligned}
\tag{6}
```

Combining (2) and (6) proves

```math
\boxed{
\frac12\log\det{}'\Delta_{C_p}
=\mathrm{gap}(-\log\sigma_p)
=\log p.}
\tag{7}
```

This is an equality between two explicitly finite operators.  It does not
show that the graph Laplacian dynamically generates the density matrix; it
shows that they share an exact action/gap invariant.

### Gibbs form

Let

```math
H_p=(\log p)|1\rangle\langle1|.
\tag{8}
```

At dimensionless inverse temperature one,

```math
\sigma_p
=\frac{e^{-H_p}}{\mathrm{Tr}\,e^{-H_p}}.
\tag{9}
```

Indeed,

```math
K_p=H_p+\log(1+p^{-1})\,\mathbf1.
\tag{10}
```

The identity term changes neither the gap nor modular commutators.

---

## 3. The shared-source purification

The canonical two-sided purification of (3) is

```math
\boxed{
|\Omega_p\rangle
=\sqrt{\frac p{p+1}}|00\rangle
+\sqrt{\frac1{p+1}}|11\rangle.}
\tag{11}
```

Equivalently,

```math
|\Omega_p\rangle
=\frac{|00\rangle+p^{-1/2}|11\rangle}{\sqrt{1+p^{-1}}}.
\tag{12}
```

Tracing out either side gives `sigma_p`.  The determinant action has therefore
acquired two further exact meanings:

```math
e^{-a_p/2}=p^{-1/2}
```

is the relative Schmidt amplitude, while

```math
e^{-a_p}=p^{-1}
```

is the relative probability in the reduced state.

This is an ordinary two-level thermofield double.  “Shared source” here means
purification and matched Schmidt labels, not a hidden communication channel.

---

## 4. `log p` is a modular-time frequency

Choose the modular-flow convention

```math
\alpha_s(A)=e^{isK_p}Ae^{-isK_p}.
\tag{13}
```

For the transition operator `A_+=|1><0|`,

```math
\boxed{
\alpha_s(A_+)=e^{is\log p}A_+.}
\tag{14}
```

Thus `log p` is exactly the angular frequency of a transition operator in
dimensionless modular time.

For a physical Gibbs state

```math
\sigma=Z^{-1}e^{-\beta H},
```

one has

```math
K=\beta H+\log Z.
```

Consequently, modular and Hamiltonian flow agree after the exact calibration

```math
t=\hbar\beta s.
\tag{15}
```

The claim that this modular flow supplies fundamental time in arbitrary
generally covariant systems is the thermal-time hypothesis, not a theorem.
For a Gibbs state, equation (15) itself is algebra.

---

## 5. One clock cancels while the other flows

Give both sides of (11) physical Hamiltonian

```math
H^\mathrm{phys}_p=E_p|1\rangle\langle1|.
\tag{16}
```

Define

```math
G_-=H_L-H_R,
\qquad
G_+=H_L+H_R.
\tag{17}
```

Since the two sides carry matched labels,

```math
\boxed{G_-|\Omega_p\rangle=0.}
\tag{18}
```

This is an exact null difference-clock relation.  The orthogonal generator is
not null:

```math
e^{-itG_+/\hbar}|\Omega_p\rangle
=\sqrt{\frac p{p+1}}|00\rangle
+e^{-2iE_pt/\hbar}\sqrt{\frac1{p+1}}|11\rangle.
\tag{19}
```

Local density matrices and entanglement entropy remain constant, but a
phase-sensitive two-sided correlation oscillates.  Entanglement can therefore
make one combination of clocks a constraint without stopping all evolution.

---

## 6. The action--wave complementarity theorem

For a pure two-branch state with probabilities `q_0` and `q_1`, define branch
predictability and maximum interference visibility by

```math
\mathcal P:=|q_0-q_1|,
\qquad
\mathcal V:=2\sqrt{q_0q_1}.
\tag{20}
```

Substituting (4),

```math
\mathcal P_p=\frac{p-1}{p+1},
\qquad
\mathcal V_p=\frac{2\sqrt p}{p+1}.
\tag{21}
```

Writing `a=log p` gives

```math
\boxed{
\mathcal P(a)=\tanh(a/2),
\qquad
\mathcal V(a)=\mathrm{sech}(a/2).}
\tag{22}
```

The identity

```math
(p-1)^2+4p=(p+1)^2
```

proves

```math
\boxed{\mathcal P(a)^2+\mathcal V(a)^2=1.}
\tag{23}
```

This is the central finite theorem.

If the action variable is physical,

```math
a=\beta E=\frac{E\tau_\beta}{\hbar},
\tag{24}
```

then (22) gives a minimal exact model of the relation between Euclidean
weighting and Lorentzian interference:

- `a=0`: equal branch probabilities and unit visibility;
- finite `a`: partial structural bias and partial visibility;
- `a -> infinity`: one branch becomes certain and visibility vanishes.

Nothing switches on and off in time.  The Euclidean action fixes branch
weights; real-time evolution changes their relative phase.

For the observable

```math
X=|00\rangle\langle11|+|11\rangle\langle00|,
```

equation (19) gives

```math
\boxed{
\langle X\rangle_t
=\mathcal V_p\cos(2E_pt/\hbar).}
\tag{25}
```

The visibility is therefore not merely a label; it is the amplitude of an
explicit correlation fringe.

### Selected prime cells

| `p` | `log p` | Predictability | Visibility | Entanglement entropy (nats) |
|---:|---:|---:|---:|---:|
| 2 | 0.693147 | 0.333333 | 0.942809 | 0.636514 |
| 3 | 1.098612 | 0.500000 | 0.866025 | 0.562335 |
| 5 | 1.609438 | 0.666667 | 0.745356 | 0.450561 |
| 7 | 1.945910 | 0.750000 | 0.661438 | 0.376770 |
| 11 | 2.397895 | 0.833333 | 0.552771 | 0.286836 |
| 157 | 5.056246 | 0.987342 | 0.158607 | 0.038351 |

Prime 2 is the most entangled and wave-visible member of this prime-indexed
family.

---

## 7. Entanglement and occupation uncertainty fall with action

The one-side entropy is

```math
S(p)
=\log(p+1)-\frac p{p+1}\log p.
\tag{26}
```

Differentiation gives

```math
\boxed{
\frac{dS}{dp}
=-\frac{\log p}{(p+1)^2}\lt 0
\quad(p>1).}
\tag{27}
```

The binary occupation variance is

```math
\mathrm{Var}(N)
=\frac p{(p+1)^2}
=\frac{\mathcal V_p^2}{4},
\tag{28}
```

which also decreases for `p>1`.  In this model low action means high
branch uncertainty and entanglement, not intermittent absence.

---

## 8. A prime-11 Schottky maximum

The modular-energy variance, equal to the canonical two-level heat capacity
in units of `k_B`, is

```math
\frac C{k_B}
=\mathrm{Var}(K_p)
=(\log p)^2\frac p{(p+1)^2}
=\frac{a^2}{4\cosh^2(a/2)}.
\tag{29}
```

The unique positive continuous maximum satisfies

```math
\boxed{a\tanh(a/2)=2.}
\tag{30}
```

The solution is

```math
a_*=2.399357280515\ldots,
\qquad
e^{a_*}=11.016093846685\ldots .
\tag{31}
```

The heat capacity is increasing below this point and decreasing above it.
Direct comparison of the adjacent primes 11 and 13 therefore proves that

```math
\boxed{
p=11
\text{ maximizes }C
\text{ among rational-prime cells}.}
\tag{32}
```

This is the ordinary two-level Schottky anomaly written in the coordinate
`a=log p`.  It is a theorem of the constructed family, not evidence that 11
has a universal role in nature.

---

## 9. Relative entropy: action minus structural entropy

Let `sigma` be any faithful reference density matrix and set

```math
K_\sigma=-\log\sigma.
\tag{33}
```

For another state `rho`, define

```math
D(\rho\|\sigma)
=\mathrm{Tr}\,\rho(\log\rho-\log\sigma).
\tag{34}
```

Writing

```math
\Delta\langle K_\sigma\rangle
=\mathrm{Tr}(\rho-\sigma)K_\sigma,
\qquad
\Delta S=S(\rho)-S(\sigma),
```

direct substitution proves

```math
\boxed{
D(\rho\|\sigma)
=\Delta\langle K_\sigma\rangle-\Delta S
\ge0.}
\tag{35}
```

For a Gibbs reference, `K=beta H+log Z`, so

```math
\boxed{
D(\rho\|\sigma)
=\beta\bigl(F(\rho)-F(\sigma)\bigr).}
\tag{36}
```

This gives a precise three-term ledger:

- `Delta<K>` is modular energy/action;
- `Delta S` is structural multiplicity;
- `D` is residual modular free action and distinguishability.

### First-order cancellation

For a differentiable perturbation `rho(lambda)` with `rho(0)=sigma`, relative
entropy has a minimum at zero.  Its linear term vanishes:

```math
\boxed{
\delta\langle K_\sigma\rangle=\delta S.}
\tag{37}
```

This is the entanglement first law.  Hence

```math
D(\rho(\lambda)\|\sigma)=O(\lambda^2).
\tag{38}
```

Equation (37) is a rigorous limited sense in which action and entanglement
structure “counteract to net null” near a quantum reference state.  It does
not set total energy or physical time to zero.

---

## 10. An operational quantum floor

The trace distance

```math
T(\rho,\sigma)=\frac12\|\rho-\sigma\|_1
\tag{39}
```

controls optimal one-shot state discrimination.  With equal priors,

```math
P_\mathrm{success}=\frac{1+T}{2}.
\tag{40}
```

Quantum Pinsker, using natural logarithms, gives

```math
D(\rho\|\sigma)\ge2T(\rho,\sigma)^2.
\tag{41}
```

Therefore

```math
\boxed{
T\le\sqrt{D/2},
\qquad
P_\mathrm{success}\le\frac12+\sqrt{D/8}.}
\tag{42}
```

This is an operational quantum floor: when the residual modular free action
`D` is small, measurements confined to the subsystem cannot reliably
distinguish the state from its vacuum or thermal reference.  The state still
exists; the distinction is not locally recordable with high confidence.

As a finite example, let

```math
\sigma_3=
\begin{pmatrix}3/4&0\\0&1/4\end{pmatrix},
\qquad
\rho=
\begin{pmatrix}3/4&0.1\\0.1&1/4\end{pmatrix}.
```

The populations—and therefore the mean modular energy—are identical.  Yet

```math
D(\rho\|\sigma_3)=0.022164078844\ldots,
\qquad
T=0.1,
\qquad
2T^2=0.02.
```

The relative entropy is positive because the coherent state has lower
entropy, illustrating that energy alone does not determine local
distinguishability.

---

## 11. The Bekenstein factor as modular geometry

For the Minkowski vacuum reduced to a Rindler wedge, the modular Hamiltonian
is the boost generator

```math
K_R
=\frac{2\pi}{\hbar c}
\int_{z>0}z\,T_{00}(\mathbf x)\,d^{d-1}x.
\tag{43}
```

For an excitation of energy `E` localized a characteristic distance `R`
from the horizon,

```math
\Delta\langle K_R\rangle
\simeq\frac{2\pi ER}{\hbar c}.
\tag{44}
```

Positivity in (35) yields

```math
\boxed{
\Delta S
\le\Delta\langle K_R\rangle
\simeq\frac{2\pi ER}{\hbar c}.}
\tag{45}
```

This is Casini's vacuum-subtracted QFT formulation of the Bekenstein bound.
The `2 pi` is the normalization of geometric modular boost flow.  Relative
entropy also decreases under restriction to a smaller observable region,
which rigorously captures the loss of local distinguishability at decreasing
resolution.

In particular, the action--information relation is not merely black-hole
numerology.  It follows from positivity of a quantum-information quantity in
the Rindler setting.

---

## 12. Relation to gravity

There are controlled contexts in which the entanglement first law becomes a
gravitational constraint:

- For holographic CFTs with the required entropy dictionary, imposing the
  first law for all ball-shaped regions is equivalent to the linearized bulk
  gravitational equations.
- Under the assumptions in Jacobson's entanglement-equilibrium argument,
  stationarity of vacuum entanglement in small geodesic balls is linked to
  the semiclassical Einstein equation.

These results motivate—but do not prove—the chain

```math
\text{determinant action}
\longrightarrow
\text{boundary modular Hamiltonian}
\longrightarrow
\text{entanglement first law}
\longrightarrow
\text{geometric response}.
\tag{46}
```

The first arrow has the exact finite realization (3)--(12).  A local
relativistic boundary algebra that actually derives the prime state has not
been constructed.

---

## 13. Causal time versus thermal time

For a causal region of radius `R`, one may define the radial crossing time

```math
\tau_c=R/c
```

and conjugate energy

```math
\varepsilon_c=\hbar/\tau_c.
```

This gives a causal action `chi=E tau_c/hbar`.  The modular action in this
note is instead

```math
a=E\tau_\beta/\hbar=\beta E.
```

There is an exact scale degeneracy here.  If

```math
\sigma=Z^{-1}e^{-\beta H},
```

then, for every positive `lambda`,

```math
H\longmapsto\lambda H,
\qquad
\beta\longmapsto\beta/\lambda
```

leaves `sigma`, its modular Hamiltonian, and every modular gap unchanged.
Consequently the determinant construction fixes the dimensionless product
`beta E=E tau_beta/hbar`; it cannot separately derive an energy in joules
and a time in seconds.  An absolute `tau_beta` requires one additional
dimensionful datum, such as a geometrically normalized surface gravity.

They coincide only if `tau_beta=tau_c`.  For a Schwarzschild horizon,

```math
\tau_\beta=4\pi\tau_c,
```

so

```math
a=4\pi\chi.
```

This factor must be retained in any proposed black-hole realization.  The
state (3) corresponds to `beta E_p=log p`; it is not automatically the
Hawking-temperature state of a causal mode with `E_p tau_c/hbar=log p`.

---

## 14. What is proved and what is conjectural

### Proved in finite dimensions

- `det' Delta_Cp=p^2` with the stated `p=2` multicycle convention.
- The determinant action is `log p`.
- The modular gap of `sigma_p` is `log p`.
- `sigma_p` is the reduction of the explicit purification (11).
- The difference generator annihilates the purification while the sum
  generator produces (19).
- `P=tanh(a/2)`, `V=sech(a/2)`, and `P^2+V^2=1`.
- Entanglement entropy and occupation variance decrease with `p`.
- The two-level modular heat capacity is maximized at prime 11.
- The finite coherent example satisfies the relative-entropy identity and
  Pinsker inequality.

### Standard general results used

- Positivity and monotonicity of quantum relative entropy.
- The entanglement first law.
- Quantum Pinsker and Helstrom discrimination.
- The Rindler modular Hamiltonian and Casini's Bekenstein formulation.

### Open or conjectural

- A physical causal boundary dynamically produces `sigma_p` from the cycle
  graph.
- The temperature or Euclidean period is fixed by the same determinant
  operator.
- Independent prime cells embed into a local relativistic QFT.
- Their modular first law yields a gravitational field equation.
- Primes label fundamental physical sectors rather than a useful spectral
  basis.

### Explicitly not claimed

- Quantum states cease to exist intermittently.
- Entanglement permits signaling.
- Energy alone guarantees classical structure.
- This construction proves the Riemann hypothesis.

---

## 15. Reproducibility

All numerical values above follow from elementary functions.  The following
minimal Python fragment reproduces the main table and Schottky root:

```python
import math


def record(prime):
    action = math.log(prime)
    predictability = math.tanh(action / 2)
    visibility = 1 / math.cosh(action / 2)
    entropy = math.log(prime + 1) - prime * action / (prime + 1)
    heat_capacity = action * action * prime / (prime + 1) ** 2
    assert math.isclose(predictability**2 + visibility**2, 1.0)
    return action, predictability, visibility, entropy, heat_capacity


for prime in (2, 3, 5, 7, 11, 13, 157):
    print(prime, record(prime))

lower, upper = 2.0, 3.0
for _ in range(100):
    midpoint = (lower + upper) / 2
    if midpoint * math.tanh(midpoint / 2) < 2:
        lower = midpoint
    else:
        upper = midpoint

action_peak = (lower + upper) / 2
print(action_peak, math.exp(action_peak))
```

---

## References

1. H. Casini, [“Relative entropy and the Bekenstein bound”](https://arxiv.org/abs/0804.2182), *Classical and Quantum Gravity* **25**, 205021 (2008).
2. A. Connes and C. Rovelli, [“Von Neumann Algebra Automorphisms and Time-Thermodynamics Relation in General Covariant Quantum Theories”](https://arxiv.org/abs/gr-qc/9406019), *Classical and Quantum Gravity* **11**, 2899 (1994).
3. D. D. Blanco, H. Casini, L.-Y. Hung, and R. C. Myers, [“Relative Entropy and Holography”](https://arxiv.org/abs/1305.3182), *JHEP* **08**, 060 (2013).
4. T. Faulkner, M. Guica, T. Hartman, R. C. Myers, and M. Van Raamsdonk, [“Gravitation from Entanglement in Holographic CFTs”](https://arxiv.org/abs/1312.7856), *JHEP* **03**, 051 (2014).
5. T. Jacobson, [“Entanglement Equilibrium and the Einstein Equation”](https://arxiv.org/abs/1505.04753), *Physical Review Letters* **116**, 201101 (2016).
6. K. M. R. Audenaert and J. Eisert, [“Continuity bounds on the quantum relative entropy”](https://arxiv.org/abs/quant-ph/0503218), *Journal of Mathematical Physics* **46**, 102104 (2005).
7. N. Margolus and L. B. Levitin, [“The maximum speed of dynamical evolution”](https://arxiv.org/abs/quant-ph/9710043), *Physica D* **120**, 188 (1998).
8. J. D. Bekenstein, [“Universal upper bound on the entropy-to-energy ratio for bounded systems”](https://doi.org/10.1103/PhysRevD.23.287), *Physical Review D* **23**, 287 (1981).
