from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def run_script(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, *args],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )


def test_skill_routing_integrity() -> None:
    result = run_script(
        "skills/skill-routing-integrity/scripts/verify_skill_links.py",
        "--root",
        str(ROOT),
    )
    assert result.returncode == 0, result.stdout + result.stderr


def test_naqra_source_contracts() -> None:
    result = run_script(
        ".github/scripts/validate_naqra.py",
        "personalkeyboard-source",
    )
    assert result.returncode == 0, result.stdout + result.stderr
