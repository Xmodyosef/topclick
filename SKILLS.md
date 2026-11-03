# Skills Index

يتكون نظام المهارات من **11 حزمة نشطة** و**50 ملفًا مرجعيًا مدمجًا**. تجمع الحزم العامة موضوعات متقاربة، وتضيف الحزم المتخصصة بوابات تحقق مستقلة عند الحاجة.

- **Active skill files:** 11
- **Integrated bundle files:** 50
- **Resource archives:** 8
- **Visible files inside `skills/`:** 74

> اقرأ `SKILL.md` للحزمة، ثم افتح `bundle-XX.md` المناسب فقط. الموارد التنفيذية والقوالب محفوظة في `resources.tar.gz` ولا تحتاج فكها إلا عند الحاجة.

## الحزم

1. [`ios-swift-platform`](skills/ios-swift-platform/SKILL.md) — Swift وSwiftUI وUIKit ومنصات Apple.
2. [`keyboard-extension`](skills/keyboard-extension/SKILL.md) — لوحة المفاتيح والإيموجي والصوت وApp Groups.
3. [`security-auditing`](skills/security-auditing/SKILL.md) — الأمان والخصوصية والتدقيق.
4. [`design-ux-accessibility`](skills/design-ux-accessibility/SKILL.md) — التصميم وUX وAccessibility.
5. [`research-memory`](skills/research-memory/SKILL.md) — البحث والذاكرة والتوثيق.
6. [`coding-architecture-git`](skills/coding-architecture-git/SKILL.md) — البرمجة والهندسة وGit.
7. [`testing-debugging-ci`](skills/testing-debugging-ci/SKILL.md) — الاختبار والتشخيص وCI.
8. [`product-release-growth`](skills/product-release-growth/SKILL.md) — المنتج والنشر والنمو.
9. [`ios-keyboard-release-gate`](skills/ios-keyboard-release-gate/SKILL.md) — تحقق إصدار تطبيق لوحة المفاتيح وامتدادها ومواردها.
10. [`skill-routing-integrity`](skills/skill-routing-integrity/SKILL.md) — سلامة فهرس المهارات ومسارات الحزم.
11. [`iphone-keyboard-accessibility-qa`](skills/iphone-keyboard-accessibility-qa/SKILL.md) — تدقيق VoiceOver وإتاحة لوحة iPhone.

## مسارات تدقيق Naqra المتخصصة

تُضاف ثلاثة مسارات تدقيق متخصصة داخل الحزم القائمة دون إنشاء حزم نشطة إضافية:

- **Keyboard Runtime Performance & Memory Auditor** — `skills/keyboard-extension/references/bundle-01.md`.
- **RTL/LTR Regression Test Generator** — `skills/testing-debugging-ci/references/bundle-01.md`.
- **Clipboard Privacy & Data Integrity Auditor** — `skills/keyboard-extension/references/bundle-01.md`.

## سياسة الدمج

المحتوى النصي محفوظ داخل الحزم `bundle-XX.md`، والموارد غير النصية أو القابلة للتنفيذ محفوظة داخل أرشيف الحزمة. لا تضف حزمة مستقلة لموضوع فرعي يمكن استيعابه في حزمة قائمة؛ أنشئ حزمة متخصصة فقط إذا كان لها محفز وسير عمل وفحوص تنفيذية مستقلة.
