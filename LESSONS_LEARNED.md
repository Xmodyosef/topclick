# Naqra Lessons Learned

## 2026-10-29 — Skill reorganization

- Git rename detection can report thousands of conflicts when a flat skill tree is moved into bundles. Resolve only after confirming that changes are limited to `skills/`, `AGENTS.md`, and `SKILLS.md`.
- At the time of the 2026-10-29 reorganization, the repository used 8 active skill packs, 50 integrated bundles, and 8 resource archives. New rules must point to `references/bundle-XX.md`, not the removed `references/source/` path.
- A clean CI result proves source and packaging checks only. It does not prove signing, installation, audio hardware, or long-session stability on an iPhone.
- Never rely on the PR page alone for a fresh head SHA; verify with the GitHub API and `git ls-remote`.
- Pass Markdown-rich PR bodies through a quoted file (`gh pr create --body-file ...`) so shell backticks cannot trigger command substitution and silently remove code references.
- 2026-11-19: Owner locked FROZEN SURFACE (layouts/emoji/hold/themes) + group.Mark1; releases require sequential numbers and post-device owner opinion before GitHub Release (AGENTS v1.7).

## 2026-11-19 — Skill suite hardened for merge

- Do not pin agent-guard strict checks to a long-lived feature branch (e.g. merged PR #139); always audit the PR tree itself.
- CAF LPCM: CAF mFormatFlags bit0=float bit1=little-endian — not the wider ASBD flag set (Apple CAF + community parsers).
- System-sound clicks should stay short; Apple documents AudioServicesPlaySystemSound for ≤30s linear PCM/IMA4 in caf/aif/wav; Signal-iOS caches SystemSoundID similarly to our engine.
- Jetsam: keep rpages as pages unless page size is known for that report; phys_footprint patterns appear in public keyboard metrics code (dictus-ios / fcitx5-ios docs) but remain device-side.
- No talk-only skill packs; freeze policy lives in AGENTS §17, not a new script pack.

## 2026-11-19 — CI IPA path filter expansion

- `paths-ignore` only skips IPA when **every** changed file is ignored; touching `agent-guard.yml` or `tests/**` used to force a full macOS build.
- Expanded ignore/stamp lists cover skills, docs, agent-guard, security-review, tests, gitignore; app source and build-ipa.yml still force IPA.

## 2026-11-19 — Release 0.2.11 version lock

- Run `python3 personalkeyboard-source/scripts/bump_version.py --check` before every IPA.
- Tag = `v{MARKETING_VERSION}`; asset = `PersonalKeyboard-{version}.ipa` only (no older IPAs on the Release).
- Release PRs must not mix skills/ with app sources (agent-guard); land skills first, then version PR.
