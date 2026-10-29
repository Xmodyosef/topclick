# iOS Keyboard Rules

- Treat `personalkeyboard-source/AGENTS.md` as the local authority for keyboard work.
- Preserve Arabic 11/11/9 layout behavior, long-press alternatives, emoji safety, App Group synchronization, and keyboard-extension memory limits.
- Validate both Container App and Keyboard Extension bundle identifiers and entitlements.
- Never claim sound, signing, Feather, ESign, or long-session stability without device evidence.
- Use safe teardown and index guards for emoji and page transitions.
- Avoid heavyweight rendering, audio engines, timers, or repeated full view reconstruction in the extension unless measured and justified.
