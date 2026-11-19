#!/usr/bin/env python3
"""Inventory UIKit button labels and icon-only keyboard controls for manual accessibility review."""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

BUTTON_CREATION = re.compile(r"\b(?:UIButton|KeyButton)\s*\(\s*type\s*:")


def _resolve_source(arg: Path | None) -> Path:
    if arg is not None:
        return arg.resolve()
    candidates = [
        Path("personalkeyboard-source"),
        Path(__file__).resolve().parents[3] / "personalkeyboard-source",
    ]
    return next((item.resolve() for item in candidates if item.is_dir()), candidates[0].resolve())


def _scan_file(
    path: Path,
    context_lines: int,
) -> tuple[int, list[tuple[Path, int, str]], list[tuple[Path, int, str]]]:
    lines = path.read_text(encoding="utf-8").splitlines()
    button_candidates: list[tuple[Path, int, str]] = []
    icon_candidates: list[tuple[Path, int, str]] = []
    total = 0
    for index, line in enumerate(lines):
        if BUTTON_CREATION.search(line):
            total += 1
            nearby = "\n".join(lines[index:index + max(1, context_lines)])
            in_icon_factory = any("func iconKey(" in prior for prior in lines[:index])
            has_native_title = any(
                token in nearby for token in ("setTitle(", "cfg.title =", "configuration.title =")
            )
            is_visual_only = "isUserInteractionEnabled = false" in nearby
            if (
                "accessibilityLabel" not in nearby
                and not has_native_title
                and not is_visual_only
                and not in_icon_factory
            ):
                button_candidates.append((path, index + 1, line.strip()))

        match = re.search(r"\b(?:let|var)\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*iconKey\(", line)
        if match:
            variable = match.group(1)
            nearby = "\n".join(lines[index:index + max(1, context_lines)])
            if not re.search(rf"\b{re.escape(variable)}\.accessibilityLabel\s*=", nearby):
                icon_candidates.append((path, index + 1, variable))
    return total, button_candidates, icon_candidates


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "source",
        nargs="?",
        type=Path,
        default=None,
        help="directory containing Swift sources (default: personalkeyboard-source)",
    )
    parser.add_argument(
        "--context-lines",
        type=int,
        default=18,
        help="following lines to search for a nearby label",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="return non-zero when review candidates are found",
    )
    args = parser.parse_args()
    source = _resolve_source(args.source)
    if not source.is_dir():
        print(f"FAIL: source directory does not exist: {source}", file=sys.stderr)
        return 2

    files = sorted(source.rglob("*.swift"))
    button_candidates: list[tuple[Path, int, str]] = []
    icon_candidates: list[tuple[Path, int, str]] = []
    total = 0
    for path in files:
        file_total, file_buttons, file_icons = _scan_file(path, args.context_lines)
        total += file_total
        button_candidates.extend(file_buttons)
        icon_candidates.extend(file_icons)

    has_announcements = any("UIAccessibility.post" in path.read_text(encoding="utf-8") for path in files)
    has_hints = any("accessibilityHint" in path.read_text(encoding="utf-8") for path in files)
    print(f"Swift files inspected: {len(files)}")
    print(f"Button construction sites found: {total}")
    print(f"Accessibility announcements present: {'yes' if has_announcements else 'no'}")
    print(f"Accessibility hints present: {'yes' if has_hints else 'no'}")

    if button_candidates:
        print("\nREVIEW button candidates (no nearby explicit label or native title):")
        for path, line, snippet in button_candidates:
            print(f"REVIEW BUTTON {path}:{line}: {snippet}")
    if icon_candidates:
        print("\nREVIEW icon-only controls without a nearby explicit accessibilityLabel:")
        for path, line, variable in icon_candidates:
            print(f"REVIEW ICON {path}:{line}: {variable}")
    if not button_candidates and not icon_candidates:
        print("No unlabeled button candidates were detected by these source heuristics.")

    if args.strict and (button_candidates or icon_candidates):
        return 1
    print("Static inventory complete; physical-device VoiceOver testing is still required.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
