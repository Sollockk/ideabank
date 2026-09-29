import PrimeUniverse.Arithmetic
import PrimeUniverse.ClockScale
import PrimeUniverse.CycleProduct
import PrimeUniverse.CycleDeterminant
import PrimeUniverse.ModularCell
import PrimeUniverse.ThermalZeta

/-! Selected formal foundations for the prime action and chaos research note.
These bridges equate explicit quantities; they do not derive a physical
generator or formalize the nonlinear-chaos and forecasting results. -/

namespace PrimeUniverse.Bridge

/-- The spectral action equals the modular gap of the specified two-level
state. The parameter need not be prime. -/
theorem cycle_action_matches_modular_gap (nonzeroModeCount : ℕ) (root : ℂ)
    (root_primitive : IsPrimitiveRoot root (nonzeroModeCount + 1)) :
    (1 / 2 : ℝ) * Real.log (CycleProduct.spectralProduct nonzeroModeCount root) =
      -Real.log (ModularCell.excitedWeight ((nonzeroModeCount : ℝ) + 1)) -
        (-Real.log (ModularCell.groundWeight ((nonzeroModeCount : ℝ) + 1))) := by
  rw [CycleProduct.logarithmic_cycle_action _ _ root_primitive,
    ModularCell.modular_gap _ (by exact_mod_cast Nat.succ_pos nonzeroModeCount)]

/-- The same equality starting from a concrete local cycle matrix, whose
determinant is proved independently through Fourier diagonalization. -/
theorem concrete_cycle_action_matches_modular_gap (nonzeroModeCount : ℕ) :
    (1 / 2 : ℝ) * Real.log
      ((CycleDeterminant.regularizedMatrix (vertexCount := nonzeroModeCount + 1)).det.re) =
        -Real.log (ModularCell.excitedWeight ((nonzeroModeCount : ℝ) + 1)) -
          (-Real.log (ModularCell.groundWeight ((nonzeroModeCount : ℝ) + 1))) := by
  rw [CycleDeterminant.concrete_cycle_logarithmic_action,
    ModularCell.modular_gap _ (by exact_mod_cast Nat.succ_pos nonzeroModeCount)]

end PrimeUniverse.Bridge
