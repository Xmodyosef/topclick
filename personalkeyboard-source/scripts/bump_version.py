#!/usr/bin/env python3
"""Keep Naqra's app and keyboard extension on one public version identity."""
from __future__ import annotations

import argparse
import os
import re
import stat
import tempfile
from pathlib import Path

VERSION = re.compile(r"^[0-9]+\.[0-9]+\.[0-9]+$")


def is_valid_version(value: str) -> bool:
    return VERSION.fullmatch(value) is not None


def next_build_number(current: int) -> int:
    if current < 1:
        raise ValueError("CURRENT_PROJECT_VERSION must be a positive integer")
    return current + 1


def extract_project_values(project: str) -> tuple[str, int]:
    marketing = re.findall(r'(?m)^\s+MARKETING_VERSION:\s*["\']?([0-9.]+)', project)
    builds = re.findall(r"(?m)^\s+CURRENT_PROJECT_VERSION:\s*([0-9]+)", project)
    if len(marketing) != 2 or len(set(marketing)) != 1:
        raise ValueError("project.yml must define the same MARKETING_VERSION for app and extension")
    if len(builds) != 2 or len(set(builds)) != 1:
        raise ValueError("project.yml must define the same CURRENT_PROJECT_VERSION for app and extension")
    return marketing[0], int(builds[0])


def replace_project_values(project: str, version: str, build: int) -> str:
    project, marketing_count = re.subn(
        r'(?m)^(\s+MARKETING_VERSION:\s*)["\']?[0-9.]+["\']?\s*$',
        lambda match: f'{match.group(1)}"{version}"',
        project,
    )
    project, build_count = re.subn(
        r"(?m)^(\s+CURRENT_PROJECT_VERSION:\s*)[0-9]+\s*$",
        lambda match: f"{match.group(1)}{build}",
        project,
    )
    if marketing_count != 2 or build_count != 2:
        raise ValueError("expected exactly two app/extension version and build settings")
    if "ROLLING_VERSION" in project:
        raise ValueError("ROLLING_VERSION is retired; remove it from project.yml")
    return project


def validate_info_plist(path: Path) -> None:
    content = path.read_text(encoding="utf-8")
    if content.count("<string>$(MARKETING_VERSION)</string>") != 1:
        raise ValueError(f"{path} must use $(MARKETING_VERSION) exactly once")
    if content.count("<string>$(CURRENT_PROJECT_VERSION)</string>") != 1:
        raise ValueError(f"{path} must use $(CURRENT_PROJECT_VERSION) exactly once")


def atomic_write(updates: dict[Path, str]) -> None:
    originals = {path: path.read_bytes() for path in updates}
    staged: dict[Path, Path] = {}
    replaced: list[Path] = []
    try:
        for path, content in updates.items():
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
    parser.add_argument("--set-version", help="set the public three-component release version")
    parser.add_argument("--bump-build", action="store_true", help="increment the shared integer build number")
    args = parser.parse_args()
    if args.check and (args.set_version or args.bump_build):
        parser.error("--check cannot be combined with version-changing options")
    if not args.check and not args.set_version and not args.bump_build:
        parser.error("choose --check, --set-version, or --bump-build")

    version_path = root / "VERSION"
    project_path = root / "project.yml"
    app_info = root / "App/Config/Info.plist"
    extension_info = root / "KeyboardExtension/Config/Info.plist"
    current_version = version_path.read_text(encoding="utf-8").strip()
    project = project_path.read_text(encoding="utf-8")
    project_version, current_build = extract_project_values(project)

    if not is_valid_version(current_version):
        raise ValueError(f"VERSION must contain exactly three numeric components, found {current_version!r}")
    if project_version != current_version:
        raise ValueError(f"project.yml version {project_version} does not match VERSION {current_version}")
    if "ROLLING_VERSION" in project:
        raise ValueError("ROLLING_VERSION is retired")
    validate_info_plist(app_info)
    validate_info_plist(extension_info)

    if args.check:
        print(f"Unified version valid: version={current_version}, build={current_build}, app=extension")
        return 0

    new_version = args.set_version or current_version
    if not is_valid_version(new_version):
        raise ValueError("--set-version must use exactly three numeric components, for example 0.2.11")
    new_build = next_build_number(current_build) if args.bump_build else current_build
    updates = {
        version_path: new_version + "\n",
        project_path: replace_project_values(project, new_version, new_build),
    }
    atomic_write(updates)
    print(f"Updated unified version: version={new_version}, build={new_build}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
