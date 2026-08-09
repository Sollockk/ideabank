# Prime-Cycle Laplacian Determinants and the Riemann Euler Product

## A rigorous note on determinant lengths, Ihara special values, Möbius grading, and the missing RH operator

**Research note — 9 August 2026**

## Abstract

Represent each rational prime $p$ by a cycle graph $C_p$. For $p\ge 3$,
$C_p$ is the ordinary simple cycle; for $p=2$, use the two-vertex
multigraph with two parallel edges. The nonzero Laplacian determinant is

```math
\det{}'\Delta_{C_p}=p^2.
```

It therefore defines the spectral determinant length

```math
L_p:=\frac12\log\det{}'\Delta_{C_p}=\log p.
```

The dynamical product over one unoriented primitive channel is then

```math
\prod_p\left(1-e^{-sL_p}\right)^{-1}
=\prod_p(1-p^{-s})^{-1}
=\zeta(s),
\qquad \Re s>1.
```

The same cycle determinant occurs as the leading coefficient of the
reciprocal Ihara zeta function at $u=1$. Bosonic occupation of the prime
cycles gives the standard Riemann-gas Hamiltonian with energy
$E_n\propto\log n$, while fermionic occupation and a graded trace give
$1/\zeta(s)$, identifying squarefree exclusion with fermionic exclusion
and the Möbius sign with fermion parity.

All of these statements are exact in their stated convergence domain. They
do **not** prove the Riemann hypothesis. Ordinary Ihara length is $p$, not
$\log p$; the cycles are disconnected; the completed gamma factor is
absent; and the natural arithmetic thermal state is not normalizable on the
critical line. The note concludes by stating the connected self-adjoint
operator problem that would have to be solved for this construction to
become relevant to RH.

## 1. Scope and novelty claim

The individual ingredients used below are standard:

- the matrix-tree theorem;
- the Laplacian spectrum of a cycle;
- the Ihara zeta function of a cycle;
- Euler's product for the Riemann zeta function;
- the bosonic Riemann-gas Hamiltonian.

The contribution of this note is the exact synthesis

```math
\boxed{
C_p
\longmapsto
\det{}'\Delta_{C_p}=p^2
\longmapsto
L_p=\tfrac12\log\det{}'\Delta_{C_p}=\log p
\longmapsto
\prod_p(1-e^{-sL_p})^{-1}=\zeta(s).
}
```

Thus, once $p$ is represented by $C_p$, the prime-logarithmic energy is
supplied by a concrete finite graph operator rather than introduced as a
separate spectral postulate.

This should not be described as a new formula for $\zeta$, an ordinary
Ihara realization of $\zeta$, or a proof of RH. It is an exact graph model
for the Euler-product side and a way to formulate precisely what the model
still lacks.

## 2. Cycle conventions and the $p=2$ exception

For $n\ge 3$, let $C_n$ be the simple cycle on $n$ vertices. Its
combinatorial Laplacian is

```math
\Delta_{C_n}=D-A.
```

The notation $\det{}'\Delta$ means the product of all nonzero eigenvalues.

A simple graph on two vertices does not contain a nonbacktracking cycle:
returning along its sole edge is immediate backtracking. To include the
prime $2$ without hiding an exception, define $C_2^{\mathrm{multi}}$ to
be the graph with two vertices and two parallel edges. Its Laplacian is

```math
\Delta_{C_2^{\mathrm{multi}}}
=
\begin{pmatrix}
2&-2\\
-2&2
\end{pmatrix}.
```

Its eigenvalues are $0$ and $4$, so

```math
\det{}'\Delta_{C_2^{\mathrm{multi}}}=4=2^2.
```

It also has two oriented primitive nonbacktracking cycles of length two:
travel out along one edge and return along the other, with the two possible
orientations.

In the rest of the note, $C_2$ denotes this multigraph convention.

## 3. The cycle pseudodeterminant theorem

### Theorem 1

For every integer $n\ge2$, with the convention above at $n=2$,

```math
\boxed{\det{}'\Delta_{C_n}=n^2.}
```

### Proof

For $n\ge3$, the Laplacian eigenvalues are

```math
\lambda_k
=2-2\cos\left(\frac{2\pi k}{n}\right)
=4\sin^2\left(\frac{\pi k}{n}\right),
\qquad k=0,\ldots,n-1.
```

The zero mode is $k=0$. Hence

```math
\det{}'\Delta_{C_n}
=\prod_{k=1}^{n-1}4\sin^2\left(\frac{\pi k}{n}\right).
```

