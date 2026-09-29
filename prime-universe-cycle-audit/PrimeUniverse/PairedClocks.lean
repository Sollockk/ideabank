import Mathlib.Analysis.Complex.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-! Chapters 145 and 149: exact finite paired states. The local Hamiltonians
are diagonal in the declared matching basis. The coefficients may contain
Möbius signs, but matching energies alone imply the difference-clock result. -/

noncomputable section
namespace PrimeUniverse.PairedClocks

variable {Level : Type*} [DecidableEq Level]

def pairedState (amplitude : Level → ℂ) (leftLevel rightLevel : Level) : ℂ :=
  if leftLevel = rightLevel then amplitude leftLevel else 0

def differenceClock (energy : Level → ℝ) (state : Level → Level → ℂ)
    (leftLevel rightLevel : Level) : ℂ :=
  ((energy leftLevel : ℂ) - (energy rightLevel : ℂ)) * state leftLevel rightLevel

def sumClock (energy : Level → ℝ) (state : Level → Level → ℂ)
    (leftLevel rightLevel : Level) : ℂ :=
  ((energy leftLevel : ℂ) + (energy rightLevel : ℂ)) * state leftLevel rightLevel

def leftReduced [Fintype Level] (state : Level → Level → ℂ)
    (row column : Level) : ℂ :=
  ∑ rightLevel, state row rightLevel * star (state column rightLevel)

theorem difference_clock_annihilates_paired_state
    (energy : Level → ℝ) (amplitude : Level → ℂ) :
    differenceClock energy (pairedState amplitude) = 0 := by
  funext leftLevel rightLevel
  by_cases levels_equal : leftLevel = rightLevel
  · subst rightLevel
    simp [differenceClock]
  · simp [differenceClock, pairedState, levels_equal]

theorem sum_clock_doubles_paired_energies (energy : Level → ℝ) (amplitude : Level → ℂ) :
    sumClock energy (pairedState amplitude) =
      pairedState (fun level => 2 * (energy level : ℂ) * amplitude level) := by
  funext leftLevel rightLevel
  by_cases levels_equal : leftLevel = rightLevel
  · subst rightLevel
    simp [sumClock, pairedState, two_mul]
  · simp [sumClock, pairedState, levels_equal]

theorem sum_clock_is_not_frozen (energy : Level → ℝ) (amplitude : Level → ℂ)
    (excitedLevel : Level) (energy_nonzero : energy excitedLevel ≠ 0)
    (amplitude_nonzero : amplitude excitedLevel ≠ 0) :
    sumClock energy (pairedState amplitude) ≠ 0 := by
  intro frozen
  have diagonal := congrFun (congrFun frozen excitedLevel) excitedLevel
  simp only [sumClock, pairedState, Pi.zero_apply] at diagonal
  have complex_energy_nonzero : (energy excitedLevel : ℂ) ≠ 0 := by
    exact_mod_cast energy_nonzero
  have doubled_nonzero : (energy excitedLevel : ℂ) + (energy excitedLevel : ℂ) ≠ 0 := by
    simpa only [two_mul] using
      (mul_ne_zero (show (2 : ℂ) ≠ 0 by norm_num) complex_energy_nonzero)
  exact (mul_ne_zero doubled_nonzero amplitude_nonzero) diagonal

/-- Two occupied unequal energies rule out even a mere global-phase eigenstate.
This is stronger than saying the generator has a nonzero action. -/
theorem unequal_occupied_energies_are_not_stationary
    (energy : Level → ℝ) (amplitude : Level → ℂ) (firstLevel secondLevel : Level)
    (energies_differ : energy firstLevel ≠ energy secondLevel)
    (first_amplitude_nonzero : amplitude firstLevel ≠ 0)
    (second_amplitude_nonzero : amplitude secondLevel ≠ 0) :
    ¬ ∃ eigenvalue : ℂ, sumClock energy (pairedState amplitude) =
      fun leftLevel rightLevel => eigenvalue * pairedState amplitude leftLevel rightLevel := by
  rintro ⟨eigenvalue, eigenvector⟩
  have first_diagonal := congrFun (congrFun eigenvector firstLevel) firstLevel
  have second_diagonal := congrFun (congrFun eigenvector secondLevel) secondLevel
  simp only [sumClock, pairedState] at first_diagonal second_diagonal
  have first_eigenvalue := mul_right_cancel₀ first_amplitude_nonzero first_diagonal
  have second_eigenvalue := mul_right_cancel₀ second_amplitude_nonzero second_diagonal
  have real_energies := congrArg Complex.re (first_eigenvalue.trans second_eigenvalue.symm)
  simp only [Complex.add_re, Complex.ofReal_re] at real_energies
  exact energies_differ (by linarith)

/-- The partial trace is computed, rather than assumed as a premise. -/
theorem reduced_state_is_diagonal [Fintype Level] (amplitude : Level → ℂ)
    (row column : Level) :
    leftReduced (pairedState amplitude) row column =
      if row = column then amplitude row * star (amplitude row) else 0 := by
  classical
  unfold leftReduced pairedState
  by_cases rows_equal : row = column
  · subst column
    simp
  · simp [rows_equal, eq_comm]

theorem paired_state_normalized [Fintype Level] (amplitude : Level → ℂ)
    (amplitudes_normalized : ∑ level, Complex.normSq (amplitude level) = 1) :
    ∑ leftLevel, ∑ rightLevel, Complex.normSq (pairedState amplitude leftLevel rightLevel) = 1 := by
  classical
  simpa [pairedState, apply_ite Complex.normSq, eq_comm] using amplitudes_normalized

/-- Any independent signs, including squarefree Möbius signs, disappear from a
one-sided reduced state. No gravitational interpretation is assumed. -/
theorem local_signs_do_not_change_reduced_state [Fintype Level]
    (amplitude sign : Level → ℂ) (signs_binary : ∀ level, sign level = 1 ∨ sign level = -1) :
    leftReduced (pairedState (fun level => sign level * amplitude level)) =
      leftReduced (pairedState amplitude) := by
  funext row column
  rw [reduced_state_is_diagonal, reduced_state_is_diagonal]
  by_cases rows_equal : row = column
  · subst column
    simp only [ite_true]
    rcases signs_binary row with sign_positive | sign_negative
    · simp [sign_positive]
    · simp [sign_negative]
  · simp [rows_equal]

end PrimeUniverse.PairedClocks
