// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'D-helper — منصة التوصيل';

  @override
  String get deliveryPlatform => 'منصة التوصيل';

  @override
  String get controlPanel => 'لوحة التحكم';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get enterBtn => 'دخول';

  @override
  String get signInWithGoogle => 'تسجيل الدخول بـ Google';

  @override
  String get welcome => 'مرحباً بعودتك';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutTitle => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل أنت متأكد من الخروج؟';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get demoAccount => 'حساب تجريبي';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get passwordField => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get recoverPassword => 'استعادة كلمة المرور';

  @override
  String get enterEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get codeWillBeSent => 'سنرسل لك رمز التحقق.';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get enterCode => 'أدخل الرمز';

  @override
  String codeSentTo(String email) {
    return 'تم إرسال الرمز إلى $email';
  }

  @override
  String get demoMode => 'الوضع التجريبي';

  @override
  String get yourCode => 'رمزك:';

  @override
  String get sixDigitCode => 'رمز 6 أرقام';

  @override
  String get verifyCode => 'تحقق';

  @override
  String get choosePassword => 'اختر كلمة مرور آمنة.';

  @override
  String get newPassword => 'كلمة مرور جديدة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get savePassword => 'حفظ كلمة المرور';

  @override
  String get passwordUpdated => 'تم تحديث كلمة المرور ✓';

  @override
  String get passwordsDontMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get minPassword => '6 أحرف على الأقل';

  @override
  String get fillAllFields => 'أكمل جميع الحقول';

  @override
  String get emailNotFound => 'البريد الإلكتروني غير موجود';

  @override
  String get wrongCode => 'الرمز غير صحيح';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get today => 'اليوم';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get thisYear => 'هذا العام';

  @override
  String get totalOrders => 'إجمالي الطلبات';

  @override
  String get fromCalls => 'من المكالمات';

  @override
  String get earnings => 'الأرباح';

  @override
  String get avgDeliveryTime => 'متوسط التوصيل';

  @override
  String get perDelivery => 'لكل توصيل';

  @override
  String get avgPerOrder => 'متوسط / طلب';

  @override
  String get ordersLast7Days => 'آخر 7 أيام';

  @override
  String get cashVsCard => 'نقد مقابل بطاقة';

  @override
  String get inProgress => 'جارٍ';

  @override
  String get callLabel => 'مكالمة';

  @override
  String get orders => 'الطلبات';

  @override
  String get newOrder => 'طلب جديد';

  @override
  String get noOrdersYet => 'لا توجد طلبات بعد';

  @override
  String get createOrder => 'إنشاء طلب';

  @override
  String get customerName => 'اسم العميل';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get deliveryAddress => 'عنوان التوصيل';

  @override
  String get foodItems => 'الأصناف';

  @override
  String get addItem => 'إضافة صنف';

  @override
  String get removeItem => 'حذف';

  @override
  String get itemName => 'اسم الصنف';

  @override
  String get quantity => 'الكمية';

  @override
  String get price => 'السعر';

  @override
  String get paymentType => 'طريقة الدفع';

  @override
  String get cash => 'نقد';

  @override
  String get card => 'بطاقة';

  @override
  String get online => 'أون لاين';

  @override
  String get submitOrder => 'إرسال الطلب';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get error => 'حدث خطأ';

  @override
  String get orderStatus => 'الحالة';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get accepted => 'مقبول';

  @override
  String get preparing => 'قيد التحضير';

  @override
  String get ready => 'جاهز';

  @override
  String get pickedUp => 'تم الاستلام';

  @override
  String get delivered => 'تم التوصيل';

  @override
  String get rejected => 'مرفوض';

  @override
  String get all => 'الكل';

  @override
  String get orderDetails => 'تفاصيل الطلب';

  @override
  String get orderCreated => 'تم إنشاء الطلب';

  @override
  String get addAtLeastOneItem => 'أضف صنفاً واحداً على الأقل';

  @override
  String get required => 'مطلوب';

  @override
  String get mapTab => 'الخريطة';

  @override
  String get driversTab => 'السائقون';

  @override
  String get restaurantsTab => 'المطاعم';

  @override
  String get addDriver => 'إضافة سائق';

  @override
  String get addRestaurant => 'إضافة مطعم';

  @override
  String get noDrivers => 'لا يوجد سائقون';

  @override
  String get noRestaurants => 'لا توجد مطاعم';

  @override
  String get addFirstHint => 'اضغط + للإضافة';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get vehicleType => 'المركبة';

  @override
  String get motorcycle => 'دراجة نارية';

  @override
  String get car => 'سيارة';

  @override
  String get bike => 'دراجة';

  @override
  String get onlineLabel => 'متصل';

  @override
  String get offlineLabel => 'غير متصل';

  @override
  String get deleteDriverTitle => 'حذف السائق';

  @override
  String get deleteRestaurantTitle => 'حذف المطعم';

  @override
  String confirmDelete(String name) {
    return 'حذف $name؟';
  }

  @override
  String get restaurantLabel => 'مطعم';

  @override
  String get restaurantName => 'اسم المطعم';

  @override
  String get restaurantAddress => 'العنوان';

  @override
  String totalItems(int count) {
    return '$count أصناف';
  }
}
