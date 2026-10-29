# فحص سطر-بسطر كامل — لوحة نقرة (topclick)
**التاريخ:** 2026-10-29  
**الإصدار المفحوص:** 0.2.8.1 / build 30 · SHA `4c47c63`  
**الحجم:** 27 ملف Swift · **3657 سطر** · 3 JSON · plists · workflows  

## الموصلات والمهارات المستخدمة (هذه الجولة)

| أداة | الدور |
|------|--------|
| **GitHub** (clone + tree + search_code) | الكود الفعلي؛ تأكيد `advanceToNextInputMode` = **0 نتائج** |
| **Parallel Search** | وثائق Apple: next keyboard, PrefersRightToLeft, memory |
| **Exa** | HIG + App Store 4.4.1 + experiences رفض |
| **Firecrawl** | صفحة Apple «Creating a custom keyboard» كاملة |
| **Context7** (`/websites/developer_apple_uikit`) | `needsInputModeSwitchKey` / `handleInputModeList` / `advanceToNextInputMode` |
| **code-reviewer skill** | قالب Critical/Major/Minor + أمان/أداء |
| **تحليل بايثون سطر-بسطر** | 3657 سطر · أنماط Timer/Unmanaged/rebuild/insert |
| **validate_naqra_split_aware.py** | PASS هيكلي (لا يغطي P0 الجديد) |

---

## 1) الحكم الإجمالي (Verdict)

**Request Changes / لا تعتمد 100% قبل إصلاح P0.**

- بعد 0.2.8.1: **hold ل** و**suite-first** تمام.
- الفحص السطر-بسطر كشف **فجوة حقيقية غابت عن الجولة السابقة:**  
  **لا يوجد أي استدعاء لـ `advanceToNextInputMode` / `handleInputModeList` / قراءة `needsInputModeSwitchKey` في المستودع كله.**  
  زر `EN/ع` يبدّل لغة **داخل** نقرة فقط — **ليس** تبديل لوحات النظام.
- على iPhone بـ Face ID غالباً النظام يرسم كرة تحت اللوحة → قد «يشتغل عندك».  
  على **SE / زر Home / بعض iPad / مراجع App Store** → **مخالفة صريحة** لتوقعات Apple وGuideline 4.4.1 («Provide a method for progressing to the next keyboard»).

---

## 2) خريطة الملفات + تغطية الفحص

| ملف | أسطر | فُحص | ملاحظات سريعة |
|-----|------|------|----------------|
| `KeyboardViewController.swift` | 324 | ✅ كامل | UIInputViewAudioFeedback ✓ · deinit يزيل Darwin فقط · **لا globe API** |
| `+BuildUI.swift` | 481 | ✅ كامل | KeyButton hit-area ✓ · makeBottom بلا next-keyboard · shadowOpacity=0 ✓ |
| `+Hold.swift` | 153 | ✅ كامل | state machine insert/delete مفهومة · multi-char «لا» OK |
| `+Input.swift` | 270 | ✅ كامل | delete repeat Timers · swipe-delete · autocorrect · double-space lang |
| `+Actions.swift` | 124 | ✅ كامل | Darwin Unmanaged · copy/paste/translate Full Access |
| `+Clipboard.swift` | 226 | ✅ كامل | panel + history · asyncAfter 0.15 |
| `+Emoji.swift` | 143 | ✅ كامل | single CollectionView (تعليق ذاكرة جيد) · `as! EmojiCell` |
| `+Paint.swift` | 90 | ✅ كامل | clipsToBounds · no shadows (جيد للذاكرة) |
| `KeyboardDataLoader.swift` | 155 | ✅ كامل | lock+cache · arabicShift محمّل ميت |
| `ThemeIO.swift` | 45 | ✅ كامل | suite-first ✓ |
| `TapSoundEngine.swift` | 92 | ✅ كامل | system 1104 + AV path |
| `NaqraPalette.swift` | 240 | ✅ كامل | جداول ألوان كبيرة في الامتداد |
| `ClipboardHistory.swift` | 33 | ✅ كامل | delimiter `\u{1F}` · privacy default |
| `TranslationBridge.swift` | 42 | ✅ كامل | SwiftUI bridge |
| `EmojiCell.swift` | 25 | ✅ كامل | fatalError(coder:) |
| `KeyboardLanguage.swift` | 5 | ✅ كامل | enum فقط |
| `SharedKeyboardData.swift` | 27 | ✅ كامل | **استعمال واحد** (hold delay) |
| `SettingsTab.swift` | 255 | ✅ كامل | لا holdDelay UI · تحذير App Group |
| `ThemesTab.swift` | 284 | ✅ كامل | |
| `ThemeModels.swift` | 180 | ✅ كامل | suite-first + Darwin |
| `PackStores.swift` | 198 | ✅ كامل | install vs apply |
| باقي Container | ~200 | ✅ | App icons / design / translation card |
| `keyboard_layouts.json` | — | ✅ | hold 119 · ل مصلح · arabic_shift ميت |
| `emoji_catalog.json` / `arabic_lexicon.json` | — | ✅ | |
| `Info.plist` امتداد | 42 | ✅ | IsASCIICapable+PrefersRightToLeft+OpenAccess+PrimaryLanguage=ar **كلها موجودة** |
| entitlements | — | ✅ | group متطابق app↔ext |
| workflows | 4 | ✅ | build-ipa · agent-guard · **بدون validate hold/globe** |

