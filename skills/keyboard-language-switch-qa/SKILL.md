---
name: keyboard-language-switch-qa
description: Audit Arabic/English transition contracts: primaryLanguage, shared toggle, coalesced rebuild, UITextChecker reuse when suggestions exist, else none. Use when language switch feels broken.
---

# Keyboard language switch QA

```bash
python3 skills/keyboard-language-switch-qa/scripts/audit_language_switch.py personalkeyboard-source --strict
```

Static contracts only. Does not prove device stability or Jetsam.
