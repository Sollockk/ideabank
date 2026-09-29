import PrimeUniverse.CycleProduct
import Mathlib.Analysis.Fourier.ZMod
import Mathlib.Combinatorics.SimpleGraph.CycleGraph
import Mathlib.Combinatorics.SimpleGraph.LapMatrix
import Mathlib.LinearAlgebra.Determinant
import Mathlib.Tactic.LinearCombination

/-! A concrete cyclic Laplacian, with its complete Fourier diagonalization.
The operator is specified by local neighboring differences, independently of
its spectrum. It agrees with the simple cycle graph Laplacian for n >= 3. -/

noncomputable section
namespace PrimeUniverse.CycleLaplacian

open Matrix

variable {vertexCount : ℕ} [NeZero vertexCount]

def cycleOperator (vector : ZMod vertexCount → ℂ) (vertex : ZMod vertexCount) : ℂ :=
  2 * vector vertex - vector (vertex + 1) - vector (vertex - 1)

def eigenvalue (frequency : ZMod vertexCount) : ℂ :=
  2 - ZMod.stdAddChar frequency - ZMod.stdAddChar (-frequency)

theorem fourier_translation (vector : ZMod vertexCount → ℂ)
    (offset frequency : ZMod vertexCount) :
    ZMod.dft (fun vertex => vector (vertex + offset)) frequency =
      ZMod.stdAddChar (offset * frequency) * ZMod.dft vector frequency := by
  simp only [ZMod.dft_apply, smul_eq_mul, Finset.mul_sum]
  refine Fintype.sum_equiv (Equiv.addRight offset) _ _ ?_
  intro vertex
  simp only [Equiv.coe_addRight]
  rw [← mul_assoc, ← AddChar.map_add_eq_mul]
  have exponent_identity : offset * frequency + -((vertex + offset) * frequency) =
      -(vertex * frequency) := by ring
  rw [exponent_identity]

theorem fourier_diagonalizes_cycle (vector : ZMod vertexCount → ℂ)
    (frequency : ZMod vertexCount) :
    ZMod.dft (cycleOperator vector) frequency = eigenvalue frequency * ZMod.dft vector frequency := by
  have operator_expression : cycleOperator vector = (2 : ℂ) • vector -
      (fun vertex => vector (vertex + 1)) - (fun vertex => vector (vertex + -1)) := by
    funext vertex
    simp [cycleOperator, sub_eq_add_neg]
  rw [operator_expression, map_sub, map_sub, map_smul]
  simp only [Pi.sub_apply, Pi.smul_apply, smul_eq_mul, fourier_translation,
    one_mul, neg_one_mul, eigenvalue]
  ring

theorem graph_laplacian_local_rule (extraVertices : ℕ)
    (vector : Fin (extraVertices + 3) → ℂ) (vertex : Fin (extraVertices + 3)) :
    ((SimpleGraph.cycleGraph (extraVertices + 3)).lapMatrix ℂ *ᵥ vector) vertex =
      2 * vector vertex - vector (vertex + 1) - vector (vertex - 1) := by
  have neighbors_distinct : vertex - 1 ≠ vertex + 1 := by
    simp only [ne_eq, sub_eq_iff_eq_add, add_assoc vertex, left_eq_add]
    exact ne_of_beq_false rfl
  rw [SimpleGraph.lapMatrix_mulVec_apply, SimpleGraph.cycleGraph_degree_three_le,
    SimpleGraph.cycleGraph_neighborFinset, Finset.sum_pair neighbors_distinct]
  norm_num
  ring

theorem graph_laplacian_is_cycle_operator (extraVertices : ℕ)
    (vector : ZMod (extraVertices + 3) → ℂ) (vertex : Fin (extraVertices + 3)) :
    ((SimpleGraph.cycleGraph (extraVertices + 3)).lapMatrix ℂ *ᵥ
      (fun position => vector (ZMod.finEquiv (extraVertices + 3) position))) vertex =
        cycleOperator vector (ZMod.finEquiv (extraVertices + 3) vertex) := by
  rw [graph_laplacian_local_rule]
  simp only [cycleOperator, map_add, map_sub, map_one]

theorem negative_character_is_conjugate (frequency : ZMod vertexCount) :
    ZMod.stdAddChar (-frequency) = star (ZMod.stdAddChar frequency) := by
  simp only [ZMod.stdAddChar_apply, AddChar.map_neg_eq_inv]
  simpa only [Circle.coe_inv, Complex.star_def] using
    Circle.coe_inv_eq_conj (ZMod.toCircle frequency)

theorem eigenvalue_is_chord_squared (frequency : ZMod vertexCount) :
    eigenvalue frequency = (Complex.normSq (1 - ZMod.stdAddChar frequency) : ℂ) := by
  have unit_norm : Complex.normSq (ZMod.stdAddChar frequency) = 1 := by
    simp [ZMod.stdAddChar_apply]
  rw [eigenvalue, negative_character_is_conjugate, Complex.normSq_eq_conj_mul_self]
  have unit_product := Complex.normSq_eq_conj_mul_self (z := ZMod.stdAddChar frequency)
  rw [unit_norm] at unit_product
  simp only [Complex.ofReal_one] at unit_product
  simp only [map_sub, map_one, Complex.star_def]
  linear_combination unit_product

theorem only_zero_frequency_has_zero_eigenvalue (frequency : ZMod vertexCount) :
    eigenvalue frequency = 0 ↔ frequency = 0 := by
  rw [eigenvalue_is_chord_squared, Complex.ofReal_eq_zero, Complex.normSq_eq_zero,
    sub_eq_zero]
  have character_zero : ZMod.stdAddChar (0 : ZMod vertexCount) = 1 :=
    AddChar.map_zero_eq_one _
  rw [← character_zero, ZMod.injective_stdAddChar.eq_iff, eq_comm]

def cycleLinearMap : (ZMod vertexCount → ℂ) →ₗ[ℂ] (ZMod vertexCount → ℂ) where
  toFun := cycleOperator
  map_add' firstVector secondVector := by
    funext vertex
    simp only [cycleOperator, Pi.add_apply]
    ring
  map_smul' scalar vector := by
    funext vertex
    simp only [cycleOperator, Pi.smul_apply, smul_eq_mul, RingHom.id_apply]
    ring

end PrimeUniverse.CycleLaplacian
