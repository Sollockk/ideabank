# Lorentz Rapidity, Euclidean Time, and the `alpha` Shift

## Why a real boost preserves a spectral exponent, while its Euclidean continuation can reweight structure

**Date:** 2026-08-10

## Abstract

A Lorentz transformation can literally shift an `alpha` when `alpha` means
**rapidity**.  It cannot change a genuine power-law spectral exponent through
one uniform inertial boost, and it cannot change the electromagnetic
fine-structure constant merely by changing frames.

The connection to Euclidean time is nevertheless exact and useful.  Wick
rotation turns Lorentz rapidity into an angular Euclidean coordinate.  For a
uniformly accelerated observer, rapidity grows linearly with proper time;
regularity of the Euclidean circle then fixes the thermal period

```math
\tau_\beta=\frac{2\pi c}{g},
\qquad
k_BT=\frac{\hbar g}{2\pi c}.
```

For a Rindler wedge, the modular Hamiltonian is `2 pi` times the generator of
unit boost rapidity.  If a prime-labelled modular sector has gap `log p`, its
boost-charge gap is therefore `log p/(2 pi)`.  Half a Euclidean turn gives
the amplitude `p^-1/2`; a full turn gives the Gibbs weight `p^-1`.

This supplies a precise geometric link between Lorentz boosts, Euclidean
thermal time, thermofield amplitudes, and prime modular action.  It also
identifies a common mistake: multiplying a spectrum by `f^-q` is a Euclidean
fractional filter, not an ordinary Lorentz boost.

---

## 1. First decide which `alpha` is being shifted

At least three unrelated quantities are commonly called `alpha`.

### Lorentz rapidity

Rapidity `eta` is defined by

```math
\frac vc=\tanh\eta,
\qquad
\gamma=\cosh\eta.
```

Many texts denote this rapidity by `alpha`.  This is the quantity that a
Lorentz boost shifts additively.

### Spectral exponent

A power spectrum may have

```math
S(f)=Cf^{-\alpha_\mathrm{P}}.
```

This `alpha_P` is a log--log slope.  It is not rapidity.

An amplitude spectrum may instead satisfy

```math
|X(f)|=C_Af^{-\alpha_\mathrm{A}}.
```

When `S=|X|^2`,

```math
\alpha_\mathrm{P}=2\alpha_\mathrm{A}.
```

A singular-value exponent or a top-frequency concentration statistic is yet
another quantity and must not be silently identified with either exponent.

### Fine-structure constant

The electromagnetic coupling

```math
\alpha_\mathrm{EM}
=\frac{e^2}{4\pi\epsilon_0\hbar c}
```

is a dimensionless Lorentz scalar.  A frame boost changes observed fields,
energies, and wavelengths, not the coupling itself.  Its quantum running with
invariant momentum scale is a different phenomenon.

---

## 2. What a boost shifts exactly

In `1+1` dimensions, choose

```math
\begin{pmatrix}ct'\\x'\end{pmatrix}
=
\begin{pmatrix}
\cosh\eta&-\sinh\eta\\
-\sinh\eta&\cosh\eta
\end{pmatrix}
\begin{pmatrix}ct\\x\end{pmatrix}.
```

Two boosts compose as

```math
\boxed{
\Lambda(\eta_2)\Lambda(\eta_1)
=\Lambda(\eta_1+\eta_2).}
```

Thus a boost really does shift rapidity by addition.

For collinear light, the Doppler factors are

```math
D_\pm
=\gamma\left(1\mp\frac vc\right)
=e^{\mp\eta}.
```

Hence

```math
\omega'=e^{\mp\eta}\omega,
\qquad
\boxed{\log\omega'=\log\omega\mp\eta.}
```

A boost translates log frequency.  Multiplication of frequency by a fixed
factor becomes addition in the logarithmic coordinate.

This fact does not mean that every logarithmic translation is physically a
Lorentz boost.  A spacetime representation, invariant metric, and physical
boost generator are still required.

---

## 3. Why a uniform boost does not change a power-law slope

Let

```math
S(f)=Cf^{-\alpha_\mathrm{P}}.
```

For a uniform Doppler scaling `f'=Df`, preservation of integrated power gives

```math
S'(f')
=\frac1D S\left(\frac{f'}D\right)
=CD^{\alpha_\mathrm{P}-1}f'^{-\alpha_\mathrm{P}}.
```

Therefore

```math
\boxed{\alpha_\mathrm{P}'=\alpha_\mathrm{P}.}
```

The boost changes the normalization and moves features along the frequency
axis.  It does not tilt a truly scale-free spectrum.

To change a fitted exponent one needs something beyond one inertial boost:

- a scale-dependent transformation;
- accelerated or nonlinear sampling;
- restriction to a horizon wedge;
- interaction with a medium;
- or a nonunitary spectral filter.

