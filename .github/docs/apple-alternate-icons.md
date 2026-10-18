# مرجع الأيقونات البديلة في iOS

تستخدم `UIApplication.setAlternateIconName(_:completionHandler:)` اسمًا مطابقًا لاسم الأيقونة البديلة المعرّف عبر إعدادات Asset Catalog Compiler. توصي وثائق Apple بتعيين الأيقونة الأساسية عبر `ASSETCATALOG_COMPILER_APPICON_NAME` والأسماء البديلة عبر `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES`؛ ويولّد Xcode إدخالات `CFBundlePrimaryIcon` و`CFBundleAlternateIcons`. لا تُحرّر مفاتيح `CFBundleIcons` يدويًا في `Info.plist` عندما تُستخدم إعدادات البناء.

في هذا المشروع، `AppIconMorning` هي الأيقونة الأساسية و`AppIconEvening` بديلة. يطلب التطبيق التبديل عند الظهور والعودة للمقدمة فقط، لأن التطبيق لا يستطيع تشغيل نفسه في الخلفية لتغيير الأيقونة عند الساعة المحددة.

المراجع:
- [UIApplication.setAlternateIconName](https://developer.apple.com/documentation/uikit/uiapplication/setalternateiconname(_:completionhandler:))
- [Configuring your app to use alternate app icons](https://developer.apple.com/documentation/xcode/configuring-your-app-to-use-alternate-app-icons)
