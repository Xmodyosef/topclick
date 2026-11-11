#!/usr/bin/env python3
"""Validate or atomically advance Naqra's marketing, build, and rolling versions."""
from __future__ import annotations

import argparse
import os
import re
import stat
import tempfile
from pathlib import Path

VERSION = re.compile(r"^([0-9]+)\.([0-9]+)\.([0-9]+)$")
ROLLING = re.compile(r"^([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)$")
RETENTION_MAX = 20


def next_versions(marketing: str, rolling: str, build: int) -> tuple[str, int, str]:
    match = VERSION.fullmatch(marketing)
    rolling_match = ROLLING.fullmatch(rolling)
    if not match or not rolling_match:
        raise ValueError("marketing must have 3 numeric components and rolling must have 4")
    major, minor, patch = map(int, match.groups())
    r_major, r_minor, r_patch, sequence = map(int, rolling_match.groups())
    if (major, minor, patch) != (r_major, r_minor, r_patch):
        raise ValueError("ROLLING_VERSION prefix must match MARKETING_VERSION")
    if not 1 <= sequence <= RETENTION_MAX:
        raise ValueError(f"rolling sequence must be between 1 and {RETENTION_MAX}")
    if build < 1:
        raise ValueError("CURRENT_PROJECT_VERSION must be a positive integer")

    next_build = build + 1
    if sequence < RETENTION_MAX:
        next_marketing = marketing
        next_rolling = f"{marketing}.{sequence + 1}"
    else:
        next_marketing = f"{major}.{minor}.{patch + 1}"
        next_rolling = f"{next_marketing}.1"
    return next_marketing, next_build, next_rolling


def extract_project_values(project: str) -> tuple[str, int, str]:
    marketing = set(re.findall(r"(?m)^\s+MARKETING_VERSION:\s*[\"']?([0-9.]+)", project))
    builds = set(re.findall(r"(?m)^\s+CURRENT_PROJECT_VERSION:\s*([0-9]+)", project))
    rolling = re.findall(r"(?m)^\s+ROLLING_VERSION:\s*[\"']?([0-9.]+)", project)
    if len(marketing) != 1 or len(builds) != 1 or len(rolling) != 1:
        raise ValueError("project.yml must define one consistent marketing, build, and rolling value")
    return next(iter(marketing)), int(next(iter(builds))), rolling[0]


def replace_project_values(project: str, marketing: str, build: int, rolling: str) -> str:
    project, m_count = re.subn(
        r'(?m)^(\s+MARKETING_VERSION:\s*)["\']?[0-9.]+["\']?\s*$',
        lambda m: f'{m.group(1)}"{marketing}"',
        project,
    )
    project, b_count = re.subn(
        r"(?m)^(\s+CURRENT_PROJECT_VERSION:\s*)[0-9]+\s*$",
        lambda m: f"{m.group(1)}{build}",
        project,
    )
    project, r_count = re.subn(
        r'(?m)^(\s+ROLLING_VERSION:\s*)["\']?[0-9.]+["\']?\s*$',
        lambda m: f'{m.group(1)}"{rolling}"',
        project,
    )
    if m_count != 2 or b_count != 2 or r_count != 1:
        raise ValueError("expected two app/extension marketing and build settings plus one rolling setting")
    return project


def replace_plist_values(plist: str, marketing: str, build: int) -> str:
    plist, m_count = re.subn(
        r"(<key>CFBundleShortVersionString</key>\s*<string>)[^<]+(</string>)",
        lambda m: f"{m.group(1)}{marketing}{m.group(2)}",
        plist,
    )
    plist, b_count = re.subn(
        r"(<key>CFBundleVersion</key>\s*<string>)[^<]+(</string>)",
        lambda m: f"{m.group(1)}{build}{m.group(2)}",
        plist,
    )
    if m_count != 1 or b_count != 1:
        raise ValueError("each Info.plist must contain exactly one short version and build value")
    return plist


def atomic_write(updates: dict[Path, str]) -> None:
    originals = {path: path.read_bytes() for path in updates}
    staged: dict[Path, Path] = {}
    replaced: list[Path] = []
    try:
        for path, content in updates.items():
            path.parent.mkdir(parents=True, exist_ok=True)
            mode = stat.S_IMODE(path.stat().st_mode) if path.exists() else 0o644
            with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=path.parent, delete=False) as handle:
                handle.write(content)
                handle.flush()
                os.fsync(handle.fileno())
                os.chmod(handle.name, mode)
                staged[path] = Path(handle.name)
        for path, temp_path in staged.items():
            os.replace(temp_path, path)
            replaced.append(path)
    except Exception:
        for path in replaced:
            path.write_bytes(originals[path])
        raise
    finally:
        for temp_path in staged.values():
            if temp_path.exists():
                temp_path.unlink()


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="validate version consistency without changing files")
    parser.add_argument("--project", type=Path, default=root / "project.yml")
    parser.add_argument("--app-info", type=Path, default=root / "App/Config/Info.plist")
    parser.add_argument("--extension-info", type=Path, default=root / "KeyboardExtension/Config/Info.plist")
    args = parser.parse_args()

    project_path = args.project.resolve()
    app_path = args.app_info.resolve()
    extension_path = args.extension_info.resolve()
    project = project_path.read_text(encoding="utf-8")
    app_info = app_path.read_text(encoding="utf-8")
    extension_info = extension_path.read_text(encoding="utf-8")
    marketing, build, rolling = extract_project_values(project)

    if args.check:
        for path, text in ((app_path, app_info), (extension_path, extension_info)):
            if f"<string>{marketing}</string>" not in text or f"<string>{build}</string>" not in text:
                raise ValueError(f"{path} does not match project.yml")
        if not VERSION.fullmatch(marketing) or not ROLLING.fullmatch(rolling):
            raise ValueError("invalid version format")
        if rolling.rsplit(".", 1)[0] != marketing or not 1 <= int(rolling.rsplit(".", 1)[1]) <= RETENTION_MAX:
            raise ValueError("invalid rolling version relationship")
        print(f"Versions consistent: marketing={marketing}, build={build}, rolling={rolling}")
        return 0

    new_marketing, new_build, new_rolling = next_versions(marketing, rolling, build)
    updates = {
        project_path: replace_project_values(project, new_marketing, new_build, new_rolling),
        app_path: replace_plist_values(app_info, new_marketing, new_build),
        extension_path: replace_plist_values(extension_info, new_marketing, new_build),
    }
    atomic_write(updates)
    print(f"Advanced versions: marketing={new_marketing}, build={new_build}, rolling={new_rolling}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
