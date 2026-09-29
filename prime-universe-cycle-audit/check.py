"""Compile the proofs against a pinned mathlib and audit every theorem's axioms."""

import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess


PROJECT_DIRECTORY = Path(__file__).resolve().parent
DEFAULT_MATHLIB = PROJECT_DIRECTORY / ".lake/packages/mathlib"
MATHLIB_REVISION = "5ed2965256430c3649e86755f9576b54eca72435"
ALLOWED_AXIOMS = {"propext", "Classical.choice", "Quot.sound"}


def file_digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checked_output(command, directory, environment=None):
    return subprocess.check_output(
        command, cwd=directory, env=environment, text=True, timeout=60
    ).strip()


def ordered_sources(requested_module=None):
    """Build the dependency closure in order, using only local module imports."""
    source_paths = {
        "PrimeUniverse." + source.stem: source
        for source in (PROJECT_DIRECTORY / "PrimeUniverse").glob("*.lean")
    }
    source_paths["PrimeUniverse"] = PROJECT_DIRECTORY / "PrimeUniverse.lean"
    ordered = []
    active = set()
    visited = set()

    def visit(module_name):
        if module_name in visited:
            return
        if module_name in active:
            raise RuntimeError(f"Cyclic local imports: {module_name}")
        if module_name not in source_paths:
            raise RuntimeError(f"Missing local module: {module_name}")
        active.add(module_name)
        source = source_paths[module_name]
        for imported in re.findall(r"^import (PrimeUniverse[\w.]*)$", source.read_text(), re.MULTILINE):
            visit(imported)
        active.remove(module_name)
        visited.add(module_name)
        ordered.append(source)

    visit("PrimeUniverse." + requested_module if requested_module else "PrimeUniverse")
    if not requested_module and visited != set(source_paths):
        raise RuntimeError(f"Modules missing from entry point: {set(source_paths) - visited}")
    return ordered


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mathlib", type=Path, default=DEFAULT_MATHLIB)
    parser.add_argument("--only", help="Compile one module while developing; skip the audit.")
    parser.add_argument("--output", type=Path, default=Path("verification.json"))
    arguments = parser.parse_args()
    mathlib_directory = arguments.mathlib.resolve()
    if checked_output(["git", "rev-parse", "HEAD"], mathlib_directory) != MATHLIB_REVISION:
        raise RuntimeError("The mathlib revision does not match the pin.")
    toolchain = (PROJECT_DIRECTORY / "lean-toolchain").read_text().strip()
    if (mathlib_directory / "lean-toolchain").read_text().strip() != toolchain:
        raise RuntimeError("The mathlib toolchain does not match the project.")
    compiler = Path(checked_output(["elan", "which", "lean"], PROJECT_DIRECTORY))
    lake = compiler.parent / "lake"
    compiler_version = checked_output([str(compiler), "--version"], PROJECT_DIRECTORY)
    if "version 4.34.0," not in compiler_version:
        raise RuntimeError("Unexpected Lean version.")
    build_directory = PROJECT_DIRECTORY / "build"
    build_directory.mkdir(exist_ok=True)
    environment = dict(os.environ, LEAN_NUM_THREADS="2")
    environment.pop("LEAN_PATH", None)
    local_mathlib = PROJECT_DIRECTORY / ".lake/packages/mathlib"
    uses_project_packages = local_mathlib.exists() and local_mathlib.resolve() == mathlib_directory
    lake_directory = PROJECT_DIRECTORY if uses_project_packages else mathlib_directory
    dependency_directory = lake_directory / ".lake/packages"
    dependency_search_path = checked_output(
        [str(lake), "env", "printenv", "LEAN_PATH"], lake_directory, environment
    )
    environment["LEAN_PATH"] = os.pathsep.join(
        [str(build_directory)]
        + [str((lake_directory / entry).resolve())
           for entry in dependency_search_path.split(os.pathsep) if entry]
    )
    sources = ordered_sources(arguments.only)
    if not arguments.only:
        # Do not let stale local objects satisfy imports in the audit.
        shutil.rmtree(build_directory / "PrimeUniverse", ignore_errors=True)
        (build_directory / "PrimeUniverse.olean").unlink(missing_ok=True)
    theorem_names = []
    source_hashes = {}
    compile_output = []
    started = datetime.now(timezone.utc).isoformat()
    for source in sources:
        relative_source = source.relative_to(PROJECT_DIRECTORY)
        source_text = source.read_text()
        source_digest_before = file_digest(source)
        if re.search(r"\b(sorry|admit|native_decide)\b|^\s*(axiom|unsafe)\b", source_text, re.MULTILINE):
            raise RuntimeError(f"Untrusted proof construct in {relative_source}")
        namespace_matches = re.findall(r"^namespace ([\w.]+)$", source_text, re.MULTILINE)
        declarations = re.findall(r"^theorem ([\w]+)", source_text, re.MULTILINE)
        if declarations and len(namespace_matches) != 1:
            raise RuntimeError(f"Cannot inventory namespaces in {relative_source}")
        theorem_names.extend(f"{namespace_matches[0]}.{name}" for name in declarations)
        destination = build_directory / relative_source.with_suffix(".olean")
        destination.parent.mkdir(parents=True, exist_ok=True)
        print(f"CHECK {relative_source}", flush=True)
        result = subprocess.run(
            [str(compiler), "-j", "2", "-DwarningAsError=true", "-R", str(PROJECT_DIRECTORY),
             "-o", str(destination), str(source)],
            cwd=PROJECT_DIRECTORY, env=environment, text=True,
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=300,
        )
        print(result.stdout, end="", flush=True)
        compile_output.append(f"CHECK {relative_source}\n{result.stdout}")
        if result.returncode:
            raise SystemExit(result.returncode)
        if file_digest(source) != source_digest_before:
            raise RuntimeError(f"Source changed during compilation: {relative_source}")
        source_hashes[str(relative_source)] = source_digest_before
    if arguments.only:
        return
    if not theorem_names or len(set(theorem_names)) != len(theorem_names):
        raise RuntimeError("Empty or duplicate theorem inventory.")
    audit_source = build_directory / "AxiomAudit.lean"
    audit_source.write_text("import PrimeUniverse\n\n" + "\n".join(
        f"#print axioms {theorem_name}" for theorem_name in theorem_names) + "\n")
    audited = subprocess.run(
        [str(compiler), "-j", "2", "-DwarningAsError=true", str(audit_source)],
        cwd=PROJECT_DIRECTORY, env=environment, text=True,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=300,
    )
    if audited.returncode:
        raise RuntimeError(audited.stdout)
    declaration_axioms = {}
    for theorem_name, dependencies in re.findall(
        r"'([^']+)' depends on axioms: \[([^\]]*)\]", audited.stdout
    ):
        declaration_axioms[theorem_name] = sorted(
            dependency.strip() for dependency in dependencies.split(",") if dependency.strip()
        )
    for theorem_name in re.findall(r"'([^']+)' does not depend on any axioms", audited.stdout):
        declaration_axioms[theorem_name] = []
    if set(declaration_axioms) != set(theorem_names):
        raise RuntimeError("The axiom audit did not cover exactly the theorem inventory.")
    for theorem_name, dependencies in declaration_axioms.items():
        if not set(dependencies) <= ALLOWED_AXIOMS:
            raise RuntimeError(f"Unexpected axioms for {theorem_name}: {dependencies}")
    manifest_path = mathlib_directory / "lake-manifest.json"
    dependency_revisions = {}
    for package in json.loads(manifest_path.read_text())["packages"]:
        actual_revision = checked_output(
            ["git", "rev-parse", "HEAD"], dependency_directory / package["name"]
        )
        if actual_revision != package["rev"]:
            raise RuntimeError(f"Dependency revision mismatch: {package['name']}")
        dependency_revisions[package["name"]] = actual_revision
    output_path = arguments.output.resolve()
    output_path.parent.mkdir(parents=True, exist_ok=True)
    compile_log = output_path.with_suffix(".compile.log")
    axiom_log = output_path.with_suffix(".axioms.log")
    compile_log.write_text("".join(compile_output))
    axiom_log.write_text(audited.stdout)
    report = {
        "started_utc": started,
        "finished_utc": datetime.now(timezone.utc).isoformat(),
        "compilation_passed": True,
        "warnings_as_errors": True,
        "compiler_version": compiler_version,
        "mathlib_revision": MATHLIB_REVISION,
        "mathlib_manifest_sha256": file_digest(manifest_path),
        "project_manifest_sha256": file_digest(PROJECT_DIRECTORY / "lake-manifest.json"),
        "project_configuration_sha256": file_digest(PROJECT_DIRECTORY / "lakefile.toml"),
        "toolchain_file_sha256": file_digest(PROJECT_DIRECTORY / "lean-toolchain"),
        "dependency_revisions": dependency_revisions,
        "theorem_count": len(theorem_names),
        "source_sha256": source_hashes,
        "provenance_sha256": file_digest(PROJECT_DIRECTORY / "PROVENANCE.md"),
        "checker_sha256": file_digest(Path(__file__)),
        "declaration_axioms": declaration_axioms,
        "allowed_axioms": sorted(ALLOWED_AXIOMS),
        "logs": {compile_log.name: file_digest(compile_log), axiom_log.name: file_digest(axiom_log)},
        "scope": "Manually translated mathematical claims; physical identifications are not certified.",
        "dependencies": "Pinned mathlib with compiled library objects; not rebuilt entirely from source.",
    }
    for relative_source, expected_digest in source_hashes.items():
        if file_digest(PROJECT_DIRECTORY / relative_source) != expected_digest:
            raise RuntimeError(f"Source changed during the audit: {relative_source}")
    output_path.write_text(json.dumps(report, indent=2) + "\n")
    print(f"PASS: {len(theorem_names)} theorems, all axiom dependencies allowed. {output_path}")


if __name__ == "__main__":
    main()
