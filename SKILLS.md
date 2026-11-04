# Skills Index

يتكون نظام المهارات من **4 حزم نشطة** و**1 ملفًا مرجعيًا مدمجًا**. تجمع الحزم العامة موضوعات متقاربة، وتضيف الحزم المتخصصة بوابات تحقق مستقلة عند الحاجة.

- **Active skill files:** 4
- **Integrated bundle files:** 1
- **Resource archives:** 1
- **Visible files inside `skills/`:** 9

> اقرأ `SKILL.md` للحزمة، ثم افتح `bundle-XX.md` المناسب فقط. الموارد التنفيذية والقوالب محفوظة في `resources.tar.gz` ولا تحتاج فكها إلا عند الحاجة.

## الحزم

1. [`keyboard-extension`](skills/keyboard-extension/SKILL.md) — لوحة المفاتيح والإيموجي والصوت وApp Groups.
2. [`ios-keyboard-release-gate`](skills/ios-keyboard-release-gate/SKILL.md) — تحقق إصدار تطبيق لوحة المفاتيح وامتدادها ومواردها.
3. [`skill-routing-integrity`](skills/skill-routing-integrity/SKILL.md) — سلامة فهرس المهارات ومسارات الحزم.
4. [`iphone-keyboard-accessibility-qa`](skills/iphone-keyboard-accessibility-qa/SKILL.md) — تدقيق VoiceOver وإتاحة لوحة iPhone.

## سياسة الدمج

المحتوى النصي محفوظ داخل الحزم `bundle-XX.md`، والموارد غير النصية أو القابلة للتنفيذ محفوظة داخل أرشيف الحزمة. لا تضف حزمة مستقلة لموضوع فرعي يمكن استيعابه في حزمة قائمة؛ أنشئ حزمة متخصصة فقط إذا كان لها محفز وسير عمل وفحوص تنفيذية مستقلة.
