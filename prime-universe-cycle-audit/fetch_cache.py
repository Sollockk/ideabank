"""Fetch the pinned Lean dependencies and caches needed by this package."""

from pathlib import Path
import re
import subprocess


def main():
    project_directory = Path(__file__).resolve().parent
    library_imports = set()
    for source in (project_directory / "PrimeUniverse").glob("*.lean"):
        library_imports.update(re.findall(
            r"^import (Mathlib[\w.]*)$", source.read_text(), re.MULTILINE
        ))
    subprocess.run(
        ["lake", "exe", "cache", "get", *sorted(library_imports)],
        cwd=project_directory,
        check=True,
    )


if __name__ == "__main__":
    main()
