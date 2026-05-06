import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'D-helper — Delivery Platform'**
  String get appName;

  /// No description provided for @deliveryPlatform.
  ///
  /// In en, this message translates to:
  /// **'Delivery Platform'**
  String get deliveryPlatform;

  /// No description provided for @controlPanel.
  ///
  /// In en, this message translates to:
  /// **'Control panel'**
  String get controlPanel;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @enterBtn.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get enterBtn;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcome;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutTitle;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sure you want to exit?'**
  String get logoutConfirm;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @demoAccount.
  ///
  /// In en, this message translates to:
  /// **'Demo account'**
  String get demoAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @passwordField.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordField;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @recoverPassword.
  ///
  /// In en, this message translates to:
  /// **'Recover password'**
  String get recoverPassword;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @codeWillBeSent.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you a verification code.'**
  String get codeWillBeSent;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get enterCode;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {email}'**
  String codeSentTo(String email);

  /// No description provided for @demoMode.
  ///
  /// In en, this message translates to:
  /// **'Demo mode'**
  String get demoMode;

  /// No description provided for @yourCode.
  ///
  /// In en, this message translates to:
  /// **'Your code:'**
  String get yourCode;

  /// No description provided for @sixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get sixDigitCode;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyCode;

  /// No description provided for @choosePassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a secure password.'**
  String get choosePassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @savePassword.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get savePassword;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated ✓'**
  String get passwordUpdated;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @minPassword.
  ///
  /// In en, this message translates to:
  /// **'Min. 6 characters'**
  String get minPassword;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Fill in all fields'**
  String get fillAllFields;

  /// No description provided for @emailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Email not found'**
  String get emailNotFound;

  /// No description provided for @wrongCode.
  ///
  /// In en, this message translates to:
  /// **'Incorrect code'**
  String get wrongCode;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get thisYear;

  /// No description provided for @totalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total orders'**
  String get totalOrders;

  /// No description provided for @fromCalls.
  ///
  /// In en, this message translates to:
  /// **'From calls'**
  String get fromCalls;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @avgDeliveryTime.
  ///
  /// In en, this message translates to:
  /// **'Avg. delivery'**
  String get avgDeliveryTime;

  /// No description provided for @perDelivery.
  ///
  /// In en, this message translates to:
  /// **'per delivery'**
  String get perDelivery;

  /// No description provided for @avgPerOrder.
  ///
  /// In en, this message translates to:
  /// **'Avg. / order'**
  String get avgPerOrder;

  /// No description provided for @ordersLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get ordersLast7Days;

  /// No description provided for @cashVsCard.
  ///
  /// In en, this message translates to:
  /// **'Cash vs Card'**
  String get cashVsCard;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @callLabel.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callLabel;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @newOrder.
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get newOrder;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @createOrder.
  ///
  /// In en, this message translates to:
  /// **'Create Order'**
  String get createOrder;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @foodItems.
  ///
  /// In en, this message translates to:
  /// **'Food Items'**
  String get foodItems;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeItem;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @paymentType.
  ///
  /// In en, this message translates to:
  /// **'Payment Type'**
  String get paymentType;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @submitOrder.
  ///
  /// In en, this message translates to:
  /// **'Submit Order'**
  String get submitOrder;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get orderStatus;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get preparing;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @pickedUp.
  ///
  /// In en, this message translates to:
  /// **'Picked Up'**
  String get pickedUp;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @orderCreated.
  ///
  /// In en, this message translates to:
  /// **'Order created successfully'**
  String get orderCreated;

  /// No description provided for @addAtLeastOneItem.
  ///
  /// In en, this message translates to:
  /// **'Add at least one item'**
  String get addAtLeastOneItem;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @mapTab.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTab;

  /// No description provided for @driversTab.
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get driversTab;

  /// No description provided for @restaurantsTab.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurantsTab;

  /// No description provided for @addDriver.
  ///
  /// In en, this message translates to:
  /// **'Add driver'**
  String get addDriver;

  /// No description provided for @addRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Add restaurant'**
  String get addRestaurant;

  /// No description provided for @noDrivers.
  ///
  /// In en, this message translates to:
  /// **'No drivers'**
  String get noDrivers;

  /// No description provided for @noRestaurants.
  ///
  /// In en, this message translates to:
  /// **'No restaurants'**
  String get noRestaurants;

  /// No description provided for @addFirstHint.
  ///
  /// In en, this message translates to:
  /// **'Press + to add one'**
  String get addFirstHint;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicleType;

  /// No description provided for @motorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get motorcycle;

  /// No description provided for @car.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get car;

  /// No description provided for @bike.
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get bike;

  /// No description provided for @onlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineLabel;

  /// No description provided for @offlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offlineLabel;

  /// No description provided for @deleteDriverTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete driver'**
  String get deleteDriverTitle;

  /// No description provided for @deleteRestaurantTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete restaurant'**
  String get deleteRestaurantTitle;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String confirmDelete(String name);

  /// No description provided for @restaurantLabel.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurantLabel;

  /// No description provided for @restaurantName.
  ///
  /// In en, this message translates to:
  /// **'Restaurant name'**
  String get restaurantName;

  /// No description provided for @restaurantAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get restaurantAddress;

  /// No description provided for @totalItems.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String totalItems(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
