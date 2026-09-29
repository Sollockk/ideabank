import PrimeUniverse.Arithmetic
import PrimeUniverse.BellAudit
import PrimeUniverse.ClockScale
import PrimeUniverse.CycleProduct
import PrimeUniverse.CycleDeterminant
import PrimeUniverse.HorizonDuality
import PrimeUniverse.ModularCell
import PrimeUniverse.PairedClocks

/-! Entry point for selected mathematical claims from PRIME_UNIVERSE_THEORY.md.
See README.md for assumptions, scope and the reproducible verification receipt. -/

namespace PrimeUniverse.Bridge

/-- Equation 149.5 at the level of the explicit spectral product and the
specified two-level density matrix. Equality does not derive the density
matrix dynamically from a cycle. Primality is again unnecessary. -/
theorem cycle_action_matches_modular_gap (nonzeroModeCount : ℕ) (root : ℂ)
    (root_primitive : IsPrimitiveRoot root (nonzeroModeCount + 1)) :
    (1 / 2 : ℝ) * Real.log (CycleProduct.spectralProduct nonzeroModeCount root) =
      -Real.log (ModularCell.excitedProbability ((nonzeroModeCount : ℝ) + 1)) -
        (-Real.log (ModularCell.groundProbability ((nonzeroModeCount : ℝ) + 1))) := by
  rw [CycleProduct.logarithmic_cycle_action _ _ root_primitive,
    ModularCell.modular_gap _ (by exact_mod_cast Nat.succ_pos nonzeroModeCount)]

/-- The same bridge using the determinant of the independently specified
local cycle matrix. No primitive root or spectrum is assumed here. -/
theorem concrete_cycle_action_matches_modular_gap (nonzeroModeCount : ℕ) :
    (1 / 2 : ℝ) * Real.log
      ((CycleDeterminant.regularizedMatrix (vertexCount := nonzeroModeCount + 1)).det.re) =
        -Real.log (ModularCell.excitedProbability ((nonzeroModeCount : ℝ) + 1)) -
          (-Real.log (ModularCell.groundProbability ((nonzeroModeCount : ℝ) + 1))) := by
  rw [CycleDeterminant.concrete_cycle_logarithmic_action,
    ModularCell.modular_gap _ (by exact_mod_cast Nat.succ_pos nonzeroModeCount)]

end PrimeUniverse.Bridge
