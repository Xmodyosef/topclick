# Naqra Lessons Learned

## 2026-10-29 — Skill reorganization

- Git rename detection can report thousands of conflicts when a flat skill tree is moved into bundles. Resolve only after confirming that changes are limited to `.agent/skills/`, `AGENTS.md`, and `SKILLS.md`.
- The repository currently uses 8 active skill packs, 50 integrated bundles, and 8 resource archives. New rules must point to `references/bundle-XX.md`, not the removed `references/source/` path.
- A clean CI result proves source and packaging checks only. It does not prove signing, installation, audio hardware, or long-session stability on an iPhone.
- Never rely on the PR page alone for a fresh head SHA; verify with the GitHub API and `git ls-remote`.
