import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-! Chapter 150, equations 150.1--150.5. Finite diagonal Gibbs states.
We prove equality of the complete probability distribution under rescaling,
then prove that the dimensionless gap cannot uniquely determine energy. -/

noncomputable section
namespace PrimeUniverse.ClockScale

def gibbsProbability {Level : Type*} [Fintype Level]
    (energy : Level → ℝ) (inverseTemperature : ℝ) (level : Level) : ℝ :=
  Real.exp (-inverseTemperature * energy level) /
    ∑ otherLevel, Real.exp (-inverseTemperature * energy otherLevel)

theorem gibbs_partition_positive {Level : Type*} [Fintype Level] [Nonempty Level]
    (energy : Level → ℝ) (inverseTemperature : ℝ) :
    0 < ∑ level, Real.exp (-inverseTemperature * energy level) := by
  exact Finset.sum_pos (fun level _ => Real.exp_pos _) Finset.univ_nonempty

theorem gibbs_probabilities_normalized {Level : Type*} [Fintype Level] [Nonempty Level]
    (energy : Level → ℝ) (inverseTemperature : ℝ) :
    ∑ level, gibbsProbability energy inverseTemperature level = 1 := by
  simp only [gibbsProbability, div_eq_mul_inv, ← Finset.sum_mul]
  rw [← div_eq_mul_inv]
  exact div_self (ne_of_gt (gibbs_partition_positive energy inverseTemperature))

theorem dimensionless_energy_invariant (energy inverseTemperature scale : ℝ)
    (scale_nonzero : scale ≠ 0) :
    (inverseTemperature / scale) * (scale * energy) = inverseTemperature * energy := by
  field_simp

theorem gibbs_distribution_invariant {Level : Type*} [Fintype Level]
    (energy : Level → ℝ) (inverseTemperature scale : ℝ)
    (scale_positive : 0 < scale) :
    gibbsProbability (fun level => scale * energy level) (inverseTemperature / scale) =
      gibbsProbability energy inverseTemperature := by
  have exponent_identity : ∀ level,
      -(inverseTemperature / scale) * (scale * energy level) =
        -inverseTemperature * energy level := by
    intro level
    field_simp
  funext level
  simp only [gibbsProbability, exponent_identity]

theorem energy_clock_product_invariant (energy clock scale : ℝ)
    (scale_nonzero : scale ≠ 0) :
    (scale * energy) * (clock / scale) = energy * clock := by
  field_simp

/-- Even positive energy and positive temperature do not remove the ambiguity. -/
theorem dimensionless_gap_cannot_determine_energy :
    ¬ ∃ calibration : ℝ → ℝ,
      ∀ energy inverseTemperature : ℝ, 0 < energy → 0 < inverseTemperature →
        calibration (inverseTemperature * energy) = energy := by
  rintro ⟨calibration, calibrates⟩
  have first := calibrates 1 1 (by norm_num) (by norm_num)
  have second := calibrates 2 (1 / 2) (by norm_num) (by norm_num)
  norm_num at first second
  linarith

end PrimeUniverse.ClockScale