The classical identity

```math
\prod_{k=1}^{n-1}\sin\left(\frac{\pi k}{n}\right)
=\frac{n}{2^{n-1}}
```

gives

```math
\det{}'\Delta_{C_n}
=4^{n-1}\frac{n^2}{2^{2n-2}}
=n^2.
```

Alternatively, $C_n$ has exactly $n$ spanning trees. The matrix-tree
theorem states that

```math
\det{}'\Delta_G=|V(G)|\,\tau(G),
```

where $\tau(G)$ is the number of spanning trees. Thus

```math
\det{}'\Delta_{C_n}=n\cdot n=n^2.
```

The $n=2$ multigraph case was computed directly above. $\square$

## 4. The reciprocal-Ihara special value

The Ihara zeta function of a finite graph is the product over equivalence
classes of primitive, tailless, nonbacktracking oriented closed paths:

```math
Z_G(u)=\prod_{[P]}(1-u^{\ell(P)})^{-1}.
```

The cycle $C_n$ has exactly two primitive classes, corresponding to its two
orientations. Therefore

```math
Z_{C_n}(u)=(1-u^n)^{-2}.
```

### Theorem 2

For every $n\ge2$, with the same multigraph convention at $n=2$,

```math
\boxed{
\lim_{u\to1}
\frac{Z_{C_n}(u)^{-1}}{(1-u)^2}
=n^2
=\det{}'\Delta_{C_n}.
}
```

### Proof

Since

```math
1-u^n=(1-u)(1+u+\cdots+u^{n-1}),
```

we have

```math
\frac{Z_{C_n}(u)^{-1}}{(1-u)^2}
=\left(1+u+\cdots+u^{n-1}\right)^2.
```

Taking $u\to1$ gives $n^2$, which equals the pseudodeterminant by
Theorem 1. $\square$

This is a genuine ordinary-Ihara statement. Recent work also uses the
$u=1$ special value of Ihara zeta functions to recover spanning-tree data
for several graph families [1].

For a finite set of primes $\mathcal P$, let

```math
Q_{\mathcal P}=\prod_{p\in\mathcal P}p.
```

The disjoint union of the corresponding cycles then satisfies

```math
\lim_{u\to1}
(1-u)^{-2|\mathcal P|}
\prod_{p\in\mathcal P}Z_{C_p}(u)^{-1}
=Q_{\mathcal P}^2.
```

## 5. Determinant length and the Riemann Euler product

Ordinary Ihara zeta uses combinatorial path length. If $u=e^{-s}$, then

```math
Z_{C_p}(e^{-s})=(1-e^{-sp})^{-2}.
```

This is **not** a Riemann Euler factor. In particular,

```math
e^{-sp}\ne p^{-s}.
```

The cycle Laplacian supplies a different, spectral quantity.

### Definition 1: determinant length

Define

```math
L_n
:=\frac12\log\det{}'\Delta_{C_n}.
```

Theorem 1 implies

```math
L_n=\log n.
```

This is the logarithm of the inverse Gaussian weight of the relative cycle
modes:

```math
\left(\det{}'\Delta_{C_n}\right)^{-1/2}
=e^{-L_n}
=\frac1n.
```

### Definition 2: determinant-length dynamical product

Identify orientation reversal and assign one primitive channel to each
prime. Define

```math
\mathfrak Z_{\det}(s)
:=\prod_p\left(1-e^{-sL_p}\right)^{-1}.
```

This is a new product constructed from the cycle determinant lengths. It is
not the ordinary Ihara zeta function of the disjoint union.

### Theorem 3

For $\Re s>1$,

```math
\boxed{\mathfrak Z_{\det}(s)=\zeta(s).}
```

### Proof

Theorem 1 gives

```math
e^{-sL_p}
=\exp\left(-\frac{s}{2}\log p^2\right)
=p^{-s}.
```

Consequently

```math
\mathfrak Z_{\det}(s)
=\prod_p(1-p^{-s})^{-1}
=\zeta(s)
```

in the half-plane where Euler's product converges absolutely. $\square$

If both orientations are retained as independent channels, the result is
$\zeta(s)^2$. One copy of $\zeta$ therefore corresponds to identifying
orientation reversal or choosing one orientation.

## 6. Energy, Euclidean time, and temperature

Introduce a Euclidean time unit $\tau_0$ and its conjugate energy unit

```math
\varepsilon_0:=\frac{\hbar}{\tau_0}.
```

Assign to the prime cycle the energy

