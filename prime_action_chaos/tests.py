#!/usr/bin/env python3
"""Independent checks of causal forecasts and the nonlinear action claims."""

from __future__ import annotations

import itertools
import math
import random
from fractions import Fraction

import benchmark


def check_forecast_against_path_enumeration() -> None:
    probabilities = [0.13, 0.37, 0.71, 0.89]
    lookup_tables = benchmark.forecast_lookup(probabilities, 2, 7)
    for initial_history in range(4):
        for horizon in range(1, 8):
            independently_summed_probability = 0.0
            for future_word in itertools.product([0, 1], repeat=horizon):
                history_code = initial_history
                path_probability = 1.0
                for symbol in future_word:
                    probability = probabilities[history_code]
                    path_probability *= probability if symbol else 1 - probability
                    history_code = ((history_code << 1) | symbol) & 3
                if future_word[-1]:
                    independently_summed_probability += path_probability
            assert math.isclose(lookup_tables[horizon][initial_history], independently_summed_probability,
                                rel_tol=1e-13, abs_tol=1e-14)


def check_future_labels_cannot_change_model_selection() -> None:
    random_generator = random.Random(329154)
    symbols = [0, 1]
    for _ in range(1998):
        next_probability = 0.8 if symbols[-2] else 0.3
        symbols.append(int(random_generator.random() < next_probability))
    changed_symbols = symbols[:1600] + [1 - symbol for symbol in symbols[1600:]]
    metadata = {"system": "logistic"}
    original_results = benchmark.evaluate_sequence(symbols, metadata, quick=True)
    changed_results = benchmark.evaluate_sequence(changed_symbols, metadata, quick=True)
    assert original_results["validation_curves"] == changed_results["validation_curves"]
    for model_name, original_model in original_results["models"].items():
        changed_model = changed_results["models"][model_name]
        for property_name in ["selected_depth", "validation_log_loss", "frozen_probabilities", "training_counts"]:
            assert original_model[property_name] == changed_model[property_name]
    assert original_results["binary_data_sha256"] != changed_results["binary_data_sha256"]
    assert original_results["models"]["continuous"]["horizon_scores"] != changed_results["models"]["continuous"]["horizon_scores"]


def check_each_forecast_origin_uses_only_its_past() -> None:
    symbols = [0, 1, 0, 0, 1, 1, 1, 0, 1, 0]
    for origin in range(2, len(symbols)):
        changed_symbols = symbols[:origin] + [1 - symbol for symbol in symbols[origin:]]
        original_history = benchmark.observed_histories(symbols, 2)[origin]
        changed_history = benchmark.observed_histories(changed_symbols, 2)[origin]
        assert original_history == changed_history
        original_scores, original_losses = benchmark.forecast_scores(
            symbols, benchmark.observed_histories(symbols, 2), [0.1, 0.3, 0.8, 0.6],
            2, origin, origin + 1)
        expected_probability = [0.1, 0.3, 0.8, 0.6][original_history]
        expected_loss = -math.log(expected_probability if symbols[origin] else 1 - expected_probability)
        assert math.isclose(original_losses[0], expected_loss, rel_tol=1e-14)
        assert original_scores["forecast_origins"] == 1


def tent_cylinder(word: tuple[int, ...]) -> tuple[Fraction, Fraction]:
    lower_bound, upper_bound = Fraction(0), Fraction(1)
    for symbol in reversed(word):
        if symbol == 0:
            lower_bound, upper_bound = lower_bound / 2, upper_bound / 2
        else:
            lower_bound, upper_bound = 1 - upper_bound / 2, 1 - lower_bound / 2
    return lower_bound, upper_bound


def check_exact_bernoulli_cylinders_and_nonlinear_conjugacy() -> None:
    for length in range(1, 9):
        for word in itertools.product([0, 1], repeat=length):
            lower_bound, upper_bound = tent_cylinder(word)
            width = upper_bound - lower_bound
            assert width == Fraction(1, 2 ** length)
            for next_symbol in [0, 1]:
                child_lower, child_upper = tent_cylinder(word + (next_symbol,))
                assert lower_bound <= child_lower < child_upper <= upper_bound
                assert child_upper - child_lower == width / 2
    for position in [0.017, 0.11, 0.37, 0.61, 0.89, 0.993]:
        transformed_position = math.sin(math.pi * position / 2) ** 2
        logistic_image = 4 * transformed_position * (1 - transformed_position)
        tent_image = 2 * min(position, 1 - position)
        transformed_image = math.sin(math.pi * tent_image / 2) ** 2
        assert math.isclose(logistic_image, transformed_image, abs_tol=1e-14)
    benchmark.audit_nonlinear_action()


def check_prime_grid_obstruction_and_loss_decomposition() -> None:
    grid = benchmark.probability_grids()["prime_odds"]
    threshold = math.log(1.5) / math.log(2)
    for probability in [0.42, 0.47, 0.5, 0.53, 0.58]:
        assert benchmark.quantize_probability(probability, grid) == 0.5
    assert benchmark.quantize_probability(threshold + 1e-6, grid) == 2 / 3
    assert benchmark.quantize_probability(1 - threshold - 1e-6, grid) == 1 / 3
    for true_probability, forecast_probability in [(0.58, 0.5), (0.3, 0.71), (0.01, 0.03)]:
        entropy = benchmark.cross_entropy(true_probability, true_probability)
        divergence = (true_probability * math.log(true_probability / forecast_probability)
                      + (1 - true_probability) * math.log((1 - true_probability) / (1 - forecast_probability)))
        cross_entropy = benchmark.cross_entropy(forecast_probability, true_probability)
        assert divergence >= 0
        assert math.isclose(cross_entropy, entropy + divergence, abs_tol=1e-14)


def main() -> None:
    checks = [check_forecast_against_path_enumeration,
              check_future_labels_cannot_change_model_selection,
              check_each_forecast_origin_uses_only_its_past,
              check_exact_bernoulli_cylinders_and_nonlinear_conjugacy,
              check_prime_grid_obstruction_and_loss_decomposition]
    for check in checks:
        check()
        print("PASS:", check.__name__)


if __name__ == "__main__":
    main()
