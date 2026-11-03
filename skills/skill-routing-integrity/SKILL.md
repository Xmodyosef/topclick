---
name: skill-routing-integrity
description: Validate agent skill indexes, skill manifests, bundle references, and project routing rules. Use when adding, moving, renaming, or auditing AI skills in this repository.
---

# تدقيق توجيه المهارات

استخدم هذه المهارة عند تعديل فهرس المهارات أو نقل حزمة أو إضافة مهارة جديدة.

## الخطوات

1. من جذر المستودع شغّل `python3 skills/skill-routing-integrity/scripts/verify_skill_links.py --root .` ثم `python3 skills/skill-routing-integrity/scripts/verify_markdown_links.py --root . --no-network` للتحقق من جميع ملفات Markdown والروابط المحلية والمراسي.
2. أصلح الروابط المكسورة أو أرقام الحزم والمجاميع غير المطابقة في `SKILLS.md` و`AGENTS.md` قبل فتح PR.
3. افتح كل `SKILL.md` المتأثر وتأكد أن وصفه يحدد محفزًا واضحًا وأن المسارات تطابق الملفات الموجودة.
4. اجعل تغييرات المهارات منفصلة عن تغييرات Swift/Plist/Entitlements وفق سياسة المستودع.

## التحقق

يفحص المدقق الأول الفهرس والحزم والمجاميع والتوجيه؛ ويفحص الثاني كل ملفات Markdown، والروابط النسبية والمراسي، ويصنف المسارات المفقودة والمنقولة والروابط الخارجية غير القابلة للتحقق أو المعاد توجيهها. استخدم الفحص الشبكي الافتراضي للروابط الخارجية في بيئة CI موثوقة، أو `--no-network` للاختبارات الحتمية. لا يثبت أي منهما أن الوكيل قرأ المهارة بالفعل؛ إثبات الاستخدام يتطلب توجيهًا تشغيليًا أو سجلات تنفيذ منفصلة.
