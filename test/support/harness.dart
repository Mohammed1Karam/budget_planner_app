import 'package:budget_planner/getx_controller/app_controller.dart';
import 'package:budget_planner/models/category_model.dart';
import 'package:budget_planner/models/operation_model.dart';
import 'package:budget_planner/models/user_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:budget_planner/utils/app_theme.dart';
import 'package:budget_planner/utils_lan/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

const CategoryModel food = CategoryModel(
  id: 'food',
  name: 'Food',
  emoji: '🍔',
  type: OperationType.expense,
);

const CategoryModel salary = CategoryModel(
  id: 'salary',
  name: 'Salary',
  emoji: '💼',
  type: OperationType.income,
);

int _seq = 0;

OperationModel op(
  CategoryModel category,
  double amount,
  DateTime date, {
  String note = '',
}) =>
    OperationModel(
      id: 'op_${_seq++}',
      category: category,
      title: note.isEmpty ? category.name : note,
      amount: amount,
      date: date,
      note: note,
    );

const UserModel testUser = UserModel(
  name: 'Yana',
  email: 'yana@example.com',
  dailyLimit: 100,
  pin: '1234',
);

/// A clean SharedPreferences for a test that touches AppPreferences.
void resetPreferences([Map<String, Object> initial = const <String, Object>{}]) {
  SharedPreferences.setMockInitialValues(initial);
}

/// Fresh storage holding [user] and [operations], and a fresh AppController.
Future<void> seed({
  UserModel? user = testUser,
  List<OperationModel> operations = const <OperationModel>[],
  bool onboardingSeen = true,
  bool loggedIn = true,
}) async {
  resetPreferences();
  await AppPreferences.init();
  final AppPreferences prefs = AppPreferences.instance;
  if (user != null) await prefs.saveUser(user);
  await prefs.saveOperations(operations);
  if (onboardingSeen) await prefs.setOnboardingSeen();
  await prefs.setLoggedIn(loggedIn);

  Get.reset();
  Get.put(AppController());
}

/// Wraps a widget in the same GetX app the real screens run inside, so `.tr`
/// resolves and Get.back / Get.toNamed work in a test.
Widget harnessScreen(
  Widget child, {
  List<GetPage<dynamic>> pages = const <GetPage<dynamic>>[],
  Locale locale = AppTranslations.fallback,
  ThemeMode themeMode = ThemeMode.light,
}) {
  return GetMaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: themeMode,
    translations: AppTranslations(),
    locale: locale,
    fallbackLocale: AppTranslations.fallback,
    supportedLocales: AppTranslations.supported,
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    getPages: pages,
    home: child,
  );
}

/// Loads the translation maps into GetX for a unit test that has no
/// GetMaterialApp above it. Without this, `.tr` echoes the key back.
void loadTranslations() {
  Get.addTranslations(AppTranslations().keys);
  Get.locale = AppTranslations.fallback;
  Get.fallbackLocale = AppTranslations.fallback;
}
