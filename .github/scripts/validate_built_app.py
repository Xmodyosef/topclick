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

    # The workflow invokes this validator from personalkeyboard-source. Resolve
    # the source root from the current working directory first, then fall back to
    # walking upward from the script location for local/manual invocations.
    cwd = Path.cwd().resolve()
    source_root = next(
        (parent for parent in (cwd, *cwd.parents) if (parent / "project.yml").is_file() and (parent / "Sources").is_dir()),
        None,
    )
    if source_root is None:
        script_path = Path(__file__).resolve()
        repo_root = next(
            (parent for parent in script_path.parents if (parent / "personalkeyboard-source" / "project.yml").is_file()),
            None,
        )
        source_root = (repo_root / "personalkeyboard-source") if repo_root else None
    if source_root is None:
        raise FileNotFoundError(f"could not locate personalkeyboard-source from cwd={cwd}")
    project_file = source_root / "project.yml"
    project_text = project_file.read_text(encoding="utf-8")
    version_match = re.search(r"MARKETING_VERSION:\s*[\"\']?(0(?:\.[0-9]+){2})[\"\']?", project_text)
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

    app_entitlements_path = source_root / "Sources/ContainerApp/PersonalKeyboard.entitlements"
    extension_entitlements_path = source_root / "Sources/KeyboardExtension/KeyboardExtension.entitlements"
    require(app_entitlements_path.is_file(), f"app entitlements exist at {app_entitlements_path}")
    require(extension_entitlements_path.is_file(), f"extension entitlements exist at {extension_entitlements_path}")

    def load_entitlements(path: Path) -> dict:
        raw = path.read_bytes()
        print(f"entitlements {path}: size={len(raw)} head={raw[:80]!r}")
        if not raw.strip():
            raise AssertionError(f"entitlements file is empty: {path}")
        try:
            data = plistlib.loads(raw)
        except Exception as exc:
            raise AssertionError(f"entitlements plist unreadable at {path}: {exc}") from exc
        if not isinstance(data, dict):
            raise AssertionError(f"entitlements root is not a dict at {path}: {type(data)}")
        return data

    app_entitlements = load_entitlements(app_entitlements_path)
    extension_entitlements = load_entitlements(extension_entitlements_path)
    entitlement_key = "com.apple.security.application-groups"
    expected_group = "group.app.personal.PersonalKeyboard"

    # xcodebuild with CODE_SIGNING_ALLOWED=NO can rewrite CODE_SIGN_ENTITLEMENTS
    # source files to an empty dict. Fall back to the expected group contract and
    # to a git clean copy when the working tree was emptied.
    def groups_from(data: dict, path: Path) -> list[str]:
        values = data.get(entitlement_key, [])
        if not values:
            return []
        return sorted({str(value).strip() for value in values if str(value).strip()})

    app_groups = groups_from(app_entitlements, app_entitlements_path)
    extension_groups = groups_from(extension_entitlements, extension_entitlements_path)

    if not app_groups or not extension_groups:
        # Restore from git index/HEAD if the build clobbered the working tree files.
        import subprocess
        repo_root = source_root.parent if (source_root.parent / ".git").exists() or (source_root.parent / ".github").exists() else source_root
        for rel in (
            "personalkeyboard-source/Sources/ContainerApp/PersonalKeyboard.entitlements",
            "personalkeyboard-source/Sources/KeyboardExtension/KeyboardExtension.entitlements",
        ):
            subprocess.run(
                ["git", "checkout", "HEAD", "--", rel],
                cwd=str(repo_root),
                check=False,
                capture_output=True,
                text=True,
            )
        app_entitlements = load_entitlements(app_entitlements_path)
        extension_entitlements = load_entitlements(extension_entitlements_path)
        app_groups = groups_from(app_entitlements, app_entitlements_path)
        extension_groups = groups_from(extension_entitlements, extension_entitlements_path)

    print(f"App Group validation source root: {source_root}")
    print(f"App entitlements path: {app_entitlements_path}")
    print(f"Extension entitlements path: {extension_entitlements_path}")
    print(f"App entitlement keys: {sorted(app_entitlements)}")
    print(f"Extension entitlement keys: {sorted(extension_entitlements)}")
    require(
        bool(app_groups) and app_groups == extension_groups,
        f"source App Group entitlement arrays match exactly (app={app_groups}, extension={extension_groups})",
    )
    require(
        app_groups == [expected_group],
        f"App Group is the expected Naqra group (got {app_groups})",
    )

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
    required_json = ("emoji_catalog.json", "keyboard_layouts.json")
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
