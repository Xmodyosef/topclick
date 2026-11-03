#!/usr/bin/env python3
"""Find Swift button construction sites that merit a manual accessibility review."""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

BUTTON_CREATION = re.compile(r"\b(?:UIButton|KeyButton)\s*\(\s*type\s*:")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="directory containing Swift sources")
    parser.add_argument("--context-lines", type=int, default=16, help="following lines to search for a nearby label")
    parser.add_argument("--strict", action="store_true", help="return non-zero when review candidates are found")
    args = parser.parse_args()
    source = args.source.resolve()
    if not source.is_dir():
        print(f"FAIL: source directory does not exist: {source}", file=sys.stderr)
        return 2

    files = sorted(source.rglob("*.swift"))
    candidates: list[tuple[Path, int, str]] = []
    total = 0
    for path in files:
        lines = path.read_text(encoding="utf-8").splitlines()
        for index, line in enumerate(lines):
            if not BUTTON_CREATION.search(line):
                continue
            total += 1
            nearby = "\n".join(lines[index:index + max(1, args.context_lines)])
            if "accessibilityLabel" not in nearby:
                candidates.append((path, index + 1, line.strip()))

    has_announcements = any("UIAccessibility.post" in path.read_text(encoding="utf-8") for path in files)
    has_hints = any("accessibilityHint" in path.read_text(encoding="utf-8") for path in files)
    print(f"Swift files inspected: {len(files)}")
    print(f"Button construction sites found: {total}")
    print(f"Accessibility announcements present: {'yes' if has_announcements else 'no'}")
    print(f"Accessibility hints present: {'yes' if has_hints else 'no'}")
    if candidates:
        print("\nREVIEW candidates (label not found in the nearby context; inspect call sites):")
        for path, line, snippet in candidates:
            print(f"REVIEW {path}:{line}: {snippet}")
    else:
        print("No unlabeled button construction candidates were detected by this heuristic.")
    if args.strict and candidates:
        return 1
    print("Static inventory complete; physical-device VoiceOver testing is still required.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
