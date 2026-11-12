# Naqra Lessons Learned

## 2026-10-29 — Skill reorganization

- Git rename detection can report thousands of conflicts when a flat skill tree is moved into bundles. Resolve only after confirming that changes are limited to `skills/`, `AGENTS.md`, and `SKILLS.md`.
- At the time of the 2026-10-29 reorganization, the repository used 8 active skill packs, 50 integrated bundles, and 8 resource archives. New rules must point to `references/bundle-XX.md`, not the removed `references/source/` path.
- A clean CI result proves source and packaging checks only. It does not prove signing, installation, audio hardware, or long-session stability on an iPhone.
- Never rely on the PR page alone for a fresh head SHA; verify with the GitHub API and `git ls-remote`.
- Pass Markdown-rich PR bodies through a quoted file (`gh pr create --body-file ...`) so shell backticks cannot trigger command substitution and silently remove code references.

## 2026-11-12 — UI polish bottom / emoji pan / space trackpad
- Space trackpad: use language-based writingDirectionSign, not a blind delta flip (AR vs EN).
- Emoji category swipe: interactive transform on single host + reload only on pan ended; never multi-CV.
- Symbol titles (؟+#): AttributedTitle + baseWritingDirection LTR; semanticContentAttribute alone is not enough.
- Prefer unified ABC over «حروف» on narrow bottom keys (bidi + width).
