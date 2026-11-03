#!/usr/bin/env python3
"""Verify the built app bundle, embedded keyboard extension, and icon metadata."""
import plistlib
import re
import sys
from pathlib import Path

APP_BUNDLE = "app.personal.PersonalKeyboard"
EXTENSION_BUNDLE = "app.personal.PersonalKeyboard.KeyboardExtension"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)
    print(f"PASS: {message}")


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: validate_built_app.py <PersonalKeyboard.app>")
    app = Path(sys.argv[1]).resolve()
    require(app.is_dir(), "built .app bundle exists")
    info_path = app / "Info.plist"
    with info_path.open("rb") as handle:
        info = plistlib.load(handle)
    require(info.get("CFBundleIdentifier") == APP_BUNDLE, "built application bundle ID unchanged")

    repo_root = Path(__file__).resolve().parents[2]
    project_file = repo_root / "personalkeyboard-source" / "project.yml"
    project_text = project_file.read_text(encoding="utf-8")
    version_match = re.search(r"MARKETING_VERSION:\s*[\"\']?(0(?:\.[0-9]+){2,3})[\"\']?", project_text)
    require(version_match is not None, "project.yml defines MARKETING_VERSION")
    expected_version = version_match.group(1)
    require(
        info.get("CFBundleShortVersionString") == expected_version,
        f"built app version matches project.yml ({expected_version})",
    )

    build_match = re.search(r"CURRENT_PROJECT_VERSION:\s*([0-9]+)", project_text)
    require(build_match is not None, "project.yml defines CURRENT_PROJECT_VERSION")
    expected_build = build_match.group(1) if build_match else ""
    require(info.get("CFBundleVersion") == expected_build, "built app build number matches project.yml")

    app_entitlements_path = repo_root / "personalkeyboard-source/Sources/ContainerApp/PersonalKeyboard.entitlements"
    extension_entitlements_path = repo_root / "personalkeyboard-source/Sources/KeyboardExtension/KeyboardExtension.entitlements"
    with app_entitlements_path.open("rb") as handle:
        app_entitlements = plistlib.load(handle)
    with extension_entitlements_path.open("rb") as handle:
        extension_entitlements = plistlib.load(handle)
    app_groups = app_entitlements.get("com.apple.security.application-groups", [])
    extension_groups = extension_entitlements.get("com.apple.security.application-groups", [])
    require(bool(app_groups) and app_groups == extension_groups, "source App Group entitlement arrays match exactly")

    icon_dictionaries = [info.get("CFBundleIcons", {}), info.get("CFBundleIcons~ipad", {})]
    alternates = {}
    primary_names = []
    for icons in icon_dictionaries:
        alternates.update(icons.get("CFBundleAlternateIcons", {}))
        primary_names.append(icons.get("CFBundlePrimaryIcon", {}).get("CFBundleIconName"))
    require("AppIconEvening" in alternates, f"built Info.plist includes AppIconEvening alternate icon (available={list(alternates)})")
    require("AppIconMorning" in primary_names, f"built app uses AppIconMorning as primary icon (available={primary_names})")

    extension = app / "PlugIns/KeyboardExtension.appex"
    require(extension.is_dir(), "keyboard extension is embedded in the app")
    with (extension / "Info.plist").open("rb") as handle:
        extension_info = plistlib.load(handle)
    require(extension_info.get("CFBundleIdentifier") == EXTENSION_BUNDLE, "built keyboard extension bundle ID unchanged")
    require(extension_info.get("CFBundlePackageType") == "XPC!", "embedded target is an app extension")
    require(extension_info.get("CFBundleShortVersionString") == expected_version, "extension marketing version matches app")
    require(extension_info.get("CFBundleVersion") == expected_build, "extension build number matches app")

    # Keyboard data JSON must ship inside the appex — missing files force tiny emoji fallbacks.
    required_json = ("emoji_catalog.json", "keyboard_layouts.json", "arabic_lexicon.json")
    for name in required_json:
        hits = list(extension.rglob(name))
        require(bool(hits), f"keyboard extension embeds {name}")
        if name == "emoji_catalog.json" and hits:
            import json
            try:
                data = json.loads(hits[0].read_text(encoding="utf-8"))
                n = sum(len(c.get("items", [])) for c in data) if isinstance(data, list) else 0
                require(n >= 500, f"emoji_catalog.json has enough items (got {n})")
            except Exception as exc:
                raise AssertionError(f"emoji_catalog.json unreadable: {exc}") from exc

    print("Built app bundle verification passed.")


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(f"FAIL: {error}", file=sys.stderr)
        sys.exit(1)
