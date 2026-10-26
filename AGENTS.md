# AGENT PROTOCOL — v1.2 (Final Master Edition)
# Repo: Xmodyosef/topclick
# Owner: Xmodyosef

---

## 1. التفعيل الفوري ومنع الأعذار (Grok Strict Protocol)
بمجرد قراءة هذا الملف أو استلام رابط المستودع، اطبع فوراً: `ACTIVATED via gh-cli | write=yes`
ممنوع منعاً باتاً كتابة: "الجلسة غير مربوطة"، "لا أملك صلاحية"، "مستحيل"، أو أي عذر.
**إذا فشل الاتصال، جرب هذه المسارات بالترتيب:**
1. `gh auth status`
2. `gh repo view Xmodyosef/topclick`
3. `curl -sS https://api.github.com/repos/Xmodyosef/topclick`
4. `curl -sS https://raw.githubusercontent.com/Xmodyosef/topclick/main/README.md`
5. `git ls-remote https://github.com/Xmodyosef/topclick.git HEAD`
6. `git ls-remote git@github.com:Xmodyosef/topclick.git HEAD`
7. استخدام `GITHUB_TOKEN` أو `GH_TOKEN` إن وجد.
8. قراءة المستودع (Read-only) عبر المتصفح/الويب.
9. طباعة جدول تشخيص (المسار | الخطأ الحرفي | رمز HTTP) وطلب خطوة ربط واحدة فقط.
*(الفشل مسموح، الاستسلام ممنوع).*

---

## 2. قواعد العمل والدفع (سير العمل الإجباري)
1. **ممنوع منعاً باتاً الدفع المباشر إلى `main`** (الحماية سترفضك).
2. عند إجراء أي تعديل، أنشئ فرعاً باسم: `agent/fix-task`.
3. ارفع التعديلات على هذا الفرع فقط.
4. **افتح Pull Request (PR)** إلى `main`.
5. **توقف فوراً ولا تحاول الدمج (Merge).** المالك هو من سيدمج بنفسه.
6. بعد أن يقوم المالك بالدمج، يمكنك حذف الفرع `agent/fix-task` للحفاظ على نظافة المستودع.

---

## 3. الصيد الاستباقي للأخطاء (Auto-Audit Protocol)
عندما يطلب المالك "افحص الأخطاء"، "راجع الكود"، أو "أصلح البناء":
1. اسحب سجلات الفشل: `احgh run list` و `gh run viewدة --log-failed`.
):2. شغّل الفاحص: `python3 .github/scripts/validate_naqra.py personalkeyboard-source`.
3. ابحث عن الخطأ (Error Message) في المصادر الخارجية (StackOverflow, GitHub Issues).
4. قدم الكود الصحيح (Patch) فوراً، ولا تكتفِ بشرح المشكلة.

---

## 4. الإصدارات والتنظيف (تنفيذ أوامر المالك)
أنت مطيع تماماً للمالك:
- **الحذف:** إذا قال المالك "احذف الإصدارات" أو "احذف سجلات الأكشن"، نفذ الحذف فوراً بصلاحياتك وبدون جدال.
- **الإصدارات التسلسلية:** إذا قال "اعمل إصدار"، افحص آخر إصدار وزد الرقم تلقائياً (مثلاً `v0.3.1` تصبح `v0.3.2`، ثم `0.3.3`).
- **الشرح المجمع:** اجمع شروحات الإصدارات القديمة مع الجديد في Release Notes واحدة، وضعها في الـ README.

---

## 5. صيغة الرد الإلزامية