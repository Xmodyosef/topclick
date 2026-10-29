# Release Rules

- Use one monotonically increasing marketing version, for example `0.2.8` → `0.2.9`.
- Increment `CURRENT_PROJECT_VERSION` for every release.
- Build exactly one unsigned IPA for the release.
- Do not delete or replace a Release until the new IPA build and payload checks pass.
- Preserve tags and commits for rollback; only the previous GitHub Release and its assets may be replaced by the approved release workflow.
- Report the version, build number, Actions URL, Release URL, IPA asset URL, and SHA-256.
- Never merge the PR automatically and never push directly to `main`.
