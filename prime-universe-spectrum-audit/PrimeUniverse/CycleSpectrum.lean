import Mathlib.RingTheory.RootsOfUnity.Lemmas
import Mathlib.RingTheory.RootsOfUnity.Complex
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.LinearAlgebra.Vandermonde
import Mathlib.LinearAlgebra.FiniteDimensional.Lemmas
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring

/-!
Chapters 146--147. The product is defined from the nonconstant Fourier modes,
not by assigning it the value n². We certify periodicity, the discrete
Laplacian equation, the root-of-unity product, and its logarithmic action.
The finite Fourier modes form a complete basis and obey the finite cyclic
Laplacian equation, including the double-edge convention at length two.
-/

noncomputable section

namespace PrimeUniverse.CycleSpectrum

def cycleRoot (vertexCount : ℕ) : ℂ :=
  Complex.exp (2 * Real.pi * Complex.I / vertexCount)

def cycleSpectralProduct (vertexCount : ℕ) : ℝ :=
  ∏ mode ∈ Finset.range (vertexCount - 1),
    Complex.normSq (1 - cycleRoot vertexCount ^ (mode + 1))

/-- This is a theorem for every cycle length, including composite lengths. -/
theorem cycle_spectral_product (modeCount : ℕ) :
    cycleSpectralProduct (modeCount + 1) = ((modeCount : ℝ) + 1) ^ 2 := by
  have primitive_root := Complex.isPrimitiveRoot_exp (modeCount + 1) (by omega)
  have root_product := primitive_root.prod_one_sub_pow_eq_order
  have squared_product := congrArg Complex.normSq root_product
  simpa [cycleSpectralProduct, cycleRoot, map_prod, Complex.normSq_apply, pow_two]
    using squared_product

theorem determinant_action (modeCount : ℕ) :
    (1 / 2 : ℝ) * Real.log (cycleSpectralProduct (modeCount + 1)) =
      Real.log ((modeCount : ℝ) + 1) := by
  rw [cycle_spectral_product, Real.log_pow]
  ring

theorem composite_cycle_has_same_law :
    cycleSpectralProduct 4 = 16 ∧
      (1 / 2 : ℝ) * Real.log (cycleSpectralProduct 4) = Real.log 4 := by
  constructor
  · convert cycle_spectral_product 3 using 1
    norm_num
  · convert determinant_action 3 using 1
    norm_num

def discreteLaplacian (wave : ℤ → ℂ) (site : ℤ) : ℂ :=
  2 * wave site - wave (site + 1) - wave (site - 1)

def fourierMode (root : ℂ) (mode : ℕ) (site : ℤ) : ℂ := (root ^ mode) ^ site

theorem fourier_mode_periodic (root : ℂ) (vertexCount mode : ℕ)
    (root_nonzero : root ≠ 0) (root_period : root ^ vertexCount = 1) (site : ℤ) :
    fourierMode root mode (site + vertexCount) = fourierMode root mode site := by
  unfold fourierMode
  rw [zpow_add₀ (pow_ne_zero _ root_nonzero), zpow_natCast, ← pow_mul, mul_comm mode vertexCount,
    pow_mul, root_period, one_pow, mul_one]

theorem fourier_mode_laplacian (root : ℂ) (mode : ℕ)
    (root_nonzero : root ≠ 0) (site : ℤ) :
    discreteLaplacian (fourierMode root mode) site =
      (2 - root ^ mode - (root ^ mode)⁻¹) * fourierMode root mode site := by
  unfold discreteLaplacian fourierMode
  rw [zpow_add₀ (pow_ne_zero _ root_nonzero), zpow_sub₀ (pow_ne_zero _ root_nonzero)]
  simp only [zpow_one, div_eq_mul_inv]
  ring

/-- A unit-circle mode has the nonnegative Fourier eigenvalue |1-z|². -/
theorem mode_eigenvalue_is_norm_square (modeRoot : ℂ)
    (unit_norm : Complex.normSq modeRoot = 1) :
    2 - modeRoot - modeRoot⁻¹ = (Complex.normSq (1 - modeRoot) : ℂ) := by
  have coordinates : modeRoot.re * modeRoot.re + modeRoot.im * modeRoot.im = 1 := unit_norm
  apply Complex.ext <;>
    simp [Complex.inv_def, unit_norm, Complex.normSq_apply]
  nlinarith [coordinates]

def finiteMode (vertexCount : ℕ) (mode site : Fin vertexCount) : ℂ :=
  (cycleRoot vertexCount ^ mode.val) ^ site.val

