import Mathlib.Analysis.SpecialFunctions.Log.Deriv
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith

/-!
Rational certificates for the logarithms used in the heat-capacity comparison.
The inequalities follow from finite sums and a proved analytic remainder bound.
No floating-point approximation participates in the proofs.
-/

namespace PrimeUniverse.LogBounds

theorem log_two_bounds :
    (693146 / 1000000 : ℝ) < Real.log 2 ∧ Real.log 2 < 693159 / 1000000 := by
  have lower := Real.sum_range_le_log_div (x := (1 / 3 : ℝ))
    (by norm_num) (by norm_num) 5
  have upper := Real.log_div_le_sum_range_add (x := (1 / 3 : ℝ))
    (by norm_num) (by norm_num) 5
  norm_num [Finset.sum_range_succ] at lower upper
  constructor <;> linarith

theorem log_three_bounds :
    (1098611 / 1000000 : ℝ) < Real.log 3 ∧ Real.log 3 < 1098632 / 1000000 := by
  have lower := Real.sum_range_le_log_div (x := (1 / 2 : ℝ))
    (by norm_num) (by norm_num) 8
  have upper := Real.log_div_le_sum_range_add (x := (1 / 2 : ℝ))
    (by norm_num) (by norm_num) 8
  norm_num [Finset.sum_range_succ] at lower upper
  constructor <;> linarith

theorem log_eleven_eighths_bounds :
    (318453 / 1000000 : ℝ) < Real.log (11 / 8) ∧
      Real.log (11 / 8) < 318454 / 1000000 := by
  have lower := Real.sum_range_le_log_div (x := (3 / 19 : ℝ))
    (by norm_num) (by norm_num) 4
  have upper := Real.log_div_le_sum_range_add (x := (3 / 19 : ℝ))
    (by norm_num) (by norm_num) 4
  norm_num [Finset.sum_range_succ] at lower upper
  constructor <;> linarith

theorem log_eleven_bounds :
    (23978 / 10000 : ℝ) < Real.log 11 ∧ Real.log 11 < 12 / 5 := by
  have product_identity := Real.log_mul (show (8 : ℝ) ≠ 0 by norm_num)
    (show (11 / 8 : ℝ) ≠ 0 by norm_num)
  have power_identity := Real.log_pow (2 : ℝ) 3
  norm_num at product_identity power_identity
  obtain ⟨two_lower, two_upper⟩ := log_two_bounds
  obtain ⟨ratio_lower, ratio_upper⟩ := log_eleven_eighths_bounds
  constructor <;> linarith

theorem log_twelve_bounds :
    (26 / 11 : ℝ) < Real.log 12 ∧ Real.log 12 < 2485 / 1000 := by
  have product_identity := Real.log_mul (show (4 : ℝ) ≠ 0 by norm_num)
    (show (3 : ℝ) ≠ 0 by norm_num)
  have power_identity := Real.log_pow (2 : ℝ) 2
  norm_num at product_identity power_identity
  obtain ⟨two_lower, two_upper⟩ := log_two_bounds
  obtain ⟨three_lower, three_upper⟩ := log_three_bounds
  constructor <;> linarith

end PrimeUniverse.LogBounds
