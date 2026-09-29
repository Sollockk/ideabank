import PrimeUniverse.LogBounds
import Mathlib.Analysis.Calculus.Deriv.MeanValue
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring

/-!
Chapter 149's two-level Schottky response. The maximum at label 11 is proved
over all integers at least two, and hence over all primes. The continuous
response is still increasing at 11, so the integer and continuous claims differ.
-/

noncomputable section

namespace PrimeUniverse.HeatCapacity

/-- Dimensionless heat capacity C/k_B in the specified two-level family. -/
def response (parameter : ℝ) : ℝ :=
  Real.log parameter ^ 2 * parameter / (parameter + 1) ^ 2

/-- Mean energy for levels 0 and energyGap in a canonical state. -/
def canonicalMeanEnergy (energyGap inverseTemperature : ℝ) : ℝ :=
  energyGap / (Real.exp (inverseTemperature * energyGap) + 1)

theorem canonical_energy_derivative (energyGap inverseTemperature : ℝ) :
    HasDerivAt (canonicalMeanEnergy energyGap)
      (-energyGap ^ 2 * Real.exp (inverseTemperature * energyGap) /
        (Real.exp (inverseTemperature * energyGap) + 1) ^ 2) inverseTemperature := by
  have expression_derivative := (hasDerivAt_const inverseTemperature energyGap).div
    ((((hasDerivAt_id inverseTemperature).mul_const energyGap).exp).add_const 1)
    (by positivity)
  convert expression_derivative using 1
  · rfl
  · dsimp
    ring

/-- At beta = 1 and gap = log(p), the negative thermal derivative is the response. -/
theorem response_is_canonical_thermal_derivative (parameter : ℝ)
    (parameter_positive : 0 < parameter) :
    -deriv (canonicalMeanEnergy (Real.log parameter)) 1 = response parameter := by
  rw [(canonical_energy_derivative (Real.log parameter) 1).deriv]
  simp only [one_mul, Real.exp_log parameter_positive, response]
  ring

