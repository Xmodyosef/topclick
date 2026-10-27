# Naqra — AGENTS.md (Master Skill-Enabled Protocol v1.5)
# Repo: Xmodyosef/topclick

## 1. التفعيل الإجباري واستخدام المهارات (Mandatory Skills Execution)
- بمجرد دخولك المستودع، اطبع: `ACTIVATED | SKILLS LOADED`
- **قبل كتابة أي كود أو حل أي مشكلة، يجب عليك:**
  1. فحص مجلد `.agent/skills/` لمعرفة المهارات المتاحة.
  2. اختيار المهارة المناسبة (مثلاً: `ios-debugger-agent` للأخطاء، `swiftui-performance-audit` للأداء).
  3. قراءة ملف `SKILL.md` الخاص بها بالكامل.
  4. تنفيذ السكربتات الموجودة داخلها (إذا كنت تملك Terminal) أو تطبيق تعليماتها بدقة.
  5. ذكر اسم المهارة التي استخدمتها في ردك.

## 2. الصدق والمحاسبة (Truth & Accountability)
- ممنوع قول "تم" بدون إعطاء رابط PR أو Commit حقيقي.
- إذا فشلت، قل: "فشلت في استخدام مهارة [X] بسبب [Y]". ممنوع التهرب.
- إذا فشل كود بناءً على طلب سابق، قل: "أنت طلبت كذا، ونفذنا كذا، وفشل بسبب كذا".

## 3. سير العمل (Workflow)
- أنشئ فرع `agent/<task-name>`.
- افتح PR. **ممنوع الدمج**، المالك فقط يدمج.
- الروابط إجبارية (PR, Commit).

## 4. المهارات والذاكرة (Skills & Memory)
- اقرأ `SKILLS.md` لمعرفة الفهرس.
- اقرأ `LESSONS_LEARNED.md` قبل البدء لتجنب الأخطاء السابقة، وسجل أي خطأ جديد فيه.

## 5. أوامر المالك (Owner Commands)
- **"افحص فقط"** أو **"لا تطبق"** = يمنع منعاً باتاً عمل Commit أو Push.
- التغييرات الجذرية (حذف ملفات، تغيير هيكلة) تتطلب تأكيداً بجملة واحدة وانتظار كلمة "نعم".

## 6. الإصدارات والتنظيف (Releases & Cleanup)
- **الترقيم التسلسلي:** يزيد الرقم الأخير بمقدار 1 فقط (v0.2.4 ← v0.2.5 ← v0.2.6).
- **دمج الملاحظات:** قبل كل إصدار، ادمج ملاحظات الإصدار السابق في `RELEASE_NOTES.md` وضعه في الإصدار الجديد.
- **تحديث README:** إجباري بعد كل تحديث ليعكس الميزات الجديدة.
- **تنظيف Actions:** احتفظ بآخر Workflow Run فقط واحذف الباقي لتوفير المساحة.

## 7. التطور المستمر واكتشاف المهارات (Continuous Evolution)
- **فحص التقادم:** راجع المهارات في `.agent/skills/` وقارنها بأحدث تقنيات Swift/iOS.
- **الاقتراح الذكي:** اعرض على المالك قائمة بأفضل 3 مهارات جديدة (مع الروابط) واطلب الإذن قبل التثبيت.

## 8. منع الإفراط في الهندسة (Anti-Over-engineering)
- **No Over-defensive Coding:** Do NOT add edge-case checks or null-checks for extremely rare scenarios unless explicitly approved by the Owner.
- **Single Boundary Validation:** Validate external data ONLY at system boundaries. Trust internal type systems.
- **No Premature Abstraction:** Inline single-use logic. Do NOT create unnecessary helper functions.
- **Control Complexity:** Avoid try/catch unless strictly necessary. Do NOT split simple single-function logic.

## 9. بيئة العمل والبناء (Build & Environment Constraints)
- **No Mac/Laptop:** المالك لا يملك جهاز Mac أو لابتوب. يعمل حصرياً من هاتف الآيفون.
- **CI/CD Only:** جميع عمليات البناء (Build) تتم عبر GitHub Actions.
- **No Local Xcode:** ممنوع منعاً باتاً اقتراح أوامر تتطلب تشغيل Xcode محلياً.
- **Signing Method:** التوقيع يتم على الجوال (Feather, E-Sign, Sideloadly) بشهادة سنوية.
- **No P12 Generation:** لا تطلب أبداً إنشاء أو رفع ملفات `.p12` أو `.mobileprovision`.
- **App Limits:** تذكر قيود الذاكرة (50MB) ومنع الميكروفون في الإضافات.

## 10. صيغة الرد (Response Format)
- نقاط مرقمة فقط (1, 2, 3). بدون مقدمات.
- سطر أخير: "هل تريد أن أعمل كمان...؟"