---

## 3) Critical (P0) — يجب إصلاحها

### P0-1 · لا يوجد «Next Keyboard / Globe» للنظام
**الأدلة:**
- `github___search_code` query `advanceToNextInputMode repo:Xmodyosef/topclick` → **total_count: 0**
- grep محلي: لا `handleInputModeList` ولا `needsInputModeSwitchKey`
- `makeBottom` (BuildUI **409–481**): رموز | EN/ع | 😊 | مسافة | . | إدخال — **لا كرة نظام**

**مرجع Apple (Context7 + Firecrawl + Exa):**
> When `needsInputModeSwitchKey` is true, your keyboard **should** provide such a key.  
> Template: `addTarget(..., #selector(handleInputModeList(from:with:)), for: .allTouchEvents)`  
> App Store 4.4.1: must **Provide a method for progressing to the next keyboard**.

**السلوك الصحيح:**
```swift
if needsInputModeSwitchKey {
  // أظهر زر globe
  next.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
}
// إعادة تقييم بعد rebuild / textDidChange / layout (الإشارة تتغيّر)
```
**لا تخلط** بين `languageTapped` (عربي↔إنجليزي داخلي) وبين next-keyboard.

**أولوية:** فورية قبل أي اعتبار App Store أو أجهزة SE.

---

## 4) Major (P1) — سطر بسطر

### P1-1 · `rebuild()` كامل — 12 استدعاء
مواقع مؤكدة: VC 91, 108, 292, 306 · Input 99, 252 · Emoji 133 · Actions 27 · BuildUI fallbacks shift.  
يفرغ `rootStack` (BuildUI **158–178**) ويعيد كل الأزرار.  
**خطر:** سقف ذاكرة الامتداد؛ jetsam صامت (Apple + Douhouse).  
**إيجابي جزئي:** `applyShiftSurface` (**227+**) يحدّث عناوين shift بدون rebuild عند تطابق الشبكة.

### P1-2 · `arabic_shift_rows` ميتة
- JSON محمّل · DataLoader **78** · VC property `arabicShiftRows`  
- `activeLetterLayout()` (**218–225**) للعربي → `arabicRows` فقط  
**إصلاح:** احذف أو اربط كصفحة تشكيل صريحة.

### P1-3 · Hold — `deleteBackward()` مرة واحدة (Hold **97–99**)
مع أساس حرف واحد + بديل «لا» → صحيح.  
إن توسّع الأساس لاحقاً → اكسر.  
**تحسين UX:** للمفاتيح ذات `holdChoices.count > 1` يمكن تأخير `insertText` حتى up (تقليل وميض).

### P1-4 · Hold popup لا يستخدم أزرار قابلة للضغط (Hold **120–136**)
الأزرار داخل الـ stack **بدون** `addTarget`؛ الاعتماد على `charDrag` لتحديث `holdChoice` ثم `charUp` يدرج.  
**يعمل** طالما الإصبع لا يزال على الزر الأصلي.  
**ضعف:** رفع الإصبع مباشرة على خيار في الـ popup (touchUp على زر الخيار) **غير مربوط** — قد يفشل إن نقل النظام touch إلى الـ popup.

