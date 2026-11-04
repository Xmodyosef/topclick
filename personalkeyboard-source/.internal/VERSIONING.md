# Versioning

## Public and internal version fields

- `MARKETING_VERSION` / `CFBundleShortVersionString`: exactly three numeric components (for example `0.2.9`).
- `CURRENT_PROJECT_VERSION` / `CFBundleVersion`: integer build number; increment by one on every release and never reset it.
- `ROLLING_VERSION`: internal four-component value. Its first three components must equal `MARKETING_VERSION`; its last component is 1–20.
- When the rolling component reaches 20, increment the marketing patch component and reset the rolling component to 1. The build number continues increasing independently.
- Both app and extension must use identical marketing and build values.
- Run `python3 scripts/bump_version.py --check` before a release. Run the script without `--check` to advance the version set atomically.
- Release tags use the three-component marketing version (for example `v0.2.9`), not the internal rolling value.

## Current version

- Marketing: **0.2.9**
- Build: **31**
- Rolling: **0.2.9.1**
