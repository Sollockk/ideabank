import PrimeUniverse.DeterminantResponse
import Mathlib.Analysis.Real.Pi.Bounds

/-!
Chapter 144's finite arithmetic cutoff. The factor 16*pi^2 is an input;
the inequalities and selected prime sets are proved. No gravitational
calibration or reason for reserving the primes 2 and 3 is assumed as a theorem.
-/

namespace PrimeUniverse.PrimeCutoff

theorem geometric_cutoff_bounds :
    (157 : ℝ) < 16 * Real.pi ^ 2 ∧ 16 * Real.pi ^ 2 < 158 := by
  have lower_square : (3.14 : ℝ) ^ 2 < Real.pi ^ 2 :=
    (sq_lt_sq₀ (by norm_num) Real.pi_pos.le).2 Real.pi_gt_d2
  have upper_square : Real.pi ^ 2 < (3.1416 : ℝ) ^ 2 :=
    (sq_lt_sq₀ Real.pi_pos.le (by norm_num)).2 Real.pi_lt_d4
  constructor <;> nlinarith

theorem horizon_membership_is_geometric_cutoff (label : ℕ) :
    label ∈ DeterminantResponse.horizonPrimes ↔
      Nat.Prime label ∧ (label : ℝ) ≤ 16 * Real.pi ^ 2 := by
  simp only [DeterminantResponse.horizonPrimes, Finset.mem_filter, Finset.mem_range]
  constructor
  · rintro ⟨below_cutoff, is_prime⟩
    have integral_bound : (label : ℝ) ≤ 157 := by
      exact_mod_cast (show label ≤ 157 by omega)
    exact ⟨is_prime, le_trans integral_bound geometric_cutoff_bounds.1.le⟩
  · rintro ⟨is_prime, below_cutoff⟩
    have integral_bound : label < 158 := by
      exact_mod_cast lt_of_le_of_lt below_cutoff geometric_cutoff_bounds.2
    exact ⟨integral_bound, is_prime⟩

theorem seam_membership_is_geometric_cutoff (label : ℕ) :
    label ∈ DeterminantResponse.seamPrimes ↔
      Nat.Prime label ∧ 5 ≤ label ∧ (label : ℝ) ≤ 16 * Real.pi ^ 2 := by
  simp only [DeterminantResponse.seamPrimes, Finset.mem_filter,
    horizon_membership_is_geometric_cutoff]
  tauto

end PrimeUniverse.PrimeCutoff
