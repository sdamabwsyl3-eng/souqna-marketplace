# سوقنا (Souqna Marketplace)

تطبيق Flutter لسوق إلكتروني بواجهة عربية RTL: ضمان بنكي (Escrow)، فحص فني، محفظة، ومحادثة تفاوض.

> **ملاحظة:** البيانات والدفع وتسجيل الدخول بنفاذ كلها **محاكاة (Mock)** للعرض فقط.
> لا يوجد Backend. الربط الحقيقي مع نفاذ ومدى وسداد يحتاج تسجيلاً رسمياً وخادماً.

## الشاشات
تسجيل الدخول (نفاذ) ← الرئيسية (بحث + تصنيفات) ← تفاصيل المنتج ← تفاوض / دفع ← تتبع الطلب
+ الإشعارات، المحفظة، الملف الشخصي، الحسابات البنكية، إضافة سلعة.

## التشغيل محلياً
```bash
flutter create . --project-name souqna_marketplace --org com.souqna --platforms=android,web,ios
flutter pub get
flutter run            # أو: flutter run -d chrome
```
> `flutter create .` يولّد مجلدات المنصات فقط ولا يغيّر ملفات `lib/`.
> لو غيّر `lib/main.dart` ارجع له من git: `git checkout lib/main.dart`.

## الرفع على GitHub والبناء التلقائي
```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/USERNAME/souqna-marketplace.git
git push -u origin main
```
بعد الـ push يشتغل `.github/workflows/build.yml` تلقائياً:
- **Actions → آخر تشغيل → Artifacts**: حمّل `souqna-apk` (ملف APK للتجربة).
- **GitHub Pages**: من *Settings → Pages → Source* اختر **GitHub Actions**، وتظهر النسخة الويب على
  `https://USERNAME.github.io/souqna-marketplace/`.

> الـ APK الناتج موقّع بمفتاح debug فقط (للتجربة). للنشر على المتجر لازم توقيع release خاص بك.

## مكونات React (اختياري)
`react-components/SouqnaKit.tsx` يحتاج مشروع Vite أو Next.js مع Tailwind. بقية ملفات React المذكورة في الأرشيف الأصلي لم تكن موجودة.

## ملاحظة للبناء المحلي (release)
`flutter create` يضيف صلاحية الإنترنت لنسخة debug فقط. قبل `flutter build apk --release` محلياً أضف داخل `<manifest>` في
`android/app/src/main/AndroidManifest.xml`:
`<uses-permission android:name="android.permission.INTERNET"/>` (الـ workflow يضيفها تلقائياً).
