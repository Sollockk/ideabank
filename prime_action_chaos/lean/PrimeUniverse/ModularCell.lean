import Mathlib.Analysis.SpecialFunctions.Log.Deriv
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.Calculus.Deriv.MeanValue
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
Chapter 149. All results apply to every real parameter greater than one:
primality is not an assumption. The state is constructed, not derived from
gravity. Coefficients are exact complex numbers, not sampled probabilities.
-/

noncomputable section

namespace PrimeUniverse.ModularCell

def groundWeight (parameter : ℝ) : ℝ := parameter / (parameter + 1)
def excitedWeight (parameter : ℝ) : ℝ := 1 / (parameter + 1)

theorem weights_normalized (parameter : ℝ) (parameter_positive : 0 < parameter) :
    groundWeight parameter + excitedWeight parameter = 1 := by
  unfold groundWeight excitedWeight
  field_simp

theorem modular_gap (parameter : ℝ) (parameter_positive : 0 < parameter) :
    -Real.log (excitedWeight parameter) - (-Real.log (groundWeight parameter)) =
      Real.log parameter := by
  unfold groundWeight excitedWeight
  rw [Real.log_div parameter_positive.ne' (by positivity),
    Real.log_div one_ne_zero (by positivity), Real.log_one]
  ring

def predictability (parameter : ℝ) : ℝ := (parameter - 1) / (parameter + 1)
def visibility (parameter : ℝ) : ℝ := 2 * Real.sqrt parameter / (parameter + 1)

theorem wave_structure_complementarity (parameter : ℝ)
    (parameter_positive : 0 < parameter) :
    predictability parameter ^ 2 + visibility parameter ^ 2 = 1 := by
  have square_root := Real.sq_sqrt parameter_positive.le
  unfold predictability visibility
  field_simp
  nlinarith

theorem visibility_squared_is_four_times_weight_product (parameter : ℝ)
    (parameter_positive : 0 < parameter) :
    visibility parameter ^ 2 = 4 * groundWeight parameter * excitedWeight parameter := by
  have square_root := Real.sq_sqrt parameter_positive.le
  unfold visibility groundWeight excitedWeight
  field_simp
  nlinarith

theorem predictability_strictly_increases (firstParameter secondParameter : ℝ)
    (first_positive : 0 < firstParameter) (increasing : firstParameter < secondParameter) :
    predictability firstParameter < predictability secondParameter := by
  unfold predictability
  apply (div_lt_div_iff₀ (by positivity) (by linarith)).mpr
  nlinarith

def entropy (parameter : ℝ) : ℝ :=
  Real.log (parameter + 1) - parameter / (parameter + 1) * Real.log parameter

theorem entropy_is_binary_entropy (parameter : ℝ) (parameter_positive : 0 < parameter) :
    entropy parameter =
      -(groundWeight parameter * Real.log (groundWeight parameter) +
        excitedWeight parameter * Real.log (excitedWeight parameter)) := by
  unfold entropy groundWeight excitedWeight
  rw [Real.log_div parameter_positive.ne' (by positivity),
    Real.log_div one_ne_zero (by positivity), Real.log_one]
  field_simp
  ring

