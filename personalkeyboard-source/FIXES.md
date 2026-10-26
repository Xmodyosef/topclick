# إصلاحات جولة 1 (2026-10-16)

1. صفحة الرموز: قراءة symbolRows من نص/رقم بشكل صحيح → تظهر 3–4 صفوف
2. فراغ تحت الأزرار: rootStack مربوط أعلى وأسفل
3. ارتفاع موحّد: letters/emoji 300، symbols 280 (أقل قفز عند الإيموجي)
4. Shift للعربي مفعّل
5. تخطيط عربي أوضح للصف 2 و 3
6. رموز موسّعة (صف رابع اختياري)
7. تصحيح تلقائي يقرأ من ThemeIO.bool
8. اقتراحات تقرأ من ThemeIO.bool
9. عرض المسافة >= 200

الهوية لم تُلمس:
- group.app.personal.PersonalKeyboard
- PRODUCT_NAME PersonalKeyboard
- Bundle IDs كما هي


## agent/fix-task — 16-point batch (2026-10-25)

1. Unified special-key color (accent) with optional 6 slots (shift/lang/enter/delete/emoji/symbols)
2. Themes/sounds prefer in-app UserDefaults.standard then App Group
3–4. Live theme canvas + tile preview; unified action keys in preview
5–7. Sound library (system/creamy/thocky/soft/typewriter) in Settings + Themes
8. Number row toggle in Themes
9. Morning cream/icon notes
10–11/15. Faces row under symbols; expanded emoji/hold for Arabic
12–13. Arabic Shift removed; diacritics/forms/numbers via long-press hold_map
14. Hold popup background near keyboard palette
16. Board height remains 324; top inset 10pt for denser layout
