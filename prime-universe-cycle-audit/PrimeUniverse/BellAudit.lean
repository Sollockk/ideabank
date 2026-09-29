import Mathlib.Analysis.Real.Sqrt
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-! Chapters 59 and 85. Explicit probability algebra and a finite CHSH audit.
`aliceProbability` is P(A=+1). `plusConditional` is P(B=+1 | A=+1).
The advertised update additionally fixes P(B=+1 | A=-1)=1-plusConditional.
None of the arithmetic alone establishes Bell locality. -/

namespace PrimeUniverse.BellAudit

def correlation (aliceProbability plusConditional minusConditional : ℝ) : ℝ :=
  aliceProbability * plusConditional - aliceProbability * (1 - plusConditional) -
    (1 - aliceProbability) * minusConditional +
    (1 - aliceProbability) * (1 - minusConditional)

def bobProbability (aliceProbability updateProbability : ℝ) : ℝ :=
  aliceProbability * updateProbability + (1 - aliceProbability) * (1 - updateProbability)

def chsh (firstFirst firstSecond secondFirst secondSecond : ℝ) : ℝ :=
  firstFirst + firstSecond + secondFirst - secondSecond

theorem update_joint_probabilities_normalize (aliceProbability updateProbability : ℝ) :
    aliceProbability * updateProbability + aliceProbability * (1 - updateProbability) +
      (1 - aliceProbability) * (1 - updateProbability) +
      (1 - aliceProbability) * updateProbability = 1 := by
  ring

theorem update_joint_probabilities_nonnegative (aliceProbability updateProbability : ℝ)
    (alice_nonnegative : 0 ≤ aliceProbability) (alice_at_most_one : aliceProbability ≤ 1)
    (update_nonnegative : 0 ≤ updateProbability) (update_at_most_one : updateProbability ≤ 1) :
    0 ≤ aliceProbability * updateProbability ∧
    0 ≤ aliceProbability * (1 - updateProbability) ∧
    0 ≤ (1 - aliceProbability) * (1 - updateProbability) ∧
    0 ≤ (1 - aliceProbability) * updateProbability := by
  exact ⟨mul_nonneg alice_nonnegative update_nonnegative,
    mul_nonneg alice_nonnegative (sub_nonneg.mpr update_at_most_one),
    mul_nonneg (sub_nonneg.mpr alice_at_most_one) (sub_nonneg.mpr update_at_most_one),
    mul_nonneg (sub_nonneg.mpr alice_at_most_one) update_nonnegative⟩

theorem complementary_update_correlation (aliceProbability updateProbability : ℝ) :
    correlation aliceProbability updateProbability (1 - updateProbability) =
      2 * updateProbability - 1 := by
  unfold correlation
  ring

theorem trigonometric_update_gives_quantum_correlation (aliceProbability angleDifference : ℝ) :
    correlation aliceProbability (Real.sin (angleDifference / 2) ^ 2)
      (Real.cos (angleDifference / 2) ^ 2) = -Real.cos angleDifference := by
  have half_angle := Real.sin_sq_add_cos_sq (angleDifference / 2)
  have complementary : Real.cos (angleDifference / 2) ^ 2 =
      1 - Real.sin (angleDifference / 2) ^ 2 := by linarith
  rw [complementary, complementary_update_correlation]
  have doubled_angle := Real.cos_two_mul (angleDifference / 2)
  have double_half : 2 * (angleDifference / 2) = angleDifference := by ring
  rw [double_half] at doubled_angle
  linarith

/-- The complementary second conditional is necessary for the claimed universal formula. -/
theorem missing_conditional_is_necessary (plusConditional minusConditional : ℝ) :
    (∀ aliceProbability : ℝ,
      correlation aliceProbability plusConditional minusConditional = 2 * plusConditional - 1) ↔
      minusConditional = 1 - plusConditional := by
  constructor
  · intro universal_formula
    have endpoint := universal_formula 0
    unfold correlation at endpoint
    linarith
  · intro complementary
    subst minusConditional
    exact fun aliceProbability => complementary_update_correlation aliceProbability plusConditional

/-- Both conditional probabilities are valid, but the single-conditional claim fails. -/
theorem one_conditional_does_not_determine_correlation :
    correlation (1 / 2) 0 0 ≠ 2 * (0 : ℝ) - 1 := by
  norm_num [correlation]

theorem unbiased_alice_gives_unbiased_bob (updateProbability : ℝ) :
    bobProbability (1 / 2) updateProbability = 1 / 2 := by
  unfold bobProbability
  ring

