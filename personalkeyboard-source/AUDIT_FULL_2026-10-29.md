# فحص شامل للوحة نقرة — 2026-10-29
**الإصدار:** 0.2.8.1 (build 30) · **main SHA:** 4c47c635f3  
**الموصلات:** GitHub · Parallel Search · Exa · Firecrawl · Context7 (UIKit resolve) · clone محلي + validate_naqra

---

## 0) خلاصة تنفيذية

| المحور | الحكم |
|--------|--------|
| البناء / الإصدار | سليم — v0.2.8.1 + IPA unsigned + release |
| Hold حرف ل | **مُصلَح** — `لا/لأ/لإ/لآ/ڵ/ّ` |
| App Group suite-first | **مُصلَح** في ThemeIO / ThemeStore / PackStores |
| validate_naqra | **PASS** كل البنود |
| مخاطر P0 المتبقية | **لا P0 وظيفي مفتوح** بعد #62–#64 |
| مخاطر P1 | ذاكرة + rebuild + صوت AVAudioEngine + arabic_shift ميت + hold popup multi-char delete واحد |
| مخاطر P2 | holdDelay UI ناقص · SharedKeyboardData غير مستخدم بالكامل · validate ضعيف |

**الحكم العام:** اللوحة جاهزة للاستخدام اليومي بعد إصلاحات 0.2.8.1، لكن ما زال فيها **ديون تقنية** (أداء ذاكرة، طبقة shift ميتة، صوت ثقيل، سكربت تحقق سطحي) تستحق جولة تنظيف قبل 0.3.

---

## 1) خريطة المكوّنات (ما يُفحص)

### Keyboard Extension
- `KeyboardViewController.swift` + 7 extensions (BuildUI, Hold, Input, Actions, Clipboard, Emoji, Paint)
- `KeyboardDataLoader` · `ThemeIO` · `TapSoundEngine` · `NaqraPalette` · `ClipboardHistory` · `TranslationBridge`
- Resources: `keyboard_layouts.json` · `emoji_catalog.json` · `arabic_lexicon.json`

### Container App
- Settings / Themes / PackStores / ThemeModels / TranslationPrepCard

### مشترك
- `SharedKeyboardData.swift` (مربوط في project.yml لكلا الهدفين)
- App Group: `group.app.personal.PersonalKeyboard`
- Darwin notify: `app.personal.PersonalKeyboard.prefs`

---

## 2) ما يعمل بشكل صحيح (تأكيد من الكود + الموصلين)

1. **Hold ل (P0 السابق)** — JSON + fallback في DataLoader يحتوي لا/لأ/لإ/لآ.
2. **suite-first** — القراءة/الكتابة تفضّل App Group ثم standard (متوافق مع Apple UserDefaults suite + ملاحظات Exa/SO عن Full Access).
3. **Darwin prefs** — `listenPrefs` + إعادة قراءة في `viewWillAppear` (يحمي من missed notify أثناء تعليق الامتداد).
4. **Full Access gating** — نسخ/لصق/حافظة/ترجمة تعرض notice عربي بدل صمت (مبدأ Apple + Douhouse).
5. **RequestsOpenAccess = true** في Info.plist.
6. **Shift إنجليزي in-place** عبر `applyShiftSurface` بدون rebuild كامل عند نجاح المسار.
7. **عربي بدون arabicShift كوضع لوحة** — `activeLetterLayout` يعيد `arabicRows` فقط؛ الحركات عبر hold.
8. **JSON layouts lazy + NSLock** في DataLoader.
9. **Emoji cache** لا يُفرَّغ كل فتحة.
10. **validate_naqra** PASS (هيكل أساسي).

---

## 3) المشاكل المتبقية (مرتّبة)

### P1 — مهم (يُفضَّل إصلاحه قبل 0.3)

#### P1-1 · `rebuild()` كامل شائع (أداء / ذاكرة)
**الموقع:** `KeyboardViewController+BuildUI.swift` · يُستدعى من ~11 موقع (لغة، رموز، إيموجي، ثيم Darwin، viewWillAppear، …).  
**السلوك:** يفرّغ `rootStack` ويعيد إنشاء كل المفاتيح + toolbar + bottom.  
**لماذا خطر (Firecrawl/Douhouse/Apple):** سقف ذاكرة الامتداد ~40–70MB؛ jetsam يقتل بصمت. `UIInputViewController` لا يحرّر view بسهولة؛ إعادة بناء كاملة + طبقات ظل/أزرار تزيد dirty heap.  
**التوصية:**
- in-place update للثيم (paint فقط) بدل rebuild عند تغيّر لون فقط.
- فصل `rebuildLetters` / `rebuildSymbols` / `rebuildEmoji`.
- في `deinit`: تفريغ view مؤجّل (نمط Douhouse) لتقليل تراكم views عبر host apps.
- قياس `phys_footprint` على جهاز (Logger) في debug فقط.

