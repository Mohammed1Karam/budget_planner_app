import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/category_model.dart';
import '../models/operation_model.dart';
import '../models/user_model.dart';
import 'preference_keys.dart';

/// The app's local store.
///
/// Everything the app keeps -- the profile, the saved transactions, the
/// custom categories, the language and theme -- lives here, so the app runs
/// fully offline with no backend. Swap the call sites for [BudgetApi] once a server exists.
class AppPreferences {
  AppPreferences._(this._prefs);

  final SharedPreferences _prefs;

  static AppPreferences? _instance;

  static AppPreferences get instance {
    final AppPreferences? i = _instance;
    if (i == null) {
      throw StateError('Call AppPreferences.init() before using it.');
    }
    return i;
  }

  /// Safe to call more than once: each call re-reads the backing store and
  /// replaces the singleton. That matters in tests, where the store is swapped
  /// between cases and a cached instance would keep serving the old data.
  static Future<AppPreferences> init() async {
    return _instance = AppPreferences._(await SharedPreferences.getInstance());
  }

  // Onboarding ------------------------------------------------------------

  bool get onboardingSeen => _prefs.getBool(PreferenceKeys.onboardingSeen) ?? false;

  Future<void> setOnboardingSeen() =>
      _prefs.setBool(PreferenceKeys.onboardingSeen, true);

  // Session ---------------------------------------------------------------

  bool get isLoggedIn => _prefs.getBool(PreferenceKeys.loggedIn) ?? false;

  Future<void> setLoggedIn(bool value) =>
      _prefs.setBool(PreferenceKeys.loggedIn, value);

  // Profile ---------------------------------------------------------------

  UserModel get user {
    final String? raw = _prefs.getString(PreferenceKeys.user);
    if (raw == null) return const UserModel();
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveUser(UserModel user) =>
      _prefs.setString(PreferenceKeys.user, jsonEncode(user.toJson()));

  // Operations ------------------------------------------------------------

  List<OperationModel> get operations {
    final String? raw = _prefs.getString(PreferenceKeys.operations);
    if (raw == null) return <OperationModel>[];
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => OperationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveOperations(List<OperationModel> operations) {
    return _prefs.setString(
      PreferenceKeys.operations,
      jsonEncode(operations.map((o) => o.toJson()).toList()),
    );
  }

  // Categories ------------------------------------------------------------

  /// Only the user's own categories; the defaults ship in the app.
  List<CategoryModel> get customCategories {
    final String? raw = _prefs.getString(PreferenceKeys.categories);
    if (raw == null) return <CategoryModel>[];
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCustomCategories(List<CategoryModel> categories) {
    return _prefs.setString(
      PreferenceKeys.categories,
      jsonEncode(categories.map((c) => c.toJson()).toList()),
    );
  }

  // Language --------------------------------------------------------------

  String? get localeCode => _prefs.getString(PreferenceKeys.locale);

  Future<void> saveLocaleCode(String code) =>
      _prefs.setString(PreferenceKeys.locale, code);

  // Theme -----------------------------------------------------------------

  /// `system`, `light` or `dark`.
  String get themeMode => _prefs.getString(PreferenceKeys.themeMode) ?? 'system';

  Future<void> saveThemeMode(String mode) =>
      _prefs.setString(PreferenceKeys.themeMode, mode);

  /// Wipes everything, behind "Delete account" in Settings.
  Future<void> clear() => _prefs.clear();
}
