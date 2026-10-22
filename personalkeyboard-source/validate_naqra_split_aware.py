#!/usr/bin/env python3
from pathlib import Path
import sys
root = Path(sys.argv[1] if len(sys.argv)>1 else 'Sources/KeyboardExtension')
files = list(root.rglob('*.swift'))
text = '\n'.join(p.read_text() for p in files)
res = root / 'Resources' if (root / 'Resources').exists() else root.parent / 'KeyboardExtension' / 'Resources'
checks = [
    ('App Group', 'group.app.personal.PersonalKeyboard' in text),
    ('KeyboardViewController', 'class KeyboardViewController' in text),
    ('split extensions', any(p.name.startswith('KeyboardViewController+') for p in files)),
    ('DataLoader', 'KeyboardDataLoader' in text),
    ('no giant emoji literal', '😀 😃 😄 😁 😆 😅 😂 🤣 😊 😇 🙂 😉' not in text),
    ('layouts json', (root/'Resources'/'keyboard_layouts.json').exists() or (Path('Sources/KeyboardExtension/Resources/keyboard_layouts.json')).exists()),
    ('emoji json', any(p.name=='emoji_catalog.json' for p in Path(root).rglob('*.json')) or Path('Sources/KeyboardExtension/Resources/emoji_catalog.json').exists()),
]
# resolve relative to cwd personalkeyboard-source
import os
os.chdir(Path(__file__).resolve().parent if Path(__file__).name.endswith('.py') else Path.cwd())
base = Path(__file__).resolve().parent if '__file__' in dir() else Path.cwd()
# simpler re-check json from known path
checks = [
    ('App Group', 'group.app.personal.PersonalKeyboard' in text),
    ('KeyboardViewController', 'class KeyboardViewController' in text),
    ('split extensions', any(p.name.startswith('KeyboardViewController+') for p in files)),
    ('DataLoader', 'KeyboardDataLoader' in text),
    ('no giant emoji literal', '😀 😃 😄 😁 😆 😅 😂 🤣 😊 😇' not in text),
    ('layouts json', Path('Sources/KeyboardExtension/Resources/keyboard_layouts.json').exists()),
    ('emoji json', Path('Sources/KeyboardExtension/Resources/emoji_catalog.json').exists()),
    ('lexicon json', Path('Sources/KeyboardExtension/Resources/arabic_lexicon.json').exists()),
    ('App slim', Path('Sources/ContainerApp/KeyboardPrototypeApp.swift').exists() and Path('Sources/ContainerApp/KeyboardPrototypeApp.swift').read_text().count('\n') < 40),
    ('no App godfile types', 'enum NaqraColors' not in Path('Sources/ContainerApp/KeyboardPrototypeApp.swift').read_text()),
]
ok=True
for n,p in checks:
    print(('PASS' if p else 'FAIL')+': '+n); ok = ok and p
print('swift files in ext:', len(files))
sys.exit(0 if ok else 1)
