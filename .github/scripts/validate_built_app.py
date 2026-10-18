#!/usr/bin/env python3
"""Verify the built app bundle, embedded keyboard extension, and icon metadata."""
import plistlib
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
    require(info.get("CFBundleShortVersionString") == "0.2", "built app version is 0.2")

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
    print("Built app bundle verification passed.")


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(f"FAIL: {error}", file=sys.stderr)
        sys.exit(1)