#### P1-2 · `arabic_shift_rows` **ميتة لكن محمّلة**
**الموقع:** JSON + `KeyboardDataLoader.Layouts.arabicShiftRows` + property `arabicShiftRows` على الـ VC.  
**الواقع:** `activeLetterLayout()` للعربي لا تستخدمها أبداً.  
**الأثر:** وزن JSON + ذاكرة + لبس للمطوّر (يُظن أن Shift العربي موجود).  
**التوصية:** حذف من JSON + Loader + property، أو إعادة تفعيل طبقة diacritics صريحة إن كانت مطلوبة كصفحة مستقلة.

#### P1-3 · Hold: `deleteBackward()` مرة واحدة فقط قبل إدراج بديل متعدد الأحرف
**الموقع:** `showHoldPopup` يحذف حرفاً واحداً إذا `pendingInserted`.  
**الحالة الحالية:** المفتاح الأساسي دائماً حرف واحد؛ بدائل **ل** متعددة الأحرف (`لا`…) تُدرج بعد الحذف → **صحيح**.  
**المخاطر الحدّية:**
- إن أصبح المفتاح الأساسي multi-codepoint لاحقاً، الحذف مرة واحدة غير كافٍ.
- سباق نظري نادر: `charUp` و`showHoldPopup` على runloop نفسه (منخفض الاحتمال لأن timer 320ms).  
**التوصية:** عند اختيار alternate: احسب `pendingBaseCount = downText.count` واحذف بنفس العدد؛ أو لا تُدرج على down أصلاً إذا `holdChoices.count > 1` (تأخير الإدراج حتى up) — UX مختلف (وميض أقل).

#### P1-4 · `TapSoundEngine` + AVAudioEngine
**الموقع:** `TapSoundEngine.swift`.  
**الوضع:** system → `AudioServicesPlaySystemSound(1104)` (ممتاز). custom packs → AVAudioEngine + session `.ambient`.  
**تحذير الموصلين (Douhouse):** AVAudio يتبع media volume وقد يفشل تفعيل الجلسة؛ يستهلك ذاكرة أكثر من system sound.  
**التوصية:** للـ custom: PCM → ملف temp → `AudioServicesCreateSystemSoundID` (نفس ناقل ringer) أو إبقاء AV لكن مع dispose صارم + عدم الإبقاء على engine دائماً إن soft silent.

#### P1-5 · `UIHostingController` لـ TranslationBridge دائماً مضمّن
**الموقع:** `attachBridge()` في `viewDidLoad`.  
**الأثر:** تكلفة SwiftUI hosting داخل امتداد ضيق الذاكرة حتى لو المستخدم لا يترجم.  
**التوصية:** lazy-create عند أول `translateTapped` فقط.

#### P1-6 · بدون Full Access: كتابة suite قد تفشل بصمت
**مرجع:** Apple Open Access + Douhouse + SO.  
**الوضع عندكم:** dual-write suite+standard يخفّف؛ لكن إن كتب الامتداد للـ suite بدون Full Access قد لا يثبت.  
**التوصية:** عند `!hasFullAccess` اعتمد standard أولاً للكتابة من الامتداد؛ من التطبيق اكتب suite+standard كالمعتاد. (اختياري: timestamp merge مثل مثال Douhouse.)

### P2 — تحسينات / صيانة

| # | الموضوع | ملاحظة |
|---|---------|--------|
| P2-1 | `holdDelayMs` | موجود في SharedKeyboardData لكن **لا UI** في SettingsTab |
| P2-2 | SharedKeyboardData | مفاتيح مكررة مع ThemeIO strings؛ لم تُستبدل الاستدعاءات بعد |
| P2-3 | validate_naqra | لا يفحص hold_map["ل"] ولا suite-first ولا dead arabic_shift |
| P2-4 | `arabic_shift` في FIXES يقول «removed» لكن JSON ما زال | وثّق أو احذف |
| P2-5 | rebuild عند كل Darwin notify | حتى لو تغيّر مفتاح صوت فقط |
| P2-6 | `NaqraPalette.swift` ~15KB | مرشّح لتقسيم / تقليل ألوان runtime |
| P2-7 | Clipboard panel | جيد مع Full Access؛ تأكد أن history لا ينمو بلا حد (prefix موجود في add) |
| P2-8 | CI | Build IPA ينجح؛ لا unit tests / memory budget gate |
| P2-9 | Globe / next keyboard | تحقق `needsInputModeSwitchKey` + `handleInputModeList` على أجهزة Face ID (مراجعة يدوية) |
| P2-10 | Accessibility | hints على hold موجودة؛ راجع VoiceOver لكل control keys |

### P3 — اقتراحات منتج (من جولة الموصلين السابقة)
- Wispr-style: مايك → deep link للتطبيق → نص عبر App Group  
- Keychain Access Group فقط للأسرار (ليس للثيمات)  
- Swift Sharing (Point-Free) كبديل أنظف للـ suite لاحقاً  

---

## 4) Hold / ضغط — تحليل UX تفصيلي

