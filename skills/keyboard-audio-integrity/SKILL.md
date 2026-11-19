---
name: keyboard-audio-integrity
description: Validate CAF assets, PCM flags, TapSoundEngine AudioServices contracts, project.yml registration, and optional built appex sounds. Use when debugging keyboard clicks or sound packs.
---

# Keyboard audio integrity

Executable only: `scripts/validate_keyboard_audio.py`.

```bash
python3 skills/keyboard-audio-integrity/scripts/validate_keyboard_audio.py personalkeyboard-source
python3 skills/keyboard-audio-integrity/scripts/validate_keyboard_audio.py personalkeyboard-source --strict
```

Checks: CAF header/chunks, PCM flags, duration ≤30s (Apple AudioServices), sample→engine map, no AVAudioEngine path, dispose + pending queue + configure(), project.yml paths.

Does **not** prove audible playback on iPhone.
