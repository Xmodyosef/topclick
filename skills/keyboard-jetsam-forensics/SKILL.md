---
name: keyboard-jetsam-forensics
description: Parse JetsamEvent JSON/text for KeyboardExtension rpages and kill reason without inventing MiB. Use after extension death or silent switch to system keyboard.
---

# Keyboard Jetsam forensics

```bash
python3 skills/keyboard-jetsam-forensics/scripts/analyze_jetsam.py path/to/JetsamEvent.json --target KeyboardExtension
```

Requires an owner-provided log. Never commit personal Jetsam logs.
