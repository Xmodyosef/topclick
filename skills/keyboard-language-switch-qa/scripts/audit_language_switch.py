#!/usr/bin/env python3
"""Audit source contracts for multilingual custom-keyboard transitions."""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


def function_body(source: str, signature: str) -> str:
    """Return a Swift method body using the repository's four-space method layout."""
    match = re.search(r"(?m)^    (?:(?:@objc|override) )*func " + re.escape(signature) + r"[^\n]*\{", source)
    if not match:
        return ""
    start = match.end()
    end = re.search(r"(?m)^    \}", source[start:])
    return source[start:start + end.start()] if end else ""


def audit(source_root: Path) -> dict:
    input_path = source_root / "KeyboardExtension/Sources/Input/KeyboardViewController+Input.swift"
    controller_path = source_root / "KeyboardExtension/Sources/Lifecycle/KeyboardViewController.swift"
    if not input_path.is_file() or not controller_path.is_file():
        raise FileNotFoundError("expected KeyboardViewController input and lifecycle sources")
    input_source = input_path.read_text(encoding="utf-8")
    controller = controller_path.read_text(encoding="utf-8")

    findings: list[dict[str, str]] = []

    def check(code: str, severity: str, condition: bool, message: str) -> None:
        if not condition:
            findings.append({"code": code, "severity": severity, "message": message})

    toggle = function_body(input_source, "toggleLanguage")
    language_tap = function_body(input_source, "languageTapped()")
    space_tap = function_body(input_source, "spaceTouchUp()")
    scheduler = function_body(input_source, "scheduleLanguageRebuild()")
    suggestions = function_body(input_source, "suggestions()")

    check(
        "LANG001",
        "high",
        bool(toggle) and re.search(
            r'primaryLanguage\s*=\s*language\s*==\s*\.arabic\s*\?\s*"ar"\s*:\s*"en"',
            toggle) is not None,
        "The shared language transition must synchronize UIInputViewController.primaryLanguage to ar/en.",
    )
    check(
        "LANG002", "high",
        bool(language_tap) and "toggleLanguage(" in language_tap,
        "The language key must use the shared transition helper.",
    )
    check(
        "LANG003", "high",
        bool(space_tap) and "toggleLanguage(" in space_tap,
        "The double-space transition must use the same language transition helper.",
    )
    check(
        "LANG004", "medium",
        bool(toggle) and "scheduleLanguageRebuild()" in toggle and "rebuild()" not in toggle,
        "Language transitions should schedule a coalesced rebuild rather than rebuilding inline.",
    )
    check(
        "LANG005", "medium",
        bool(scheduler)
        and "languageRebuildScheduled" in scheduler
        and "DispatchQueue.main.async" in scheduler
        and "rebuild()" in scheduler,
        "The rebuild scheduler should guard duplicate requests and rebuild on the main queue.",
    )
    check(
        "LANG006", "high",
        bool(suggestions) and "textChecker" in suggestions and "UITextChecker()" not in suggestions,
        "Suggestion generation must reuse the controller's UITextChecker instead of allocating it per call.",
    )
    check(
        "LANG007", "medium",
        re.search(r"(?m)^\s*lazy var textChecker\s*=\s*UITextChecker\(\)", controller) is not None,
        "The keyboard controller should lazily retain one UITextChecker instance.",
    )

    # Catch independent language mutations outside the shared transition helper.
    direct_mutations = [
        f"{path.name}:{number}"
        for path in sorted((source_root / "KeyboardExtension/Sources").rglob("*.swift"))
        for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1)
        if re.search(r"\blanguage\s*=\s*language\s*==", line)
        and path != input_path
    ]
    check(
        "LANG008", "medium",
        not direct_mutations,
        "Language state is mutated outside the shared input transition helper: " + ", ".join(direct_mutations),
    )
    check(
        "LANG009", "medium",
        bool(space_tap) and ("deleteBackward" in space_tap or "deleteBackward(" in space_tap),
        "Double-space language switch should delete the space from the first tap.",
    )

    return {
        "source_root": str(source_root),
        "status": "findings" if findings else "pass",
        "finding_count": len(findings),
        "findings": findings,
        "interpretation": "Static source contracts only; no UIKit runtime or physical-device behavior is proven.",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="personalkeyboard-source directory")
    parser.add_argument("--json", action="store_true", help="emit machine-readable JSON")
    parser.add_argument("--strict", action="store_true", help="exit 1 when any finding exists")
    args = parser.parse_args()
    try:
        report = audit(args.source.resolve())
    except (OSError, FileNotFoundError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 2
    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        print(f"Language-switch source audit: {report['status']} ({report['finding_count']} findings)")
        for item in report["findings"]:
            print(f"{item['severity'].upper()} {item['code']}: {item['message']}")
        print(report["interpretation"])
    return 1 if args.strict and report["findings"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
