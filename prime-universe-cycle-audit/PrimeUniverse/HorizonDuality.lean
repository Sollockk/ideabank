import Mathlib.Analysis.Real.Sqrt
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-! Chapter 143, equations 143.30--143.41. The radiation and horizon energy
laws are supplied definitions. This proves their reciprocal duality, not a
spacetime extension, a physical bounce, or a mechanism creating a universe. -/

noncomputable section
namespace PrimeUniverse.HorizonDuality

def reciprocalRadius (referenceSquared radius : ℝ) : ℝ := referenceSquared / radius
def radiationEnergy (actionScale radius : ℝ) : ℝ := actionScale / radius
def horizonEnergy (gravitationalSlope radius : ℝ) : ℝ := gravitationalSlope * radius

theorem dual_radius_positive (referenceSquared radius : ℝ)
    (reference_positive : 0 < referenceSquared) (radius_positive : 0 < radius) :
    0 < reciprocalRadius referenceSquared radius := div_pos reference_positive radius_positive

theorem radius_duality_is_involution (referenceSquared radius : ℝ)
    (reference_nonzero : referenceSquared ≠ 0) (radius_nonzero : radius ≠ 0) :
    reciprocalRadius referenceSquared (reciprocalRadius referenceSquared radius) = radius := by
  unfold reciprocalRadius
  field_simp

theorem duality_exchanges_energy_branches (actionScale gravitationalSlope radius : ℝ)
    (action_nonzero : actionScale ≠ 0) (slope_nonzero : gravitationalSlope ≠ 0)
    (radius_nonzero : radius ≠ 0) :
    radiationEnergy actionScale (reciprocalRadius (actionScale / gravitationalSlope) radius) =
      horizonEnergy gravitationalSlope radius := by
  unfold radiationEnergy reciprocalRadius horizonEnergy
  field_simp

theorem positive_fixed_point_iff (referenceSquared radius : ℝ)
    (radius_positive : 0 < radius) :
    reciprocalRadius referenceSquared radius = radius ↔ radius ^ 2 = referenceSquared := by
  unfold reciprocalRadius
  rw [div_eq_iff (ne_of_gt radius_positive)]
  constructor <;> intro equality <;> nlinarith

theorem unique_positive_fixed_point (referenceSquared : ℝ)
    (reference_positive : 0 < referenceSquared) :
    ∃! radius : ℝ, 0 < radius ∧ reciprocalRadius referenceSquared radius = radius := by
  refine ⟨Real.sqrt referenceSquared, ?_, ?_⟩
  · refine ⟨Real.sqrt_pos.2 reference_positive, ?_⟩
    exact (positive_fixed_point_iff _ _ (Real.sqrt_pos.2 reference_positive)).2
      (Real.sq_sqrt (le_of_lt reference_positive))
  · intro radius conditions
    have radius_square := (positive_fixed_point_iff _ _ conditions.1).1 conditions.2
    have root_square := Real.sq_sqrt (le_of_lt reference_positive)
    have root_nonnegative := Real.sqrt_nonneg referenceSquared
    nlinarith

/-- Larger positive radius is mapped to smaller positive radius. -/
theorem duality_reverses_order (referenceSquared firstRadius secondRadius : ℝ)
    (reference_positive : 0 < referenceSquared) (first_positive : 0 < firstRadius)
    (radii_ordered : firstRadius < secondRadius) :
    reciprocalRadius referenceSquared secondRadius < reciprocalRadius referenceSquared firstRadius := by
  unfold reciprocalRadius
  exact div_lt_div_of_pos_left reference_positive first_positive radii_ordered

/-- Schwarzschild entropy/action equality, conditional on the displayed energy law.
`planckArea` stands for G*hbar/c^3, and entropy is dimensionless S/k_B. -/
theorem horizon_information_equals_crossing_action
    (radius lightSpeed gravity reducedPlanck : ℝ)
    (light_nonzero : lightSpeed ≠ 0) (gravity_nonzero : gravity ≠ 0)
    (planck_nonzero : reducedPlanck ≠ 0) :
    (4 * Real.pi * radius ^ 2) / (4 * (gravity * reducedPlanck / lightSpeed ^ 3)) =
      2 * Real.pi * ((lightSpeed ^ 4 * radius / (2 * gravity)) * (radius / lightSpeed)) /
        reducedPlanck := by
  field_simp

end PrimeUniverse.HorizonDuality
