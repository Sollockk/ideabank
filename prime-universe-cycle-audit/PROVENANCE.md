# Provenance and scope

This package develops selected mathematical claims from the research manuscript
`experiments/PRIME_UNIVERSE_THEORY.md` in the originating
`Sollockk/ik_llama_cpp_frankenstein` workspace. The manuscript itself is not a
build dependency and is not bundled with this mathematical note.

- Manuscript SHA-256 used by the original 60-statement audit: `892231a01a8de065f6008b3619a0e4aac723f9a38645bdd71d5e788ae7223253`.
- Manuscript SHA-256 at the start of this extension: `273b2cf0bd148b0cb84398e738501a439f178eb147f644b40cbb5f09062bb43a`.
- Initial audit completed: `2026-09-29T05:13:31.375365+00:00`.
- Source-to-Lean translation: manual, with assumptions documented in theorem
  signatures and in `CLAIMS.md`.

The extension supplies an actual cycle graph Laplacian, its Fourier
coordinate representation, its constant mode, and a concrete determinant.
These are established mathematical structures. The package does not claim a
new discovery of the cycle spectrum, Fourier diagonalization, the Möbius
identity, complementarity, or the CHSH inequality.

The proposed physical interpretation remains separate. No statement in this
package identifies an integer with a physical force, derives a cosmological
constant, establishes a quantum speedup, or proves the Riemann hypothesis.

The numbered source anchors used by the formalization are:

| Source chapters | Equations or subject |
|---|---|
| 1 and 40 | Möbius divisor cancellation |
| 59 and 85 | Conditional Bell correlation and the locality question |
| 66 and 145 | Finite product/subset expansion and paired states |
| 143 | 143.30--143.41: reciprocal radius and action bookkeeping |
| 145 and 149 | Matching-energy paired generators and reduced states |
| 146 | 146.18--146.22: cycle spectrum, determinant and logarithmic action |
| 149 | 149.2--149.25: the specified two-level modular cell |
| 150 | 150.1--150.5: scale degeneracy |

The formalization extends the initial audit; the packaged Bell counterexample
uses `P(A=+1)=1/2`, so both conditioning branches have positive probability.

Dependencies are pinned to Lean 4.34.0 and mathlib commit
`5ed2965256430c3649e86755f9576b54eca72435`. Mathlib is imported as an external
Apache-2.0 dependency, not copied into this package. The originating repository's
MIT license is preserved in `LICENSE`.

Primary library references:

- [Root-of-unity product](https://github.com/leanprover-community/mathlib4/blob/5ed2965256430c3649e86755f9576b54eca72435/Mathlib/RingTheory/RootsOfUnity/Lemmas.lean)
- [Invertible Fourier transform on ZMod](https://github.com/leanprover-community/mathlib4/blob/5ed2965256430c3649e86755f9576b54eca72435/Mathlib/Analysis/Fourier/ZMod.lean)
- [Cycle graph definition](https://github.com/leanprover-community/mathlib4/blob/5ed2965256430c3649e86755f9576b54eca72435/Mathlib/Combinatorics/SimpleGraph/CycleGraph.lean)
- [Graph Laplacian](https://github.com/leanprover-community/mathlib4/blob/5ed2965256430c3649e86755f9576b54eca72435/Mathlib/Combinatorics/SimpleGraph/LapMatrix.lean)
- [Lean axiom auditing](https://lean-lang.org/doc/reference/latest/Axioms/)