---

## 4. Wick rotation converts the boost into a Euclidean rotation

Make the analytic continuation

```math
t=-i\tau_E,
\qquad
\eta=i\theta.
```

Since

```math
\cosh(i\theta)=\cos\theta,
\qquad
\sinh(i\theta)=i\sin\theta,
```

the Lorentz matrix becomes

```math
\boxed{
\begin{pmatrix}c\tau_E'\\x'\end{pmatrix}
=
\begin{pmatrix}
\cos\theta&\sin\theta\\
-\sin\theta&\cos\theta
\end{pmatrix}
\begin{pmatrix}c\tau_E\\x\end{pmatrix}.}
```

The hyperbolic boost has become a circular rotation.  A real Euclidean angle
corresponds to imaginary rapidity, so the Euclidean operation is not another
ordinary real boost.

That distinction is also the difference between unitary phase evolution and
nonunitary Euclidean weighting.

---

## 5. Acceleration turns rapidity into physical time

A uniformly accelerated worldline is

```math
ct(\tau_L)
=\frac{c^2}{g}\sinh\left(\frac{g\tau_L}{c}\right),
\qquad
x(\tau_L)
=\frac{c^2}{g}\cosh\left(\frac{g\tau_L}{c}\right).
```

Its rapidity is

```math
\boxed{\eta=\frac{g\tau_L}{c}.}
```

After Wick rotation, it becomes a Euclidean circle:

```math
ct_E
=\frac{c^2}{g}\sin\left(\frac{g\tau_E}{c}\right),
\qquad
x
=\frac{c^2}{g}\cos\left(\frac{g\tau_E}{c}\right).
```

The Euclidean angle is

```math
\theta=\frac{g\tau_E}{c}.
```

Smooth closure requires `theta` to have period `2 pi`.  Therefore

```math
\boxed{
\tau_\beta=\frac{2\pi c}{g},
\qquad
k_BT_U=\frac{\hbar g}{2\pi c}.}
```

This is the Unruh temperature.  For a general horizon, normalized surface
gravity `kappa` replaces `g`.

The important logical chain is

```math
\boxed{
\text{rapidity}
\xrightarrow{\;g/c\;}
\text{proper time}
\xrightarrow{\mathrm{Wick}}
\text{Euclidean angle}
\xrightarrow{2\pi\ \mathrm{closure}}
\text{temperature}.}
```

---

## 6. Modular time is normalized boost time

For the vacuum restricted to a Rindler wedge, let `B` denote the
dimensionless generator of unit Lorentz rapidity.  The modular Hamiltonian is

```math
\boxed{K=2\pi B+\text{constant}.}
```

Equivalently, modular flow by parameter `s` is a Lorentz boost of rapidity

```math
\boxed{\eta=2\pi s.}
```

Casini gives the exact trajectory

```math
t'=\cosh(2\pi s)t+\sinh(2\pi s)z,
```

```math
z'=\sinh(2\pi s)t+\cosh(2\pi s)z.
```

