import 'package:budget_planner/getx_controller/app_controller.dart';
import 'package:budget_planner/getx_controller/category_controller.dart';
import 'package:budget_planner/models/category_model.dart';
import 'package:budget_planner/models/operation_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

void main() {
  tearDown(Get.reset);

  group('AppController', () {
    test('reads the saved profile and verifies the PIN', () async {
      await seed();
      final AppController app = Get.find<AppController>();
      expect(app.hasAccount, isTrue);
      expect(app.verifyPin('1234'), isTrue);
      expect(app.verifyPin('0000'), isFalse);
      expect(app.currencySymbol, r'$');
    });

    test('changePin persists', () async {
      await seed();
      await Get.find<AppController>().changePin('9876');
      expect(AppPreferences.instance.user.pin, '9876');
    });

    test('theme mode round-trips through storage', () async {
      await seed();
      expect(AppController.themeModeOf('dark'), ThemeMode.dark);
      expect(AppController.themeModeOf('light'), ThemeMode.light);
      expect(AppController.themeModeOf('???'), ThemeMode.system);
      await AppPreferences.instance.saveThemeMode('dark');
      Get.reset();
      expect(Get.put(AppController()).themeMode.value, ThemeMode.dark);
    });

    test('localeOf splits language and country', () {
      expect(AppController.localeOf('ar_JO'), const Locale('ar', 'JO'));
      expect(AppController.localeOf('en'), const Locale('en'));
    });

    test('deleteAccount wipes data but keeps language, theme, onboarding',
        () async {
      await seed(operations: <OperationModel>[op(food, 5, DateTime.now())]);
      final AppController app = Get.find<AppController>();
      app.localeCode.value = 'ar_JO';
      await AppPreferences.instance.saveThemeMode('dark');
      app.themeMode.value = ThemeMode.dark;

      await app.deleteAccount();

      final AppPreferences prefs = AppPreferences.instance;
      expect(app.hasAccount, isFalse);
      expect(prefs.user.pin, isEmpty);
      expect(prefs.operations, isEmpty);
      expect(prefs.onboardingSeen, isTrue);
      expect(prefs.localeCode, 'ar_JO');
      expect(prefs.themeMode, 'dark');
    });
  });

  group('CategoryController', () {
    test('loads built-ins for both sides', () async {
      await seed();
      final CategoryController c = Get.put(CategoryController());
      await c.load();
      expect(c.ofType(OperationType.expense),
          hasLength(CategoryController.defaultExpenses.length));
      expect(c.ofType(OperationType.income),
          hasLength(CategoryController.defaultIncomes.length));
    });

    test('add persists a custom category and remove deletes it', () async {
      await seed();
      final CategoryController c = Get.put(CategoryController());
      await c.load();
      final CategoryModel added =
          await c.add(name: ' Coffee ', type: OperationType.expense, emoji: '☕');
      expect(added.isCustom, isTrue);
      expect(added.displayName, 'Coffee');
      expect(AppPreferences.instance.customCategories.single.name, 'Coffee');

      await c.remove(added);
      expect(AppPreferences.instance.customCategories, isEmpty);
      expect(c.categories.where((CategoryModel x) => x.id == added.id), isEmpty);
    });

    test('built-in categories cannot be removed', () async {
      await seed();
      final CategoryController c = Get.put(CategoryController());
      await c.load();
      final int before = c.categories.length;
      await c.remove(CategoryController.defaultExpenses.first);
      expect(c.categories, hasLength(before));
    });

    test('built-in names translate, custom ones do not', () {
      loadTranslations();
      Get.locale = const Locale('ar', 'JO');
      expect(food.displayName, 'طعام');
      const CategoryModel mine = CategoryModel(
        id: 'custom_1',
        name: 'Gym',
        emoji: '🏋️',
        type: OperationType.expense,
        isCustom: true,
      );
      expect(mine.displayName, 'Gym');
      Get.locale = const Locale('en', 'US');
    });

    test('custom flag survives JSON', () {
      final CategoryModel back = CategoryModel.fromJson(
        const CategoryModel(
          id: 'custom_9',
          name: 'X',
          emoji: '⭐',
          type: OperationType.income,
          isCustom: true,
        ).toJson(),
      );
      expect(back.isCustom, isTrue);
      expect(back.type, OperationType.income);
    });
  });
}
