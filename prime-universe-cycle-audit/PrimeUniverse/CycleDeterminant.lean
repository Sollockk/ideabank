import PrimeUniverse.CycleLaplacian

/-! Removing the common constant mode by adding its mean projection.
The determinant here belongs to a concrete matrix with local cycle entries,
not to a function defined as the desired spectral product. -/

noncomputable section
namespace PrimeUniverse.CycleDeterminant

open Matrix CycleLaplacian

variable {vertexCount : ℕ} [NeZero vertexCount]

def averageProjection : (ZMod vertexCount → ℂ) →ₗ[ℂ] (ZMod vertexCount → ℂ) where
  toFun vector _ := (vertexCount : ℂ)⁻¹ * ∑ vertex, vector vertex
  map_add' firstVector secondVector := by
    funext vertex
    simp only [Pi.add_apply, Finset.sum_add_distrib, mul_add]
  map_smul' scalar vector := by
    funext vertex
    simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply, ← Finset.mul_sum]
    ring

def regularizedLinearMap : (ZMod vertexCount → ℂ) →ₗ[ℂ] (ZMod vertexCount → ℂ) :=
  cycleLinearMap + averageProjection

def regularizedEigenvalue (frequency : ZMod vertexCount) : ℂ :=
  if frequency = 0 then 1 else eigenvalue frequency

def regularizedMatrix : Matrix (ZMod vertexCount) (ZMod vertexCount) ℂ :=
  LinearMap.toMatrix' regularizedLinearMap

theorem character_sum (frequency : ZMod vertexCount) :
    (∑ vertex : ZMod vertexCount, ZMod.stdAddChar (-(vertex * frequency))) =
      if frequency = 0 then (vertexCount : ℂ) else 0 := by
  split_ifs with frequency_zero
  · subst frequency
    simp
  · have character_nontrivial :=
      ZMod.isPrimitive_stdAddChar vertexCount (neg_ne_zero.mpr frequency_zero)
    simpa only [AddChar.mulShift_apply, mul_neg, neg_mul, mul_comm] using
      AddChar.sum_eq_zero_of_ne_one character_nontrivial

theorem fourier_constant (constant : ℂ) (frequency : ZMod vertexCount) :
    ZMod.dft (fun _ : ZMod vertexCount => constant) frequency =
      if frequency = 0 then (vertexCount : ℂ) * constant else 0 := by
  simp only [ZMod.dft_apply, smul_eq_mul, ← Finset.sum_mul, character_sum,
    ite_mul, zero_mul]

theorem fourier_average_projection (vector : ZMod vertexCount → ℂ)
    (frequency : ZMod vertexCount) :
    ZMod.dft (averageProjection vector) frequency =
      if frequency = 0 then ZMod.dft vector 0 else 0 := by
  change ZMod.dft (fun _ => (vertexCount : ℂ)⁻¹ * ∑ vertex, vector vertex) frequency = _
  rw [fourier_constant]
  split_ifs
  · rw [ZMod.dft_apply_zero, ← mul_assoc, mul_inv_cancel₀ (NeZero.ne (vertexCount : ℂ)), one_mul]
  · rfl

theorem average_projection_is_idempotent (vector : ZMod vertexCount → ℂ) :
    averageProjection (averageProjection vector) = averageProjection vector := by
  apply ZMod.dft.injective
  funext frequency
  rw [fourier_average_projection, fourier_average_projection]
  simp only [fourier_average_projection, ite_true]

theorem zero_modes_are_exactly_constants (vector : ZMod vertexCount → ℂ) :
    cycleOperator vector = 0 ↔ ∃ constant : ℂ, vector = fun _ => constant := by
  constructor
  · intro zero_mode
    refine ⟨(vertexCount : ℂ)⁻¹ * ∑ vertex, vector vertex, ?_⟩
    change vector = averageProjection vector
    apply ZMod.dft.injective
    funext frequency
    rw [fourier_average_projection]
    split_ifs with frequency_zero
    · subst frequency
      rfl
    · have zero_coefficient : ZMod.dft (cycleOperator vector) frequency = 0 := by
        rw [zero_mode, map_zero]
        rfl
      rw [fourier_diagonalizes_cycle] at zero_coefficient
      exact (mul_eq_zero.mp zero_coefficient).resolve_left
        ((only_zero_frequency_has_zero_eigenvalue frequency).not.mpr frequency_zero)
  · rintro ⟨constant, rfl⟩
    funext vertex
    simp [cycleOperator]
    ring

