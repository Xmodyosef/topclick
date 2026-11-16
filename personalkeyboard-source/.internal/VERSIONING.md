# Versioning — single release identity

## Source of truth

- `VERSION` is the only source of truth for the public three-part release version (SemVer), currently `0.2.10`.
- `MARKETING_VERSION` is generated into both app and keyboard-extension targets from `VERSION` by `scripts/bump_version.py`.
- `CFBundleShortVersionString` in both Info.plists uses `$(MARKETING_VERSION)`; `CFBundleVersion` uses `$(CURRENT_PROJECT_VERSION)`.
- `CURRENT_PROJECT_VERSION` is a separate, monotonically increasing integer build identifier; it is not a second product version. Both targets must have the same value.
- The four-part `ROLLING_VERSION` is retired. It must not appear in project settings, artifact names, or release instructions.

## Release naming contract

- Git tag: `v<VERSION>` (current target: `v0.2.10`).
- IPA: `PersonalKeyboard-<VERSION>.ipa` (current target: `PersonalKeyboard-0.2.10.ipa`).
- Release title and changelog heading use the same `VERSION` value.
- Never create a tag or Release until the corresponding PR has passed CI and the built IPA has been inspected.

## Current source version

- Version: **0.2.10**
- Build: **32**
- App + extension: same version and build.

## Commands

- Validate: `python3 scripts/bump_version.py --check`.
- Set the next public version: `python3 scripts/bump_version.py --set-version 0.2.11`.
- Increment build for a new build: `python3 scripts/bump_version.py --bump-build`.
- Set version and increment build together: `python3 scripts/bump_version.py --set-version 0.2.11 --bump-build`.
