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


def dependency_order(sources):
    """Compile local imports before their users, independently of file names."""
    ordered = []
    visited = set()
    visiting = set()

    def visit(source):
        if source in visited:
            return
        if source in visiting:
            raise RuntimeError(f"Cyclic local import: {source.name}")
        visiting.add(source)
        for module in re.findall(r"^import (PrimeUniverse[\w.]*)$", source.read_text(), re.MULTILINE):
            visit(PROJECT_DIRECTORY / (module.replace(".", "/") + ".lean"))
        visiting.remove(source)
        visited.add(source)
        ordered.append(source)

    for source in sources:
        visit(source)
    return ordered


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mathlib", type=Path, default=DEFAULT_MATHLIB)
    parser.add_argument("--only", help="Compile one module while developing; skip the audit.")
    parser.add_argument("--output", type=Path, default=Path("verification.json"))
    arguments = parser.parse_args()
    project_dependencies = arguments.mathlib.absolute() == DEFAULT_MATHLIB.absolute()
    mathlib_directory = arguments.mathlib.resolve()
    if not (mathlib_directory / "lean-toolchain").is_file():
        parser.error("mathlib is missing; run 'lake update' and 'lake exe cache get', "
                     "or supply --mathlib /path/to/the/pinned/checkout")
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
    dependency_root = PROJECT_DIRECTORY if project_dependencies else mathlib_directory
    dependency_search_path = checked_output(
        [str(lake), "env", "printenv", "LEAN_PATH"], dependency_root, environment
    )
    environment["LEAN_PATH"] = os.pathsep.join(
        [str(build_directory)]
        + [str((dependency_root / entry).resolve())
           for entry in dependency_search_path.split(os.pathsep)
           if entry and (dependency_root / entry).resolve() !=
           (PROJECT_DIRECTORY / ".lake/build/lib/lean").resolve()]
    )
    sources = sorted((PROJECT_DIRECTORY / "PrimeUniverse").glob("*.lean"))
    if arguments.only:
        sources = [PROJECT_DIRECTORY / "PrimeUniverse" / f"{arguments.only}.lean"]
    else:
        # Do not let stale local objects satisfy imports in the audit.
        shutil.rmtree(build_directory / "PrimeUniverse", ignore_errors=True)
        (build_directory / "PrimeUniverse.olean").unlink(missing_ok=True)
        sources.append(PROJECT_DIRECTORY / "PrimeUniverse.lean")
    sources = dependency_order(sources)
    theorem_names = []
    source_hashes = {}
    compile_output = []
    started = datetime.now(timezone.utc).isoformat()
    for source in sources:
        relative_source = source.relative_to(PROJECT_DIRECTORY)
        source_text = source.read_text()
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
        source_hashes[str(relative_source)] = file_digest(source)
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
    manifest_path = dependency_root / "lake-manifest.json"
    dependency_revisions = {}
    for package in json.loads(manifest_path.read_text())["packages"]:
        actual_revision = checked_output(
            ["git", "rev-parse", "HEAD"], dependency_root / ".lake/packages" / package["name"]
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
        "dependency_manifest_sha256": file_digest(manifest_path),
        "dependency_revisions": dependency_revisions,
        "theorem_count": len(theorem_names),
        "source_sha256": source_hashes,
        "project_configuration_sha256": {
            filename: file_digest(PROJECT_DIRECTORY / filename)
            for filename in ["lean-toolchain", "lakefile.toml", "lake-manifest.json"]
        },
        "provenance_sha256": file_digest(PROJECT_DIRECTORY / "provenance.json"),
        "checker_sha256": file_digest(Path(__file__)),
        "declaration_axioms": declaration_axioms,
        "allowed_axioms": sorted(ALLOWED_AXIOMS),
        "logs": {compile_log.name: file_digest(compile_log), axiom_log.name: file_digest(axiom_log)},
        "scope": "Manually translated mathematical claims; physical identifications are not certified.",
        "dependencies": "Pinned mathlib with compiled library objects; not rebuilt entirely from source.",
    }
    output_path.write_text(json.dumps(report, indent=2) + "\n")
    print(f"PASS: {len(theorem_names)} theorems, all axiom dependencies allowed. {output_path}")


if __name__ == "__main__":
    main()
