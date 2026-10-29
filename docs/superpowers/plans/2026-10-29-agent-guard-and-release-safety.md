# Agent Guard and Release Safety Implementation Plan

> **For agentic workers:** Apply this plan task-by-task and verify every task before committing.

**Goal:** Make Grok and other coding agents follow one strict review, evidence, PR, and release protocol.

**Architecture:** Root `AGENTS.md` remains the shared policy. Grok-specific rules live in `.grok/rules/`; keyboard-specific rules live under `personalkeyboard-source/AGENTS.md`. GitHub Actions enforces scope, skill structure, conflict markers, secret patterns, and release-version consistency.

**Tech Stack:** Markdown, GitHub Actions, Bash, Python, XcodeGen, unsigned IPA build.

**Spec:** User-approved strict review and latest-release-only workflow.

## Global Constraints

- No direct pushes or merges to `main`.
- No claim of completion without fresh verification evidence and links.
- No deletion of Releases or Tags during this change.
- Apple signing remains external through Feather or ESign.
- The repository must retain 8 active skills, 50 integrated bundles, and 8 resource archives.

## Review Focus

- Agent instructions must point to `references/bundle-XX.md`, not removed `references/source/` paths.
- Skill-only PRs must not modify application source.
- Application PRs must not silently restructure skills.
- CI must reject conflict markers, obvious secrets, malformed skill structure, and invalid release versions.
- Reports must distinguish automated validation from iPhone-only validation.

## Tasks

### Task 1: Shared agent policy

- Modify `AGENTS.md` to correct bundle navigation and add evidence, scope, no-auto-merge, and iPhone limitation rules.
- Add `.grok/rules/10-safety.md`, `20-review.md`, `30-ios-keyboard.md`, and `40-release.md`.
- Add `personalkeyboard-source/AGENTS.md` for keyboard-specific constraints.

### Task 2: CI guard

- Add `.github/workflows/agent-guard.yml` for pull requests to `main`.
- Validate active skill counts, bundle counts, archive integrity, conflict markers, obvious secrets, and mixed skill/app scope.
- Publish a review summary and upload the report as an artifact.

### Task 3: Release safety

- Add `.github/workflows/release-latest-only.yml` as a manual release workflow.
- Derive the marketing version from `project.yml`, build one unsigned IPA, validate its payload, then replace the prior Release only after successful build.
- Preserve Git tags and commits; do not execute the workflow during this change.

### Task 4: Verification

- Run repository checks, YAML syntax checks where available, skill-count checks, archive tests, and `git diff --check`.
- Commit and push to the existing PR branch without merging.
