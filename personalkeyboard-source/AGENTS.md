# Keyboard Source Rules

- This subtree contains the Container App and Custom Keyboard Extension.
- Read the root `AGENTS.md`, `SKILLS.md`, and the relevant keyboard bundle before editing.
- Keep Arabic rows aligned with the approved 11/11/9 layout and preserve English layout behavior.
- Treat App Groups, Info.plist, entitlements, project.yml, and shared settings as one connected feature.
- For every UI or state change, inspect lifecycle transitions: first load, language switch, theme switch, emoji page, background/foreground, and keyboard re-entry.
- Prefer system defaults and bounded work in the extension. Do not add unmeasured heavyweight effects.
- Automated CI can validate source and unsigned packaging; only the owner can validate signing and real iPhone behavior through Feather or ESign.
