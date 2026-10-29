#!/bin/bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

git fetch origin
git checkout main
git pull --ff-only origin main
git checkout -b chore/move-skills-full

# النسخة الناقصة (SKILL.md فقط)
if git ls-files --error-unmatch skills >/dev/null 2>&1 || [ -d skills ]; then
  git rm -r skills 2>/dev/null || rm -rf skills
fi

# النقل الكامل: bundles + tar.gz + SKILL.md
git mv skills skills
rmdir .agent 2>/dev/null || true

# تحديث المسارات في الوثائق والـ CI
python3 - << 'PY'
from pathlib import Path
for p in Path(".").rglob("*"):
    if not p.is_file() or ".git" in p.parts:
        continue
    if p.suffix.lower() in {".png", ".jpg", ".jpeg", ".gz", ".ipa", ".zip", ".webp"}:
        continue
    try:
        t = p.read_text(encoding="utf-8")
    except Exception:
        continue
    if "skills" not in t:
        continue
    p.write_text(t.replace("skills", "skills"), encoding="utf-8")
    print("updated", p)
PY

git add -A
git status
git commit -m "chore: move full skill packs from skills to skills"
git push -u origin chore/move-skills-full

echo ""
echo "تم. افتح Pull Request:"
echo "https://github.com/Xmodyosef/topclick/compare/main...chore/move-skills-full?expand=1"
