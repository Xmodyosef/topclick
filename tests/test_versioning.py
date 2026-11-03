from __future__ import annotations

import importlib.util
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "personalkeyboard-source/scripts/bump_version.py"
SPEC = importlib.util.spec_from_file_location("bump_version", SCRIPT)
assert SPEC and SPEC.loader
bump_version = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(bump_version)


def test_rolling_sequence_increments_until_twenty() -> None:
    assert bump_version.next_versions("0.2.9", "0.2.9.19", 49) == ("0.2.9", 50, "0.2.9.20")


def test_twenty_rolls_patch_and_resets_sequence_without_resetting_build() -> None:
    assert bump_version.next_versions("0.2.9", "0.2.9.20", 50) == ("0.2.10", 51, "0.2.10.1")


def test_rejects_mismatched_rolling_prefix() -> None:
    try:
        bump_version.next_versions("0.2.9", "0.2.8.19", 49)
    except ValueError:
        return
    raise AssertionError("mismatched rolling prefix must be rejected")
