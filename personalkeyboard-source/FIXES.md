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

## skills-pass (agentic-eval + a11y + swift review) 2026-10-25

- Arabic layout never switches to arabicShiftRows (Shift removed for real)
- Symbols pack: 3 content rows + faces row visible under symbols (#11)
- VoiceOver labels/hints on letter keys; language announcement
- paint() sets isAccessibilityElement + .button trait
- Special-key 6-slot UI in Themes (presets)
- validate: نوع الصوت + top inset 12

## 0.2.4 — 2026-10-27

- Arabic symbols page: same solid 4×10 layout as English (no invisible diacritic row)
- Diacritics/tanween via long-press only (hold_map)
- Symbols key label unified to `#+=`
- Version marketing 0.2.4 / build 20

## Point #11 restore (2026-10-27)

- Symbols: 3 solid rows + faces row last (Arabic + English)
- No blank diacritic keys; tanween stays on long-press
- packedSymbolRows re-appends faces after solid content

## جولة 2026-10-27 — إصلاح شامل للوحة

1. الهولد (الضغط المطوّل) العربي مكتمل: ي←ى، و، ة، ء، وأرقام (٩→٠).
2. الرموز: 4 صفوف رموز عالمية بنفس الطول 10 — بدون صف إيموجي داخل الرموز.
3. زر الرموز أيقونة `textformat.123` بدون نص #+=.
4. الصوت: AVAudioSession `.ambient` بدل `.playback`.
5. الإيموجي: لا يمسح الكاش في كل فتحة.
6. الإصدار موحّد: 0.2.6 (build 26).
7. صف الشيفت العربي يبقى 9 مفاتيح (١–٩) و٠ عبر الهولد على ٩ ليتوافق مع عرض صف الحروف.

## جولة 2026-10-27b — أرقام عربية + صفر ظاهر

1. صف الأرقام يتبع اللغة: عربي = ١٢٣٤٥٦٧٨٩٠ (الصفر ظاهر مباشرة).
2. الهولد على ي يبدأ بـ ى (ياء بلا نقاط).
3. الإصدار 0.2.7 (build 27).

## جولة 2026-10-27c — إنهاء الباقي
1. TranslationPrepCard مربوط في Settings (iOS 18+).
2. README + CHANGELOG يطابقان v0.2.7.

## 0.2.8 (build 28)
- TranslationPrepCard في Settings
- README/CHANGELOG محدّثان
- إصدار موحّد 0.2.8 / 28
