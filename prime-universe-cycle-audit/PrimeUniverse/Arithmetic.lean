import Mathlib.NumberTheory.ArithmeticFunction.Moebius
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Tactic.NormNum

/-! Chapters 1, 40, 66 and 145. Established arithmetic behind the proposed
interpretations. The Möbius results are explicit applications of mathlib's
existing theorems, not claims of newly discovered number theory. -/

namespace PrimeUniverse.Arithmetic

open scoped ArithmeticFunction.Moebius

theorem mobius_at_one : μ 1 = 1 := ArithmeticFunction.moebius_apply_one

theorem mobius_at_prime (prime : ℕ) (prime_is_prime : Nat.Prime prime) : μ prime = -1 :=
  ArithmeticFunction.moebius_apply_prime prime_is_prime

theorem mobius_square_is_unit (number : ℕ) (number_squarefree : Squarefree number) :
    μ number ^ 2 = 1 := ArithmeticFunction.moebius_sq_eq_one_of_squarefree number_squarefree

theorem mobius_divisor_cancellation (number : ℕ) :
    ∑ divisor ∈ number.divisors, μ divisor = if number = 1 then 1 else 0 := by
  have inverse_identity := congrArg (fun arithmetic : ArithmeticFunction ℤ => arithmetic number)
    ArithmeticFunction.moebius_mul_coe_zeta
  simpa only [ArithmeticFunction.coe_mul_zeta_apply, ArithmeticFunction.one_apply] using
    inverse_identity

theorem one_is_unique_nonzero_divisor_sum (number : ℕ) :
    (∑ divisor ∈ number.divisors, μ divisor) ≠ 0 ↔ number = 1 := by
  rw [mobius_divisor_cancellation]
  split_ifs with number_is_one <;> simp [number_is_one]

/-- Exactly 2^K subsets expand from K factors; no prime hypothesis is involved.
This is an identity for a structured product, not free access to arbitrary
independent amplitudes on an exponentially large state space. -/
theorem finite_euler_product_expansion {Label Scalar : Type*} [CommSemiring Scalar]
    (labels : Finset Label) (weight : Label → Scalar) :
    ∏ label ∈ labels, (1 + weight label) =
      ∑ selected ∈ labels.powerset, ∏ label ∈ selected, weight label :=
  Finset.prod_one_add labels

theorem euler_configuration_count {Label : Type*} (labels : Finset Label) :
    labels.powerset.card = 2 ^ labels.card := Finset.card_powerset labels

end PrimeUniverse.Arithmetic
