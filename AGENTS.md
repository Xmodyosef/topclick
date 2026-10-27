# Naqra — AGENTS.md (Master Skill-Enabled Protocol v1.5.0)
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

## 3. سير العمل (Workflow)
- أنشئ فرع `agent/<task-name>`.
- افتح PR. **ممنوع الدمج**، المالك فقط يدمج.
- الروابط إجبارية.

## 4. المهارات والذاكرة
- اقرأ `SKILLS.md` لمعرفة الفهرس.
- اقرأ `LESSONS_LEARNED.md` قبل البدء لتجنب الأخطاء السابقة.

## 5. صيغة الرد
- نقاط مرقمة فقط (1, 2, 3). سطر أخير: "هل تريد أن أعمل كمان...؟"

## 9. التطور المستمر واكتشاف المهارات (Continuous Evolution & Skill Discovery)
- **فحص التقادم:** راجع المهارات في `.agent/skills/` وقارنها بأحدث تقنيات Swift/iOS.
- **البحث الاستباقي:** ابحث في الإنترنت عن مهارات جديدة تناسب المهام الحالية.
- **الاقتراح الذكي:** اعرض على المالك قائمة بأفضل 3 مهارات جديدة (مع الروابط) واطلب الإذن قبل التثبيت.
- **التوثيق:** بعد الموافقة، قم بتثبيتها وتحديث `SKILLS.md` تلقائيًا.
## 10. منع الإفراط في الهندسة (Anti-Over-engineering)
- **No Over-defensive Coding:** Do NOT add edge-case checks or null-checks for extremely rare scenarios unless explicitly approved by the Owner.
- **Single Boundary Validation:** Validate external data ONLY at system boundaries. Trust internal type systems.
- **No Premature Abstraction:** Inline single-use logic. Do NOT create unnecessary helper functions.
- **Control Complexity:** Avoid try/catch unless strictly necessary. Do NOT split simple single-function logic.

## 11. بيئة العمل والبناء (Build & Environment Constraints)
- **No Mac/Laptop:** المالك لا يملك جهاز Mac أو لابتوب. يعمل حصرياً من هاتف الآيفون.
- **CI/CD Only:** جميع عمليات البناء (Build) تتم عبر GitHub Actions.
- **No Local Xcode:** ممنوع منعاً باتاً اقتراح أوامر تتطلب تشغيل Xcode محلياً.
- **Signing Method:** التوقيع يتم على الجوال (Feather, E-Sign, Sideloadly) بشهادة سنوية.
- **No P12 Generation:** لا تطلب أبداً إنشاء أو رفع ملفات `.p12` أو `.mobileprovision`.
- **App Limits:** تذكر قيود الذاكرة (50MB) ومنع الميكروفون في الإضافات.