/-- At a fixed Alice marginal, independence from every update value in [0,1]
requires unbiased Alice. This is a marginal statement, not Bell locality. -/
theorem bob_marginal_independent_iff_unbiased (aliceProbability : ℝ) :
    (∀ updateProbability : ℝ, 0 ≤ updateProbability → updateProbability ≤ 1 →
      bobProbability aliceProbability updateProbability = bobProbability aliceProbability 0) ↔
      aliceProbability = 1 / 2 := by
  constructor
  · intro independent
    have endpoints := independent 1 (by norm_num) (by norm_num)
    unfold bobProbability at endpoints
    linarith
  · intro unbiased
    subst aliceProbability
    intro updateProbability _ _
    rw [unbiased_alice_gives_unbiased_bob, unbiased_alice_gives_unbiased_bob]

theorem deterministic_local_chsh_bound (aliceFirst aliceSecond bobFirst bobSecond : ℝ)
    (alice_first_binary : aliceFirst = 1 ∨ aliceFirst = -1)
    (alice_second_binary : aliceSecond = 1 ∨ aliceSecond = -1)
    (bob_first_binary : bobFirst = 1 ∨ bobFirst = -1)
    (bob_second_binary : bobSecond = 1 ∨ bobSecond = -1) :
    |chsh (aliceFirst * bobFirst) (aliceFirst * bobSecond)
      (aliceSecond * bobFirst) (aliceSecond * bobSecond)| ≤ 2 := by
  rcases alice_first_binary with rfl | rfl <;>
    rcases alice_second_binary with rfl | rfl <;>
    rcases bob_first_binary with rfl | rfl <;>
    rcases bob_second_binary with rfl | rfl <;> norm_num [chsh]

/-- One shared distribution and four local response functions, for any finite
hidden-state space. Measurement-dependent distributions are outside this theorem. -/
theorem finite_local_chsh_bound {HiddenState : Type*} [Fintype HiddenState]
    (weight aliceFirst aliceSecond bobFirst bobSecond : HiddenState → ℝ)
    (weights_nonnegative : ∀ hiddenState, 0 ≤ weight hiddenState)
    (weights_normalized : ∑ hiddenState, weight hiddenState = 1)
    (alice_first_binary : ∀ hiddenState, aliceFirst hiddenState = 1 ∨ aliceFirst hiddenState = -1)
    (alice_second_binary : ∀ hiddenState, aliceSecond hiddenState = 1 ∨ aliceSecond hiddenState = -1)
    (bob_first_binary : ∀ hiddenState, bobFirst hiddenState = 1 ∨ bobFirst hiddenState = -1)
    (bob_second_binary : ∀ hiddenState, bobSecond hiddenState = 1 ∨ bobSecond hiddenState = -1) :
    |∑ hiddenState, weight hiddenState *
      chsh (aliceFirst hiddenState * bobFirst hiddenState)
        (aliceFirst hiddenState * bobSecond hiddenState)
        (aliceSecond hiddenState * bobFirst hiddenState)
        (aliceSecond hiddenState * bobSecond hiddenState)| ≤ 2 := by
  calc
    _ ≤ ∑ hiddenState, |weight hiddenState *
        chsh (aliceFirst hiddenState * bobFirst hiddenState)
          (aliceFirst hiddenState * bobSecond hiddenState)
          (aliceSecond hiddenState * bobFirst hiddenState)
          (aliceSecond hiddenState * bobSecond hiddenState)| :=
      Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ hiddenState, weight hiddenState * 2 := by
      apply Finset.sum_le_sum
      intro hiddenState _
      rw [abs_mul, abs_of_nonneg (weights_nonnegative hiddenState)]
      exact mul_le_mul_of_nonneg_left
        (deterministic_local_chsh_bound _ _ _ _
          (alice_first_binary hiddenState) (alice_second_binary hiddenState)
          (bob_first_binary hiddenState) (bob_second_binary hiddenState))
        (weights_nonnegative hiddenState)
    _ = 2 := by rw [← Finset.sum_mul, weights_normalized, one_mul]

/-- A conditional sampler can prescribe the PR correlation table.
Together with the local bound, this does not furnish a local hidden-variable model. -/
theorem conditional_sampler_reaches_four :
    chsh (correlation (1 / 2) 1 0) (correlation (1 / 2) 1 0)
      (correlation (1 / 2) 1 0) (correlation (1 / 2) 0 1) = 4 := by
  norm_num [chsh, correlation]

end PrimeUniverse.BellAudit