theorem finite_modes_linearly_independent (vertexCount : ℕ) (positive_count : 0 < vertexCount) :
    LinearIndependent ℂ (finiteMode vertexCount) := by
  apply Matrix.linearIndependent_rows_of_det_ne_zero
    (A := Matrix.vandermonde (fun mode : Fin vertexCount => cycleRoot vertexCount ^ mode.val))
  apply Matrix.det_vandermonde_ne_zero_iff.mpr
  intro firstMode secondMode equal_roots
  apply Fin.ext
  exact (Complex.isPrimitiveRoot_exp vertexCount positive_count.ne').pow_inj
    firstMode.isLt secondMode.isLt equal_roots

theorem finite_modes_span (vertexCount : ℕ) (positive_count : 0 < vertexCount) :
    Submodule.span ℂ (Set.range (finiteMode vertexCount)) = ⊤ := by
  apply (finite_modes_linearly_independent vertexCount positive_count).span_eq_top_of_card_eq_finrank'
  simp

def finiteLaplacian (modeCount : ℕ) (wave : Fin (modeCount + 1) → ℂ)
    (site : Fin (modeCount + 1)) : ℂ :=
  2 * wave site - wave ⟨(site.val + 1) % (modeCount + 1), Nat.mod_lt _ (by omega)⟩ -
    wave ⟨(site.val + modeCount) % (modeCount + 1), Nat.mod_lt _ (by omega)⟩

/-- The same operator as a complex linear endomorphism, with linearity checked
from the nearest-neighbor formula. -/
def finiteLaplacianMap (modeCount : ℕ) :
    Module.End ℂ (Fin (modeCount + 1) → ℂ) where
  toFun := finiteLaplacian modeCount
  map_add' := by
    intro firstWave secondWave
    funext site
    simp only [finiteLaplacian, Pi.add_apply]
    ring
  map_smul' := by
    intro scalar wave
    funext site
    simp only [finiteLaplacian, Pi.smul_apply, smul_eq_mul, RingHom.id_apply]
    ring

theorem finite_mode_laplacian (modeCount : ℕ) (mode site : Fin (modeCount + 1)) :
    finiteLaplacian modeCount (finiteMode (modeCount + 1) mode) site =
      (2 - cycleRoot (modeCount + 1) ^ mode.val -
        (cycleRoot (modeCount + 1) ^ mode.val)⁻¹) * finiteMode (modeCount + 1) mode site := by
  let modeRoot := cycleRoot (modeCount + 1) ^ mode.val
  have root_nonzero : cycleRoot (modeCount + 1) ≠ 0 := Complex.exp_ne_zero _
  have mode_nonzero : modeRoot ≠ 0 := pow_ne_zero _ root_nonzero
  have root_period : cycleRoot (modeCount + 1) ^ (modeCount + 1) = 1 :=
    (Complex.isPrimitiveRoot_exp (modeCount + 1) (by omega)).pow_eq_one
  have mode_period : modeRoot ^ (modeCount + 1) = 1 := by
    dsimp [modeRoot]
    rw [← pow_mul, mul_comm mode.val, pow_mul, root_period, one_pow]
  have wrap_power (exponent : ℕ) :
      modeRoot ^ (exponent % (modeCount + 1)) = modeRoot ^ exponent := by
    conv_rhs => rw [← Nat.mod_add_div exponent (modeCount + 1)]
    rw [pow_add, pow_mul, mode_period, one_pow, mul_one]
  have backwards : modeRoot ^ modeCount = modeRoot⁻¹ := by
    apply mul_left_cancel₀ mode_nonzero
    rw [mul_inv_cancel₀ mode_nonzero, ← pow_succ', mode_period]
  change 2 * modeRoot ^ site.val - modeRoot ^ ((site.val + 1) % (modeCount + 1)) -
      modeRoot ^ ((site.val + modeCount) % (modeCount + 1)) =
        (2 - modeRoot - modeRoot⁻¹) * modeRoot ^ site.val
  rw [wrap_power, wrap_power, pow_succ, pow_add, backwards]
  ring

theorem only_constant_mode_has_zero_eigenvalue (vertexCount : ℕ) (positive_count : 0 < vertexCount)
    (mode : Fin vertexCount) :
    Complex.normSq (1 - cycleRoot vertexCount ^ mode.val) = 0 ↔ mode.val = 0 := by
  rw [Complex.normSq_eq_zero, sub_eq_zero, eq_comm]
  have primitive_root : IsPrimitiveRoot (cycleRoot vertexCount) vertexCount :=
    Complex.isPrimitiveRoot_exp vertexCount positive_count.ne'
  rw [primitive_root.pow_eq_one_iff_dvd]
  exact Nat.dvd_iff_mod_eq_zero.trans (by rw [Nat.mod_eq_of_lt mode.isLt])

theorem finite_mode_real_eigenvalue (modeCount : ℕ) (mode site : Fin (modeCount + 1)) :
    finiteLaplacian modeCount (finiteMode (modeCount + 1) mode) site =
      (Complex.normSq (1 - cycleRoot (modeCount + 1) ^ mode.val) : ℂ) *
        finiteMode (modeCount + 1) mode site := by
  have root_norm : ‖cycleRoot (modeCount + 1)‖ = 1 :=
    (Complex.isPrimitiveRoot_exp (modeCount + 1) (by omega)).norm'_eq_one (by omega)
  have mode_norm : Complex.normSq (cycleRoot (modeCount + 1) ^ mode.val) = 1 := by
    rw [Complex.normSq_eq_norm_sq, norm_pow, root_norm, one_pow, one_pow]
  rw [finite_mode_laplacian, mode_eigenvalue_is_norm_square _ mode_norm]

end PrimeUniverse.CycleSpectrum
