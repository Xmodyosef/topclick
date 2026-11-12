# Skills Index

يتكون نظام المهارات من **4 حزم نشطة**. لا يوجد حالياً ملف مرجعي مدمج (`bundle-XX.md`): مرجع نسخ HTML لحافظة الماك أُزيل لأنه لا يخص لوحة iOS. الحزم المتخصصة تبقى بوابات تحقق مستقلة.

- **Active skill files:** 4
- **Integrated bundle files:** 0
- **Resource archives:** 1
- **Visible files inside `skills/`:** 8

> اقرأ `SKILL.md` للحزمة قبل أي تعديل. لا تفتح مرجع `bundle-XX.md` إلا إذا أُضيف لاحقاً وكان يخص iOS. الموارد التنفيذية داخل `resources.tar.gz` لا تُفك إلا عند الحاجة.

## الحزم

1. [`keyboard-extension`](skills/keyboard-extension/SKILL.md) — لوحة المفاتيح والإيموجي والصوت وApp Groups.
2. [`ios-keyboard-release-gate`](skills/ios-keyboard-release-gate/SKILL.md) — تحقق إصدار تطبيق لوحة المفاتيح وامتدادها ومواردها.
3. [`skill-routing-integrity`](skills/skill-routing-integrity/SKILL.md) — سلامة فهرس المهارات ومسارات الحزم.
4. [`iphone-keyboard-accessibility-qa`](skills/iphone-keyboard-accessibility-qa/SKILL.md) — تدقيق VoiceOver وإتاحة لوحة iPhone.

## سياسة الدمج

لا تضف حزمة مستقلة لموضوع فرعي يمكن استيعابه في حزمة قائمة؛ أنشئ حزمة متخصصة فقط إذا كان لها محفز وسير عمل وفحوص تنفيذية مستقلة. أي `bundle-XX.md` جديد يجب أن يخص iOS/لوحة المفاتيح فقط، ويُحدَّث عدّاده هنا.
