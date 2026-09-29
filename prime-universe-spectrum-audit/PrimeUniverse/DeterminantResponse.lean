import PrimeUniverse.CycleSpectrum
import Mathlib.Analysis.SpecialFunctions.Log.Deriv
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic.Linarith

/-!
Chapter 146: what a scaled cycle determinant actually contributes to an action.
We start with the previously certified complete nonzero spectrum, scale each
eigenvalue, and differentiate its half-log product. This is a one-parameter
scale response, not a formalization of a covariant gravitational stress tensor.
-/

noncomputable section

namespace PrimeUniverse.DeterminantResponse

def scaledSpectralProduct (modeCount : ℕ) (scale referenceScale : ℝ) : ℝ :=
  ∏ mode ∈ Finset.range modeCount,
    Complex.normSq (1 - CycleSpectrum.cycleRoot (modeCount + 1) ^ (mode + 1)) /
      (scale * referenceScale) ^ 2

def effectiveAction (modeCount : ℕ) (referenceScale scale : ℝ) : ℝ :=
  (1 / 2 : ℝ) * Real.log (scaledSpectralProduct modeCount scale referenceScale)

theorem scaled_spectral_product (modeCount : ℕ) (scale referenceScale : ℝ) :
    scaledSpectralProduct modeCount scale referenceScale =
      ((modeCount : ℝ) + 1) ^ 2 / ((scale * referenceScale) ^ 2) ^ modeCount := by
  unfold scaledSpectralProduct
  rw [Finset.prod_div_distrib]
  have unscaled_product := CycleSpectrum.cycle_spectral_product modeCount
  simp only [CycleSpectrum.cycleSpectralProduct, Nat.add_sub_cancel] at unscaled_product
  rw [unscaled_product]
  simp

theorem scaled_action (modeCount : ℕ) (scale referenceScale : ℝ)
    (scale_positive : 0 < scale) (reference_positive : 0 < referenceScale) :
    effectiveAction modeCount referenceScale scale =
      Real.log ((modeCount : ℝ) + 1) -
        modeCount * (Real.log scale + Real.log referenceScale) := by
  unfold effectiveAction
  rw [scaled_spectral_product,
    Real.log_div (by positivity) (by positivity),
    Real.log_pow, Real.log_pow, Real.log_pow,
    Real.log_mul scale_positive.ne' reference_positive.ne']
  ring

theorem action_derivative (modeCount : ℕ) (scale referenceScale : ℝ)
    (scale_positive : 0 < scale) (reference_positive : 0 < referenceScale) :
    HasDerivAt (effectiveAction modeCount referenceScale) (-(modeCount : ℝ) / scale) scale := by
  have expression_derivative := (hasDerivAt_const scale (Real.log ((modeCount : ℝ) + 1))).sub
    (((Real.hasDerivAt_log scale_positive.ne').add_const (Real.log referenceScale)).const_mul
      (modeCount : ℝ))
  have simplified_derivative :
      HasDerivAt (fun nearby => Real.log ((modeCount : ℝ) + 1) -
        modeCount * (Real.log nearby + Real.log referenceScale)) (-(modeCount : ℝ) / scale) scale := by
    convert expression_derivative using 1
    simp [div_eq_mul_inv]
  apply simplified_derivative.congr_of_eventuallyEq
  filter_upwards [Ioi_mem_nhds scale_positive] with nearby nearby_positive
  exact scaled_action modeCount nearby referenceScale nearby_positive reference_positive

theorem logarithmic_scale_response (modeCount : ℕ) (scale referenceScale : ℝ)
    (scale_positive : 0 < scale) (reference_positive : 0 < referenceScale) :
    scale * deriv (effectiveAction modeCount referenceScale) scale = -(modeCount : ℝ) := by
  rw [(action_derivative modeCount scale referenceScale scale_positive reference_positive).deriv]
  field_simp

/-- Changing the normalization scale changes the action by a constant in scale. -/
theorem reference_scale_shift (modeCount : ℕ) (scale firstReference secondReference : ℝ)
    (scale_positive : 0 < scale) (first_positive : 0 < firstReference)
    (second_positive : 0 < secondReference) :
    effectiveAction modeCount firstReference scale -
      effectiveAction modeCount secondReference scale =
      modeCount * (Real.log secondReference - Real.log firstReference) := by
  rw [scaled_action modeCount scale firstReference scale_positive first_positive,
    scaled_action modeCount scale secondReference scale_positive second_positive]
  ring

/-- The finite log(n) normalization has zero derivative with respect to size. -/
theorem determinant_normalization_has_zero_response (modeCount : ℕ) (scale : ℝ) :
    HasDerivAt (fun _ : ℝ => Real.log ((modeCount : ℝ) + 1)) 0 scale :=
  hasDerivAt_const scale _

/-- Any finite family responds by its total nonzero mode count. -/
theorem family_action_derivative (labels : Finset ℕ) (scale referenceScale : ℝ)
    (scale_positive : 0 < scale) (reference_positive : 0 < referenceScale) :
    HasDerivAt
      (fun nearby => ∑ label ∈ labels, effectiveAction (label - 1) referenceScale nearby)
      (-(∑ label ∈ labels, ((label - 1 : ℕ) : ℝ)) / scale) scale := by
  have family_derivative := HasDerivAt.fun_sum (u := labels)
    (fun label _ => action_derivative (label - 1) scale referenceScale
      scale_positive reference_positive)
  convert family_derivative using 1
  simp [div_eq_mul_inv, Finset.sum_mul, Finset.sum_neg_distrib]

/-- The manuscript's first 37 primes, specified by a primality predicate. -/
def horizonPrimes : Finset ℕ := (Finset.range 158).filter Nat.Prime

set_option maxRecDepth 4096 in
theorem horizon_prime_count : horizonPrimes.card = 37 := by decide

set_option maxRecDepth 4096 in
theorem horizon_nonzero_mode_count : (∑ prime ∈ horizonPrimes, (prime - 1)) = 2547 := by decide

/-- Chapter 146 reserves 2 and 3, and uses the remaining 35 prime cycles. -/
def seamPrimes : Finset ℕ := horizonPrimes.filter (5 ≤ ·)

set_option maxRecDepth 4096 in
theorem seam_prime_count : seamPrimes.card = 35 := by decide

set_option maxRecDepth 4096 in
theorem seam_nonzero_mode_count : (∑ prime ∈ seamPrimes, (prime - 1)) = 2544 := by decide

theorem seam_logarithmic_response (scale referenceScale : ℝ)
    (scale_positive : 0 < scale) (reference_positive : 0 < referenceScale) :
    scale * deriv
      (fun nearby => ∑ prime ∈ seamPrimes, effectiveAction (prime - 1) referenceScale nearby)
      scale = -2544 := by
  rw [(family_action_derivative seamPrimes scale referenceScale
    scale_positive reference_positive).deriv]
  have mode_count : (∑ prime ∈ seamPrimes, ((prime - 1 : ℕ) : ℝ)) = 2544 := by
    exact_mod_cast seam_nonzero_mode_count
  rw [mode_count]
  field_simp

end PrimeUniverse.DeterminantResponse
