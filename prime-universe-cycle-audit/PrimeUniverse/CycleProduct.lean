import Mathlib.RingTheory.RootsOfUnity.Lemmas
import Mathlib.RingTheory.RootsOfUnity.Complex
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-! Chapter 146, equations 146.18--146.22: the exact product of the declared
cycle spectrum and its logarithm. The root-of-unity product is an existing
mathlib theorem. CycleLaplacian and CycleDeterminant connect this product to
an actual graph matrix. A normalized Gaussian integral remains outside scope. -/

noncomputable section
namespace PrimeUniverse.CycleProduct

def spectralProduct (nonzeroModeCount : ℕ) (root : ℂ) : ℝ :=
  ∏ mode ∈ Finset.range nonzeroModeCount, Complex.normSq (1 - root ^ (mode + 1))

theorem root_product_squared (nonzeroModeCount : ℕ) (root : ℂ)
    (root_primitive : IsPrimitiveRoot root (nonzeroModeCount + 1)) :
    spectralProduct nonzeroModeCount root = ((nonzeroModeCount : ℝ) + 1) ^ 2 := by
  unfold spectralProduct
  rw [← map_prod Complex.normSq, root_primitive.prod_one_sub_pow_eq_order]
  simp [Complex.normSq_apply, pow_two]

theorem spectral_product_positive (nonzeroModeCount : ℕ) (root : ℂ)
    (root_primitive : IsPrimitiveRoot root (nonzeroModeCount + 1)) :
    0 < spectralProduct nonzeroModeCount root := by
  rw [root_product_squared _ _ root_primitive]
  exact sq_pos_of_pos (by exact_mod_cast Nat.succ_pos nonzeroModeCount)

theorem logarithmic_cycle_action (nonzeroModeCount : ℕ) (root : ℂ)
    (root_primitive : IsPrimitiveRoot root (nonzeroModeCount + 1)) :
    (1 / 2 : ℝ) * Real.log (spectralProduct nonzeroModeCount root) =
      Real.log ((nonzeroModeCount : ℝ) + 1) := by
  rw [root_product_squared _ _ root_primitive, Real.log_pow]
  ring

theorem reciprocal_square_root_weight (nonzeroModeCount : ℕ) (root : ℂ)
    (root_primitive : IsPrimitiveRoot root (nonzeroModeCount + 1)) :
    1 / Real.sqrt (spectralProduct nonzeroModeCount root) =
      1 / ((nonzeroModeCount : ℝ) + 1) := by
  rw [root_product_squared _ _ root_primitive, Real.sqrt_sq
    (show 0 ≤ (nonzeroModeCount : ℝ) + 1 by exact_mod_cast Nat.zero_le (nonzeroModeCount + 1))]

theorem rotation_chord_squared (angle : ℝ) :
    Complex.normSq (1 - Complex.exp ((angle : ℂ) * Complex.I)) =
      4 * Real.sin (angle / 2) ^ 2 := by
  have full_angle := Real.sin_sq_add_cos_sq angle
  have half_angle := Real.sin_sq_add_cos_sq (angle / 2)
  have doubled_angle := Real.cos_two_mul (angle / 2)
  have double_half : 2 * (angle / 2) = angle := by ring
  rw [double_half] at doubled_angle
  simp only [Complex.normSq_apply, Complex.sub_re, Complex.one_re,
    Complex.exp_ofReal_mul_I_re, Complex.sub_im, Complex.one_im,
    Complex.exp_ofReal_mul_I_im]
  nlinarith

/-- An explicit primitive root supplies the spectrum for every positive order. -/
theorem cycle_sine_product (nonzeroModeCount : ℕ) :
    (∏ mode ∈ Finset.range nonzeroModeCount,
      4 * Real.sin (Real.pi * ((mode : ℝ) + 1) / ((nonzeroModeCount : ℝ) + 1)) ^ 2) =
        ((nonzeroModeCount : ℝ) + 1) ^ 2 := by
  let root : ℂ := Complex.exp (2 * Real.pi * Complex.I / (nonzeroModeCount + 1))
  have root_primitive : IsPrimitiveRoot root (nonzeroModeCount + 1) := by
    convert Complex.isPrimitiveRoot_exp (nonzeroModeCount + 1) (Nat.succ_ne_zero _) using 1
    simp [root]
  have mode_identity : ∀ mode : ℕ,
      Complex.normSq (1 - root ^ (mode + 1)) =
        4 * Real.sin (Real.pi * ((mode : ℝ) + 1) / ((nonzeroModeCount : ℝ) + 1)) ^ 2 := by
    intro mode
    have exponent_identity :
        (mode + 1 : ℂ) * (2 * Real.pi * Complex.I / (nonzeroModeCount + 1)) =
          (((2 * Real.pi * ((mode : ℝ) + 1) / ((nonzeroModeCount : ℝ) + 1) : ℝ) : ℂ) *
            Complex.I) := by
      push_cast
      ring
    dsimp [root]
    rw [← Complex.exp_nat_mul]
    push_cast
    rw [exponent_identity, rotation_chord_squared]
    congr 3
    ring
  simpa only [spectralProduct, mode_identity] using
    root_product_squared nonzeroModeCount root root_primitive

/-- The composite cycle n=4 gives 16, just as predicted by the general formula. -/
theorem composite_cycle_four : spectralProduct 3 Complex.I = 16 := by
  have product_identity := root_product_squared 3 Complex.I Complex.isPrimitiveRoot_I
  norm_num at product_identity
  exact product_identity

end PrimeUniverse.CycleProduct