theorem response_derivative (parameter : ℝ) (parameter_positive : 0 < parameter) :
    HasDerivAt response
      (Real.log parameter * (2 * (parameter + 1) -
        (parameter - 1) * Real.log parameter) / (parameter + 1) ^ 3) parameter := by
  have denominator_nonzero : parameter + 1 ≠ 0 := by positivity
  have expression_derivative :=
    (((Real.hasDerivAt_log parameter_positive.ne').pow 2).mul (hasDerivAt_id parameter)).div
      (((hasDerivAt_id parameter).add_const 1).pow 2) (pow_ne_zero 2 denominator_nonzero)
  convert expression_derivative using 1
  · rfl
  · dsimp
    field_simp
    ring

theorem derivative_positive_through_eleven (parameter : ℝ)
    (parameter_gt_one : 1 < parameter) (parameter_le_eleven : parameter ≤ 11) :
    0 < deriv response parameter := by
  have parameter_positive : 0 < parameter := by linarith
  have log_bound : Real.log parameter < 12 / 5 :=
    lt_of_le_of_lt (Real.log_le_log parameter_positive parameter_le_eleven)
      LogBounds.log_eleven_bounds.2
  have positive_product : 0 < (parameter - 1) * (12 / 5 - Real.log parameter) :=
    mul_pos (by linarith) (by linarith)
  have positive_factor : 0 < 2 * (parameter + 1) - (parameter - 1) * Real.log parameter := by
    nlinarith
  rw [(response_derivative parameter parameter_positive).deriv]
  exact div_pos (mul_pos (Real.log_pos parameter_gt_one) positive_factor) (by positivity)

theorem derivative_negative_from_twelve (parameter : ℝ)
    (parameter_ge_twelve : 12 ≤ parameter) :
    deriv response parameter < 0 := by
  have parameter_positive : 0 < parameter := by linarith
  have log_bound : (26 / 11 : ℝ) < Real.log parameter :=
    lt_of_lt_of_le LogBounds.log_twelve_bounds.1
      (Real.log_le_log (by norm_num) parameter_ge_twelve)
  have positive_product : 0 < (parameter - 1) * (Real.log parameter - 26 / 11) :=
    mul_pos (by linarith) (by linarith)
  have negative_factor : 2 * (parameter + 1) - (parameter - 1) * Real.log parameter < 0 := by
    nlinarith
  rw [(response_derivative parameter parameter_positive).deriv]
  exact div_neg_of_neg_of_pos
    (mul_neg_of_pos_of_neg (Real.log_pos (by linarith)) negative_factor) (by positivity)

theorem response_increases_through_eleven : StrictMonoOn response (Set.Ioc (1 : ℝ) 11) := by
  apply strictMonoOn_of_deriv_pos (convex_Ioc 1 11)
  · intro parameter parameter_in_domain
    exact (response_derivative parameter (by have := parameter_in_domain.1; linarith)).continuousAt.continuousWithinAt
  · intro parameter parameter_in_interior
    have membership : 1 < parameter ∧ parameter < 11 := by
      simpa only [interior_Ioc, Set.mem_Ioo] using parameter_in_interior
    exact derivative_positive_through_eleven parameter membership.1 membership.2.le

theorem response_decreases_from_twelve : StrictAntiOn response (Set.Ici (12 : ℝ)) := by
  apply strictAntiOn_of_deriv_neg (convex_Ici 12)
  · intro parameter parameter_in_domain
    exact (response_derivative parameter (by have : 12 ≤ parameter := parameter_in_domain; linarith)).continuousAt.continuousWithinAt
  · intro parameter parameter_in_interior
    have parameter_gt_twelve : 12 < parameter := by
      simpa only [interior_Ici, Set.mem_Ioi] using parameter_in_interior
    exact derivative_negative_from_twelve parameter parameter_gt_twelve.le

/-- This close comparison uses certified rational log bounds, not decimal evaluation. -/
theorem eleven_beats_twelve : response 12 < response 11 := by
  have eleven_lower := LogBounds.log_eleven_bounds.1
  have twelve_upper := LogBounds.log_twelve_bounds.2
  have eleven_positive : 0 < Real.log 11 := Real.log_pos (by norm_num)
  have twelve_positive : 0 < Real.log 12 := Real.log_pos (by norm_num)
  have lower_square : (23978 / 10000 : ℝ) ^ 2 < Real.log 11 ^ 2 := by nlinarith
  have upper_square : Real.log 12 ^ 2 < (2485 / 1000 : ℝ) ^ 2 := by nlinarith
  norm_num [response]
  nlinarith

/-- The stronger result: primality is unnecessary for the maximizing label. -/
theorem eleven_unique_integer_maximum (label : ℕ) (label_at_least_two : 2 ≤ label)
    (label_not_eleven : label ≠ 11) : response label < response 11 := by
  rcases lt_or_gt_of_ne label_not_eleven with below | above
  · apply response_increases_through_eleven
    · constructor
      · exact_mod_cast (show 1 < label by omega)
      · exact_mod_cast below.le
    · norm_num
    · exact_mod_cast below
  · have label_ge_twelve : (12 : ℝ) ≤ label := by exact_mod_cast (show 12 ≤ label by omega)
    exact lt_of_le_of_lt
      (response_decreases_from_twelve.antitoneOn (by norm_num) label_ge_twelve label_ge_twelve)
      eleven_beats_twelve

theorem eleven_unique_prime_maximum (prime : ℕ) (is_prime : Nat.Prime prime)
    (prime_not_eleven : prime ≠ 11) : response prime < response 11 :=
  eleven_unique_integer_maximum prime is_prime.two_le prime_not_eleven

theorem eleven_still_on_increasing_continuous_branch : 0 < deriv response 11 :=
  derivative_positive_through_eleven 11 (by norm_num) (by norm_num)

end PrimeUniverse.HeatCapacity
