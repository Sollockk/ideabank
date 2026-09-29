import PrimeUniverse.Bell
import PrimeUniverse.ConformalPulse
import PrimeUniverse.CycleSpectrum
import PrimeUniverse.ModularCell
import PrimeUniverse.ScaleAndHorizon
import PrimeUniverse.ThermalZeta
import PrimeUniverse.HeatCapacity
import PrimeUniverse.DeterminantResponse
import PrimeUniverse.PrimeCutoff

/-! The cross-chapter connections, using the independently checked modules. -/

noncomputable section

namespace PrimeUniverse.Connections

/-- The constructed modular gap equals the cycle's half-log spectral product.
This equality applies to composites too; it is not a dynamics selecting primes. -/
theorem cycle_action_equals_modular_gap (modeCount : ℕ) :
    -Real.log (ModularCell.excitedWeight ((modeCount : ℝ) + 1)) -
      (-Real.log (ModularCell.groundWeight ((modeCount : ℝ) + 1))) =
        (1 / 2 : ℝ) * Real.log (CycleSpectrum.cycleSpectralProduct (modeCount + 1)) := by
  rw [ModularCell.modular_gap _ (by positivity), CycleSpectrum.determinant_action]

/-- The local cycle spectral action gives the actual n^(-s) Boltzmann factor;
the infinite prime product theorem in ThermalZeta supplies its domain of validity. -/
theorem cycle_action_gives_arithmetic_weight (modeCount : ℕ) (spectralParameter : ℂ) :
    Complex.exp (-spectralParameter *
      (((1 / 2 : ℝ) * Real.log (CycleSpectrum.cycleSpectralProduct (modeCount + 1)) : ℝ) : ℂ)) =
      ((modeCount + 1 : ℕ) : ℂ) ^ (-spectralParameter) := by
  rw [CycleSpectrum.determinant_action]
  convert ThermalZeta.orbit_weight_is_prime_power (modeCount + 1) (by omega) spectralParameter using 1
  simp [ThermalZeta.orbitWeight]

end PrimeUniverse.Connections
