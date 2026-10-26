# PersonalKeyboard — إصدار موحّد

هذا الإصدار الوحيد بعد تنظيف كل الـ releases السابقة.
يجمع ملاحظات كل الجولات في مكان واحد، ويُرفق:
- **IPA الأول** (أقدم بناء محفوظ من Actions)
- **IPA الأحدث** (main بعد #31 + #33 + #32)

## الهوية (ثابتة)
- App Group: `group.app.personal.PersonalKeyboard`
- Bundle: `app.personal.PersonalKeyboard`
- Extension: `app.personal.PersonalKeyboard.KeyboardExtension`
- PRODUCT_NAME: PersonalKeyboard

## ملخص تاريخي موحّد (من كل الرليز/الجولات)

### جولة 1 — أساس التخطيط
- رموز متعددة الصفوف، فراغ تحت الأزرار، ارتفاع موحّد
- Shift عربي (لاحقًا أُزيل من الواجهة)
- تصحيح تلقائي + اقتراحات من ThemeIO
- مسافة عريضة

### تنظيف الواجهة والإعدادات
- إزالة أزرار ميتة / تبويب معاينة
- أيقونات صباح/مساء
- App Group notes

### إيموجي + ضغط مطوّل + رموز @ 324
- كتالوج إيموجي
- hold_map عربي/إنجليزي
- ارتفاع اللوحة 324

### دفعة 16 نقطة (#31)
1. توحيد لون الأزرار الأساسية + slots اختيارية
2. ثيمات/أصوات داخل التطبيق (standard ثم group)
3–4. معاينة حية + canvas
5–7. مكتبة أصوات (system/creamy/thocky/soft/typewriter)
8. صف أرقام من الثيمات
9. أيقونة صباحية سكري
10–11/15. فيسات تحت الرموز + hold موسّع
12–13. حذف شيفت العربي؛ حركات بضغط مطوّل
14. لون popup قريب من الكيبورد
16. ارتفاع 324 + inset

### skills-pass (#33)
- Arabic layout لا يستخدم arabicShiftRows
- faces ظاهرة تحت الرموز (packedSymbolRows)
- VoiceOver labels/hints + إعلان اللغة
- UI لألوان الأزرار الستة في الثيمات

### validate (#32)
- عنوان Picker «نوع الصوت»
- top inset constant 12

---

## ملاحظة تقنية
- الـ tags القديمة (`build-*`) **محميّة بقواعد المستودع** ولا يمكن حذفها من هنا.
- ملفات workflow حُذفت بطلب المالك (لا بناء Actions تلقائي بعد الدمج).
- السجل المختصر المخفي: `personalkeyboard-source/.internal/RELEASE_HISTORY.md`

## FIXES.md (مرجع كامل)
```
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

```
