// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'D-helper — Delivery Platform';

  @override
  String get deliveryPlatform => 'Delivery Platform';

  @override
  String get controlPanel => 'Control panel';

  @override
  String get login => 'Login';

  @override
  String get enterBtn => 'Enter';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get welcome => 'Welcome Back';

  @override
  String get logout => 'Logout';

  @override
  String get logoutTitle => 'Log out';

  @override
  String get logoutConfirm => 'Sure you want to exit?';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get profile => 'Profile';

  @override
  String get demoAccount => 'Demo account';

  @override
  String get email => 'Email';

  @override
  String get passwordField => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get recoverPassword => 'Recover password';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get codeWillBeSent => 'We\'ll send you a verification code.';

  @override
  String get sendCode => 'Send code';

  @override
  String get enterCode => 'Enter the code';

  @override
  String codeSentTo(String email) {
    return 'Code sent to $email';
  }

  @override
  String get demoMode => 'Demo mode';

  @override
  String get yourCode => 'Your code:';

  @override
  String get sixDigitCode => '6-digit code';

  @override
  String get verifyCode => 'Verify';

  @override
  String get choosePassword => 'Choose a secure password.';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get savePassword => 'Save password';

  @override
  String get passwordUpdated => 'Password updated ✓';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get minPassword => 'Min. 6 characters';

  @override
  String get fillAllFields => 'Fill in all fields';

  @override
  String get emailNotFound => 'Email not found';

  @override
  String get wrongCode => 'Incorrect code';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get today => 'Today';

  @override
  String get thisMonth => 'This month';

  @override
  String get thisYear => 'This year';

  @override
  String get totalOrders => 'Total orders';

  @override
  String get fromCalls => 'From calls';

  @override
  String get earnings => 'Earnings';

  @override
  String get avgDeliveryTime => 'Avg. delivery';

  @override
  String get perDelivery => 'per delivery';

  @override
  String get avgPerOrder => 'Avg. / order';

  @override
  String get ordersLast7Days => 'Last 7 days';

  @override
  String get cashVsCard => 'Cash vs Card';

  @override
  String get inProgress => 'In progress';

  @override
  String get callLabel => 'Call';

  @override
  String get orders => 'Orders';

  @override
  String get newOrder => 'New Order';

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get createOrder => 'Create Order';

  @override
  String get customerName => 'Customer Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get foodItems => 'Food Items';

  @override
  String get addItem => 'Add Item';

  @override
  String get removeItem => 'Remove';

  @override
  String get itemName => 'Item Name';

  @override
  String get quantity => 'Quantity';

  @override
  String get price => 'Price';

  @override
  String get paymentType => 'Payment Type';

  @override
  String get cash => 'Cash';

  @override
  String get card => 'Card';

  @override
  String get online => 'Online';

  @override
  String get submitOrder => 'Submit Order';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'An error occurred';

  @override
  String get orderStatus => 'Status';

  @override
  String get pending => 'Pending';

  @override
  String get accepted => 'Accepted';

  @override
  String get preparing => 'Preparing';

  @override
  String get ready => 'Ready';

  @override
  String get pickedUp => 'Picked Up';

  @override
  String get delivered => 'Delivered';

  @override
  String get rejected => 'Rejected';

  @override
  String get all => 'All';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get orderCreated => 'Order created successfully';

  @override
  String get addAtLeastOneItem => 'Add at least one item';

  @override
  String get required => 'Required';

  @override
  String get mapTab => 'Map';

  @override
  String get driversTab => 'Drivers';

  @override
  String get restaurantsTab => 'Restaurants';

  @override
  String get addDriver => 'Add driver';

  @override
  String get addRestaurant => 'Add restaurant';

  @override
  String get noDrivers => 'No drivers';

  @override
  String get noRestaurants => 'No restaurants';

  @override
  String get addFirstHint => 'Press + to add one';

  @override
  String get fullName => 'Full name';

  @override
  String get vehicleType => 'Vehicle';

  @override
  String get motorcycle => 'Motorcycle';

  @override
  String get car => 'Car';

  @override
  String get bike => 'Bike';

  @override
  String get onlineLabel => 'Online';

  @override
  String get offlineLabel => 'Offline';

  @override
  String get deleteDriverTitle => 'Delete driver';

  @override
  String get deleteRestaurantTitle => 'Delete restaurant';

  @override
  String confirmDelete(String name) {
    return 'Delete $name?';
  }

  @override
  String get restaurantLabel => 'Restaurant';

  @override
  String get restaurantName => 'Restaurant name';

  @override
  String get restaurantAddress => 'Address';

  @override
  String totalItems(int count) {
    return '$count items';
  }
}
