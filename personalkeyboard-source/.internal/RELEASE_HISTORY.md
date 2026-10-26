# RELEASE_HISTORY (internal)

Consolidated 2026-10-26 after owner requested: delete all GitHub Releases, keep one app release with full notes, remove workflows.

- First IPA artifact: Actions 2026-10-25T12:34 (id 12598814462)
- Latest IPA: main after #31/#33/#32
- Old build-* tags retained (tag-immutability ruleset — no delete bypass)
- Workflows: removed from tree by agent PR

## Workflows
All `.github/workflows/*` removed on owner request (2026-10-26).
CI no longer auto-builds IPA. Rebuild locally with xcodegen + xcodebuild if needed.
