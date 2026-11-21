## Unreleased

### Quiet switch clicks
- Replaced the five custom CAF clicks with short, low-amplitude taps modeled on silent-switch measurements: about 500–1800 Hz, 16–30 ms, no 2.5–7 kHz click spike, and no low rumble.
- Pack ids are unchanged so a saved choice still plays. Titles now match the new sound: صامت، دافئ، خشب خافت، ناعم، همس.
- Not ocean, waterfall, or a sampled instrument. System click is still iOS and is not volume-controlled.


### Piano pluck (option 2)
- Replace heavy `piano.caf` (~420 ms) with a short string-pluck click (~68 ms, quieter amplitude).
- Cap concurrent click playback to one; dispose cached sound IDs on memory warning.
- Still AudioServices + single CAF (no AVAudioEngine). Not a full piano instrument.

### Language-path probe (no version bump)
Not a fix. One on-keyboard control, default mode is the current path.

- Toolbar speedometer: tap shows footprint / peak / available and counts of `surface`, `remount`, and `rebuild`. Long-press or أدخل writes one line into the text field.
- Mode button cycles one variable: الحالي (in-place + CTFont) → إعادة بناء (`rebuild()` on language switch) → خط النظام (same path, `UIFont.systemFont` instead of `CTFontCreateForStringWithLanguage`).
- صفر resets the peak and the counters without reinstalling.
- `theme` counts a real `rebuild()` from `applyThemeFromGroupIfNeeded` only. It does not count language-mode rebuild, emoji, or symbol-page rebuilds.

### Jetsam memory experiments (branch `agent/jetsam-memory-experiments`, no version bump)
Evidence: `KeyboardExtension` killed by `per-process-limit` at `rpages=4928` / `lifetimeMax=4928` while `active`. These are **isolatable experiments**, not a declared final fix. Re-measure `rpages` after each IPA trial.

1. **Bounded Arabic font cache** — `KeyboardTypography` caches `CTFontCreateForStringWithLanguage` results in an `NSCache` with `countLimit=96`, and clears on memory warning. Goal: cut repeated CTFont cost on language retitle / suggestions.
2. **Lazy TranslationBridge** — `UIHostingController` + Translation host is created on first translate tap only; detached on memory warning. Goal: remove framework host cost from every keyboard open.
3. **Emoji leave fallback** — `discardEmojiIfLeaving` rebuilds the letter surface when in-place swap fails; `swapEmojiSurface` re-inserts the toolbar if emoji full-mount dropped it. Goal: never leave the emoji collection mounted after hide.

Acceptance (device, clean IPA): slow language switch survives 2–3 flips; fast switch lasts longer than baseline; capture fresh Jetsam `rpages`/`lifetimeMax` after each trial. Do not call any experiment a final fix until it repeats on device.

- Added three focused skills with runnable release, skill-routing, and accessibility-audit scripts.
- Fixed stale `references/source/` instructions and updated the skill index and CI pack-count checks.
- Reorganized iOS sources into App, KeyboardExtension, Shared, Config, Resources, and functional Swift groups without changing app behavior.

## 0.2.11 — 2026-11-19
- **Build 33** — إصدار موحّد App + KeyboardExtension + VERSION + IPA.
- يتضمّن ما دُمج من **PR #140** على main: 7 مهارات تنفيذية + إصلاح CodeFactor + فلتر IPA للمهارات.
- تثبيت عقد الإصدار: `bump_version.py --check`؛ اختبار العقود لا يثبّت رقماً ثابتاً.
- Tag المستهدف: `v0.2.11` — IPA فقط: `PersonalKeyboard-0.2.11.ipa` (بدون أصول إصدارات أقدم).

## 0.2.10 — 2026-11-17
- إصلاح دورة حياة صفحة الإيموجي: إزالة شريط درجات البشرة ولقطات السحب عند إعادة البناء أو مغادرة لوحة المفاتيح.
- منع callbacks الخاصة بحركات الإيموجي القديمة من تعديل صفحة جديدة بعد تبديل اللغة أو إعادة بناء الواجهة.
- تبديل اللغة يحافظ على الصفحة الحالية، بما فيها صفحة الإيموجي.
- توحيد إصدار التطبيق والامتداد واسم IPA على 0.2.10، مع build 32.

## 0.2.8.1 — 2026-10-29
- إصدار صيانة فوق 0.2.8 مع إصلاحات #62/#63
- Hold حرف **ل**: لا / لأ / لإ / لآ / ڵ / ّ
- مزامنة App Group suite-first (ThemeIO + ThemeStore + PackStores)
- SharedKeyboardData + hold delay قابل للتعديل
- build 30

## 0.2.9 — 2026-10-29
- Hold حرف **ل**: لا / لأ / لإ / لآ / ڵ / ّ
- مزامنة App Group: suite أولاً ثم standard (ThemeIO + ThemeStore + PackStores)
- SharedKeyboardData.swift (مفاتيح مشتركة + hold delay قابل للتعديل لاحقاً)
- مراجعة موصلين: GitHub + Exa + Firecrawl + Context7

## 0.2.8 — 2026-10-27
- صف الأرقام عربي: ١٢٣٤٥٦٧٨٩٠ (الصفر ظاهر)
- Hold على ي يعطي ى أولاً
- Hold أرقام عربي↔إنجليزي
- TranslationPrepCard في الإعدادات (iOS 18+)
- README محدّث بروابط الإصدار

## 0.2.6 — 2026-10-27
- Hold عربي مكتمل
- رموز 4 صفوف عالمية موحّدة + زر أيقونة textformat.123
- AVAudioSession ambient
- كاش إيموجي بدون إعادة تحميل كل فتحة
- توحيد الإصدار 0.2.6

