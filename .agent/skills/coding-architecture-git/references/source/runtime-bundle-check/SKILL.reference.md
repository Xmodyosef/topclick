---
name: runtime-bundle-check
description: Verify every resource file (JSON, PNG, plist) is actually present inside the built IPA or app bundle before claiming a release is ready. Use before any release, after any Resources change, or when runtime data appears missing on device.
---

# Runtime Bundle Check

## Why

Static analysis and project.yml inclusion do not guarantee a file survives the build. A missing emoji_catalog.json or a PNG that did not copy produces silent empty grids and blank icons on a real device. This skill catches that before the user does.

## Procedure

1. Build the unsigned IPA (or .app) locally or via CI.
2. Unzip or expand the payload.
3. For every file listed in Resources directories and project.yml resources, assert it exists inside the bundle at the expected path.
4. For every JSON: parse it. Empty object, truncated file, or invalid UTF-8 = fail.
5. For every PNG: decode dimensions. Zero-byte or corrupt = fail.
6. Diff the bundle file list against the source Resources tree. Any source file absent from the bundle = hard fail.
7. Report a table: file, expected, found, size, status.

## Gate

Release cannot be tagged until this check is green. No exceptions for tiredness or rush.

## Common misses

- JSON in Resources but excluded by a .gitignore pattern that also matched the copy phase.
- Asset catalog images referenced by name but the imageset folder missing from the target.
- Large PNGs silently stripped by an over-aggressive thinning step.
- Info.plist keys present in source but the built plist differs after processing.