| الحدث | السلوك الحالي | تقييم |
|--------|----------------|--------|
| touchDown | insert حرف فوري + صوت + haptic | استجابة سريعة ✓؛ وميض إن ظهر popup |
| timer 320ms (قابل للتعديل بالكود) | showHoldPopup + deleteBackward مرة | مطابق نمط PowerToys insert-then-replace |
| drag على popup | يحدّث holdChoice | ✓ |
| touchUp مع popup | insert الاختيار | ✓ (بعد حذف الأساس) |
| touchUp بدون popup | لا إدراج ثاني إن pendingInserted | ✓ يمنع double-insert |
| cancel مع popup و pending false | يعيد insert downText | منطقي |
| char "ل" + اختيار "لا" | delete 1 + insert "لا" | ✓ |

**لا يوجد double-insert واضح في المسار السعيد.**

---

## 5) التطبيق الحاوي

- Settings يكتب ThemeStore + تحذير sideload إن `!groupAlive` ✓  
- Themes/PackStores install vs apply مفصولة ✓  
- SpecialKeyColorStore موحّد ✓  
- TranslationPrepCard iOS 18+ ✓  
- لا god-file في app entry ✓  

---

## 6) جدول «ما لا يعمل / ضعيف / غلط» — صيغة طلبك

| الحالة | العنصر |
|--------|--------|
| **كان لا يعمل → أُصلح في 0.2.8.1** | hold_map ل؛ suite-first |
| **يعمل لكن ضعيف** | rebuild الكامل؛ AVAudioEngine للpacks؛ Translation hosting دائم؛ validate سطحي |
| **كود ميت / مربك** | arabic_shift_rows محمّلة وغير مستخدمة |
| **ناقص منتج** | UI لـ hold delay؛ deep-link مايك |
| **يعتمد على الجهاز** | Full Access للـ pasteboard/group write؛ توقيع App Group في sideload |

---

## 7) رأي الموصلين (مُلخّص مقارن)

| موصل | ماذا أفاد |
|------|-----------|
| **GitHub** | شجرة الملفات، SHA، PRs، entitlements، diff فعلي |
| **Parallel Search** | وثائق Apple: Full Access، memory tips، insertText/deleteBackward |
| **Exa** | SO/App Group pitfalls، KeyboardKit openURL patterns |
| **Firecrawl** | مقال Douhouse: 3 قيود صلبة (memory / sandbox / audio bus) — أهم مرجع تطبيقي |
| **Context7** | resolve UIKit docs library (مرجع للمرحلة التالية من توثيق API) |
| **validate + clone** | PASS هيكلي + إحصائيات hold_map (119 مفتاح، ل مُصلح) |

**الاتفاق:** suite-first + Full Access notices + تقليل dirty heap + system sound path = أولوية صحيحة.  
**لا خلاف جوهري** بين الموصلين على P1 أعلاه.

---

## 8) خطة إصلاح مقترحة (بدون تنفيذ الآن)

### جولة A (يوم واحد) — تنظيف ميت + تحقق
1. حذف `arabic_shift_rows` من JSON/Loader/VC **أو** توثيق صريح «legacy unused».  
2. تقوية `validate_naqra`: assert `hold_map["ل"]` يحتوي لا؛ assert ThemeIO suite-first؛ ban arabicShift في activeLetterLayout.  
3. Settings: slider `holdDelayMs` 200–1500 يكتب SharedKeyboardData.

### جولة B (1–2 أيام) — أداء
1. `applyThemeInPlace()` بدون rebuild عند تغيّر لون فقط.  
2. lazy Translation hosting.  
3. deinit view teardown.  
4. (اختياري) system-sound path للـ custom packs.

### جولة C — منتج
1. deep link مايك.  
2. memory probe debug.  
3. tag tests على جهاز حقيقي (Jetsam).

---

## 9) اختبار يدوي مطلوب منك على الجهاز

1. هولد **ل** → لا / لأ / لإ / لآ.  
2. بدون Full Access: نسخ/لصق يظهر تنبيه؛ الكتابة الأساسية تعمل.  
3. مع Full Access: ثيم من التطبيق يظهر في اللوحة فوراً/عند الظهور.  
4. تبديل لغة/رموز/إيموجي 20 مرة — هل تموت اللوحة؟  
5. صوت system vs creamy مع media volume منخفض.  
6. Sideload بدون App Group provisioning: هل الإعدادات تبقى محلية كما في تحذير Settings؟

---

## 10) الخلاصة بجملة

**نقرة 0.2.8.1 صارت سليمة وظيفياً لما كسر الاستخدام (hold ل + مزامنة prefs)، والبناء أخضر؛ الفحص العميق مع الموصلين يُظهر أن الخطر التالي ليس «ما يشتغلش»، بل «قد تُقتل بصمت أو تثقل» بسبب rebuild/ذاكرة/صوت، مع طبقة shift عربية ميتة وvalidate ضعيف.**

