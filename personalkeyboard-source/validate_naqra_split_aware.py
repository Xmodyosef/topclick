#!/usr/bin/env python3
from pathlib import Path
import sys
root = Path(sys.argv[1] if len(sys.argv)>1 else 'KeyboardExtension')
files = list(root.rglob('*.swift'))
text = '\n'.join(p.read_text() for p in files)
checks = [
    ('App Group', 'group.app.personal.PersonalKeyboard' in text),
    ('Arabic shift', 'arabicShiftRows' in text),
    ('boardHeight', 'boardHeight' in text),
    ('ThemeIO', 'enum ThemeIO' in text),
    ('emojiPager', 'emojiPager' in text),
    ('hasFullAccess', 'hasFullAccess' in text),
    ('KeyboardViewController', 'class KeyboardViewController' in text),
    ('split extensions', any(p.name.startswith('KeyboardViewController+') for p in files)),
    ('rebuild', 'func rebuild' in text),
]
ok=True
for n,p in checks:
    print(('PASS' if p else 'FAIL')+': '+n); ok = ok and p
print('swift files:', len(files))
sys.exit(0 if ok else 1)
