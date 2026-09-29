import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
Chapters 59 and 85. Conditional sampling reproduces the proposed correlation,
but locality is a separate mathematical requirement. The finite hidden-variable
bound below quantifies over arbitrary probability weights and local sign tables.
-/

namespace PrimeUniverse.Bell

/-- Joint outcome probabilities, with Alice's positive probability `aliceWeight`
and Bob's probability of agreeing with Alice `agreement`. -/
def correlation (aliceWeight agreement : ℝ) : ℝ :=
  aliceWeight * agreement - aliceWeight * (1 - agreement) -
    (1 - aliceWeight) * (1 - agreement) + (1 - aliceWeight) * agreement

theorem conditional_correlation (aliceWeight agreement : ℝ) :
    correlation aliceWeight agreement = 2 * agreement - 1 := by
  unfold correlation
  ring

theorem quantum_correlation (aliceWeight angle : ℝ) :
    correlation aliceWeight (Real.sin (angle / 2) ^ 2) = -Real.cos angle := by
  rw [conditional_correlation]
  have double_angle := Real.cos_two_mul (angle / 2)
  have pythagoras := Real.sin_sq_add_cos_sq (angle / 2)
  have twice_half : 2 * (angle / 2) = angle := by ring
  rw [twice_half] at double_angle
  nlinarith

/-- Bob's local marginal, after forgetting Alice's outcome. -/
def bobPositive (aliceWeight agreement : ℝ) : ℝ :=
  aliceWeight * agreement + (1 - aliceWeight) * (1 - agreement)

theorem marginal_setting_dependence (aliceWeight firstAgreement secondAgreement : ℝ) :
    bobPositive aliceWeight firstAgreement - bobPositive aliceWeight secondAgreement =
      (2 * aliceWeight - 1) * (firstAgreement - secondAgreement) := by
  unfold bobPositive
  ring

theorem no_signalling_iff_balanced (aliceWeight : ℝ) :
    (∀ firstAgreement ∈ Set.Icc (0 : ℝ) 1,
      ∀ secondAgreement ∈ Set.Icc (0 : ℝ) 1,
      bobPositive aliceWeight firstAgreement = bobPositive aliceWeight secondAgreement) ↔
      aliceWeight = 1 / 2 := by
  constructor
  · intro independent
    have endpoints := independent 0 (by constructor <;> norm_num) 1
      (by constructor <;> norm_num)
    unfold bobPositive at endpoints
    linarith
  · rintro rfl firstAgreement _ secondAgreement _
    unfold bobPositive
    ring

def chsh (aliceFirst aliceSecond bobFirst bobSecond : ℝ) : ℝ :=
  aliceFirst * bobFirst + aliceFirst * bobSecond +
    aliceSecond * bobFirst - aliceSecond * bobSecond

theorem local_chsh_pointwise (aliceFirst aliceSecond bobFirst bobSecond : ℝ)
    (aliceFirst_sign : aliceFirst = 1 ∨ aliceFirst = -1)
    (aliceSecond_sign : aliceSecond = 1 ∨ aliceSecond = -1)
    (bobFirst_sign : bobFirst = 1 ∨ bobFirst = -1)
    (bobSecond_sign : bobSecond = 1 ∨ bobSecond = -1) :
    |chsh aliceFirst aliceSecond bobFirst bobSecond| = 2 := by
  rcases aliceFirst_sign with rfl | rfl <;>
    rcases aliceSecond_sign with rfl | rfl <;>
    rcases bobFirst_sign with rfl | rfl <;>
    rcases bobSecond_sign with rfl | rfl <;>
    norm_num [chsh]

/-- One common probability distribution and one response per local setting are
the locality/measurement-independence premises. Stochastic local responses can
be represented by enlarging the hidden variable; that reduction is not needed here. -/
theorem local_hidden_variable_chsh_bound {Hidden : Type*} [Fintype Hidden]
    (weight aliceFirst aliceSecond bobFirst bobSecond : Hidden → ℝ)
    (weights_nonnegative : ∀ hidden, 0 ≤ weight hidden)
    (weights_normalized : ∑ hidden, weight hidden = 1)
    (aliceFirst_sign : ∀ hidden, aliceFirst hidden = 1 ∨ aliceFirst hidden = -1)
    (aliceSecond_sign : ∀ hidden, aliceSecond hidden = 1 ∨ aliceSecond hidden = -1)
    (bobFirst_sign : ∀ hidden, bobFirst hidden = 1 ∨ bobFirst hidden = -1)
    (bobSecond_sign : ∀ hidden, bobSecond hidden = 1 ∨ bobSecond hidden = -1) :
    |∑ hidden, weight hidden *
      chsh (aliceFirst hidden) (aliceSecond hidden) (bobFirst hidden) (bobSecond hidden)| ≤ 2 := by
  calc
    _ ≤ ∑ hidden, |weight hidden *
        chsh (aliceFirst hidden) (aliceSecond hidden) (bobFirst hidden) (bobSecond hidden)| :=
      Finset.abs_sum_le_sum_abs _ _
    _ = ∑ hidden, weight hidden * 2 := by
      apply Finset.sum_congr rfl
      intro hidden _
      rw [abs_mul, abs_of_nonneg (weights_nonnegative hidden),
        local_chsh_pointwise _ _ _ _ (aliceFirst_sign hidden) (aliceSecond_sign hidden)
          (bobFirst_sign hidden) (bobSecond_sign hidden)]
    _ = 2 := by rw [← Finset.sum_mul, weights_normalized, one_mul]

/-- The same conditional mechanism allows the algebraic value four even with
balanced marginals. These four context-dependent agreements are not local tables. -/
theorem conditional_pr_box :
    correlation (1 / 2) 1 + correlation (1 / 2) 1 +
      correlation (1 / 2) 1 - correlation (1 / 2) 0 = 4 := by
  norm_num [correlation]

/-- Settings a₀=0, a₁=π/2, b₀=π/4, b₁=-π/4 give these four angle
differences (up to the even correlation). The conditional rule reaches 2√2. -/
theorem quantum_chsh_value (aliceWeight : ℝ) :
    |correlation aliceWeight (Real.sin ((Real.pi / 4) / 2) ^ 2) +
      correlation aliceWeight (Real.sin ((-Real.pi / 4) / 2) ^ 2) +
      correlation aliceWeight (Real.sin ((Real.pi / 4) / 2) ^ 2) -
      correlation aliceWeight (Real.sin ((3 * Real.pi / 4) / 2) ^ 2)| =
        2 * Real.sqrt 2 := by
  simp_rw [quantum_correlation]
  have third_angle : Real.cos (3 * Real.pi / 4) = -(Real.sqrt 2 / 2) := by
    rw [show 3 * Real.pi / 4 = Real.pi - Real.pi / 4 by ring,
      Real.cos_pi_sub, Real.cos_pi_div_four]
  rw [neg_div, Real.cos_neg, Real.cos_pi_div_four, third_angle]
  rw [abs_of_nonpos (by have := Real.sqrt_nonneg (2 : ℝ); linarith)]
  ring

theorem quantum_value_exceeds_local_bound : (2 : ℝ) < 2 * Real.sqrt 2 := by
  have square_root := Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 2)
  have nonnegative := Real.sqrt_nonneg (2 : ℝ)
  nlinarith

end PrimeUniverse.Bell