### P1-5 · `TapSoundEngine` AVAudioEngine (أسطر **28–45, 74–91**)
- system → `AudioServicesPlaySystemSound(1104)` ✓  
- custom → تفعيل session + engine **بدون stop** عند اختفاء اللوحة  
- توليد `sin` كل ضغطة (85) → dirty heap  
**مرجع Douhouse:** AV على ناقل media volume ≠ ringer.

### P1-6 · Translation hosting دائم (Actions **36–49**)
`UIHostingController` من `viewDidLoad` حتى لو ما ترجم.  
+ `applyTranslation` يشترط `selectedText == pendingTranslationText` (هش في تطبيقات كثيرة).

### P1-7 · Darwin + `Unmanaged` (Actions **15–33**, VC deinit **95**)
الإزالة في `deinit` فقط. إن عُلّق الـ VC بدون deinit فوري والمراقب ما زال → نظرياً خطر.  
**أضف** remove في `viewWillDisappear` أيضاً (مع add عند appear إن لزم).

### P1-8 · حذف متكرر Timers (Input **115–129**)
`arm` 0.35s ثم repeat 0.07s — `[weak self]` ✓ · يُلغى في up/cancel/disappear ✓  
**ملاحظة:** عند `deleteDrag` swipe-word (Input **142**) يستخدم `token.count` ثم loop `deleteBackward` — مع علامات عربية مركّبة قد يحذف أقل/أكثر من المتوقع.

### P1-9 · Autocorrect عربي محدود (Input **234–235** + خريطة ثابتة)
lexicon صغير + edits بسيطة؛ `token.count` لحذف التصحيح.  
UITextChecker للإنجليزي OK.

### P1-10 · Emoji `as! EmojiCell` (Emoji cellForItem)
force cast — آمن عملياً مع register، يخالف سياسة «لا force».

### P1-11 · بدون Full Access: كتابة suite قد تفشل بصمت
dual-write يخفّف؛ من الامتداد الأفضل standard-first عند `!hasFullAccess`.

---

## 5) Minor (P2)

| # | الموقع | التفاصيل |
|---|--------|----------|
| P2-1 | SettingsTab | لا UI لـ `holdDelayMs` رغم SharedKeyboardData |
| P2-2 | SharedKeyboardData | **استدعاء واحد** فقط من Hold:44 — باقي المفاتيح strings مكررة |
| P2-3 | EmojiCell:20 | `fatalError()` في `init(coder:)` |
| P2-4 | Clipboard:19 | `asyncAfter(0.15)` لـ long-press flag |
| P2-5 | validate_naqra | لا يفحص globe API / hold ل / suite-first / dead shift |
| P2-6 | makeBottom semantic | `forceLeftToRight` على صف سفلي للوحة عربية — مقصود غالباً لتثبيت مواقع المفاتيح |
| P2-7 | enter icon | `arrow.down.to.line` بدل return — تسمية a11y «إدخال سطر جديد» ✓ لكن الشكل غير iOS-default |
| P2-8 | hide keyboard | موجود في toolbar (`keyboard.chevron.compact.down` → `dismissKeyboard`) ✓ |
| P2-9 | CI | build-ipa أخضر؛ لا memory budget / unit tests |
| P2-10 | NaqraPalette ~240 سطر | في Process الامتداد — مرشّح للتبسيط |
| P2-11 | hold_map | 21 مفتاح single-choice فقط (popup بلا معنى حقيقي إن count==1 يُتخطى أصلاً لأن guard >1) |
| P2-12 | builtin symbol pages | صفوف مكررة في fallback DataLoader (] [ { } مكررة) |

---

## 6) State machine — Hold (سطر بسطر)

| سطر | الكود | الحكم |
|-----|--------|--------|
| Hold 28–38 | charDown: insert فوري + pending=true | سريع؛ وميض إن popup |
| 43–48 | Timer 320ms weak self | ✓ SharedKeyboardData.holdDelaySeconds |
| 50–59 | charDrag: hit-test أزرار popup | ✓ بدون targets على الأزرار |
| 62–74 | charUp: إن popup → insert choice؛ وإلا إن !pending → insert | يمنع double-insert ✓ |
| 76–78 | reset shift إنجليزي بعد up | ✓ |
| 80–90 | charCancel: إن popup وحُذف الأساس → re-insert downText | ✓ |
| 93–99 | showHoldPopup: deleteBackward مرة إن pending | ✓ لأساس char واحد |
| 100–150 | بناء popup UI + قيود | قد يخرج عن الشاشة يُعالَج بـ top/leading/trailing ✓ |

