#!/usr/bin/env python3
"""Audit an explicit arithmetic realization of deterministic chaos.

This is a model construction, not a derivation of physical dynamics.  The
independent checks connect cycle determinants, Fourier dilation, reversible
baker maps, exact symbolic cycles, and zeta-distributed branch probabilities.
Only the Python standard library is required.  No observed future state is
supplied to any forward trajectory.
"""

from __future__ import annotations

import argparse
import cmath
import itertools
import json
import math
from bisect import bisect_right
from fractions import Fraction
from pathlib import Path

def generate_primes_up_to(limit: int) -> list[int]:
    """Small sieve, included here to keep the research folder independent."""
    primality_flags = bytearray(b"\x01") * (limit + 1)
    primality_flags[0:2] = b"\x00\x00"
    for possible_divisor in range(2, math.isqrt(limit) + 1):
        if primality_flags[possible_divisor]:
            first_composite = possible_divisor * possible_divisor
            composite_count = (limit - first_composite) // possible_divisor + 1
            primality_flags[first_composite:limit + 1:possible_divisor] = b"\x00" * composite_count
    return [candidate for candidate in range(2, limit + 1) if primality_flags[candidate]]


def exact_cycle_pseudodeterminant(cycle_order: int) -> int:
    """Compute the cofactor recurrence, then apply the matrix-tree theorem.

    C_2 denotes the two-parallel-edge multicycle. These small helpers are
    adapted from the originating repository's prime-cycle audit; no import
    from that repository is needed.
    """
    if cycle_order < 2:
        raise ValueError("cycle order must be at least two")
    determinant_two_sizes_back = 1
    determinant_one_size_back = 2
    for _matrix_size in range(2, cycle_order):
        current_determinant = 2 * determinant_one_size_back - determinant_two_sizes_back
        determinant_two_sizes_back = determinant_one_size_back
        determinant_one_size_back = current_determinant
    return cycle_order * determinant_one_size_back


def require(condition: bool, explanation: str) -> None:
    if not condition:
        raise AssertionError(explanation)


def require_close(actual: float, expected: float, tolerance: float = 1e-11) -> None:
    require(abs(actual - expected) <= tolerance, f"{actual} != {expected}")


def mobius_value(integer_value: int) -> int:
    remaining_factor = integer_value
    parity_sign = 1
    possible_divisor = 2
    while possible_divisor * possible_divisor <= remaining_factor:
        if remaining_factor % possible_divisor == 0:
            remaining_factor //= possible_divisor
            parity_sign = -parity_sign
            if remaining_factor % possible_divisor == 0:
                return 0
        possible_divisor += 1
    return -parity_sign if remaining_factor > 1 else parity_sign


