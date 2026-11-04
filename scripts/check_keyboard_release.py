#!/usr/bin/env python3
"""Release gate: verify App Group, signing, and version before shipping Naqra."""

from __future__ import annotations

import json
import os
import plistlib
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PASS = 0
FAIL = 0


def check(name: str, cond: bool, detail: str = "") -> None:
    global PASS, FAIL
    if cond:
        PASS += 1
        print(f"  [PASS] {name}")
    else:
        FAIL += 1
        msg = f"  [FAIL] {name}"
        if detail:
            msg += f" — {detail}"
        print(msg)


def read_plist(path: Path) -> dict:
    with path.open("rb") as f:
        return plistlib.load(f)


def main() -> int:
    print("=== Naqra release gate ===")

    # 1) Info.plist exists and has a version
    info = ROOT / "Naqra" / "Info.plist"
    if not info.exists():
        # try common alternate location
        alt = list(ROOT.rglob("Info.plist"))
        info = alt[0] if alt else info
    if info.exists():
        try:
            data = read_plist(info)
            ver = data.get("CFBundleShortVersionString") or data.get("CFBundleVersion")
            check("Info.plist has version", bool(ver), f"found {ver}")
        except Exception as e:
            check("Info.plist readable", False, str(e))
    else:
        check("Info.plist found", False, str(info))

    # 2) Entitlements: App Group present
    ents = list(ROOT.rglob("*.entitlements"))
    if ents:
        try:
            data = read_plist(ents[0])
            groups = data.get("com.apple.security.application-groups", [])
            check("App Group entitlement present", bool(groups), ", ".join(groups) or "empty")
        except Exception as e:
            check("Entitlements readable", False, str(e))
    else:
        check("Entitlements file found", False)

    # 3) Code signing identity available (ad-hoc is fine)
    try:
        r = subprocess.run(
            ["security", "find-identity", "-v", "-p", "codesigning"],
            capture_output=True, text=True, timeout=30,
        )
        check("At least one codesigning identity", r.returncode == 0 and "0 valid identities found" not in r.stdout)
    except Exception as e:
        check("codesign check runnable", False, str(e))

    # 4) No debug-only leftovers in release sources
    swift_files = list((ROOT / "Naqra").rglob("*.swift")) if (ROOT / "Naqra").exists() else list(ROOT.rglob("*.swift"))
    debug_hits = []
    for sf in swift_files:
        try:
            text = sf.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        if "#if DEBUG" in text:
            # allowed if paired with #endif
            if text.count("#if DEBUG") != text.count("#endif"):
                debug_hits.append(sf.name)
    check("DEBUG blocks balanced", not debug_hits, ", ".join(debug_hits))

    print(f"\nResult: {PASS} passed, {FAIL} failed")
    return 1 if FAIL else 0


if __name__ == "__main__":
    sys.exit(main())
