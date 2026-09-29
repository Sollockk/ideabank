#!/usr/bin/env python3
"""Render the recorded benchmark without refitting or regenerating trajectories."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import statistics
from pathlib import Path


def case_label(case: dict) -> str:
    dynamics = case["dynamics"]
    if dynamics["system"] == "logistic":
        return f"Logistic {dynamics['parameter']}, x0={dynamics['initial_position']}"
    return f"Lorenz x0={dynamics['initial_position'][0]}, dt={dynamics['rk4_step']}"


def model_loss(case: dict, model_name: str, horizon: int = 1) -> float:
    return case["models"][model_name]["horizon_scores"][str(horizon)]["log_loss_nats"]


def groups(cases: list[dict]) -> list[tuple[str, list[dict]]]:
    return [("Logistic 4.0", [case for case in cases if case["dynamics"].get("parameter") == 4.0]),
            ("Logistic 3.9", [case for case in cases if case["dynamics"].get("parameter") == 3.9]),
            ("Lorenz returns", [case for case in cases if case["dynamics"]["system"] == "lorenz"])]


def render_report(results: dict) -> str:
    cases = results["cases"]
    lines = [
        "# Recorded external benchmark results",
        "",
        "Generated from [results/benchmark.json](results/benchmark.json) by",
        "[report.py](report.py). Protocol and benchmark source hashes are verified",
        "before rendering. This report does not select new models or rerun fitting.",
        "",
        "**Result:** Past binary observations improve one-step forecasts for",
        "logistic parameter 3.9 and give a smaller improvement for Lorenz return",
        "labels. Restricting the conditional odds to the tested prime-cell values",
        "does not improve prediction. It performs worse than both controls in all",
        "six runs with temporal structure; uncertainty varies by run.",
        "",
        "## Design and scope",
        "",
        "The [protocol](PROTOCOL.md) was specified before the full run on",
        "2026-09-29. Six logistic trajectories each supply 100,000 symbols, split",
        "60,000 / 20,000 / 20,000 into chronological training / validation / test",
        "sets. Three Lorenz trajectories each supply 10,000 return labels, split",
        "6,000 / 2,000 / 2,000. Models observe only past binary labels.",
        "",
        "All models choose context depth from 0 through 10 by validation loss.",
        "Their probabilities are fit on training data only. The prime-odds and",
        "nonprime grids both have 75 values and the same probability range.",
        "The nonprime grid is uniformly spaced in log odds; its endpoints and",
        "neutral value intentionally coincide with the prime grid. Its defining",
        "spacing does not use the intervening primes.",
        "",
        "The recorded run used Python " + results["python_version"] + " and the standard library only.",
        "Floating-point chaotic trajectories can differ across platforms and",
        "evaluation orders. Data hashes identify this run; statistical replication",
        "is more meaningful than requiring long trajectories to agree pointwise.",
        "The protocol is a local record, not an independently timestamped public",
        "preregistration. These are synthetic dynamical benchmarks, not laboratory",
        "measurements or a comprehensive comparison with forecasting methods.",
        "",
        "## One-step test loss",
        "",
        "Loss is in nats per observed label; lower is better. Each cell in the",
        "first table is an unweighted mean of the three specified runs. The Lorenz",
        "mean combines two initial conditions and a step-refinement run; it is not",
        "a confidence estimate from three independent experimental replicates.",
        "",
        "| System | Marginal baseline | Continuous history | Prime odds | Nonprime grid | Relative history gain |",
        "|---|---:|---:|---:|---:|---:|",
    ]
    for group_name, group_cases in groups(cases):
        losses = {model_name: statistics.fmean(model_loss(case, model_name) for case in group_cases)
                  for model_name in ["marginal_baseline", "continuous", "prime_odds", "nonprime_grid"]}
        gain = 100 * (1 - losses["continuous"] / losses["marginal_baseline"])
        lines.append(f"| {group_name} | {losses['marginal_baseline']:.6f} | {losses['continuous']:.6f} | {losses['prime_odds']:.6f} | {losses['nonprime_grid']:.6f} | {gain:.2f}% |")
    lines += ["", "The full per-run results prevent a favorable mean from hiding a failed run.", "",
              "| Run | Marginal | Continuous | Prime odds | Nonprime grid | Selected depths: continuous / prime / grid |",
              "|---|---:|---:|---:|---:|---|" ]
    for case in cases:
        depths = " / ".join(str(case["models"][model_name]["selected_depth"]) for model_name in ["continuous", "prime_odds", "nonprime_grid"])
        lines.append(f"| {case_label(case)} | {model_loss(case, 'marginal_baseline'):.6f} | {model_loss(case, 'continuous'):.6f} | {model_loss(case, 'prime_odds'):.6f} | {model_loss(case, 'nonprime_grid'):.6f} | {depths} |")
    lines += [
        "", "All logistic-4 models select depth zero. Both grids return exactly 1/2,",
        "so they tie. Their slight advantage over the fitted marginal frequency",
        "is shared shrinkage to the true fair-bit probability, not evidence for",
        "primes. All logistic-3.9 models select the maximum tested depth, ten; the",
        "experiment does not establish that ten is sufficient or optimal among",
        "longer contexts.",
        "", "## Paired loss differences", "",
        "Each entry gives mean difference [descriptive approximate 95% interval].",
        "Negative favors the first model named. Intervals use contiguous block",
        "means, with 20 blocks for each logistic run and 10 for each Lorenz run.",
        "They are normal approximations, not independence guarantees or adjusted",
        "tests across all comparisons. The refined Lorenz run's prime-versus-grid",
        "interval includes zero; its point estimate is still unfavorable to primes.",
        "",
        "| Run | Continuous minus marginal | Prime minus continuous | Prime minus nonprime grid |",
        "|---|---:|---:|---:|",
    ]
    for case in cases:
        if case["dynamics"].get("parameter") == 4.0:
            continue
        comparison_cells = []
        for comparison_name in ["continuous_minus_marginal", "prime_minus_continuous", "prime_minus_nonprime_grid"]:
            comparison = case["paired_loss_comparisons"][comparison_name]
            lower_bound, upper_bound = comparison["approximate_95_percent_block_interval"]
            comparison_cells.append(f"{comparison['mean_loss_difference']:+.6f} [{lower_bound:+.6f}, {upper_bound:+.6f}]")
        lines.append("| " + case_label(case) + " | " + " | ".join(comparison_cells) + " |")
    lines += [
        "", "## Quantization at the same context depth", "",
        "Both grids below use the continuous model's selected context depth. This",
        "removes a possible explanation based only on different selected depths.",
        "For logistic 3.9 these coincide with the main table because every model",
        "selects ten. The matched controls remain unfavorable to the prime grid.",
        "",
        "| Lorenz run | Depth | Continuous | Prime at same depth | Nonprime at same depth |",
        "|---|---:|---:|---:|---:|",
    ]
    for case in cases:
        if case["dynamics"]["system"] != "lorenz":
            continue
        controls = case["matched_depth_quantization_controls"]
        lines.append(f"| {case_label(case)} | {case['models']['continuous']['selected_depth']} | {model_loss(case, 'continuous'):.6f} | {controls['prime_odds']['log_loss_nats']:.6f} | {controls['nonprime_grid']['log_loss_nats']:.6f} |")
    lines += [
        "", "## Forecast horizon", "",
        "These are rolling forecasts of the label at the indicated horizon. The",
        "model propagates its own distribution between origin and target without",
        "receiving intervening observations. A later forecast origin can use the",
        "past newly observed by that origin. This is not exact future trajectory",
        "reconstruction or a claim of predicting all intervening symbols.",
        "",
        "The table shows the continuous history model's mean test loss. Horizon",
        "units are map iterations or Lorenz return events, not a shared physical",
        "second. All model and Brier-score curves are retained in the JSON.",
        "",
        "| System | 1 | 2 | 4 | 8 | 16 | 32 | Marginal at 1 |",
        "|---|---:|---:|---:|---:|---:|---:|---:|",
    ]
    for group_name, group_cases in groups(cases):
        horizon_cells = [f"{statistics.fmean(model_loss(case, 'continuous', horizon) for case in group_cases):.6f}" for horizon in [1, 2, 4, 8, 16, 32]]
        horizon_cells.append(f"{statistics.fmean(model_loss(case, 'marginal_baseline') for case in group_cases):.6f}")
        lines.append("| " + group_name + " | " + " | ".join(horizon_cells) + " |")
    lines += [
        "", "The history advantage largely disappears with horizon. The measured",
        "temporal structure improves near-term probability forecasts; it does not",
        "remove the unpredictability associated with incomplete state information.",
        "", "## Post-benchmark explanation of the prime-grid failure", "",
        "The [exact derivation](NONLINEAR_ACTION.md) shows that the nearest allowed",
        "prime-odds values to 1/2 are 1/3 and 2/3. Cross-entropy quantization maps",
        "every probability between 0.415037499 and 0.584962501 to 1/2. This interval",
        "cannot be filled by increasing the maximum prime in this model.",
        "",
        "The following diagnostic was added after seeing the benchmark. It uses",
        "training counts and the already selected continuous probabilities; it",
        "did not change the protocol, models, or held-out scores. The fraction is",
        "training-context mass whose fitted probabilities fall in this interval,",
        "not the mass of known true conditional probabilities.",
        "",
        "| Lorenz run | Training-context mass rounded to neutral odds |",
        "|---|---:|",
    ]
    threshold = math.log(1.5) / math.log(2)
    for case in cases:
        if case["dynamics"]["system"] != "lorenz":
            continue
        model = case["models"]["continuous"]
        counts = [sum(count) for count in model["training_counts"]]
        neutral_count = sum(count for count, probability in zip(counts, model["frozen_probabilities"])
                            if 1 - threshold <= probability <= threshold)
        lines.append(f"| {case_label(case)} | {100 * neutral_count / sum(counts):.2f}% |")
    lines += [
        "", "This supplies a specific approximation error mechanism. It does not",
        "exclude mixtures, products, or other dynamical uses of primes that were",
        "not tested. Allowing those models would require a new fixed protocol and",
        "appropriate complexity controls.",
        "", "## Dynamics and numerical checks", "",
        "The logistic finite-time Lyapunov exponents are about 0.69313–0.69315",
        "at parameter 4 and 0.49524–0.49554 at 3.9, in nats per iteration. No",
        "logistic machine state repeated within any recorded trajectory. That",
        "check does not turn finite-precision arithmetic into an exact real orbit.",
        "",
        "The Lorenz equations and their motivation originate in",
        "[Lorenz (1963), Deterministic Nonperiodic Flow](https://samizdat.co/works/do-while/lorenz-1963.pdf).",
        "The following values are results of this implementation, not values",
        "quoted from that paper.",
        "",
        "| Lorenz run | Tangent exponent / time | Mean return time | Product |",
        "|---|---:|---:|---:|",
    ]
    for case in cases:
        dynamics = case["dynamics"]
        if dynamics["system"] == "lorenz":
            lines.append(f"| {case_label(case)} | {dynamics['finite_time_lyapunov_per_time']:.6f} | {dynamics['mean_return_time']:.6f} | {dynamics['lyapunov_times_mean_return_time']:.6f} |")
    nonlinear_check = results["nonlinear_action_check"]
    integrator_check = results["lorenz_integrator_check"]
    lines += [
        "", "The similar tangent rates under step refinement support numerical",
        "consistency. The return-sign partition is not proved generating, so the",
        "product in the last column must not be identified with forecast loss or",
        "a verified metric-entropy estimate.",
        "",
        f"The RK4 short-time refinement error ratio is {integrator_check['short_time_refinement_ratio']:.6f}",
        "at time 0.5, near the fourth-order expectation of 16. The independently",
        f"checked tangent derivative has residual {integrator_check['tangent_derivative_error']:.3g}.",
        f"The nonlinear action identity's maximum residual is {nonlinear_check['max_action_identity_error']:.3g}",
        f"over {nonlinear_check['tested_points']} interior points.",
        "",
        "Before the full benchmark, the short-time integrator check was moved",
        "from time 2 to time 0.5 after its endpoint error ratio failed the chosen",
        "8–24 check window. This is disclosed as numerical-test development; the",
        "benchmark equations, steps, initial states, observations, splits, models,",
        "and scoring protocol were not adjusted in response to forecast results.",
        "", "## Reproduce or inspect", "",
        "```bash", "python tests.py", "python report.py --check",
        "python benchmark.py --output /tmp/prime_action_benchmark.json", "```", "",
        "The tests compare multi-step forecasts with direct path enumeration,",
        "change test futures to check that model selection and fitted parameters",
        "remain fixed, check each origin's information access, verify exact",
        "Bernoulli cylinder widths, and check the grid obstruction. The separate",
        "`audit.py` covers the earlier arithmetic and reversible constructions.",
        "",
        "Recorded source SHA-256: `" + results["source_sha256"] + "`.",
        "",
        "Recorded protocol SHA-256: `" + results["protocol_sha256"] + "`.",
        "",
        "**Interpretation:** This is evidence for ordinary conditional predictive",
        "structure at the chosen observation resolution and evidence against an",
        "advantage for the particular prime-odds restriction tested here. It is",
        "not a validation of a universal prime substrate, an autonomous prediction",
        "of three-body coordinates, or a new law of nature.",
    ]
    return "\n".join(lines) + "\n"


def main() -> None:
    directory = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--results", type=Path, default=directory / "results" / "benchmark.json")
    parser.add_argument("--output", type=Path, default=directory / "BENCHMARK_RESULTS.md")
    parser.add_argument("--check", action="store_true")
    arguments = parser.parse_args()
    results = json.loads(arguments.results.read_text(encoding="utf-8"))
    if results["quick_run"] or len(results["cases"]) != 9:
        raise ValueError("The report requires the full nine-case benchmark")
    for source_name, hash_key in [("benchmark.py", "source_sha256"), ("PROTOCOL.md", "protocol_sha256")]:
        if hashlib.sha256((directory / source_name).read_bytes()).hexdigest() != results[hash_key]:
            raise ValueError(f"Recorded results do not match {source_name}")
    report = render_report(results)
    if arguments.check:
        if arguments.output.read_text(encoding="utf-8") != report:
            raise ValueError("The report differs from the recorded results; run report.py to regenerate")
        print("PASS: recorded source/protocol hashes and report contents agree")
    else:
        arguments.output.write_text(report, encoding="utf-8")
        print("Wrote", arguments.output)


if __name__ == "__main__":
    main()