def primitive_necklaces(alphabet_size: int, word_length: int):
    """Enumerate primitive symbolic cycles without using Mobius inversion."""
    for symbol_word in itertools.product(range(alphabet_size), repeat=word_length):
        if any(
            word_length % shorter_length == 0
            and symbol_word == symbol_word[:shorter_length] * (word_length // shorter_length)
            for shorter_length in range(1, word_length)
        ):
            continue
        if symbol_word == min(
            symbol_word[rotation:] + symbol_word[:rotation]
            for rotation in range(word_length)
        ):
            yield symbol_word


def audit_prime_dilation() -> dict:
    rows = []
    largest_commutator_error = 0.0
    largest_pullback_error = 0.0
    largest_modular_phase_error = 0.0
    for expansion_factor in [2, 3, 4, 5, 6, 11]:
        determinant_action = 0.5 * math.log(exact_cycle_pseudodeterminant(expansion_factor))
        require_close(determinant_action, math.log(expansion_factor))
        for frequency_index in range(1, 41):
            action_increment = math.log(expansion_factor * frequency_index) - math.log(frequency_index)
            largest_commutator_error = max(
                largest_commutator_error, abs(action_increment - determinant_action)
            )
            coordinate = Fraction(17, 101)
            mapped_coordinate = (expansion_factor * coordinate) % 1
            pullback_value = cmath.exp(2j * math.pi * frequency_index * float(mapped_coordinate))
            shifted_mode_value = cmath.exp(
                2j * math.pi * (expansion_factor * frequency_index * coordinate % 1)
            )
            largest_pullback_error = max(largest_pullback_error, abs(pullback_value - shifted_mode_value))
            inverse_temperature = 2.0
            modular_time = 0.37
            conjugated_shift_phase = cmath.exp(1j * modular_time * inverse_temperature * action_increment)
            expected_shift_phase = cmath.exp(1j * modular_time * inverse_temperature * determinant_action)
            largest_modular_phase_error = max(
                largest_modular_phase_error, abs(conjugated_shift_phase - expected_shift_phase)
            )
        cutoff = 4096
        remaining_modes = [cutoff // expansion_factor**step for step in range(15)]
        first_zero_step = next(step for step, rank in enumerate(remaining_modes) if rank == 0)
        rows.append({
            "expansion_factor": expansion_factor,
            "cycle_action": determinant_action,
            "positive_lyapunov_per_step": math.log(expansion_factor),
            "compressed_mode_cutoff": cutoff,
            "first_zero_rank_step": first_zero_step,
        })
    require(largest_pullback_error < 1e-12, "Fourier pullback does not agree with dilation")
    require(largest_commutator_error < 1e-12, "logarithmic action commutator failed")
    require(largest_modular_phase_error < 1e-12, "Gibbs modular covariance failed")
    return {
        "rows": rows,
        "max_fourier_pullback_error": largest_pullback_error,
        "max_action_commutator_error": largest_commutator_error,
        "max_modular_phase_error": largest_modular_phase_error,
        "composite_controls_included": [4, 6],
        "global_gibbs_state_requires_inverse_temperature_greater_than_one": True,
    }


def audit_symbolic_cycles() -> dict:
    counting_rows = []
    for alphabet_size in [2, 3]:
        for word_length in range(1, 7):
            primitive_count = sum(1 for _ in primitive_necklaces(alphabet_size, word_length))
            mobius_numerator = sum(
                mobius_value(divisor) * alphabet_size ** (word_length // divisor)
                for divisor in range(1, word_length + 1)
                if word_length % divisor == 0
            )
            require(mobius_numerator == word_length * primitive_count, "primitive orbit count failed")
            counting_rows.append({
                "alphabet_size": alphabet_size,
                "word_length": word_length,
                "primitive_symbolic_orbits": primitive_count,
            })

    branch_weights = [Fraction(36, 49), Fraction(9, 49), Fraction(4, 49)]
    maximum_degree = 6
    cycle_products = []
    for moment_order in [1, 2]:
        coefficients = [Fraction(1)] + [Fraction(0)] * maximum_degree
        for word_length in range(1, maximum_degree + 1):
            for symbol_word in primitive_necklaces(len(branch_weights), word_length):
                cycle_weight = math.prod(branch_weights[symbol] ** moment_order for symbol in symbol_word)
                previous_coefficients = coefficients[:]
                for degree in range(maximum_degree + 1):
                    coefficients[degree] = sum(
                        previous_coefficients[degree - repeat_count * word_length] * cycle_weight**repeat_count
                        for repeat_count in range(degree // word_length + 1)
                    )
        branch_moment = sum(weight**moment_order for weight in branch_weights)
        require(
            coefficients == [branch_moment**degree for degree in range(maximum_degree + 1)],
            "primitive-cycle Euler product differs from independently summed words",
        )
        cycle_products.append({
            "moment_order": moment_order,
            "branch_moment": str(branch_moment),
            "coefficients": [str(coefficient) for coefficient in coefficients],
        })
    return {
        "primitive_counts": counting_rows,
        "weighted_cycle_products": cycle_products,
        "finite_cycle_check_counts_symbolic_words_not_endpoint_quotiented_interval_orbits": True,
        "circle_fixed_point_correction": "Fix(x -> m*x mod 1, step k) = m**k - 1",
    }


def cumulative_starts(branch_weights: list[Fraction]) -> list[Fraction]:
    require(sum(branch_weights) == 1, "branch weights must sum to one")
    require(all(weight > 0 for weight in branch_weights), "branch weights must be positive")
    boundaries = [Fraction(0)]
    for branch_weight in branch_weights:
        boundaries.append(boundaries[-1] + branch_weight)
    return boundaries


def exact_baker_step(
    position: Fraction, history: Fraction, branch_weights: list[Fraction], boundaries: list[Fraction]
) -> tuple[Fraction, Fraction, int]:
    require(0 <= position < 1 and 0 <= history < 1, "state is outside the unit square")
    branch_index = bisect_right(boundaries, position) - 1
    branch_weight = branch_weights[branch_index]
    branch_start = boundaries[branch_index]
    return (position - branch_start) / branch_weight, branch_start + branch_weight * history, branch_index


def exact_baker_inverse(
    position: Fraction, history: Fraction, branch_weights: list[Fraction], boundaries: list[Fraction]
) -> tuple[Fraction, Fraction]:
    branch_index = bisect_right(boundaries, history) - 1
    branch_weight = branch_weights[branch_index]
    branch_start = boundaries[branch_index]
    return branch_start + branch_weight * position, (history - branch_start) / branch_weight


def cylinder_interval(symbol_word: tuple[int, ...], branch_weights: list[Fraction]) -> tuple[Fraction, Fraction]:
    boundaries = cumulative_starts(branch_weights)
    lower_endpoint, upper_endpoint = Fraction(0), Fraction(1)
    for branch_index in reversed(symbol_word):
        lower_endpoint = boundaries[branch_index] + branch_weights[branch_index] * lower_endpoint
        upper_endpoint = boundaries[branch_index] + branch_weights[branch_index] * upper_endpoint
    return lower_endpoint, upper_endpoint


def audit_reversible_action_flow() -> dict:
    branch_weights = [Fraction(144, 205), Fraction(36, 205), Fraction(16, 205), Fraction(9, 205)]
    boundaries = cumulative_starts(branch_weights)
    initial_position, initial_history = Fraction(173, 997), Fraction(31, 127)
    position, history = initial_position, initial_history
    perturbation = Fraction(1, 10**30)
    perturbed_position, perturbed_history = initial_position + perturbation, initial_history
    cumulative_stretch = Fraction(1)
    action_sum = 0.0
    shared_itinerary = True
    first_distinct_branch_step = None
    shared_itinerary_steps_checked = 0
    trajectory_samples = []
    for step in range(1, 101):
        position, history, branch_index = exact_baker_step(position, history, branch_weights, boundaries)
        perturbed_position, perturbed_history, perturbed_branch_index = exact_baker_step(
            perturbed_position, perturbed_history, branch_weights, boundaries
        )
        if branch_index != perturbed_branch_index and shared_itinerary:
            first_distinct_branch_step = step
            shared_itinerary = False
        cumulative_stretch /= branch_weights[branch_index]
        action_sum -= math.log(float(branch_weights[branch_index]))
        if shared_itinerary:
            require(position - perturbed_position == -perturbation * cumulative_stretch, "exact action growth failed")
            shared_itinerary_steps_checked += 1
        if step in [10, 20, 40, 60, 80, 100]:
            trajectory_samples.append({
                "step": step,
                "position": float(position),
                "separation": float(abs(position - perturbed_position)),
                "accumulated_modular_action": action_sum,
                "itineraries_still_match": shared_itinerary,
            })
    for _ in range(100):
        position, history = exact_baker_inverse(position, history, branch_weights, boundaries)
    require((position, history) == (initial_position, initial_history), "exact reverse evolution failed")
    require(shared_itinerary_steps_checked > 20, "too little common trajectory to test stretching")
    first_cylinder = cylinder_interval((1, 2), branch_weights)
    second_cylinder = cylinder_interval((2, 1), branch_weights)
    require(first_cylinder != second_cylinder, "ordered paths were incorrectly identified")
    require(
        first_cylinder[1] - first_cylinder[0] == second_cylinder[1] - second_cylinder[0],
        "equal products must have equal cylinder widths",
    )
    for symbol_word in itertools.product(range(4), repeat=4):
        lower_endpoint, upper_endpoint = cylinder_interval(symbol_word, branch_weights)
        require(
            upper_endpoint - lower_endpoint == math.prod(branch_weights[symbol] for symbol in symbol_word),
            "cylinder information is not accumulated modular action",
        )
    return {
        "branch_weights": [str(weight) for weight in branch_weights],
        "forward_steps": 100,
        "inverse_steps": 100,
        "exact_state_recovered": True,
        "initial_position_perturbation": str(perturbation),
        "shared_itinerary_steps_checked_exactly": shared_itinerary_steps_checked,
        "first_distinct_branch_step": first_distinct_branch_step,
        "trajectory_samples": trajectory_samples,
        "same_action_different_paths": {
            "word_2_3_interval": [str(endpoint) for endpoint in first_cylinder],
            "word_3_2_interval": [str(endpoint) for endpoint in second_cylinder],
            "common_width": str(first_cylinder[1] - first_cylinder[0]),
        },
    }


def zeta_and_log_moment(exponent: float, cutoff: int = 4096) -> tuple[float, float]:
    """Euler--Maclaurin values for zeta(s) and -zeta'(s), real s > 1.

    Independent integral bounds below check the result; these floating point
    evaluations are not advertised as interval-arithmetic certificates.
    """
    if exponent <= 1:
        raise ValueError("a normalized arithmetic Gibbs state requires s > 1")
    logarithmic_cutoff = math.log(cutoff)
    partition_sum = math.fsum(index**-exponent for index in range(1, cutoff))
    logarithmic_sum = math.fsum(math.log(index) * index**-exponent for index in range(1, cutoff))
    partition_sum += cutoff ** (1 - exponent) / (exponent - 1) + 0.5 * cutoff**-exponent
    logarithmic_sum += cutoff ** (1 - exponent) * (
        logarithmic_cutoff / (exponent - 1) + 1 / (exponent - 1) ** 2
    ) + 0.5 * logarithmic_cutoff * cutoff**-exponent
    bernoulli_coefficients = [Fraction(1, 12), Fraction(-1, 720), Fraction(1, 30240), Fraction(-1, 1209600)]
    for coefficient_index, coefficient in enumerate(bernoulli_coefficients, start=1):
        rising_length = 2 * coefficient_index - 1
        rising_product = math.prod(exponent + offset for offset in range(rising_length))
        derivative_log_product = sum(1 / (exponent + offset) for offset in range(rising_length))
        correction = float(coefficient) * rising_product * cutoff ** (-exponent - rising_length)
        partition_sum += correction
        logarithmic_sum += correction * (logarithmic_cutoff - derivative_log_product)
    return partition_sum, logarithmic_sum


def entropy_integral_bounds(exponent: float, cutoff: int = 20000) -> tuple[float, float]:
    partition_sum = math.fsum(index**-exponent for index in range(1, cutoff + 1))
    logarithmic_sum = math.fsum(math.log(index) * index**-exponent for index in range(1, cutoff + 1))
    partition_lower = partition_sum + (cutoff + 1) ** (1 - exponent) / (exponent - 1)
    partition_upper = partition_sum + cutoff ** (1 - exponent) / (exponent - 1)

    def integrated_log_tail(lower_limit: int) -> float:
        return lower_limit ** (1 - exponent) * (
            math.log(lower_limit) / (exponent - 1) + 1 / (exponent - 1) ** 2
        )

    logarithmic_lower = logarithmic_sum + integrated_log_tail(cutoff + 1)
    logarithmic_upper = logarithmic_sum + integrated_log_tail(cutoff)
    return (
        math.log(partition_lower) + exponent * logarithmic_lower / partition_upper,
        math.log(partition_upper) + exponent * logarithmic_upper / partition_lower,
    )


def audit_zeta_chaos() -> dict:
    entropy_rows = []
    for exponent in [1.1, 1.5, 2.0, 3.0]:
        partition_value, logarithmic_moment = zeta_and_log_moment(exponent)
        entropy = math.log(partition_value) + exponent * logarithmic_moment / partition_value
        entropy_lower, entropy_upper = entropy_integral_bounds(exponent)
        require(entropy_lower - 1e-13 <= entropy <= entropy_upper + 1e-13, "entropy outside integral bounds")
        alternate_partition, alternate_logarithmic_moment = zeta_and_log_moment(exponent, cutoff=256)
        require_close(partition_value, alternate_partition)
        require_close(logarithmic_moment, alternate_logarithmic_moment)
        entropy_rows.append({
            "inverse_temperature": exponent,
            "zeta": partition_value,
            "positive_lyapunov_and_entropy_nats_per_step": entropy,
            "bits_per_step": entropy / math.log(2),
            "independent_entropy_bounds": [entropy_lower, entropy_upper],
        })
    require_close(zeta_and_log_moment(2)[0], math.pi**2 / 6)
    require_close(zeta_and_log_moment(4)[0], math.pi**4 / 90)
    prime_cutoff = 100000
    prime_entropy = math.fsum(
        -math.log1p(-prime_value**-2) + 2 * math.log(prime_value) / (prime_value**2 - 1)
        for prime_value in generate_primes_up_to(prime_cutoff)
    )
    entropy_at_two = entropy_rows[2]["positive_lyapunov_and_entropy_nats_per_step"]
    require(0 < entropy_at_two - prime_entropy < 3e-5, "prime sum does not approach the zeta entropy")
    partition_at_two = zeta_and_log_moment(2)[0]
    second_moment = zeta_and_log_moment(4)[0] / partition_at_two**2
    require_close(second_moment, 0.4)
    finite_difference_step = 1e-5

    def pressure(moment_order: float) -> float:
        return math.log(zeta_and_log_moment(2 * moment_order)[0]) - moment_order * math.log(partition_at_two)

    pressure_derivative = (pressure(1 + finite_difference_step) - pressure(1 - finite_difference_step)) / (2 * finite_difference_step)
    require_close(-pressure_derivative, entropy_at_two, tolerance=2e-9)
    return {
        "entropy_rows": entropy_rows,
        "prime_entropy_cutoff": prime_cutoff,
        "finite_prime_entropy_at_s_2": prime_entropy,
        "uncomputed_prime_entropy_tail": entropy_at_two - prime_entropy,
        "purity_at_s_2": second_moment,
        "negative_pressure_derivative_at_q_1": -pressure_derivative,
        "moment_domain": "s*q > 1; the q=1/2 boundary at s=2 is divergence, not RH",
    }


def audit_state_dynamics_nonuniqueness() -> dict:
    cell_rows = []
    for prime_value in [2, 3, 5, 11, 157]:
        cell_weights = [prime_value / (prime_value + 1), 1 / (prime_value + 1)]
        cell_entropy = -math.fsum(weight * math.log(weight) for weight in cell_weights)
        require_close(cell_entropy, math.log(prime_value + 1) - prime_value * math.log(prime_value) / (prime_value + 1))
        cell_rows.append({
            "prime": prime_value,
            "modular_gap": math.log(prime_value),
            "two_branch_baker_lyapunov": cell_entropy,
            "identity_map_lyapunov": 0.0,
            "same_one_time_branch_probabilities": cell_weights,
        })
    require(
        all(cell_rows[index + 1]["two_branch_baker_lyapunov"] < cell_rows[index]["two_branch_baker_lyapunov"] for index in range(len(cell_rows) - 1)),
        "cell entropy should decrease while the modular gap increases",
    )
    return {
        "cell_rows": cell_rows,
        "independent_finite_phase_rotation_lyapunov": 0.0,
        "entropy_rate_bound_applies_to_the_observed_symbol_process": True,
        "no_universal_chaos_rate_follows_from_a_density_matrix_alone": True,
    }


def markov_baker_step(
    position: Fraction,
    history: Fraction,
    stationary_weights: list[Fraction],
    transition_matrix: list[list[Fraction]],
) -> tuple[Fraction, Fraction, int, int]:
    boundaries = cumulative_starts(stationary_weights)
    source_index = bisect_right(boundaries, position) - 1
    relative_position = (position - boundaries[source_index]) / stationary_weights[source_index]
    outgoing_boundaries = cumulative_starts(transition_matrix[source_index])
    target_index = bisect_right(outgoing_boundaries, relative_position) - 1
    subinterval_start = boundaries[source_index] + stationary_weights[source_index] * outgoing_boundaries[target_index]
    reverse_probability = (
        stationary_weights[source_index] * transition_matrix[source_index][target_index]
        / stationary_weights[target_index]
    )
    history_start = sum(
        stationary_weights[earlier_index] * transition_matrix[earlier_index][target_index]
        / stationary_weights[target_index]
        for earlier_index in range(source_index)
    )
    return (
        boundaries[target_index] + (position - subinterval_start) / reverse_probability,
        history_start + reverse_probability * history,
        source_index,
        target_index,
    )


def markov_baker_inverse(
    position: Fraction,
    history: Fraction,
    stationary_weights: list[Fraction],
    transition_matrix: list[list[Fraction]],
) -> tuple[Fraction, Fraction]:
    boundaries = cumulative_starts(stationary_weights)
    target_index = bisect_right(boundaries, position) - 1
    reverse_probabilities = [
        stationary_weights[source_index] * transition_matrix[source_index][target_index]
        / stationary_weights[target_index]
        for source_index in range(len(stationary_weights))
    ]
    history_boundaries = cumulative_starts(reverse_probabilities)
    source_index = bisect_right(history_boundaries, history) - 1
    outgoing_start = sum(transition_matrix[source_index][:target_index])
    subinterval_start = boundaries[source_index] + stationary_weights[source_index] * outgoing_start
    return (
        subinterval_start + reverse_probabilities[source_index] * (position - boundaries[target_index]),
        (history - history_boundaries[source_index]) / reverse_probabilities[source_index],
    )


def audit_ordered_markov_flow() -> dict:
    stationary_weights = [Fraction(3, 4), Fraction(1, 4)]
    refresh_fraction = Fraction(1, 4)
    transition_matrix = [
        [
            (1 - refresh_fraction if source_index == target_index else 0)
            + refresh_fraction * stationary_weights[target_index]
            for target_index in range(2)
        ]
        for source_index in range(2)
    ]
    require(
        [sum(stationary_weights[source_index] * transition_matrix[source_index][target_index] for source_index in range(2)) for target_index in range(2)]
        == stationary_weights,
        "the transition operator does not preserve the Gibbs marginals",
    )
    marginal_entropy = -sum(float(weight) * math.log(float(weight)) for weight in stationary_weights)
    entropy_rate = -sum(
        float(stationary_weights[source_index] * transition_matrix[source_index][target_index])
        * math.log(float(transition_matrix[source_index][target_index]))
        for source_index in range(2) for target_index in range(2)
    )
    mutual_information = sum(
        float(stationary_weights[source_index] * transition_matrix[source_index][target_index])
        * math.log(float(transition_matrix[source_index][target_index] / stationary_weights[target_index]))
        for source_index in range(2) for target_index in range(2)
    )
    expected_stretch = sum(
        float(stationary_weights[source_index] * transition_matrix[source_index][target_index])
        * math.log(float(stationary_weights[target_index] / (stationary_weights[source_index] * transition_matrix[source_index][target_index])))
        for source_index in range(2) for target_index in range(2)
    )
    require_close(entropy_rate, marginal_entropy - mutual_information)
    require_close(entropy_rate, expected_stretch)

    initial_state = Fraction(173, 997), Fraction(31, 127)
    position, history = initial_state
    cumulative_derivative = Fraction(1)
    path_probability = Fraction(1)
    initial_branch = None
    final_branch = None
    for _ in range(100):
        position, history, source_index, target_index = markov_baker_step(
            position, history, stationary_weights, transition_matrix
        )
        if initial_branch is None:
            initial_branch = source_index
        final_branch = target_index
        path_probability *= transition_matrix[source_index][target_index]
        cumulative_derivative *= stationary_weights[target_index] / (
            stationary_weights[source_index] * transition_matrix[source_index][target_index]
        )
    require(
        cumulative_derivative == stationary_weights[final_branch] / (stationary_weights[initial_branch] * path_probability),
        "the conditional action failed to telescope along the actual trajectory",
    )
    for _ in range(100):
        position, history = markov_baker_inverse(position, history, stationary_weights, transition_matrix)
    require((position, history) == initial_state, "Markov baker inverse did not recover the exact initial state")

    forecasts = []
    for horizon in [1, 2, 5, 10]:
        enumerated_rare_probability = Fraction(0)
        for future_word in itertools.product(range(2), repeat=horizon):
            if future_word[-1] != 1:
                continue
            last_index = 1
            word_probability = Fraction(1)
            for next_index in future_word:
                word_probability *= transition_matrix[last_index][next_index]
                last_index = next_index
            enumerated_rare_probability += word_probability
        spectral_prediction = stationary_weights[1] + (1 - refresh_fraction)**horizon * (1 - stationary_weights[1])
        require(enumerated_rare_probability == spectral_prediction, "blind forecast disagrees with all future path weights")
        forecasts.append({"horizon": horizon, "probability_of_rare_branch_given_initial_rare_branch": float(spectral_prediction)})

    maximum_degree = 6
    for moment_order in [1, 2]:
        coefficients = [Fraction(1)] + [Fraction(0)] * maximum_degree
        for word_length in range(1, maximum_degree + 1):
            for symbol_word in primitive_necklaces(2, word_length):
                cycle_weight = math.prod(
                    transition_matrix[symbol_word[index]][symbol_word[(index + 1) % word_length]]**moment_order
                    for index in range(word_length)
                )
                previous_coefficients = coefficients[:]
                for degree in range(maximum_degree + 1):
                    coefficients[degree] = sum(
                        previous_coefficients[degree - repeat_count * word_length] * cycle_weight**repeat_count
                        for repeat_count in range(degree // word_length + 1)
                    )
        weighted_matrix = [[entry**moment_order for entry in row] for row in transition_matrix]
        matrix_trace = weighted_matrix[0][0] + weighted_matrix[1][1]
        matrix_determinant = weighted_matrix[0][0] * weighted_matrix[1][1] - weighted_matrix[0][1] * weighted_matrix[1][0]
        determinant_coefficients = [Fraction(1), matrix_trace]
        for degree in range(2, maximum_degree + 1):
            determinant_coefficients.append(matrix_trace * determinant_coefficients[-1] - matrix_determinant * determinant_coefficients[-2])
        require(coefficients == determinant_coefficients, "ordered cycle product differs from transition determinant")
    return {
        "stationary_weights": [str(weight) for weight in stationary_weights],
        "transition_matrix": [[str(entry) for entry in row] for row in transition_matrix],
        "refresh_fraction": str(refresh_fraction),
        "marginal_entropy": marginal_entropy,
        "conditional_entropy_and_lyapunov": entropy_rate,
        "successive_label_mutual_information": mutual_information,
        "per_step_forecast_log_loss_improvement_with_current_label": mutual_information,
        "subleading_transition_eigenvalue": float(1 - refresh_fraction),
        "blind_ensemble_forecasts": forecasts,
        "exact_forward_and_inverse_steps": 100,
        "path_action_telescoping_verified": True,
        "primitive_cycle_determinant_checked_through_degree": maximum_degree,
        "forecast_scope": "known constructed Markov dynamics; initial label only; future path enumeration is validation, not prediction input",
    }


def audit_exact_jump_and_resolution() -> dict:
    expansion_factor = 3
    denominator = 1000000007
    initial_numerator = 123456789
    iterative_numerator = initial_numerator
    for step in range(1, 1001):
        iterative_numerator = expansion_factor * iterative_numerator % denominator
        require(
            iterative_numerator == initial_numerator * pow(expansion_factor, step, denominator) % denominator,
            "modular jump differs from direct iteration",
        )
    target_step = 10**18
    target_numerator = initial_numerator * pow(expansion_factor, target_step, denominator) % denominator
    intermediate_step = 123456789012345678
    composed_numerator = (
        initial_numerator * pow(expansion_factor, intermediate_step, denominator)
        * pow(expansion_factor, target_step - intermediate_step, denominator)
    ) % denominator
    require(target_numerator == composed_numerator, "jump composition failed")

    known_digit_count, hidden_digit_count = 5, 4
    known_prefix = 37
    initial_grid_denominator = expansion_factor ** (known_digit_count + hidden_digit_count)
    final_numerators = sorted({
        (known_prefix * expansion_factor**hidden_digit_count + hidden_digits) * expansion_factor**known_digit_count
        % initial_grid_denominator
        for hidden_digits in range(expansion_factor**hidden_digit_count)
    })
    expected_numerators = [index * expansion_factor**known_digit_count for index in range(expansion_factor**hidden_digit_count)]
    require(final_numerators == expected_numerators, "unresolved digits did not fill the expected observation grid")
    return {
        "expansion_factor": expansion_factor,
        "initial_rational_state": f"{initial_numerator}/{denominator}",
        "direct_iteration_comparisons": 1000,
        "jump_step": target_step,
        "jump_rational_state": f"{target_numerator}/{denominator}",
        "jump_composition_verified": True,
        "known_initial_base_three_digits": known_digit_count,
        "unresolved_suffix_ensemble_size": len(final_numerators),
        "ensemble_covers_uniform_grid_after_steps": known_digit_count,
        "limitation": "exact rational input and this special map only; finite rational orbits are eventually periodic",
    }


def main() -> None:
    argument_parser = argparse.ArgumentParser(description=__doc__)
    argument_parser.add_argument("--json-output", type=Path, help="write the complete audit as JSON")
    command_line_arguments = argument_parser.parse_args()
    audit_results = {
        "status": "all_checks_passed",
        "scope": "exact model construction; physical generator selection and predictive advantage remain open",
        "prime_dilation": audit_prime_dilation(),
        "symbolic_cycles": audit_symbolic_cycles(),
        "reversible_action_flow": audit_reversible_action_flow(),
        "zeta_chaos": audit_zeta_chaos(),
        "state_dynamics_nonuniqueness": audit_state_dynamics_nonuniqueness(),
        "ordered_markov_flow": audit_ordered_markov_flow(),
        "exact_jump_and_resolution": audit_exact_jump_and_resolution(),
    }
    if command_line_arguments.json_output:
        command_line_arguments.json_output.write_text(json.dumps(audit_results, indent=2) + "\n", encoding="utf-8")
    print("PASS: Fourier dilation, symbolic cycles, reversible flow, zeta entropy, ordered Markov flow, controls, and jumps")
    for entropy_row in audit_results["zeta_chaos"]["entropy_rows"]:
        print(
            f"s={entropy_row['inverse_temperature']:3.1f}: "
            f"lambda+=hKS=S={entropy_row['positive_lyapunov_and_entropy_nats_per_step']:.12f} nats/step; "
            f"{entropy_row['bits_per_step']:.12f} bits/step"
        )
    print("Exact reversible trajectory:", audit_results["reversible_action_flow"]["forward_steps"], "steps")
    print(
        "Markov flow: h=", audit_results["ordered_markov_flow"]["conditional_entropy_and_lyapunov"],
        "nats/step; saved predictive information=", audit_results["ordered_markov_flow"]["successive_label_mutual_information"],
    )
    print("Physical mechanism and general forecasting advantage: OPEN")


if __name__ == "__main__":
    main()
