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


def test_ios_source_tree_contracts() -> None:
    source = ROOT / "personalkeyboard-source"
    required = (
        source / "App/Sources/AppShell/KeyboardPrototypeApp.swift",
        source / "App/Resources/Assets.xcassets/Contents.json",
        source / "App/Config/Info.plist",
        source / "KeyboardExtension/Sources/Lifecycle/KeyboardViewController.swift",
        source / "KeyboardExtension/Resources/keyboard_layouts.json",
        source / "KeyboardExtension/Config/Info.plist",
        source / "Shared/Models/SharedKeyboardData.swift",
    )
    assert all(path.is_file() for path in required)
    assert not (source / "Sources").exists()
    project = (source / "project.yml").read_text(encoding="utf-8")
    assert "path: App/Sources" in project
    assert "path: App/Resources" in project
    assert "path: KeyboardExtension/Sources" in project
    assert "Shared/Models/SharedKeyboardData.swift" in project


def test_clipboard_privacy_default_does_not_destroy_existing_history() -> None:
    source = (
        ROOT / "personalkeyboard-source/KeyboardExtension/Sources/Features/ClipboardHistory.swift"
    ).read_text(encoding="utf-8")
    block = source.split("func ensurePrivacyDefault()", 1)[1].split("\n    }", 1)[0]
    assert 'ThemeIO.set("clipboardHistoryEnabled", value: false)' in block
    assert 'ThemeIO.set(key, value: "")' not in block