```math
E_p:=\varepsilon_0L_p=\varepsilon_0\log p.
```

For Euclidean duration $\tau=s\tau_0$, its action and propagation weight
are

```math
\frac{S_{E,p}}{\hbar}
=\frac{E_p\tau}{\hbar}
=s\log p,
```

and

```math
e^{-S_{E,p}/\hbar}=p^{-s}.
```

At temperature $T$, Euclidean time has period

```math
\tau=\hbar\beta=\frac{\hbar}{k_BT},
```

so

```math
s=\frac{\tau}{\tau_0}
=\beta\varepsilon_0
=\frac{\varepsilon_0}{k_BT}.
```

The defensible interpretation is therefore

```math
\boxed{
\text{energy is conjugate to time},\qquad
\text{action is time-integrated energy},\qquad
\text{inverse temperature is Euclidean time divided by }\hbar.
}
```

Energy and time are not the same dimensionful quantity. Their product,
divided by $\hbar$, is the dimensionless exponent controlling the
Euclidean weight.

## 7. Bosonic occupations and unique factorization

Give every prime a bosonic occupation number

```math
N_p\in\{0,1,2,\ldots\}
```

and define

```math
H_B=\varepsilon_0\sum_p(\log p)N_p.
```

A finite occupation vector corresponds by unique factorization to exactly
one positive integer

```math
n=\prod_pp^{N_p}.
```

Its energy is

```math
E_n
=\varepsilon_0\sum_pN_p\log p
=\varepsilon_0\log n.
```

It follows that

```math
\begin{aligned}
\mathrm{Tr}\,e^{-sH_B/\varepsilon_0}
&=\prod_p\sum_{m=0}^{\infty}p^{-sm}\\
&=\prod_p(1-p^{-s})^{-1}\\
&=\sum_{n=1}^{\infty}n^{-s}\\
&=\zeta(s),
\qquad \Re s>1.
\end{aligned}
```

This is the standard bosonic Riemann-gas construction [2]. The additional
finite-operator observation here is that each prime-logarithmic oscillator
energy is the half-logarithm of a cycle Laplacian pseudodeterminant.

## 8. Fermionic occupations and the Möbius function

Now impose fermionic occupation

```math
F_p\in\{0,1\}.
```

In the graded trace, the occupied state contributes a minus sign. Hence

```math
\begin{aligned}
\mathrm{Str}\,e^{-sH_F/\varepsilon_0}
&=\prod_p(1-p^{-s})\\
&=\sum_{n=1}^{\infty}\frac{\mu(n)}{n^s}\\
&=\frac1{\zeta(s)},
\qquad \Re s>1.
\end{aligned}
```

This gives the exact dictionary

```math
\boxed{
\text{squarefree integer}
\longleftrightarrow
\text{fermionic prime occupation},
\qquad
\mu(n)
\longleftrightarrow
\text{fermion parity}.
}
```

The state with no occupied prime channels corresponds to $n=1$ and has
even parity, giving $\mu(1)=+1$.

## 9. The arithmetic thermofield double and its boundary

For real $s>1$, define

```math
|\mathrm{TFD}(s)\rangle
=\frac1{\sqrt{\zeta(s)}}
\sum_{n\ge1}n^{-s/2}|n\rangle_L|n\rangle_R.
```

The two copies carry equal energy, so

```math
(H_L-H_R)|\mathrm{TFD}(s)\rangle=0.
```

In general,

```math
(H_L+H_R)|\mathrm{TFD}(s)\rangle\ne0.
```

Thus the state has null **relative** time translation, not zero total
energy.

Its normalization is also a sharp obstruction:

```math
\|\mathrm{TFD}(s)\|^2
=\sum_{n\ge1}n^{-s}
=\zeta(s),
```

which converges for real $s>1$. At $s=1/2$, the candidate state is not a
Hilbert-space vector. Zeta as a partition function is therefore not a
Hilbert--Pólya operator, and zeros at complex inverse temperature are not
eigenvalues of $H_B$.

## 10. Prime repetitions and the von Mangoldt trace

Logarithmically differentiating Theorem 3 in $\Re s>1$ gives

```math
\begin{aligned}
-\frac{\zeta'(s)}{\zeta(s)}
&=\sum_p\frac{\log p}{p^s-1}\\
&=\sum_p\sum_{r\ge1}(\log p)e^{-sr\log p}\\
&=\sum_{n\ge1}\frac{\Lambda(n)}{n^s}.
\end{aligned}
```

The determinant-cycle data consequently have the standard primitive-orbit
form