theorem fourier_regularized_operator (vector : ZMod vertexCount → ℂ)
    (frequency : ZMod vertexCount) :
    ZMod.dft (regularizedLinearMap vector) frequency =
      regularizedEigenvalue frequency * ZMod.dft vector frequency := by
  simp only [regularizedLinearMap, LinearMap.add_apply, map_add, Pi.add_apply]
  change ZMod.dft (cycleOperator vector) frequency +
    ZMod.dft (averageProjection vector) frequency = _
  rw [fourier_diagonalizes_cycle, fourier_average_projection]
  unfold regularizedEigenvalue
  split_ifs with frequency_zero
  · subst frequency
    norm_num [eigenvalue]
  · ring

theorem regularized_matrix_entries (row column : ZMod vertexCount) :
    regularizedMatrix row column =
      (if row = column then 2 else 0) - (if row + 1 = column then 1 else 0) -
        (if row - 1 = column then 1 else 0) + (vertexCount : ℂ)⁻¹ := by
  simp [regularizedMatrix, LinearMap.toMatrix'_apply, regularizedLinearMap,
    cycleLinearMap, cycleOperator, averageProjection, Pi.single_apply, mul_ite]

theorem fourier_conjugation_is_diagonal :
    ((ZMod.dft (N := vertexCount) (E := ℂ)).toLinearMap ∘ₗ regularizedLinearMap ∘ₗ
      ZMod.dft.symm.toLinearMap) =
      Matrix.toLin' (Matrix.diagonal (regularizedEigenvalue (vertexCount := vertexCount))) := by
  apply LinearMap.ext
  intro vector
  funext frequency
  change ZMod.dft (regularizedLinearMap (ZMod.dft.symm vector)) frequency =
    (Matrix.diagonal regularizedEigenvalue *ᵥ vector) frequency
  rw [Matrix.mulVec_diagonal, fourier_regularized_operator, ZMod.dft.apply_symm_apply]

