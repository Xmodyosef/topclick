# Naqra Lessons Learned

## 2026-10-29 — Skill reorganization

- Git rename detection can report thousands of conflicts when a flat skill tree is moved into bundles. Resolve only after confirming that changes are limited to `skills/`, `AGENTS.md`, and `SKILLS.md`.
- At the time of the 2026-10-29 reorganization, the repository used 8 active skill packs, 50 integrated bundles, and 8 resource archives. New rules must point to `references/bundle-XX.md`, not the removed `references/source/` path.
- A clean CI result proves source and packaging checks only. It does not prove signing, installation, audio hardware, or long-session stability on an iPhone.
- Never rely on the PR page alone for a fresh head SHA; verify with the GitHub API and `git ls-remote`.
- Pass Markdown-rich PR bodies through a quoted file (`gh pr create --body-file ...`) so shell backticks cannot trigger command substitution and silently remove code references.
- 2026-11-19: Owner locked FROZEN SURFACE (layouts/emoji/hold/themes) + group.Mark1; releases require sequential numbers and post-device owner opinion before GitHub Release (AGENTS v1.7).

## 2026-11-19 — CI IPA path filter expansion

- `paths-ignore` only skips IPA when **every** changed file is ignored; touching `agent-guard.yml` or `tests/**` used to force a full macOS build.
- Expanded ignore/stamp lists cover skills, docs, agent-guard, security-review, tests, gitignore; app source and build-ipa.yml still force IPA.