```math
\boxed{
\text{primitive length}=\log p,
\quad
\text{repetition length}=r\log p,
\quad
\text{weight}=\log p.
}
```

Formally setting $s=1/2+it$ produces the oscillatory term

```math
$(\log p)p^{-r/2}e^{-itr\log p}$,
```

which is the prime-power phase structure in explicit formulas. This
substitution is not a proof step: the derivation above holds in
$\Re s>1$, while passage to the critical line requires analytic
continuation and distributional regularization.

## 11. A finite exact example

Let

```math
\mathcal P=\{p:5\le p\le157\}.
```

There are $35$ primes in this set, and

```math
Q=\prod_{p\in\mathcal P}p
=5895861165619582473439294514658624035342928441314996237071645.
```

The direct sum of their cycle Laplacians satisfies

```math
\det{}'\left(\bigoplus_{p\in\mathcal P}\Delta_{C_p}\right)
=Q^2.
```

Its normalized Gaussian relative-mode factor is

```math
\left[
\det{}'\left(\bigoplus_{p\in\mathcal P}\Delta_{C_p}\right)
\right]^{-1/2}
=Q^{-1}.
```

Squaring the amplitude, or using two identical Gaussian copies, gives

```math
Q^{-2}
=2.876772399835876\times10^{-122}.
```

This number is an exact consequence of the declared finite graph model. No
physical or cosmological interpretation of it follows from the determinant
identity alone.

## 12. Knots: a useful analogy and a warning

Weighted knot-diagram walks can realize Alexander-type invariants as
Ihara-type zeta functions [3]. For the trefoil,

```math
\Delta_{3_1}(t)=t^2-t+1,
```

so

```math
\Delta_{3_1}(-m)=m^2+m+1=\Phi_3(m).
```

This is an exact common cyclotomic polynomial, but it does not identify a
cycle graph with a trefoil knot.

A more strategic lesson comes from connected sum. Alexander polynomials
multiply:

```math
\Delta_{K\#J}(t)=\Delta_K(t)\Delta_J(t).
```

Nevertheless, explicit knots are now known for which unknotting number is
strictly subadditive:

```math
u(K\#J)\lt u(K)+u(J) [4].
```

Thus an additive log-determinant does not, by itself, determine a global
minimum-complexity operation. Cross-component moves can lower the optimum
while the multiplicative invariant remains exact. For the present model,
this suggests that isolated prime cycles can encode Euler factors, while
the cancellations relevant to zeta zeros must reside in a connected gluing
or mixed-prime interaction.

## 13. Why ordinary graph RH does not settle classical RH here

For a connected $(q+1)$-regular graph with $q>1$, the Ramanujan condition
is equivalent to a graph-zeta analogue of RH in which nontrivial Ihara poles
lie on

```math
|u|=q^{-1/2} [5].
```

A cycle is $2$-regular, so $q=1$. The critical circle degenerates to

```math
|u|=1,
```

and the usual parameterization $u=q^{-s}$ becomes $u=1$ for every
$s$. It cannot select $\Re s=1/2$.

Moreover, $\mathfrak Z_{\det}$ is an infinite, disconnected,
spectrally reweighted product—not the ordinary Ihara zeta function of a
finite regular graph. Finite Bass determinant and Ramanujan-graph theorems
therefore do not imply RH for this construction.

## 14. The self-adjointness trap

The operator

```math
H|n\rangle=\varepsilon_0\log n\,|n\rangle
```

on $\ell^2(\mathbb N)$ is self-adjoint on its natural domain, and

```math
\mathrm{Tr}\,e^{-sH/\varepsilon_0}=\zeta(s)
```

for real $s>1$. It is not a Hilbert--Pólya operator:

1. its eigenvalues are $\varepsilon_0\log n$, not zero ordinates;
2. zeta zeros are zeros of a complex-temperature continuation, not
   eigenvalues of $H$;
3. the heat operator is not trace class at $\Re s\le1$;
4. analytic continuation is not an ordinary positive thermal trace.

Quantum graphs can reproduce the oscillatory prime-orbit part of the zero
density while retaining a different smooth term and therefore a different
full spectrum [6]. Matching the prime oscillations is necessary but not
sufficient.

## 15. The exact open operator problem

The local determinant data suggest the following sharply stated target.

### Determinant-cycle completion problem

Construct a connected operator $D$ on a completed, graded prime-cycle
space and prove all of the following:

1. **Self-adjointness.** $D$ is self-adjoint on an explicit dense domain.

