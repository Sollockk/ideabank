#!/usr/bin/env python3
"""Frozen-protocol symbolic forecasts for logistic and Lorenz dynamics.

Models observe binary history only. All probabilities are fit on training
data; depth is selected on validation data; test futures are scoring-only.
The standard library is the only dependency.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import platform
import statistics
from pathlib import Path


def require(condition: bool, explanation: str) -> None:
    if not condition:
        raise AssertionError(explanation)


def prime_values_up_to(limit: int) -> list[int]:
    return [
        candidate for candidate in range(2, limit + 1)
        if all(candidate % divisor for divisor in range(2, math.isqrt(candidate) + 1))
    ]


def probability_grids() -> dict[str, list[float]]:
    prime_values = prime_values_up_to(157)
    prime_grid = sorted({0.5} | {1 / (prime_value + 1) for prime_value in prime_values}
                        | {prime_value / (prime_value + 1) for prime_value in prime_values})
    log_odds_magnitudes = [index * math.log(157) / len(prime_values) for index in range(len(prime_values) + 1)]
    nonprime_grid = sorted({1 / (1 + math.exp(sign * magnitude)) for magnitude in log_odds_magnitudes for sign in [-1, 1]})
    require(len(prime_grid) == len(nonprime_grid) == 75, "the grid controls must have equal cardinality")
    require(abs(prime_grid[0] - nonprime_grid[0]) < 1e-15, "grid probability ranges differ")
    return {"prime_odds": prime_grid, "nonprime_grid": nonprime_grid}


def generate_logistic(parameter: float, initial_position: float, count: int) -> tuple[list[int], dict]:
    position = initial_position
    symbols = []
    stretches = []
    seen_positions = set()
    repeated_state_count = 0
    for step in range(count + 2000):
        require(0 < position < 1, "logistic trajectory reached a degenerate floating-point endpoint")
        if step >= 2000:
            symbols.append(int(position >= 0.5))
            stretches.append(math.log(abs(parameter * (1 - 2 * position))))
            repeated_state_count += position in seen_positions
            seen_positions.add(position)
        position = parameter * position * (1 - position)
    require(repeated_state_count == 0, "logistic trajectory repeated a machine state within the benchmark")
    return symbols, {
        "system": "logistic", "parameter": parameter, "initial_position": initial_position,
        "discarded_steps": 2000, "observations": count,
        "finite_time_lyapunov_per_iteration": statistics.fmean(stretches),
        "repeated_machine_states": repeated_state_count,
    }


def lorenz_derivative(state: tuple[float, ...]) -> tuple[float, ...]:
    position_x, position_y, position_z, tangent_x, tangent_y, tangent_z = state
    return (
        10 * (position_y - position_x),
        position_x * (28 - position_z) - position_y,
        position_x * position_y - (8 / 3) * position_z,
        10 * (tangent_y - tangent_x),
        (28 - position_z) * tangent_x - tangent_y - position_x * tangent_z,
        position_y * tangent_x + position_x * tangent_y - (8 / 3) * tangent_z,
    )


def rk4_step(state: tuple[float, ...], duration: float) -> tuple[float, ...]:
    first_derivative = lorenz_derivative(state)
    second_derivative = lorenz_derivative(tuple(value + duration * derivative / 2 for value, derivative in zip(state, first_derivative)))
    third_derivative = lorenz_derivative(tuple(value + duration * derivative / 2 for value, derivative in zip(state, second_derivative)))
    fourth_derivative = lorenz_derivative(tuple(value + duration * derivative for value, derivative in zip(state, third_derivative)))
    return tuple(
        value + duration * (first + 2 * second + 2 * third + fourth) / 6
        for value, first, second, third, fourth in zip(state, first_derivative, second_derivative, third_derivative, fourth_derivative)
    )


def audit_lorenz_integrator() -> dict:
    initial_state = (1.0, 1.0, 1.0, 1.0, 0.0, 0.0)
    endpoints = []
    for duration in [0.01, 0.005, 0.0025]:
        state = initial_state
        for _ in range(round(0.5 / duration)):
            state = rk4_step(state, duration)
        endpoints.append(state[:3])
    coarse_difference = math.dist(endpoints[0], endpoints[1])
    fine_difference = math.dist(endpoints[1], endpoints[2])
    require(coarse_difference > fine_difference > 0, "RK4 refinement failed")
    require(8 < coarse_difference / fine_difference < 24, "RK4 does not show fourth-order short-time convergence")
    reference_state = (2.0, -3.0, 17.0, 0.3, -0.4, 0.5)
    perturbation_size = 1e-5
    positive_state = tuple(reference_state[index] + perturbation_size * reference_state[index + 3] for index in range(3)) + reference_state[3:]
    negative_state = tuple(reference_state[index] - perturbation_size * reference_state[index + 3] for index in range(3)) + reference_state[3:]
    finite_difference_tangent = tuple(
        (positive - negative) / (2 * perturbation_size)
        for positive, negative in zip(lorenz_derivative(positive_state)[:3], lorenz_derivative(negative_state)[:3])
    )
    tangent_error = math.dist(finite_difference_tangent, lorenz_derivative(reference_state)[3:])
    require(tangent_error < 1e-8, "the Lorenz tangent equation failed its finite-difference check")
    return {"short_time_endpoint": 0.5, "short_time_refinement_ratio": coarse_difference / fine_difference, "tangent_derivative_error": tangent_error}


def generate_lorenz(initial_position_x: float, duration: float, count: int) -> tuple[list[int], dict]:
    state = (initial_position_x, 1.0, 1.0, 1.0, 0.0, 0.0)
    symbols = []
    crossing_times = []
    step = 0
    log_stretch = 0.0
    normalized_duration = 0.0
    burn_steps = round(100 / duration)
    while len(symbols) < count:
        previous_state = state
        state = rk4_step(state, duration)
        step += 1
        if step % 10 == 0:
            tangent_norm = math.sqrt(sum(value * value for value in state[3:]))
            require(tangent_norm > 0 and math.isfinite(tangent_norm), "invalid tangent norm")
            if step > burn_steps:
                log_stretch += math.log(tangent_norm)
                normalized_duration += 10 * duration
            state = state[:3] + tuple(value / tangent_norm for value in state[3:])
        if step > burn_steps and previous_state[2] < 27 <= state[2]:
            crossing_fraction = (27 - previous_state[2]) / (state[2] - previous_state[2])
            crossing_position_x = previous_state[0] + crossing_fraction * (state[0] - previous_state[0])
            symbols.append(int(crossing_position_x >= 0))
            crossing_times.append((step - 1 + crossing_fraction) * duration)
        require(step < burn_steps + count * round(5 / duration), "Lorenz return collection exceeded the time bound")
    mean_return_time = statistics.fmean(later - earlier for earlier, later in zip(crossing_times, crossing_times[1:]))
    lyapunov_per_time = log_stretch / normalized_duration
    return symbols, {
        "system": "lorenz", "parameters": {"sigma": 10, "rho": 28, "beta": 8 / 3},
        "initial_position": [initial_position_x, 1.0, 1.0], "rk4_step": duration,
        "discarded_time": 100, "observations": count, "integration_steps": step,
        "mean_return_time": mean_return_time,
        "finite_time_lyapunov_per_time": lyapunov_per_time,
        "lyapunov_times_mean_return_time": lyapunov_per_time * mean_return_time,
        "observation": "sign of x on upward crossings of z=27; not assumed proved generating",
    }


def cross_entropy(probability: float, target_fraction: float) -> float:
    return -target_fraction * math.log(probability) - (1 - target_fraction) * math.log1p(-probability)


def quantize_probability(probability: float, grid: list[float]) -> float:
    return min(grid, key=lambda candidate: cross_entropy(candidate, probability))


def observed_histories(symbols: list[int], maximum_depth: int) -> list[int]:
    histories = []
    history_code = 0
    history_mask = (1 << maximum_depth) - 1
    for symbol in symbols:
        histories.append(history_code)
        history_code = ((history_code << 1) | symbol) & history_mask
    return histories


def fit_context_probabilities(symbols: list[int], histories: list[int], depth: int, training_end: int, first_target: int) -> tuple[list[float], list[list[int]]]:
    counts = [[0, 0] for _ in range(1 << depth)]
    history_mask = (1 << depth) - 1
    for target_index in range(first_target, training_end):
        counts[histories[target_index] & history_mask][symbols[target_index]] += 1
    probabilities = [(count_one + 0.5) / (count_zero + count_one + 1) for count_zero, count_one in counts]
    return probabilities, counts


def forecast_lookup(probabilities: list[float], depth: int, maximum_horizon: int) -> dict[int, list[float]]:
    lookups = {1: probabilities}
    history_mask = (1 << depth) - 1
    for horizon in range(2, maximum_horizon + 1):
        preceding_lookup = lookups[horizon - 1]
        lookups[horizon] = [
            (1 - probability) * preceding_lookup[(history_code << 1) & history_mask]
            + probability * preceding_lookup[((history_code << 1) | 1) & history_mask]
            for history_code, probability in enumerate(probabilities)
        ]
    return lookups


def forecast_scores(symbols: list[int], histories: list[int], probabilities: list[float], depth: int, first_target: int, end_target: int, horizon: int = 1) -> tuple[dict, list[float]]:
    history_mask = (1 << depth) - 1
    losses = []
    squared_errors = []
    for origin_target in range(first_target, end_target - horizon + 1):
        probability = probabilities[histories[origin_target] & history_mask]
        target = symbols[origin_target + horizon - 1]
        losses.append(-math.log(probability) if target else -math.log1p(-probability))
        squared_errors.append((probability - target) ** 2)
    return {"log_loss_nats": statistics.fmean(losses), "brier_score": statistics.fmean(squared_errors), "forecast_origins": len(losses)}, losses


def block_difference(first_losses: list[float], second_losses: list[float], block_length: int) -> dict:
    paired_differences = [first - second for first, second in zip(first_losses, second_losses)]
    block_means = [statistics.fmean(paired_differences[start:start + block_length])
                   for start in range(0, len(paired_differences) - block_length + 1, block_length)]
    mean_difference = statistics.fmean(paired_differences)
    standard_error = statistics.stdev(block_means) / math.sqrt(len(block_means)) if len(block_means) > 1 else 0.0
    return {
        "mean_loss_difference": mean_difference,
        "approximate_95_percent_block_interval": [mean_difference - 1.96 * standard_error, mean_difference + 1.96 * standard_error],
        "blocks": len(block_means), "block_length": block_length,
        "interpretation": "negative favors first model; descriptive dependent-data approximation",
    }


def evaluate_sequence(symbols: list[int], metadata: dict, quick: bool) -> dict:
    maximum_depth = 10
    training_end = len(symbols) * 3 // 5
    validation_end = len(symbols) * 4 // 5
    histories = observed_histories(symbols, maximum_depth)
    grids = probability_grids()
    candidates = {model_name: [] for model_name in ["continuous", "prime_odds", "nonprime_grid"]}
    count_tables = []
    for depth in range(maximum_depth + 1):
        continuous_probabilities, counts = fit_context_probabilities(symbols, histories, depth, training_end, maximum_depth)
        count_tables.append(counts)
        model_probabilities = {"continuous": continuous_probabilities}
        model_probabilities.update({model_name: [quantize_probability(probability, grid) for probability in continuous_probabilities]
                                    for model_name, grid in grids.items()})
        for model_name, probabilities in model_probabilities.items():
            validation_score, _ = forecast_scores(symbols, histories, probabilities, depth, training_end, validation_end)
            candidates[model_name].append({"depth": depth, "probabilities": probabilities, "validation_log_loss": validation_score["log_loss_nats"]})

    selected_candidates = {model_name: min(model_candidates, key=lambda candidate: (candidate["validation_log_loss"], candidate["depth"]))
                           for model_name, model_candidates in candidates.items()}
    selected_candidates["marginal_baseline"] = candidates["continuous"][0]
    results = {}
    one_step_losses = {}
    for model_name, candidate in selected_candidates.items():
        depth = candidate["depth"]
        lookup_tables = forecast_lookup(candidate["probabilities"], depth, 32)
        horizon_scores = {}
        for horizon in [1, 2, 4, 8, 16, 32]:
            horizon_score, losses = forecast_scores(symbols, histories, lookup_tables[horizon], depth, validation_end, len(symbols), horizon)
            horizon_scores[str(horizon)] = horizon_score
            if horizon == 1:
                one_step_losses[model_name] = losses
        results[model_name] = {
            "selected_depth": depth, "validation_log_loss": candidate["validation_log_loss"],
            "frozen_probabilities": candidate["probabilities"], "training_counts": count_tables[depth],
            "horizon_scores": horizon_scores,
        }
    matched_depth = selected_candidates["continuous"]["depth"]
    matched_controls = {}
    for model_name in ["prime_odds", "nonprime_grid"]:
        matched_score, _ = forecast_scores(symbols, histories, candidates[model_name][matched_depth]["probabilities"], matched_depth, validation_end, len(symbols))
        matched_controls[model_name] = {"depth": matched_depth, **matched_score}
    block_length = 100 if quick else (1000 if metadata["system"] == "logistic" else 200)
    comparisons = {
        "continuous_minus_marginal": block_difference(one_step_losses["continuous"], one_step_losses["marginal_baseline"], block_length),
        "prime_minus_continuous": block_difference(one_step_losses["prime_odds"], one_step_losses["continuous"], block_length),
        "prime_minus_nonprime_grid": block_difference(one_step_losses["prime_odds"], one_step_losses["nonprime_grid"], block_length),
    }
    return {
        "dynamics": metadata,
        "binary_data_sha256": hashlib.sha256(bytes(symbols)).hexdigest(),
        "split_counts": [training_end, validation_end - training_end, len(symbols) - validation_end],
        "validation_curves": {model_name: [{"depth": candidate["depth"], "log_loss": candidate["validation_log_loss"]} for candidate in model_candidates]
                              for model_name, model_candidates in candidates.items()},
        "models": results, "matched_depth_quantization_controls": matched_controls,
        "paired_loss_comparisons": comparisons,
    }


def audit_nonlinear_action() -> dict:
    largest_local_error = 0.0
    largest_inverse_weight_error = 0.0
    for grid_index in range(1, 1000):
        position = (grid_index + 0.123) / 1001
        next_position = 4 * position * (1 - position)
        local_stretch = math.log(abs(4 - 8 * position))
        log_density = -math.log(math.pi) - 0.5 * math.log(position * (1 - position))
        next_log_density = -math.log(math.pi) - 0.5 * math.log(next_position * (1 - next_position))
        corrected_action = math.log(2) + log_density - next_log_density
        largest_local_error = max(largest_local_error, abs(local_stretch - corrected_action))
        inverse_weight = math.exp(log_density - local_stretch - next_log_density)
        largest_inverse_weight_error = max(largest_inverse_weight_error, abs(inverse_weight - 0.5))
    require(largest_local_error < 1e-8, "nonlinear action boundary correction failed")
    require(largest_inverse_weight_error < 1e-8, "inverse branch weights are not one half")
    return {"map": "4*x*(1-x)", "tested_points": 999, "max_action_identity_error": largest_local_error,
            "max_inverse_branch_weight_error": largest_inverse_weight_error,
            "identity": "log|f'(x)| = log(2) + log(rho(x)) - log(rho(f(x)))",
            "density": "rho(x)=1/(pi*sqrt(x*(1-x)))"}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--quick", action="store_true")
    arguments = parser.parse_args()
    results = {
        "schema_version": 1, "quick_run": arguments.quick,
        "python_version": platform.python_version(),
        "source_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        "protocol_sha256": hashlib.sha256(Path(__file__).with_name("PROTOCOL.md").read_bytes()).hexdigest(),
        "nonlinear_action_check": audit_nonlinear_action(),
        "lorenz_integrator_check": audit_lorenz_integrator(),
        "grids": probability_grids(), "cases": [],
    }
    logistic_count = 5000 if arguments.quick else 100000
    lorenz_count = 1000 if arguments.quick else 10000
    initial_positions = [0.123456789] if arguments.quick else [0.123456789, 0.314159265, 0.271828182]
    for parameter in [4.0, 3.9]:
        for initial_position in initial_positions:
            symbols, metadata = generate_logistic(parameter, initial_position, logistic_count)
            case_results = evaluate_sequence(symbols, metadata, arguments.quick)
            results["cases"].append(case_results)
            print(f"Completed logistic r={parameter}, initial={initial_position}", flush=True)
    lorenz_cases = [(1.0, 0.01)] if arguments.quick else [(1.0, 0.01), (1.001, 0.01), (1.0, 0.005)]
    for initial_position, duration in lorenz_cases:
        print(f"Integrating Lorenz initial x={initial_position}, dt={duration}", flush=True)
        symbols, metadata = generate_lorenz(initial_position, duration, lorenz_count)
        case_results = evaluate_sequence(symbols, metadata, arguments.quick)
        results["cases"].append(case_results)
        print(f"Completed Lorenz: lambda={metadata['finite_time_lyapunov_per_time']:.6f}", flush=True)
    arguments.output.parent.mkdir(parents=True, exist_ok=True)
    arguments.output.write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")
    print("PASS: completed all configured cases; results saved to", arguments.output, flush=True)


if __name__ == "__main__":
    main()