theorem regularized_determinant_is_eigenvalue_product :
    (regularizedMatrix (vertexCount := vertexCount)).det =
      ∏ frequency : ZMod vertexCount, regularizedEigenvalue frequency := by
  rw [regularizedMatrix, LinearMap.det_toMatrix', ← LinearMap.det_conj _ ZMod.dft,
    fourier_conjugation_is_diagonal, LinearMap.det_toLin', Matrix.det_diagonal]

theorem character_at_successor (nonzeroModeCount : ℕ) (frequency : Fin nonzeroModeCount) :
    ZMod.stdAddChar (ZMod.finEquiv (nonzeroModeCount + 1) frequency.succ) =
      Complex.exp (2 * Real.pi * Complex.I / (nonzeroModeCount + 1)) ^ (frequency.val + 1) := by
  rw [ZMod.stdAddChar_apply, ZMod.toCircle_apply, ← Complex.exp_nat_mul]
  congr 1
  change 2 * (Real.pi : ℂ) * Complex.I * ((frequency.val + 1 : ℕ) : ℂ) /
    ((nonzeroModeCount + 1 : ℕ) : ℂ) = _
  push_cast
  ring

theorem regularized_eigenvalue_product (nonzeroModeCount : ℕ) :
    (∏ frequency : ZMod (nonzeroModeCount + 1), regularizedEigenvalue frequency) =
      ((nonzeroModeCount : ℂ) + 1) ^ 2 := by
  let root : ℂ := Complex.exp (2 * Real.pi * Complex.I / (nonzeroModeCount + 1))
  have root_primitive : IsPrimitiveRoot root (nonzeroModeCount + 1) := by
    convert Complex.isPrimitiveRoot_exp (nonzeroModeCount + 1) (Nat.succ_ne_zero _) using 1
    simp [root]
  rw [← (ZMod.finEquiv (nonzeroModeCount + 1)).toEquiv.prod_comp regularizedEigenvalue,
    Fin.prod_univ_succ]
  have zero_eigenvalue : regularizedEigenvalue (0 : ZMod (nonzeroModeCount + 1)) = 1 := by
    simp [regularizedEigenvalue]
  change regularizedEigenvalue (ZMod.finEquiv (nonzeroModeCount + 1) 0) *
    (∏ frequency : Fin nonzeroModeCount,
      regularizedEigenvalue (ZMod.finEquiv (nonzeroModeCount + 1) frequency.succ)) = _
  rw [map_zero, zero_eigenvalue, one_mul]
  calc
    (∏ frequency : Fin nonzeroModeCount,
      regularizedEigenvalue (ZMod.finEquiv (nonzeroModeCount + 1) frequency.succ)) =
        ∏ frequency : Fin nonzeroModeCount,
          (Complex.normSq (1 - root ^ (frequency.val + 1)) : ℂ) := by
      apply Finset.prod_congr rfl
      intro frequency _
      have successor_not_zero : ZMod.finEquiv (nonzeroModeCount + 1) frequency.succ ≠ 0 := by
        intro contradiction
        apply Fin.succ_ne_zero frequency
        apply (ZMod.finEquiv (nonzeroModeCount + 1)).injective
        simpa only [map_zero] using contradiction
      simp only [regularizedEigenvalue, successor_not_zero, ite_false]
      rw [eigenvalue_is_chord_squared, character_at_successor]
    _ = (CycleProduct.spectralProduct nonzeroModeCount root : ℂ) := by
      change (∏ frequency : Fin nonzeroModeCount,
        Complex.ofRealHom (Complex.normSq (1 - root ^ (frequency.val + 1)))) =
          Complex.ofRealHom (CycleProduct.spectralProduct nonzeroModeCount root)
      rw [← map_prod Complex.ofRealHom]
      congr 1
      exact Fin.prod_univ_eq_prod_range
        (fun mode => Complex.normSq (1 - root ^ (mode + 1))) nonzeroModeCount
    _ = ((nonzeroModeCount : ℂ) + 1) ^ 2 := by
      rw [CycleProduct.root_product_squared _ _ root_primitive]
      push_cast
      rfl

/-- The concrete matrix determinant after replacing the sole constant zero
mode by eigenvalue one. For n >= 3 this is the cycle Laplacian pseudodeterminant. -/
theorem concrete_cycle_determinant (nonzeroModeCount : ℕ) :
    (regularizedMatrix (vertexCount := nonzeroModeCount + 1)).det =
      ((nonzeroModeCount : ℂ) + 1) ^ 2 := by
  rw [regularized_determinant_is_eigenvalue_product, regularized_eigenvalue_product]

theorem concrete_cycle_logarithmic_action (nonzeroModeCount : ℕ) :
    (1 / 2 : ℝ) * Real.log
      ((regularizedMatrix (vertexCount := nonzeroModeCount + 1)).det.re) =
        Real.log ((nonzeroModeCount : ℝ) + 1) := by
  rw [concrete_cycle_determinant]
  have real_part : (((nonzeroModeCount : ℂ) + 1) ^ 2).re =
      ((nonzeroModeCount : ℝ) + 1) ^ 2 := by
    simp [pow_two, Complex.mul_re]
  rw [real_part, Real.log_pow]
  ring

theorem composite_four_matrix_determinant :
    (regularizedMatrix (vertexCount := 4)).det = 16 := by
  have determinant_identity := concrete_cycle_determinant 3
  norm_num at determinant_identity
  exact determinant_identity

/-- Relabeling the concrete matrix by Fin gives the ordinary graph Laplacian
plus the matrix of the constant-mode projection. -/
theorem regularized_matrix_is_graph_laplacian_plus_mean (extraVertices : ℕ) :
    (regularizedMatrix (vertexCount := extraVertices + 3)).submatrix
      (ZMod.finEquiv (extraVertices + 3)) (ZMod.finEquiv (extraVertices + 3)) =
        (SimpleGraph.cycleGraph (extraVertices + 3)).lapMatrix ℂ +
          Matrix.of (fun (_ _ : Fin (extraVertices + 3)) =>
            ((extraVertices + 3 : ℕ) : ℂ)⁻¹) := by
  ext row column
  rw [Matrix.submatrix_apply, regularized_matrix_entries]
  have graph_entry := graph_laplacian_local_rule extraVertices
    (Pi.single column (1 : ℂ)) row
  simp only [Matrix.mulVec_single_one, Matrix.col_apply, Pi.single_apply,
    mul_ite, mul_one, mul_zero] at graph_entry
  rw [Matrix.add_apply, graph_entry]
  simp only [← map_one (ZMod.finEquiv (extraVertices + 3)), ← map_add, ← map_sub,
    (ZMod.finEquiv (extraVertices + 3)).injective.eq_iff, Matrix.of_apply]

/-- A theorem about the actual simple graph matrix, for every n >= 3. -/
theorem simple_cycle_matrix_determinant (extraVertices : ℕ) :
    ((SimpleGraph.cycleGraph (extraVertices + 3)).lapMatrix ℂ +
      Matrix.of (fun (_ _ : Fin (extraVertices + 3)) =>
        ((extraVertices + 3 : ℕ) : ℂ)⁻¹)).det =
        ((extraVertices + 3 : ℕ) : ℂ) ^ 2 := by
  rw [← regularized_matrix_is_graph_laplacian_plus_mean]
  calc
    _ = (regularizedMatrix (vertexCount := extraVertices + 3)).det :=
      Matrix.det_submatrix_equiv_self (ZMod.finEquiv (extraVertices + 3)).toEquiv _
    _ = ((extraVertices + 3 : ℕ) : ℂ) ^ 2 := by
      have determinant_identity := concrete_cycle_determinant (extraVertices + 2)
      convert determinant_identity using 1
      push_cast
      ring

end PrimeUniverse.CycleDeterminant
