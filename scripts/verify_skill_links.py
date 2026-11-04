#!/usr/bin/env python3
"""Verify TOOLS_INDEX.md skill links and script paths are intact."""

from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[1]
INDEX = ROOT / "TOOLS_INDEX.md"

URL_RE = re.compile(r"https?://[^\s|)]+")
PATH_RE = re.compile(r"`([^`]+\.(?:py|sh|yml|yaml|swift|md))`")


def main() -> int:
    if not INDEX.exists():
        print(f"[FAIL] {INDEX} not found")
        return 1

    text = INDEX.read_text(encoding="utf-8")
    print(f"=== verify_skill_links: {INDEX.name} ===")

    ok = True

    # 1) Referenced local script paths must exist
    for m in PATH_RE.finditer(text):
        rel = m.group(1)
        # skip URLs mistaken as paths
        if rel.startswith("http"):
            continue
        p = ROOT / rel
        if p.exists():
            print(f"  [OK]  path exists: {rel}")
        else:
            # some paths are descriptive (e.g. scripts/ meaning directory)
            if rel.endswith("/") and (ROOT / rel).is_dir():
                print(f"  [OK]  dir exists:  {rel}")
            else:
                print(f"  [MISS] path missing: {rel}")
                ok = False

    # 2) URLs in the index — just report count, don't fetch (offline-safe)
    urls = URL_RE.findall(text)
    print(f"\n  URLs listed: {len(urls)} (not fetched; run with network to validate)")

    # 3) skills/ directory should only contain the 4 kept bundles
    skills_dir = ROOT / "skills"
    if skills_dir.is_dir():
        kept = {"keyboard-extension", "ios-keyboard-release-gate",
                "skill-routing-integrity", "iphone-keyboard-accessibility-qa"}
        found = {d.name for d in skills_dir.iterdir() if d.is_dir()}
        extra = found - kept
        missing = kept - found
        if extra:
            print(f"  [WARN] unexpected skill bundles: {', '.join(sorted(extra))}")
        if missing:
            print(f"  [MISS] expected skill bundles missing: {', '.join(sorted(missing))}")
            ok = False
        else:
            print(f"  [OK]  skills/ contains exactly the 4 kept bundles")

    print("\nResult:", "PASS" if ok else "FAIL")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