This relationship is a QFT result, not a numerical analogy.  See
[Casini's relative-entropy formulation of the Bekenstein bound](https://arxiv.org/abs/0804.2182).

The broader proposal that physical time should generally be identified with
state-defined modular flow is the
[Connes--Rovelli thermal-time hypothesis](https://arxiv.org/abs/gr-qc/9406019),
which should be distinguished from the geometric Rindler theorem.

---

## 7. A prime modular gap becomes a boost-charge gap

Consider a prime-labelled modular sector with

```math
\mathrm{gap}\,K_p=\log p.
```

Since `K=2 pi B`, its boost-generator gap is

```math
\boxed{
\mathrm{gap}\,B_p=\frac{\log p}{2\pi}.}
```

At acceleration `g`, its physical energy is

```math
\boxed{
E_p
=\frac{\hbar g}{c}\mathrm{gap}\,B_p
=\frac{\hbar g}{2\pi c}\log p
=k_BT_U\log p.}
```

This is exactly the modular relation

```math
\beta_UE_p=\log p.
```

Lorentzian evolution through rapidity `eta` produces

```math
e^{-iE_p\tau_L/\hbar}
=p^{-i\eta/(2\pi)}.
```

Euclidean evolution through angle `theta` produces

```math
e^{-E_p\tau_E/\hbar}
=p^{-\theta/(2\pi)}.
```

Two angles are especially important:

```math
\boxed{
\theta=\pi\Longrightarrow p^{-1/2},
\qquad
\theta=2\pi\Longrightarrow p^{-1}.}
```

The half-turn gives the relative thermofield-double amplitude.  The full turn
gives the relative Gibbs probability.  The square-root relation between
amplitude and probability is therefore a half-circle/full-circle relation in
Euclidean boost geometry.

This statement is exact once the prime modular gap is embedded in the
Rindler normalization.  Deriving that embedding from a local boundary theory
remains open.

---

## 8. Complex modular time

Let

```math
s=\sigma+it,
\qquad
\theta=2\pi\sigma,
\qquad
\eta=2\pi t.
```

Then

```math
\boxed{s=\frac{\theta+i\eta}{2\pi}}
```

and a prime gap contributes

```math
\boxed{
p^{-s}
=p^{-\sigma}e^{-it\log p}.}
```

The real coordinate is Euclidean damping.  The imaginary coordinate is
Lorentzian modular phase.

At

```math
\sigma=\frac12,
```

the Euclidean angle is `pi`, precisely the thermofield half-turn.  This gives
an exact finite-sector interpretation of the familiar prime amplitude
`p^-1/2`.

For a finite collection of primes,

```math
Z_P(s)=\prod_{p\le P}(1-p^{-s})^{-1}
```

is the partition function of independent bosonic occupation numbers with
gaps `log p`.  The infinite Euler product converges only for `Re(s)>1`.
Therefore this half-turn picture does not prove anything about all Riemann
zeros on `Re(s)=1/2`; analytic continuation and global operator structure
remain indispensable.

---

## 9. How a spectral exponent can actually be shifted

Consider the Fourier-amplitude operation

```math
X_\mathrm{out}(f)=f^{-q}X_\mathrm{in}(f).
```

This is

```math
f^{-q}=e^{-q\log f}.
```

It follows that

```math
S_\mathrm{out}(f)
=f^{-2q}S_\mathrm{in}(f).
```

If the input is a power law, then

```math
\boxed{
\alpha_{\mathrm{P,out}}
=\alpha_{\mathrm{P,in}}+2q.}
```

For an amplitude exponent,

```math
\boxed{
\alpha_{\mathrm{A,out}}
=\alpha_{\mathrm{A,in}}+q.}
```

This operation can shift a spectral `alpha`, but it is not a uniform Lorentz
boost.  It is a positive Euclidean spectral filter generated by `log f`.

Its Lorentzian continuation is

```math
f^{-it}=e^{-it\log f},
```

which has unit magnitude and changes phase rather than power.

This leads to the corrected statement:

```math
\boxed{
\text{A real boost supplies unitary phase flow; its Euclidean continuation
can supply mode reweighting.}}
```

Identifying the frequency operator `log f` with an actual physical boost
generator is an additional hypothesis that must be derived, not assumed from
the shared logarithm.

---

## 10. What is established and what remains open

### Established

- Lorentz boosts add rapidities.
- Collinear Doppler shifts translate log frequency.
- Wick rotation maps hyperbolic boosts to circular Euclidean rotations.
- Uniform acceleration fixes the Euclidean thermal period.
- Rindler modular flow is Lorentz boost flow with the `2 pi` normalization.
- A uniform Doppler scaling preserves a true power-law exponent.
- A filter `f^-q` shifts a power-spectrum exponent by `2q`.
- Given modular gap `log p`, a half Euclidean turn gives `p^-1/2` and a full
  turn gives `p^-1`.

### Open

- Deriving prime-labelled modular gaps from one local relativistic boundary
  algebra instead of choosing them in a finite model.
- Showing that a particular neural or physical log-frequency operator is the
  boundary boost generator.
- Deriving surface gravity from the same prime determinant operator.
- Extending the finite prime half-turn picture through the analytic
  continuation needed by the zeta function.

The proposed physical target can be written concisely as

```math
\boxed{
K_{\partial\mathcal D}=2\pi B_{\partial\mathcal D},
\qquad
\mathrm{gap}\,K_p=\log p.}
```

If both relations arise in the same local boundary theory, the physical
energies must obey

```math
E_p=\frac{\hbar\kappa}{2\pi c}\log p,
\qquad
\frac{E_p}{E_q}=\frac{\log p}{\log q}.
```

That operator construction—not another numerical correlation—is the next
decisive test.

## Primary references

- H. Casini,
  ["Relative entropy and the Bekenstein bound"](https://arxiv.org/abs/0804.2182).
- J. J. Bisognano and E. H. Wichmann,
  ["On the Duality Condition for a Hermitian Scalar Field"](https://doi.org/10.1063/1.522605).
- W. G. Unruh,
  ["Notes on black-hole evaporation"](https://doi.org/10.1103/PhysRevD.14.870).
- A. Connes and C. Rovelli,
  ["Von Neumann Algebra Automorphisms and Time-Thermodynamics Relation in General Covariant Quantum Theories"](https://arxiv.org/abs/gr-qc/9406019).
- G. W. Gibbons and S. W. Hawking,
  ["Action integrals and partition functions in quantum gravity"](https://doi.org/10.1103/PhysRevD.15.2752).

