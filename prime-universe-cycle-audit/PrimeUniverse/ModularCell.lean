import Mathlib.Analysis.SpecialFunctions.Log.Deriv
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-! Chapter 149, equations 149.2--149.5 and 149.17--149.25.
The parameter is a real number. No primality assumption is needed.
These are identities for the specified two-level model, not a derivation
of that model from a cycle or from gravitational dynamics. -/

noncomputable section
namespace PrimeUniverse.ModularCell

def groundProbability (parameter : ℝ) : ℝ := parameter / (parameter + 1)
def excitedProbability (parameter : ℝ) : ℝ := 1 / (parameter + 1)
def predictability (parameter : ℝ) : ℝ := (parameter - 1) / (parameter + 1)
def visibility (parameter : ℝ) : ℝ := 2 * Real.sqrt parameter / (parameter + 1)
def occupationVariance (parameter : ℝ) : ℝ := parameter / (parameter + 1) ^ 2
def binaryEntropy (parameter : ℝ) : ℝ :=
  Real.log (parameter + 1) - parameter / (parameter + 1) * Real.log parameter

theorem probabilities_positive (parameter : ℝ) (parameter_positive : 0 < parameter) :
    0 < groundProbability parameter ∧ 0 < excitedProbability parameter := by
  constructor
  · exact div_pos parameter_positive (by linarith)
  · exact div_pos zero_lt_one (by linarith)

theorem probabilities_sum_one (parameter : ℝ) (parameter_nonnegative : 0 ≤ parameter) :
    groundProbability parameter + excitedProbability parameter = 1 := by
  unfold groundProbability excitedProbability
  have denominator_nonzero : parameter + 1 ≠ 0 := by linarith
  field_simp

theorem modular_gap (parameter : ℝ) (parameter_positive : 0 < parameter) :
    -Real.log (excitedProbability parameter) -
      (-Real.log (groundProbability parameter)) = Real.log parameter := by
  unfold groundProbability excitedProbability
  rw [Real.log_div (ne_of_gt parameter_positive) (by linarith),
    Real.log_div one_ne_zero (by linarith), Real.log_one]
  ring

theorem entropy_is_probability_entropy (parameter : ℝ) (parameter_positive : 0 < parameter) :
    binaryEntropy parameter =
      -groundProbability parameter * Real.log (groundProbability parameter) -
        excitedProbability parameter * Real.log (excitedProbability parameter) := by
  unfold binaryEntropy groundProbability excitedProbability
  have denominator_nonzero : parameter + 1 ≠ 0 := by linarith
  rw [Real.log_div (ne_of_gt parameter_positive) denominator_nonzero,
    Real.log_div one_ne_zero denominator_nonzero, Real.log_one]
  field_simp
  ring

theorem predictability_is_population_difference (parameter : ℝ) :
    predictability parameter = groundProbability parameter - excitedProbability parameter := by
  unfold predictability groundProbability excitedProbability
  rw [sub_div]

/-- On the manuscript's parameter domain, the signed expression is exactly
the operational absolute population predictability. -/
theorem predictability_is_absolute_population_difference (parameter : ℝ)
    (parameter_at_least_one : 1 ≤ parameter) :
    predictability parameter = |groundProbability parameter - excitedProbability parameter| := by
  rw [← predictability_is_population_difference]
  exact (abs_of_nonneg (div_nonneg (sub_nonneg.mpr parameter_at_least_one) (by linarith))).symm

theorem wave_structure_complementarity (parameter : ℝ)
    (parameter_nonnegative : 0 ≤ parameter) :
    predictability parameter ^ 2 + visibility parameter ^ 2 = 1 := by
  unfold predictability visibility
  have denominator_nonzero : parameter + 1 ≠ 0 := by linarith
  have square_root_identity := Real.sq_sqrt parameter_nonnegative
  field_simp
  nlinarith

theorem visibility_squared_is_four_variance (parameter : ℝ)
    (parameter_nonnegative : 0 ≤ parameter) :
    visibility parameter ^ 2 = 4 * occupationVariance parameter := by
  unfold visibility occupationVariance
  rw [div_pow, mul_pow, Real.sq_sqrt parameter_nonnegative]
  ring

theorem predictability_strictly_increases (firstParameter secondParameter : ℝ)
    (first_positive : 0 < firstParameter) (parameters_ordered : firstParameter < secondParameter) :
    predictability firstParameter < predictability secondParameter := by
  unfold predictability
  apply (div_lt_div_iff₀ (by linarith) (by linarith)).2
  nlinarith

theorem variance_strictly_decreases (firstParameter secondParameter : ℝ)
    (first_above_one : 1 < firstParameter) (parameters_ordered : firstParameter < secondParameter) :
    occupationVariance secondParameter < occupationVariance firstParameter := by
  unfold occupationVariance
  apply (div_lt_div_iff₀ (sq_pos_of_pos (by linarith))
    (sq_pos_of_pos (by linarith))).2
  have positive_difference : 0 < secondParameter - firstParameter := by linarith
  have positive_product : 0 < firstParameter * secondParameter - 1 := by nlinarith
  nlinarith [mul_pos positive_difference positive_product]

theorem visibility_strictly_decreases (firstParameter secondParameter : ℝ)
    (first_above_one : 1 < firstParameter) (parameters_ordered : firstParameter < secondParameter) :
    visibility secondParameter < visibility firstParameter := by
  have variance_order := variance_strictly_decreases firstParameter secondParameter
    first_above_one parameters_ordered
  have first_square := visibility_squared_is_four_variance firstParameter (by linarith)
  have second_square := visibility_squared_is_four_variance secondParameter (by linarith)
  have first_nonnegative : 0 ≤ visibility firstParameter :=
    div_nonneg (mul_nonneg (by norm_num) (Real.sqrt_nonneg _)) (by linarith)
  have second_nonnegative : 0 ≤ visibility secondParameter :=
    div_nonneg (mul_nonneg (by norm_num) (Real.sqrt_nonneg _)) (by linarith)
  nlinarith

theorem entropy_derivative (parameter : ℝ) (parameter_positive : 0 < parameter) :
    HasDerivAt binaryEntropy (-Real.log parameter / (parameter + 1) ^ 2) parameter := by
  have denominator_nonzero : parameter + 1 ≠ 0 := by linarith
  have shifted_identity := (hasDerivAt_id parameter).add_const 1
  have shifted_logarithm := shifted_identity.log denominator_nonzero
  have quotient_derivative := (hasDerivAt_id parameter).div shifted_identity denominator_nonzero
  have logarithm_derivative := Real.hasDerivAt_log (ne_of_gt parameter_positive)
  convert shifted_logarithm.sub (quotient_derivative.mul logarithm_derivative) using 1
  · rfl
  · dsimp
    field_simp
    ring

theorem entropy_derivative_negative (parameter : ℝ) (parameter_above_one : 1 < parameter) :
    deriv binaryEntropy parameter < 0 := by
  rw [(entropy_derivative parameter (by linarith)).deriv]
  exact div_neg_of_neg_of_pos (neg_neg_of_pos (Real.log_pos parameter_above_one))
    (sq_pos_of_pos (by linarith))

/-- A composite satisfies exactly the same complementarity law. -/
theorem composite_four_also_satisfies_complementarity :
    predictability 4 ^ 2 + visibility 4 ^ 2 = 1 :=
  wave_structure_complementarity 4 (by norm_num)

end PrimeUniverse.ModularCell
