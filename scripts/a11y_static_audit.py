#!/usr/bin/env python3
"""Static audit: find UIButton / UIBarButtonItem creations missing accessibilityLabel."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# Match button instantiation lines
BUTTON_RE = re.compile(
    r"\b(UIButton|UIBarButtonItem)\s*\(",
)
# accessibilityLabel assignment on same or nearby scope is hard statically;
# we flag every button creation and let the developer confirm.
LABEL_RE = re.compile(r"accessibilityLabel\s*=")


def audit_file(path: Path) -> list[tuple[int, str]]:
    hits = []
    try:
        lines = path.read_text(encoding="utf-8", errors="ignore").splitlines()
    except Exception:
        return hits
    for i, line in enumerate(lines, 1):
        if BUTTON_RE.search(line):
            # look ahead up to 8 lines for an accessibilityLabel assignment
            window = "\n".join(lines[i - 1 : i + 8])
            if not LABEL_RE.search(window):
                hits.append((i, line.strip()[:100]))
    return hits


def main() -> int:
    print("=== a11y static audit: buttons missing accessibilityLabel ===")
    total = 0
    swift_files = list(ROOT.rglob("*.swift"))
    if not swift_files:
        print("  No Swift files found.")
        return 0
    for sf in sorted(swift_files):
        hits = audit_file(sf)
        if hits:
            rel = sf.relative_to(ROOT)
            print(f"\n{rel}")
            for ln, txt in hits:
                print(f"  line {ln}: {txt}")
                total += 1
    print(f"\nTotal flagged: {total}")
    if total:
        print("Review each: either add accessibilityLabel or confirm it's decorative.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
