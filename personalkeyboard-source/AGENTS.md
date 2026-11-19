# Keyboard Source Rules

- Read root `AGENTS.md` (v1.7+) first — **FROZEN SURFACE §17** and **`group.Mark1`** bind this tree.
- **Do not** reorder Arabic 11/11/9, English rows, symbols pages, emoji layout, long-press maps, or theme storage without owner unfreeze.
- App Group live name: **`group.Mark1` only**. Theme key: `naqra.themeId`. Never invent another group for themes.
- Default work: stability/power fixes only (lifecycle, audio configure-on-appear, memory, CI). Not visual redesign.
- Releases: sequential marketing versions + owner device opinion before GitHub Release/Tag.
- Treat App Groups, Info.plist, entitlements, `project.yml`, and shared settings as one connected feature.
- Inspect lifecycle on every state change: first load, language switch, theme switch, emoji page, background/foreground, keyboard re-entry.
- Prefer system defaults and bounded work in the extension. Automated CI ≠ device proof (Feather/ESign).
