#!/usr/bin/env python3
"""Small structural smoke checks for Naqra's split Swift sources."""
from __future__ import annotations

from pathlib import Path
import sys

source = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parent
keyboard_sources = source / "KeyboardExtension/Sources"
keyboard_resources = source / "KeyboardExtension/Resources"
app_entry = source / "App/Sources/AppShell/KeyboardPrototypeApp.swift"

files = sorted(keyboard_sources.rglob("*.swift"))
text = "\n".join(path.read_text(encoding="utf-8") for path in files)
project = (source / "project.yml").read_text(encoding="utf-8")
checks = [
    ("App Group identifier remains in extension sources", "group.app.personal.PersonalKeyboard" in text),
    ("KeyboardViewController exists", "class KeyboardViewController" in text),
    ("split controller extensions exist", any(path.name.startswith("KeyboardViewController+") for path in files)),
    ("KeyboardDataLoader exists", "KeyboardDataLoader" in text),
    ("large emoji literal is not inlined", "😀 😃 😄 😁 😆 😅 😂 🤣 😊 😇 🙂 😉" not in text),
    ("keyboard layout JSON exists", (keyboard_resources / "keyboard_layouts.json").is_file()),
    ("emoji catalog JSON exists", (keyboard_resources / "emoji_catalog.json").is_file()),
    ("app entry remains small", app_entry.is_file() and app_entry.read_text(encoding="utf-8").count("\n") < 40),
    ("app entry has no palette implementation", app_entry.is_file() and "enum NaqraColors" not in app_entry.read_text(encoding="utf-8")),
    ("XcodeGen declares app source root", "path: App/Sources" in project),
    ("XcodeGen declares extension source root", "path: KeyboardExtension/Sources" in project),
    ("XcodeGen declares shared source file", "Shared/Models/SharedKeyboardData.swift" in project),
]

ok = True
for name, passed in checks:
    print(f"{'PASS' if passed else 'FAIL'}: {name}")
    ok = ok and passed
print(f"Swift files in extension: {len(files)}")
sys.exit(0 if ok else 1)
