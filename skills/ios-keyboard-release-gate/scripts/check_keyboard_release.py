#!/usr/bin/env python3
"""Static release-contract checks for an iOS app with a custom keyboard extension."""
from __future__ import annotations

import argparse
import json
import plistlib
import re
import sys
from pathlib import Path

REQUIRED_RESOURCES = {"emoji_catalog.json", "keyboard_layouts.json"}
APP_GROUP_KEY = "com.apple.security.application-groups"


class Checks:
    def __init__(self) -> None:
        self.failures: list[str] = []

    def require(self, condition: bool, message: str) -> None:
        print(f"{'PASS' if condition else 'FAIL'}: {message}")
        if not condition:
            self.failures.append(message)


def read_plist(checks: Checks, path: Path) -> dict:
    try:
        with path.open("rb") as file:
            value = plistlib.load(file)
        checks.require(isinstance(value, dict), f"{path} is a plist dictionary")
        return value if isinstance(value, dict) else {}
    except (OSError, plistlib.InvalidFileException, ValueError) as error:
        checks.require(False, f"Cannot read {path}: {error}")
        return {}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="personalkeyboard-source directory")
    parser.add_argument("--built-app", type=Path, help="optional built .app bundle to inspect")
    args = parser.parse_args()
    source = args.source.resolve()
    checks = Checks()
    project_path = source / "project.yml"
    try:
        project = project_path.read_text(encoding="utf-8")
    except OSError as error:
        print(f"FAIL: Cannot read {project_path}: {error}", file=sys.stderr)
        return 2

    app_info = read_plist(checks, source / "Sources/ContainerApp/Info.plist")
    ext_info = read_plist(checks, source / "Sources/KeyboardExtension/Info.plist")
    app_entitlements = read_plist(checks, source / "Sources/ContainerApp/PersonalKeyboard.entitlements")
    ext_entitlements = read_plist(checks, source / "Sources/KeyboardExtension/KeyboardExtension.entitlements")

    app_group = app_entitlements.get(APP_GROUP_KEY, [])
    ext_group = ext_entitlements.get(APP_GROUP_KEY, [])
    checks.require(bool(app_group) and app_group == ext_group, "container and keyboard share the same App Group entitlement")

    def target_bundle_id(target: str) -> str | None:
        block = re.search(rf"(?ms)^  {re.escape(target)}:\n(.*?)(?=^  [A-Za-z][A-Za-z0-9]+:\n|\Z)", project)
        if not block:
            return None
        match = re.search(r"(?m)^\s+PRODUCT_BUNDLE_IDENTIFIER:\s*([^\s#]+)", block.group(1))
        return match.group(1) if match else None

    app_bundle = target_bundle_id("PersonalKeyboard")
    ext_bundle = target_bundle_id("KeyboardExtension")
    app_source_id = app_info.get("CFBundleIdentifier")
    ext_source_id = ext_info.get("CFBundleIdentifier")
    placeholder = "$(PRODUCT_BUNDLE_IDENTIFIER)"
    checks.require(bool(app_bundle) and app_source_id in (app_bundle, placeholder), "container bundle ID matches project.yml or its Xcode placeholder")
    checks.require(bool(ext_bundle) and ext_source_id in (ext_bundle, placeholder), "extension bundle ID matches project.yml or its Xcode placeholder")
    checks.require(bool(app_bundle and ext_bundle and ext_bundle.startswith(app_bundle + ".")), "extension bundle ID is nested under container bundle ID")
    extension_attributes = ext_info.get("NSExtension", {}).get("NSExtensionAttributes", {})
    checks.require(extension_attributes.get("RequestsOpenAccess") is True, "keyboard Full Access request is declared in extension Info.plist")

    versions = re.findall(r"MARKETING_VERSION:\s*[\"']?([^\"'\s]+)", project)
    builds = re.findall(r"CURRENT_PROJECT_VERSION:\s*([0-9]+)", project)
    checks.require(bool(versions) and len(set(versions)) == 1, "app and extension marketing versions agree")
    checks.require(bool(builds) and len(set(builds)) == 1, "app and extension build numbers agree")
    if versions:
        checks.require(app_info.get("CFBundleShortVersionString") == versions[0] == ext_info.get("CFBundleShortVersionString"), "source Info.plist versions match project.yml")
    if builds:
        checks.require(app_info.get("CFBundleVersion") == builds[0] == ext_info.get("CFBundleVersion"), "source Info.plist build numbers match project.yml")

    resource_paths = re.findall(r"- path:\s*(Sources/KeyboardExtension/Resources/[^\s]+\.json)", project)
    resource_names = {Path(item).name for item in resource_paths}
    checks.require(REQUIRED_RESOURCES <= resource_names, "project.yml registers all required keyboard JSON resources")
    for relative in resource_paths:
        path = source / relative
        try:
            json.loads(path.read_text(encoding="utf-8"))
            checks.require(True, f"resource JSON is valid: {relative}")
        except (OSError, json.JSONDecodeError) as error:
            checks.require(False, f"resource JSON is invalid: {relative}: {error}")

    swift_files = list((source / "Sources").rglob("*.swift"))
    swift = "\n".join(path.read_text(encoding="utf-8") for path in swift_files)
    checks.require("needsInputModeSwitchKey" in swift, "system switch key is gated by needsInputModeSwitchKey")
    checks.require("handleInputModeList(from:with:)" in swift and "for: .allTouchEvents" in swift, "system switch key invokes the UIKit input-mode handler")

    if args.built_app:
        app_path = args.built_app.resolve()
        built_info = read_plist(checks, app_path / "Info.plist")
        checks.require(app_path.is_dir(), "built .app bundle exists")
        checks.require(built_info.get("CFBundleIdentifier") == app_bundle, "built app bundle ID matches project.yml")
        if versions:
            checks.require(built_info.get("CFBundleShortVersionString") == versions[0], "built app marketing version matches source")
        if builds:
            checks.require(built_info.get("CFBundleVersion") == builds[0], "built app build number matches source")
        extension_path = app_path / "PlugIns/KeyboardExtension.appex"
        checks.require(extension_path.is_dir(), "built app embeds KeyboardExtension.appex")
        if extension_path.is_dir():
            built_ext = read_plist(checks, extension_path / "Info.plist")
            checks.require(built_ext.get("CFBundleIdentifier") == ext_bundle, "built extension bundle ID matches project.yml")
            for name in sorted(REQUIRED_RESOURCES):
                checks.require(any(extension_path.rglob(name)), f"built extension contains {name}")

    if checks.failures:
        print(f"\n{len(checks.failures)} release-contract check(s) failed.", file=sys.stderr)
        return 1
    print("\nAll keyboard release-contract checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
