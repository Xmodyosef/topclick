# Skills Index

يتكون نظام المهارات من **7 حزم نشطة**. لا يوجد `bundle-XX.md`. الحزم 5–7 سكربتات Python فقط (ليست وثائق).

- **Active skill files:** 7
- **Integrated bundle files:** 0
- **Resource archives:** 1
- **Visible files inside `skills/`:** 14

> اقرأ `SKILL.md` قبل أي تعديل. أرشيف الموارد فقط في `keyboard-extension/resources.tar.gz`.

## الحزم

1. [`keyboard-extension`](skills/keyboard-extension/SKILL.md) — لوحة/إيموجي/صوت/App Groups (مرجع تشغيل).
2. [`ios-keyboard-release-gate`](skills/ios-keyboard-release-gate/SKILL.md) — عقود الإصدار والحزمة.
3. [`skill-routing-integrity`](skills/skill-routing-integrity/SKILL.md) — سلامة الفهرس والعدادات.
4. [`iphone-keyboard-accessibility-qa`](skills/iphone-keyboard-accessibility-qa/SKILL.md) — فحص a11y ساكن.
5. [`keyboard-language-switch-qa`](skills/keyboard-language-switch-qa/SKILL.md) — `primaryLanguage` + مسار rebuild مؤجّل + UITextChecker.
6. [`keyboard-audio-integrity`](skills/keyboard-audio-integrity/SKILL.md) — CAF/PCM + ربط المحرك + مدة النقرة + حد الطابور.
7. [`keyboard-jetsam-forensics`](skills/keyboard-jetsam-forensics/SKILL.md) — تحليل JetsamEvent؛ `rpages` صفحات لا MiB بدون page size.

## CI

- `agent-guard.yml` يشغّل تدقيقات إعلامية ثم **strict** للغة والصوت على **شجرة الـ PR الحالية** (لا فروع مرشحة ثابتة).
- `pytest` يغطي محللات CAF/Jetsam/اللغة بملفات اصطناعية.
- Jetsam الحقيقي = ملف من الجهاز؛ لا يُرفع لـ git.
- نجاح ساكن ≠ صوت/VoiceOver/ثبات على iPhone.
- **FROZEN SURFACE** و`group.Mark1` = `AGENTS.md` §15–17؛ ليست مهارة skills/.

## سياسة الدمج

لا تضف حزمة بلا سكربت تنفيذي. لا حزمة مستقلة لموضوع فرعي يمكن ضمه لحزمة قائمة. حدّث العداد هنا وفي `agent-guard` معاً.
