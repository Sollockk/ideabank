import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Tactic.Linarith

/-!
Chapter 140. For a smooth compact entropy pulse, the completed source moment
has a strictly positive square remainder. This is a continuum integral theorem,
with derivatives and boundary conditions as hypotheses. No gravitational field
equation or choice of conformal state is assumed to follow from arithmetic.
-/

noncomputable section

namespace PrimeUniverse.ConformalPulse

open MeasureTheory

def source (entropySlope entropyCurvature : ℝ → ℝ) (coefficient position : ℝ) : ℝ :=
  entropyCurvature position + coefficient * entropySlope position ^ 2

theorem completed_source_moment (entropySlope entropyCurvature : ℝ → ℝ)
    (coefficient leftEndpoint rightEndpoint : ℝ)
    (slope_derivative : ∀ position ∈ Set.uIcc leftEndpoint rightEndpoint,
      HasDerivAt entropySlope (entropyCurvature position) position)
    (curvature_integrable : IntervalIntegrable entropyCurvature volume leftEndpoint rightEndpoint)
    (slope_square_integrable : IntervalIntegrable (fun position => entropySlope position ^ 2)
      volume leftEndpoint rightEndpoint)
    (left_flat : entropySlope leftEndpoint = 0)
    (right_flat : entropySlope rightEndpoint = 0) :
    (∫ position in leftEndpoint..rightEndpoint,
      source entropySlope entropyCurvature coefficient position) =
        coefficient * ∫ position in leftEndpoint..rightEndpoint, entropySlope position ^ 2 := by
  unfold source
  rw [intervalIntegral.integral_add curvature_integrable (slope_square_integrable.const_mul coefficient),
    intervalIntegral.integral_const_mul,
    intervalIntegral.integral_eq_sub_of_hasDerivAt slope_derivative curvature_integrable,
    left_flat, right_flat]
  ring

/-- One nonzero slope point and continuity are enough for strict positivity;
positivity of the integral is proved here rather than supplied as a premise. -/
theorem nontrivial_pulse_cannot_reset (entropySlope entropyCurvature : ℝ → ℝ)
    (coefficient leftEndpoint rightEndpoint : ℝ)
    (coefficient_positive : 0 < coefficient) (interval_positive : leftEndpoint < rightEndpoint)
    (slope_continuous : ContinuousOn entropySlope (Set.Icc leftEndpoint rightEndpoint))
    (slope_derivative : ∀ position ∈ Set.uIcc leftEndpoint rightEndpoint,
      HasDerivAt entropySlope (entropyCurvature position) position)
    (curvature_integrable : IntervalIntegrable entropyCurvature volume leftEndpoint rightEndpoint)
    (left_flat : entropySlope leftEndpoint = 0)
    (right_flat : entropySlope rightEndpoint = 0)
    (pulse_nontrivial : ∃ position ∈ Set.Icc leftEndpoint rightEndpoint, entropySlope position ≠ 0) :
    0 < ∫ position in leftEndpoint..rightEndpoint,
      source entropySlope entropyCurvature coefficient position := by
  have square_continuous := slope_continuous.pow 2
  have square_integrable : IntervalIntegrable (fun position => entropySlope position ^ 2)
      volume leftEndpoint rightEndpoint :=
    square_continuous.intervalIntegrable_of_Icc interval_positive.le
  rw [completed_source_moment entropySlope entropyCurvature coefficient leftEndpoint rightEndpoint
    slope_derivative curvature_integrable square_integrable left_flat right_flat]
  apply mul_pos coefficient_positive
  have strictly_positive := intervalIntegral.integral_lt_integral_of_continuousOn_of_le_of_exists_lt
    interval_positive (continuousOn_const : ContinuousOn (fun _ : ℝ => (0 : ℝ)) _)
    square_continuous (fun position _ => sq_nonneg (entropySlope position))
    (by
      obtain ⟨position, membership, nonzero_slope⟩ := pulse_nontrivial
      exact ⟨position, membership, sq_pos_of_ne_zero nonzero_slope⟩)
  simpa using strictly_positive

/-- Negative energy at a stationary entropy maximum is consistent with the
positive completed moment above. The local and integrated claims differ. -/
theorem local_source_negative (entropySlope entropyCurvature : ℝ → ℝ)
    (coefficient position : ℝ) (stationary : entropySlope position = 0)
    (negative_curvature : entropyCurvature position < 0) :
    source entropySlope entropyCurvature coefficient position < 0 := by
  simpa [source, stationary] using negative_curvature

def exampleSlope (position : ℝ) : ℝ := 4 * position ^ 3 - 4 * position
def exampleCurvature (position : ℝ) : ℝ := 12 * position ^ 2 - 4

/-- On [-1,1], the entropy profile (1-x²)² supplies an explicit nontrivial
slope with flat endpoints. It realizes both signs in the preceding theorems. -/
theorem example_negative_local_positive_total (coefficient : ℝ)
    (coefficient_positive : 0 < coefficient) :
    source exampleSlope exampleCurvature coefficient 0 = -4 ∧
      0 < ∫ position in (-1 : ℝ)..1, source exampleSlope exampleCurvature coefficient position := by
  constructor
  · norm_num [source, exampleSlope, exampleCurvature]
  · apply nontrivial_pulse_cannot_reset exampleSlope exampleCurvature coefficient (-1) 1
      coefficient_positive (by norm_num)
    · unfold exampleSlope
      fun_prop
    · intro position _
      convert (((hasDerivAt_id position).pow 3).const_mul 4).sub
        ((hasDerivAt_id position).const_mul 4) using 1
      · rfl
      · dsimp [exampleCurvature]
        ring
    · apply Continuous.intervalIntegrable
      unfold exampleCurvature
      fun_prop
    · norm_num [exampleSlope]
    · norm_num [exampleSlope]
    · refine ⟨1 / 2, ?_, ?_⟩ <;> norm_num [exampleSlope]

end PrimeUniverse.ConformalPulse
