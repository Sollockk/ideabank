import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
Chapters 143 and 150. Algebraic horizon/action consequences and a genuine
nonidentifiability theorem. The energy-radius laws are explicit model inputs;
no Einstein equation, junction, or physical clock is derived here.
-/

noncomputable section

namespace PrimeUniverse.ScaleAndHorizon

def gibbsProbability {Level : Type*} [Fintype Level]
    (inverseTemperature : ℝ) (energy : Level → ℝ) (level : Level) : ℝ :=
  Real.exp (-inverseTemperature * energy level) /
    ∑ otherLevel, Real.exp (-inverseTemperature * energy otherLevel)

theorem gibbs_scale_invariant {Level : Type*} [Fintype Level]
    (inverseTemperature scale : ℝ) (energy : Level → ℝ) (scale_positive : 0 < scale) :
    gibbsProbability (inverseTemperature / scale) (fun level => scale * energy level) =
      gibbsProbability inverseTemperature energy := by
  have exponent_identity (level : Level) :
      -(inverseTemperature / scale) * (scale * energy level) =
        -inverseTemperature * energy level := by
    field_simp
  funext level
  simp only [gibbsProbability, exponent_identity]

/-- No function of the normalized state alone recovers every physical inverse
temperature: the all-zero Hamiltonian has the same state at temperatures 1 and 2. -/
theorem no_state_only_temperature {Level : Type*} [Fintype Level] :
    ¬∃ recover : (Level → ℝ) → ℝ,
      ∀ inverseTemperature : ℝ, 0 < inverseTemperature →
        ∀ energy : Level → ℝ,
          recover (gibbsProbability inverseTemperature energy) = inverseTemperature := by
  rintro ⟨recover, recovery⟩
  have first := recovery 1 (by norm_num) (fun _ => 0)
  have second := recovery 2 (by norm_num) (fun _ => 0)
  have same_state : gibbsProbability (1 : ℝ) (fun _ : Level => 0) =
      gibbsProbability 2 (fun _ : Level => 0) := by
    funext level
    simp [gibbsProbability]
  rw [same_state] at first
  linarith

/-- A nonzero gap retains the degeneracy too; it is not an artifact of the
constant-energy example in the general impossibility theorem. -/
theorem nonzero_gap_scale_degeneracy (inverseTemperature gap : ℝ)
    (gap_positive : 0 < gap) :
    gibbsProbability (inverseTemperature / 2) (fun excited : Bool => if excited then 2 * gap else 0) =
      gibbsProbability inverseTemperature (fun excited : Bool => if excited then gap else 0) ∧
      gap ≠ 2 * gap := by
  constructor
  · convert gibbs_scale_invariant inverseTemperature 2
      (fun excited : Bool => if excited then gap else 0) (by norm_num) using 1
    congr 1
    funext excited
    cases excited <;> simp
  · linarith

def reciprocalRadius (fixedRadiusSquared radius : ℝ) : ℝ := fixedRadiusSquared / radius

theorem positive_radius_involution (fixedRadiusSquared radius : ℝ)
    (seed_positive : 0 < fixedRadiusSquared) (radius_positive : 0 < radius) :
    0 < reciprocalRadius fixedRadiusSquared radius ∧
      reciprocalRadius fixedRadiusSquared (reciprocalRadius fixedRadiusSquared radius) = radius := by
  unfold reciprocalRadius
  constructor
  · positivity
  · field_simp

theorem reciprocal_radius_fixed_iff (fixedRadiusSquared radius : ℝ)
    (radius_positive : 0 < radius) :
    reciprocalRadius fixedRadiusSquared radius = radius ↔ radius ^ 2 = fixedRadiusSquared := by
  unfold reciprocalRadius
  rw [div_eq_iff radius_positive.ne']
  constructor <;> intro equality <;> nlinarith [equality]

/-- Radiation energy is K/R and the horizon threshold is coefficient*R.
Their exchange under R ↦ (K/coefficient)/R is exact for positive inputs. -/
theorem radiation_horizon_exchange (waveConstant horizonCoefficient radius : ℝ)
    (wave_positive : 0 < waveConstant) (horizon_positive : 0 < horizonCoefficient)
    (radius_positive : 0 < radius) :
    waveConstant / reciprocalRadius (waveConstant / horizonCoefficient) radius =
      horizonCoefficient * radius := by
  unfold reciprocalRadius
  field_simp

theorem inherited_action_matches_seed (gravity lightSpeed parentRadius : ℝ)
    (gravity_positive : 0 < gravity) (light_positive : 0 < lightSpeed) :
    let parentEnergy := lightSpeed ^ 4 * parentRadius / (2 * gravity)
    let inheritedAction := parentEnergy * parentRadius / lightSpeed
    2 * gravity * inheritedAction / lightSpeed ^ 3 = parentRadius ^ 2 := by
  dsimp
  field_simp

/-- At the assumed Schwarzschild energy law, the Euclidean free action and
area entropy agree. All constants and the factor 4π are retained symbolically. -/
theorem horizon_action_entropy (gravity lightSpeed reducedPlanck radius circleConstant : ℝ)
    (gravity_positive : 0 < gravity) (light_positive : 0 < lightSpeed)
    (planck_positive : 0 < reducedPlanck) :
    let energy := lightSpeed ^ 4 * radius / (2 * gravity)
    let freeEnergy := energy / 2
    let thermalPeriod := 4 * circleConstant * radius / lightSpeed
    let area := 4 * circleConstant * radius ^ 2
    freeEnergy * thermalPeriod / reducedPlanck =
      area * lightSpeed ^ 3 / (4 * gravity * reducedPlanck) := by
  dsimp
  field_simp
  ring

end PrimeUniverse.ScaleAndHorizon
