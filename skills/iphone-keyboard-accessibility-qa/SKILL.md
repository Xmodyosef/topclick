---
name: iphone-keyboard-accessibility-qa
description: Audit accessibility and VoiceOver behavior in custom iPhone keyboards, including Arabic RTL layouts, system keyboard switching, key labels, and touch targets. Use for keyboard UX reviews and pre-release device testing.
---

# مراجعة إتاحة لوحة مفاتيح iPhone

استخدم هذه المهارة لمراجعة لوحة مفاتيح مخصصة قبل الإصدار، مع فصل نتائج الفحص الساكن عن تجربة الجهاز.

## سير العمل

1. من جذر المستودع شغّل `python3 skills/iphone-keyboard-accessibility-qa/scripts/a11y_static_audit.py personalkeyboard-source`.
2. تعامل مع كل سطر `REVIEW` كمرشح للمراجعة، لا كإثبات أن الزر غير قابل للوصول؛ فقد يُعيَّن اسمه في موضع استدعاء المصنع.
3. على iPhone، فعّل VoiceOver واختبر زر 🌐، تبديل العربية/الإنجليزية، الحروف، Shift، الحذف، المسافة، الرموز والإيموجي.
4. اختبر تكبير النص، RTL، VoiceOver focus order، وأحجام الشاشات الصغيرة، ثم سجّل طراز الجهاز وإصدار iOS والنتيجة.

## حدود الأتمتة

الفحص الساكن لا يشغّل VoiceOver ولا يثبت صحة النطق أو ترتيب التركيز أو حجم الهدف اللمسي. لا تعلن اجتياز الإتاحة دون تجربة فعلية على جهاز.
