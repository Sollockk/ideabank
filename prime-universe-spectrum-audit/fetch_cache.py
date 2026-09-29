"""Download mathlib's compiled cache only for this project's imported modules."""

from pathlib import Path
import re
import subprocess


PROJECT_DIRECTORY = Path(__file__).resolve().parent
imported_modules = sorted({
    imported
    for source in (PROJECT_DIRECTORY / "PrimeUniverse").glob("*.lean")
    for imported in re.findall(r"^import (Mathlib[\w.]*)$", source.read_text(), re.MULTILINE)
})
if not imported_modules:
    raise RuntimeError("No mathlib imports found.")
subprocess.run(
    ["lake", "exe", "cache", "get", *imported_modules],
    cwd=PROJECT_DIRECTORY,
    check=True,
)