2. **Valid determinant theory.** $D$ admits a relative, Fredholm, or
   zeta-regularized determinant under proved summability and heat-trace
   hypotheses [7].

3. **Prime trace.** Its trace formula contains primitive lengths
   $\log p$, repeated lengths $r\log p$, and the correct amplitudes
   $(\log p)p^{-r/2}$.

4. **Mixed-path control.** Connecting the cycles creates new primitive
   paths involving several primes. These paths must reproduce exactly the
   required composite terms or cancel through a proved grading mechanism.

5. **Archimedean completion.** The smooth term must generate the
   $\pi^{-s/2}\Gamma(s/2)$ factor and the correct zero-counting
   asymptotic.

6. **Secular identity.** There is an entire nowhere-zero function $E(t)$
   such that

   ```math
   \det_{\mathrm{rel}}(D-t)
   =E(t)\,\xi\left(\frac12+it\right).
   ```

If such an identity were proved for self-adjoint $D$, all zeros of the
right-hand side would occur at real spectral parameters $t$, and RH would
follow. Condition 6 is the missing theorem; it is not implied by the finite
cycle identities.

## 16. Status table

| Statement | Status |
|---|---|
| $\det{}'\Delta_{C_n}=n^2$ | Proved; standard cycle/matrix-tree identity |
| $Z_{C_n}(u)=(1-u^n)^{-2}$ | Proved; standard Ihara formula |
| The normalized reciprocal-Ihara coefficient at $u=1$ is $n^2$ | Proved exactly |
| $L_p=\frac12\log\det{}'\Delta_{C_p}=\log p$ | Proved in the declared cycle model |
| $\mathfrak Z_{\det}(s)=\zeta(s)$ for $\Re s>1$ | Proved exactly |
| $\mathfrak Z_{\det}$ is ordinary Ihara zeta under $u=e^{-s}$ | False; ordinary length is $p$ |
| Bosonic occupation gives $E_n\propto\log n$ and partition function $\zeta(s)$ | Proved for $\Re s>1$ |
| Fermionic supertrace gives $1/\zeta(s)$ and Möbius parity | Proved for $\Re s>1$ |
| The arithmetic TFD is normalizable on the critical line | False |
| Ramanujan graph RH for cycles proves classical RH | False; $q=1$ degenerates |
| The prime cycles already define a Hilbert--Pólya operator | False |
| A connected completion satisfying conditions 1--6 exists | Open |

## 17. Conclusion

The exact result is modest but structurally clean:

```math
\boxed{
\text{prime cycles provide finite operators whose one-loop determinant
lengths are precisely the Riemann primitive lengths }\log p.
}
```

This construction simultaneously explains the Euler factors, the
prime-power repetitions in $-\zeta'/\zeta$, the bosonic integer spectrum,
and the Möbius function as a fermionic supertrace. It also exposes the
boundary of the construction: independent Euler factors do not provide the
global connected interference, archimedean term, determinant class, or
self-adjoint secular identity required for RH.

The most promising next question is consequently not whether another
finite prime product approximates a zeta zero. It is whether the prime-cycle
relative spaces admit a connected graded gluing whose mixed paths,
archimedean sector, and relative determinant can all be controlled at once.

## References

1. M. Chico, T. W. Mattman, and A. Richards, “Ihara zeta functions for some
   simple graph families,” 2024. <https://arxiv.org/abs/2501.00639>

2. J. G. Dueñas and N. F. Svaiter, “Thermodynamics of the Bosonic Randomized
   Riemann Gas,” 2014. <https://arxiv.org/abs/1401.8190>

3. Z. Zhuang, “Ihara zeta function and twisted Alexander invariants,” 2021.
   <https://arxiv.org/abs/2104.00215>

4. M. Brittenham and S. Hermiller, “Unknotting number is not additive under
   connected sum,” revised 2025. <https://arxiv.org/abs/2506.24088>

5. H.-W. Huang, “Ihara zeta function, coefficients of Maclaurin series, and
   Ramanujan graphs,” 2020. <https://arxiv.org/abs/1905.13485>

6. J. Kuipers, Q. Hummel, and K. Richter, “Quantum graphs whose spectra
   mimic the zeros of the Riemann zeta function,” *Physical Review Letters*
   **112**, 070406 (2014). <https://arxiv.org/abs/1307.6055>

7. L. Hartmann and M. Lesch, “Zeta and Fredholm determinants of self-adjoint
   operators,” 2022. <https://arxiv.org/abs/2106.02444>