**لا double-insert في المسار السعيد.**  
**ضعف:** عدم استقبال touchUp على زر الخيار نفسه.

---

## 7) Prefs / App Group (سطر بسطر)

| ThemeIO | الحكم |
|---------|--------|
| set: suite ثم standard | dual-write ✓ |
| string/bool: suite أولاً | ✓ بعد #62 |
| Darwin write() | ✓ |
| ThemeStore نفس الترتيب | ✓ |
| groupAlive عبر containerURL | ✓ + تحذير sideload في Settings |
| Info RequestsOpenAccess true | ✓ |
| PrefersRightToLeft true | ✓ (كان التقرير السابق أخطأ إن قال إنها ناقصة — **موجودة** plist 29–30) |
| IsASCIICapable true | ✓ (إنجليزي موجود) |

---

## 8) ما يعمل بشكل ممتاز (Positive)

1. فصل VC إلى extensions واضحة.  
2. JSON layouts + lock cache.  
3. suite-first بعد الإصلاح.  
4. hold ل مكتمل.  
5. Full Access notices عربية بدل صمت.  
6. `shadowOpacity = 0` + `isOpaque` في paint (ذاكرة).  
7. إيموجي: تعليق صريح عن multi-CollectionView memory — single grid.  
8. KeyButton hit area أطول.  
9. applyShiftSurface.  
10. UIInputViewAudioFeedback + enableInputClicksWhenVisible.  
11. entitlements متطابقة.  
12. إصدارات 0.2.8.1/30 متسقة yml+plists.

---

## 9) جدول «ما لا يشتغل / غلط / ضعيف» — صيغة طلبك

| الحالة | العنصر | سطور/دليل |
|--------|--------|-----------|
| **لا يشتغل (على أجهزة needsInputModeSwitchKey)** | تبديل لوحة النظام | لا API في الريبو |
| **كان مكسور → مُصلح** | hold ل · suite-first | JSON + ThemeIO |
| **ضعيف** | rebuild×12 · AV engine · Translation host · hold popup بدون button targets | أعلاه |
| **ميت/مربك** | arabic_shift_rows | JSON+Loader |
| **ناقص منتج** | holdDelay UI · SharedKeyboardData غير مُستغل | Settings / SKD |
| **تحقق أعمى** | validate_naqra | لا P0 globe |

---

## 10) خطة إصلاح مرتّبة

### جولة 0 (P0 — ساعات)
1. زر next-keyboard مشروط بـ `needsInputModeSwitchKey`.  
2. `handleInputModeList(from:with:)` على `.allTouchEvents`.  
3. إعادة ربط الزر بعد كل `rebuild()` / عند تغيّر الخاصية.  
4. اختبار SE + Face ID.

### جولة A
- حذف أو توثيق arabic_shift.  
- validate: assert globe API موجود + hold ل + suite-first.  
- holdDelay slider.

### جولة B
- theme in-place · lazy translation · stop audio engine on disappear · popup button targets.

---

## 11) أسئلة للمؤلف
1. هل تعمدت الاعتماد على globe النظام فقط (Face ID) ورفض دعم SE؟  
2. هل arabic_shift مقصود كـ legacy أم نسيّ حذف؟  
3. هل الترجمة أولوية كافية لإبقاء Hosting دائماً؟

---

## 12) خلاصة بجملة

**الفحص السطر-بسطر على 3657 سطراً + موصلات Apple/Exa/Firecrawl/Context7/GitHub يؤكد: 0.2.8.1 أصلحت hold/prefs، لكن أكبر نقص كان مخفياً: صفر تكامل مع Next-Keyboard API — مع ديون ذاكرة/rebuild/صوت/طبقة shift ميتة. الجولة السابقة كانت «اتجاه صحيح» ونقصها الجوهري هو عدم إثبات/نفي API النظام سطراً بسطر.**
