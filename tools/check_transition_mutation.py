"""Negative control: identity mutation must break the preservation theorem."""

from __future__ import annotations

import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "Member.lean"

OLD = """  { before with
    role := next_role
"""
NEW = """  { before with
    identity := { before.identity with repo := before.identity.repo ++ "/mutated" }
    role := next_role
"""


def main() -> None:
    source = SOURCE.read_text()
    if source.count(OLD) != 1:
        raise SystemExit("mutation target missing or ambiguous")
    mutant = source.replace(OLD, NEW, 1)
    with tempfile.TemporaryDirectory(prefix="union-mutation-") as tmp:
        path = Path(tmp) / "MemberMutation.lean"
        path.write_text(mutant)
        run = subprocess.run(
            ["lean", "-DwarningAsError=true", str(path)],
            cwd=ROOT,
            capture_output=True,
            text=True,
            timeout=120,
        )
        if run.returncode == 0:
            raise SystemExit("identity mutation SURVIVED")
        print("identity mutation KILLED")


if __name__ == "__main__":
    main()
