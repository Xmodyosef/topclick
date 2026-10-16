# Status Round 2 — Honest Audit

Checked live repo at commit d9c7307 (2026-10-16).

## Already on the keyboard (KeyboardViewController.swift)
- [x] Globe button removed (no globe / advanceToNextInputMode in extension)
- [x] arabicShiftRows removed — Arabic layout is fixed rows
- [x] TimeTheme auto (morning 6-18 / evening) when no saved theme
- [x] loadPreparedTheme() — extension reads theme from App Group only
- [x] playSystemSound: main thread + respects sounds toggle + enableInputClicksWhenVisible
- [x] Suggestions row moved into toolbar (between copy/paste and translate)
- [x] Autocorrect triggers at 2+ chars (was 2, now also runs when token not a known word)
- [x] Emoji catalog: frequent first, faces second, flags later
- [x] showNumberRow toggle exists in settings

## Still missing
- [ ] MiniKeyboardView in the APP still shows a globe button (app preview only, not the real keyboard)
- [ ] ThemesTab: plain grid, no sections (core/morning/evening), no live keyboard preview
- [ ] SettingsTab: no Full Access button (openSettingsURLString not present)
- [ ] KeyboardViewController tail (~69KB) not fully verified: holdMap, symbolRows, emoji spacing, duplicate و/ؤ/ئ layout
- [ ] Extension TapSoundEngine: AVAudioEngine tones; needs full access to be reliable; system click fallback exists
- [ ] App TapSoundEngine vs Extension TapSoundEngine are two different implementations (different Sound enums) — should be unified

## Next actions
1. Push MiniKeyboardView fix (remove globe) + ThemesTab sections + live preview + Full Access button
2. Verify KeyboardViewController tail for holdMap / symbolRows / emoji spacing
3. Unify the two TapSoundEngine files
4. Build IPA via Actions and test on device
