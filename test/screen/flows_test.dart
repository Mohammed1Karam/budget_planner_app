import 'package:budget_planner/models/operation_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:budget_planner/screen/auth/create_account_screen.dart';
import 'package:budget_planner/screen/auth/lock_screen.dart';
import 'package:budget_planner/screen/bottom_nav_bar/bottom_nav_bar_screen.dart';
import 'package:budget_planner/screen/home/home_screen.dart';
import 'package:budget_planner/screen/lunch/splash_screen.dart';
import 'package:budget_planner/utils/app_pages.dart';
import 'package:budget_planner/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

void main() {
  tearDown(Get.reset);

  Future<void> open(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(harnessScreen(screen, pages: AppPages.pages));
    await tester.pump(const Duration(milliseconds: 600));
  }

  /// Lets route transitions and entrance animations finish.
  Future<void> settle(WidgetTester tester) async {
    for (int i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> typePin(WidgetTester tester, String pin) async {
    for (final String d in pin.split('')) {
      await tester.tap(find.text(d).last);
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  group('splash routing', () {
    test('first launch goes to onboarding', () async {
      await seed(user: null, onboardingSeen: false, loggedIn: false);
      expect(SplashScreen.nextRoute(), AppRoutes.onboarding);
    });

    test('no account goes to sign-up', () async {
      await seed(user: null, loggedIn: false);
      expect(SplashScreen.nextRoute(), AppRoutes.createAccount);
    });

    test('locked account goes to the lock screen', () async {
      await seed(loggedIn: false);
      expect(SplashScreen.nextRoute(), AppRoutes.lock);
    });

    test('unlocked account goes straight in', () async {
      await seed();
      expect(SplashScreen.nextRoute(), AppRoutes.shell);
    });
  });

  testWidgets('sign up: fill the form, set and confirm a PIN, land on Home',
      (WidgetTester tester) async {
    await seed(user: null, loggedIn: false);
    await open(tester, const CreateAccountScreen());

    await tester.enterText(find.byType(TextField).at(0), 'Sara');
    await tester.enterText(find.byType(TextField).at(2), '60');
    await tester.pump();

    await tester.tap(find.text('Set a 4-digit PIN'));
    await settle(tester);
    expect(find.text('Create a PIN'), findsOneWidget);
    await typePin(tester, '2468');
    expect(find.text('Confirm your PIN'), findsOneWidget);
    await typePin(tester, '2468');
    await settle(tester);

    expect(find.text('PIN is set ✓'), findsOneWidget);
    await tester.tap(find.text('Create account'));
    await settle(tester);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Sara'), findsWidgets);
    expect(AppPreferences.instance.user.pin, '2468');
    expect(AppPreferences.instance.isLoggedIn, isTrue);
  });

  testWidgets('PIN confirmation mismatch starts over',
      (WidgetTester tester) async {
    await seed(user: null, loggedIn: false);
    await open(tester, const CreateAccountScreen());
    await tester.tap(find.text('Set a 4-digit PIN'));
    await settle(tester);
    await typePin(tester, '1111');
    await typePin(tester, '2222');
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text("The PINs didn't match. Try again."), findsOneWidget);
    expect(find.text('Create a PIN'), findsOneWidget);
  });

  testWidgets('lock screen rejects a wrong PIN and opens with the right one',
      (WidgetTester tester) async {
    await seed(loggedIn: false);
    await open(tester, const LockScreen());
    expect(find.text('Welcome back, Yana'), findsOneWidget);

    await typePin(tester, '0000');
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Wrong PIN, try again'), findsOneWidget);

    await typePin(tester, '1234');
    await settle(tester);
    expect(find.byType(BottomNavBarScreen), findsOneWidget);
  });

  testWidgets('add a transaction from the shell and see it on Home',
      (WidgetTester tester) async {
    await seed();
    await open(tester, const BottomNavBarScreen());
    expect(find.text('No transactions yet'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Add transaction').first);
    await settle(tester);
    expect(find.text('New transaction'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '35');
    await tester.tap(find.text('Food'));
    await tester.pump();
    await tester.tap(find.text('Save transaction'));
    await settle(tester);

    expect(find.text('New transaction'), findsNothing);
    expect(find.text('Food'), findsWidgets);
    expect(find.text(r'$ 65'), findsOneWidget); // left today: 100 - 35
    expect(AppPreferences.instance.operations.single.amount, 35);
  });

  testWidgets('edit a transaction, then delete it',
      (WidgetTester tester) async {
    await seed(
      operations: <OperationModel>[op(food, 20, DateTime.now())],
    );
    await open(tester, const BottomNavBarScreen());

    await tester.tap(find.text('Food').first);
    await settle(tester);
    expect(find.text('Edit transaction'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '25');
    await tester.tap(find.text('Save changes'));
    await settle(tester);
    expect(AppPreferences.instance.operations.single.amount, 25);

    await tester.tap(find.text('Food').first);
    await settle(tester);
    await tester.tap(find.byTooltip('Delete'));
    await settle(tester);
    await tester.tap(find.widgetWithText(InkWell, 'Delete').last);
    await settle(tester);

    expect(AppPreferences.instance.operations, isEmpty);
    expect(find.text('No transactions yet'), findsOneWidget);
  });

  testWidgets('settings: language sheet lists both, clear transactions works',
      (WidgetTester tester) async {
    await seed(
      operations: <OperationModel>[op(food, 20, DateTime.now())],
    );
    await open(tester, const BottomNavBarScreen());

    await tester.tap(find.text('Settings').last);
    await settle(tester);
    await tester.tap(find.text('Language'));
    await settle(tester);
    expect(find.text('العربية'), findsOneWidget);
    await tester.tapAt(const Offset(200, 80)); // dismiss the sheet
    await settle(tester);

    await tester.tap(find.text('Clear all transactions'));
    await settle(tester);
    await tester.tap(find.widgetWithText(InkWell, 'Clear').last);
    await settle(tester);
    expect(AppPreferences.instance.operations, isEmpty);

    await tester.tap(find.text('Home').last);
    await settle(tester);
    expect(find.text('No transactions yet'), findsOneWidget);
  });
}
