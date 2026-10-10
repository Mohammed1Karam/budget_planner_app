import 'package:budget_planner/getx_controller/category_controller.dart';
import 'package:budget_planner/getx_controller/home_controller.dart';
import 'package:budget_planner/getx_controller/operation_controller.dart';
import 'package:budget_planner/models/operation_model.dart';
import 'package:budget_planner/screen/about/about_screen.dart';
import 'package:budget_planner/screen/auth/create_account_screen.dart';
import 'package:budget_planner/screen/auth/lock_screen.dart';
import 'package:budget_planner/screen/auth/pin_code_screen.dart';
import 'package:budget_planner/screen/bottom_nav_bar/bottom_nav_bar_screen.dart';
import 'package:budget_planner/screen/category/add_category_screen.dart';
import 'package:budget_planner/screen/category/category_screen.dart';
import 'package:budget_planner/screen/lunch/onboarding_screen.dart';
import 'package:budget_planner/screen/operation/add_operation_screen.dart';
import 'package:budget_planner/screen/profile/profile_screen.dart';
import 'package:budget_planner/utils/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

/// Renders every screen at a regular and a small phone size, in light and
/// dark, English and Arabic. Catches a screen that throws on build, overflows,
/// or asks for a controller nobody registered.
void main() {
  const List<Size> sizes = <Size>[Size(414, 896), Size(360, 640)];

  List<OperationModel> ledger() {
    final DateTime now = DateTime.now();
    return <OperationModel>[
      op(food, 42.5, now, note: 'Lunch with the team at the new place'),
      op(salary, 1500, now),
      op(food, 12, DateTime(now.year, now.month, now.day - 1, 10)),
      op(food, 95, DateTime(now.year, now.month, now.day - 3, 18)),
    ];
  }

  final Map<String, Widget Function()> screens = <String, Widget Function()>{
    'onboarding': () => const OnboardingScreen(),
    'create account': () => const CreateAccountScreen(),
    'lock': () => const LockScreen(),
    'pin': () => const PinCodeScreen(),
    'shell': () => const BottomNavBarScreen(),
    'transaction form': () => const AddOperationScreen(),
    'categories': () => const CategoryScreen(),
    'add category': () => const AddCategoryScreen(),
    'profile': () => const ProfileScreen(),
    'about': () => const AboutScreen(),
  };

  tearDown(Get.reset);

  for (final Size size in sizes) {
    for (final bool dark in <bool>[false, true]) {
      for (final Locale locale in <Locale>[
        const Locale('en', 'US'),
        const Locale('ar', 'JO'),
      ]) {
        final String variant =
            '${size.width.toInt()}x${size.height.toInt()} '
            '${dark ? 'dark' : 'light'} ${locale.languageCode}';

        for (final MapEntry<String, Widget Function()> screen
            in screens.entries) {
          testWidgets('${screen.key} renders ($variant)',
              (WidgetTester tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1.0;
            addTearDown(tester.view.reset);

            await seed(operations: ledger());
            Get.put(HomeController());
            Get.put(CategoryController());
            if (screen.key == 'transaction form') {
              Get.put(OperationController());
            }

            await tester.pumpWidget(
              harnessScreen(
                screen.value(),
                pages: AppPages.pages,
                locale: locale,
                themeMode: dark ? ThemeMode.dark : ThemeMode.light,
              ),
            );
            await tester.pump(const Duration(milliseconds: 900));
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  }

  testWidgets('every tab of the shell renders', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await seed(operations: ledger());

    await tester.pumpWidget(
      harnessScreen(const BottomNavBarScreen(), pages: AppPages.pages),
    );
    await tester.pump(const Duration(milliseconds: 900));

    for (final String tab in <String>['Transactions', 'Statistics', 'Settings', 'Home']) {
      await tester.tap(find.text(tab).last);
      await tester.pump(const Duration(milliseconds: 900));
      expect(tester.takeException(), isNull, reason: tab);
    }
  });
}
