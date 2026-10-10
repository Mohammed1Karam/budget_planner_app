import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../api/budget_api.dart';
import '../models/currency_model.dart';
import '../models/user_model.dart';
import '../preferences/app_preferences.dart';

/// App-wide state: the profile, the language and the theme.
///
/// Registered permanently in `main`, so any screen can reach the profile
/// without threading it through constructors.
class AppController extends GetxController {
  AppController({BudgetApi? api}) : _api = api ?? BudgetApi();

  final BudgetApi _api;

  final Rx<UserModel> user = const UserModel().obs;

  /// Locale as a `language_COUNTRY` code, matching the AppTranslations keys.
  final RxString localeCode = 'en_US'.obs;

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    final AppPreferences prefs = AppPreferences.instance;
    localeCode.value = prefs.localeCode ?? 'en_US';
    themeMode.value = themeModeOf(prefs.themeMode);
    user.value = prefs.user;
  }

  Future<void> loadUser() async {
    user.value = await _api.fetchUser();
  }

  Future<void> saveUser(UserModel value) async {
    user.value = value;
    await _api.saveUser(value);
  }

  /// A profile with a PIN exists on this device.
  bool get hasAccount => user.value.pin.isNotEmpty;

  CurrencyModel get currency => CurrencyModel.byCode(user.value.currencyCode);

  String get currencySymbol => currency.symbol;

  bool verifyPin(String pin) => pin == user.value.pin;

  Future<void> changePin(String pin) => saveUser(user.value.copyWith(pin: pin));

  /// Turns a stored `language_COUNTRY` code into a [Locale].
  static Locale localeOf(String code) {
    final List<String> parts = code.split('_');
    return Locale(parts.first, parts.length > 1 ? parts[1] : null);
  }

  bool get isArabic => localeCode.value.startsWith('ar');

  Future<void> changeLocale(String code) async {
    localeCode.value = code;
    await AppPreferences.instance.saveLocaleCode(code);
    Get.updateLocale(localeOf(code));
  }

  static ThemeMode themeModeOf(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> changeThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await AppPreferences.instance.saveThemeMode(mode.name);
    Get.changeThemeMode(mode);
  }

  /// Locks the app; the PIN is needed to get back in.
  Future<void> logout() => AppPreferences.instance.setLoggedIn(false);

  /// Wipes the profile, transactions and categories, keeping only the
  /// language, the theme and the fact that onboarding was already seen.
  Future<void> deleteAccount() async {
    final AppPreferences prefs = AppPreferences.instance;
    await prefs.clear();
    await prefs.setOnboardingSeen();
    await prefs.saveLocaleCode(localeCode.value);
    await prefs.saveThemeMode(themeMode.value.name);
    user.value = const UserModel();
  }
}