theorem entropy_derivative (parameter : ℝ) (parameter_positive : 0 < parameter) :
    HasDerivAt entropy (-Real.log parameter / (parameter + 1) ^ 2) parameter := by
  have denominator_nonzero : parameter + 1 ≠ 0 := by positivity
  have denominator_derivative := (hasDerivAt_id parameter).add_const 1
  have quotient_derivative := (hasDerivAt_id parameter).div denominator_derivative denominator_nonzero
  have expression_derivative := (denominator_derivative.log denominator_nonzero).sub
    (quotient_derivative.mul (Real.hasDerivAt_log parameter_positive.ne'))
  convert expression_derivative using 1
  · rfl
  · dsimp
    field_simp
    ring

theorem entropy_strictly_decreases : StrictAntiOn entropy (Set.Ioi (1 : ℝ)) := by
  apply strictAntiOn_of_deriv_neg (convex_Ioi 1)
  · intro parameter parameter_in_domain
    exact (entropy_derivative parameter (lt_trans zero_lt_one parameter_in_domain)).continuousAt.continuousWithinAt
  · intro parameter parameter_in_interior
    have parameter_gt_one : 1 < parameter := by
      simpa only [interior_Ioi, Set.mem_Ioi] using parameter_in_interior
    rw [(entropy_derivative parameter (lt_trans zero_lt_one parameter_gt_one)).deriv]
    exact div_neg_of_neg_of_pos (neg_neg_of_pos (Real.log_pos parameter_gt_one)) (by positivity)

/-- A paired two-level pure state in the product basis. -/
def pairedState (groundAmplitude excitedAmplitude : ℂ) (left right : Bool) : ℂ :=
  if left = right then (if left then excitedAmplitude else groundAmplitude) else 0

def modularState (parameter : ℝ) : Bool → Bool → ℂ :=
  pairedState (Real.sqrt (groundWeight parameter)) (Real.sqrt (excitedWeight parameter))

theorem reduced_state (parameter : ℝ) (parameter_positive : 0 < parameter)
    (left right : Bool) :
    (∑ partner : Bool, modularState parameter left partner *
      star (modularState parameter right partner)) =
    if left = right then
      (if left then (excitedWeight parameter : ℂ) else (groundWeight parameter : ℂ))
    else 0 := by
  have ground_nonnegative : 0 ≤ groundWeight parameter := by
    unfold groundWeight
    positivity
  have excited_nonnegative : 0 ≤ excitedWeight parameter := by
    unfold excitedWeight
    positivity
  cases left <;> cases right <;>
    simp [modularState, pairedState, ← Complex.ofReal_mul,
      Real.mul_self_sqrt ground_nonnegative, Real.mul_self_sqrt excited_nonnegative]

theorem modular_state_normalized (parameter : ℝ) (parameter_positive : 0 < parameter) :
    (∑ left : Bool, ∑ right : Bool, Complex.normSq (modularState parameter left right)) = 1 := by
  have ground_nonnegative : 0 ≤ groundWeight parameter := by
    unfold groundWeight
    positivity
  have excited_nonnegative : 0 ≤ excitedWeight parameter := by
    unfold excitedWeight
    positivity
  simpa [modularState, pairedState, Real.mul_self_sqrt ground_nonnegative,
    Real.mul_self_sqrt excited_nonnegative, add_comm] using weights_normalized parameter parameter_positive

/-- Nonzero paired amplitudes cannot factor into separate left and right states. -/
theorem paired_state_entangled (groundAmplitude excitedAmplitude : ℂ)
    (ground_nonzero : groundAmplitude ≠ 0) (excited_nonzero : excitedAmplitude ≠ 0) :
    ¬∃ leftState rightState : Bool → ℂ,
      ∀ left right, pairedState groundAmplitude excitedAmplitude left right =
        leftState left * rightState right := by
  rintro ⟨leftState, rightState, factorization⟩
  have ground_equation := factorization false false
  have excited_equation := factorization true true
  have off_diagonal_first := factorization false true
  have off_diagonal_second := factorization true false
  simp only [pairedState, ↓reduceIte, Bool.false_eq_true, Bool.true_eq_false] at *
  apply mul_ne_zero ground_nonzero excited_nonzero
  calc
    groundAmplitude * excitedAmplitude =
      (leftState false * rightState false) * (leftState true * rightState true) := by
        rw [ground_equation, excited_equation]
    _ = (leftState false * rightState true) * (leftState true * rightState false) := by ring
    _ = 0 := by rw [← off_diagonal_first, zero_mul]

theorem modular_state_entangled (parameter : ℝ) (parameter_positive : 0 < parameter) :
    ¬∃ leftState rightState : Bool → ℂ,
      ∀ left right, modularState parameter left right = leftState left * rightState right := by
  apply paired_state_entangled
  · exact_mod_cast (Real.sqrt_pos.mpr (by unfold groundWeight; positivity)).ne'
  · exact_mod_cast (Real.sqrt_pos.mpr (by unfold excitedWeight; positivity)).ne'

def occupation (state : Bool) : ℂ := if state then 1 else 0

def differenceGenerator (energy : ℂ) (state : Bool → Bool → ℂ) (left right : Bool) : ℂ :=
  energy * (occupation left - occupation right) * state left right

def sumGenerator (energy : ℂ) (state : Bool → Bool → ℂ) (left right : Bool) : ℂ :=
  energy * (occupation left + occupation right) * state left right

theorem difference_time_is_null (energy groundAmplitude excitedAmplitude : ℂ) :
    differenceGenerator energy (pairedState groundAmplitude excitedAmplitude) = 0 := by
  funext left right
  cases left <;> cases right <;> simp [differenceGenerator, occupation, pairedState]

theorem sum_time_is_nonzero (energy groundAmplitude excitedAmplitude : ℂ)
    (energy_nonzero : energy ≠ 0) (excited_nonzero : excitedAmplitude ≠ 0) :
    sumGenerator energy (pairedState groundAmplitude excitedAmplitude) ≠ 0 := by
  intro zero_generator
  have excited_component := congrFun (congrFun zero_generator true) true
  have product_nonzero : energy * (2 : ℂ) * excitedAmplitude ≠ 0 :=
    mul_ne_zero (mul_ne_zero energy_nonzero (by norm_num)) excited_nonzero
  apply product_nonzero
  simpa [sumGenerator, occupation, pairedState] using excited_component

/-- The sum generator changes relative phase, not just an unobservable common
phase: a state with both amplitudes nonzero is not its eigenvector. -/
theorem sum_time_not_just_global_phase (energy groundAmplitude excitedAmplitude : ℂ)
    (energy_nonzero : energy ≠ 0) (ground_nonzero : groundAmplitude ≠ 0)
    (excited_nonzero : excitedAmplitude ≠ 0) :
    ¬∃ scalar : ℂ, sumGenerator energy (pairedState groundAmplitude excitedAmplitude) =
      fun left right => scalar * pairedState groundAmplitude excitedAmplitude left right := by
  rintro ⟨scalar, stationary⟩
  have ground_component := congrFun (congrFun stationary false) false
  simp [sumGenerator, occupation, pairedState] at ground_component
  have scalar_zero : scalar = 0 := ground_component.resolve_right ground_nonzero
  have generator_zero : sumGenerator energy (pairedState groundAmplitude excitedAmplitude) = 0 := by
    rw [stationary, scalar_zero]
    funext left right
    simp
  exact sum_time_is_nonzero energy groundAmplitude excitedAmplitude energy_nonzero excited_nonzero
    generator_zero

end PrimeUniverse.ModularCell
