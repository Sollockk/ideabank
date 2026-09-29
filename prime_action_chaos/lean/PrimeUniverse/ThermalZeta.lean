import Mathlib.NumberTheory.EulerProduct.DirichletLSeries
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
Chapters 145 and 147. Convergent prime orbit products give the ordinary zeta
function, but the corresponding infinite arithmetic thermal amplitudes are
square summable only above exponent one. Analytic continuation is not a
normalization prescription for a divergent vector.
-/

noncomputable section

namespace PrimeUniverse.ThermalZeta

def thermalAmplitude (exponent : ℝ) (occupationIndex : ℕ) : ℝ :=
  Real.sqrt (1 / ((occupationIndex : ℝ) + 1) ^ exponent)

theorem arithmetic_state_normalizable_iff (exponent : ℝ) :
    Summable (fun occupationIndex => thermalAmplitude exponent occupationIndex ^ 2) ↔
      1 < exponent := by
  have squared_amplitude (occupationIndex : ℕ) :
      thermalAmplitude exponent occupationIndex ^ 2 =
        1 / ((occupationIndex : ℝ) + 1) ^ exponent := by
    unfold thermalAmplitude
    exact Real.sq_sqrt (by positivity)
  simp_rw [squared_amplitude]
  have shifted := summable_nat_add_iff 1
    (f := fun occupationIndex : ℕ => 1 / (occupationIndex : ℝ) ^ exponent)
  simpa only [Nat.cast_add, Nat.cast_one] using
    shifted.trans Real.summable_one_div_nat_rpow

theorem critical_line_state_not_normalizable :
    ¬Summable (fun occupationIndex => thermalAmplitude (1 / 2) occupationIndex ^ 2) := by
  rw [arithmetic_state_normalizable_iff]
  norm_num

theorem finite_rescaling_cannot_normalize_critical_state (normalization : ℝ)
    (normalization_nonzero : normalization ≠ 0) :
    ¬Summable (fun occupationIndex =>
      (normalization * thermalAmplitude (1 / 2) occupationIndex) ^ 2) := by
  simp_rw [mul_pow]
  rw [summable_mul_left_iff (pow_ne_zero 2 normalization_nonzero)]
  exact critical_line_state_not_normalizable

/-- Oscillatory phases do not cure the divergent norm. This covers any
unit-modulus phases, not just those from a particular time parameter. -/
theorem phases_cannot_normalize_critical_state (phase : ℕ → ℂ)
    (unit_phases : ∀ occupationIndex, Complex.normSq (phase occupationIndex) = 1) :
    ¬Summable (fun occupationIndex => Complex.normSq
      (phase occupationIndex * (thermalAmplitude (1 / 2) occupationIndex : ℂ))) := by
  simpa only [map_mul, unit_phases, one_mul, Complex.normSq_ofReal, ← pow_two] using
    critical_line_state_not_normalizable

theorem arithmetic_state_at_two_is_normalizable :
    Summable (fun occupationIndex => thermalAmplitude 2 occupationIndex ^ 2) := by
  rw [arithmetic_state_normalizable_iff]
  norm_num

def orbitWeight (parameter : ℕ) (spectralParameter : ℂ) : ℂ :=
  Complex.exp (-spectralParameter * (Real.log parameter : ℂ))

theorem orbit_weight_is_prime_power (parameter : ℕ) (parameter_nonzero : parameter ≠ 0)
    (spectralParameter : ℂ) :
    orbitWeight parameter spectralParameter = (parameter : ℂ) ^ (-spectralParameter) := by
  rw [Complex.cpow_def_of_ne_zero (by exact_mod_cast parameter_nonzero)]
  unfold orbitWeight
  rw [Complex.natCast_log]
  congr 1
  ring

/-- This invokes mathlib's established Euler product; it is not a new proof of
Euler's theorem, nor does it continue the product to the critical strip. -/
theorem determinant_length_euler_product (spectralParameter : ℂ)
    (in_convergence_domain : 1 < spectralParameter.re) :
    HasProd (fun prime : Nat.Primes => (1 - orbitWeight prime spectralParameter)⁻¹)
      (riemannZeta spectralParameter) := by
  have weight_identity (prime : Nat.Primes) :
      orbitWeight prime spectralParameter = (prime : ℂ) ^ (-spectralParameter) :=
    orbit_weight_is_prime_power prime prime.property.ne_zero spectralParameter
  simp_rw [weight_identity]
  exact riemannZeta_eulerProduct_hasProd in_convergence_domain

/-- Every finite Euler product is nonzero even throughout Re(s)>0. A finite
minimum near a zeta zero cannot be an actual zero of this product. -/
theorem finite_euler_product_nonzero (parameters : Finset ℕ) (spectralParameter : ℂ)
    (parameters_gt_one : ∀ parameter ∈ parameters, 1 < parameter)
    (positive_real_part : 0 < spectralParameter.re) :
    (∏ parameter ∈ parameters, (1 - orbitWeight parameter spectralParameter)⁻¹) ≠ 0 := by
  apply Finset.prod_ne_zero_iff.mpr
  intro parameter membership
  apply inv_ne_zero
  intro denominator_zero
  have weight_one : orbitWeight parameter spectralParameter = 1 :=
    (sub_eq_zero.mp denominator_zero).symm
  have logarithm_positive : 0 < Real.log (parameter : ℝ) :=
    Real.log_pos (by exact_mod_cast parameters_gt_one parameter membership)
  have weight_small : ‖orbitWeight parameter spectralParameter‖ < 1 := by
    unfold orbitWeight
    rw [Complex.norm_exp, Real.exp_lt_one_iff]
    simp only [Complex.mul_re, Complex.neg_re, Complex.neg_im, Complex.ofReal_re,
      Complex.ofReal_im, mul_zero, sub_zero]
    nlinarith
  rw [weight_one, norm_one] at weight_small
  exact (lt_irrefl (1 : ℝ)) weight_small

end PrimeUniverse.ThermalZeta
