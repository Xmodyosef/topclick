---
name: skill-routing-integrity
description: Validate agent skill indexes, skill manifests, bundle references, and project routing rules. Use when adding, moving, renaming, or auditing AI skills in this repository.
---

# تدقيق توجيه المهارات

استخدم هذه المهارة عند تعديل فهرس المهارات أو نقل حزمة أو إضافة مهارة جديدة.

## الخطوات

1. من جذر المستودع شغّل `python3 skills/skill-routing-integrity/scripts/verify_skill_links.py --root .`.
2. أصلح الروابط المكسورة أو أرقام الحزم والمجاميع غير المطابقة في `SKILLS.md` و`AGENTS.md` قبل فتح PR.
3. افتح كل `SKILL.md` المتأثر وتأكد أن وصفه يحدد محفزًا واضحًا وأن المسارات تطابق الملفات الموجودة.
4. اجعل تغييرات المهارات منفصلة عن تغييرات Swift/Plist/Entitlements وفق سياسة المستودع.

## التحقق

السكربت يفحص الفهرس ومسارات Markdown وأسماء الحزم والمجاميع. لا يثبت أن الوكيل قرأ المهارة بالفعل؛ إثبات الاستخدام يتطلب توجيهًا تشغيليًا أو سجلات تنفيذ منفصلة.
