from __future__ import annotations

import importlib.util
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "personalkeyboard-source/scripts/bump_version.py"
SPEC = importlib.util.spec_from_file_location("bump_version", SCRIPT)
assert SPEC and SPEC.loader
bump_version = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(bump_version)


def test_version_requires_three_numeric_components() -> None:
    assert bump_version.is_valid_version("0.2.10")
    assert not bump_version.is_valid_version("0.2.10.1")
    assert not bump_version.is_valid_version("v0.2.10")
    assert not bump_version.is_valid_version("0.2.x")


def test_build_number_increments_independently() -> None:
    assert bump_version.next_build_number(31) == 32
    assert bump_version.next_build_number(32) == 33


def test_project_version_values_are_updated_as_one_set() -> None:
    project = (SCRIPT.parent.parent / "project.yml").read_text(encoding="utf-8")
    updated = bump_version.replace_project_values(project, "0.2.11", 33)
    assert updated.count('MARKETING_VERSION: "0.2.11"') == 2
    assert updated.count("CURRENT_PROJECT_VERSION: 33") == 2
    assert "ROLLING_VERSION" not in updated


def test_info_plist_values_are_updated_as_one_set() -> None:
    source = SCRIPT.parent.parent
    content = (source / "App/Config/Info.plist").read_text(encoding="utf-8")
    updated = bump_version.replace_plist_values(content, "0.2.11", 33)
    assert "<string>0.2.11</string>" in updated
    assert "<string>33</string>" in updated
