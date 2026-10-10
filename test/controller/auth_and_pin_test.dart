import 'package:budget_planner/getx_controller/auth_controller.dart';
import 'package:budget_planner/getx_controller/pin_controller.dart';
import 'package:budget_planner/models/currency_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

void main() {
  group('AuthController', () {
    late AuthController auth;

    setUp(() async {
      await seed(user: null, loggedIn: false);
      auth = Get.put(AuthController());
    });

    tearDown(Get.reset);

    test('needs a name, a limit and a 4-digit PIN; email is optional', () {
      expect(auth.canSubmit, isFalse);
      auth.nameController.text = 'Sara';
      auth.dailyLimitController.text = '40';
      auth.touch();
      expect(auth.canSubmit, isFalse);
      auth.setPin('1234');
      expect(auth.canSubmit, isTrue);
    });

    test('a typed email must be valid', () {
      auth.nameController.text = 'Sara';
      auth.dailyLimitController.text = '40';
      auth.setPin('1234');
      auth.emailController.text = 'not-an-email';
      auth.touch();
      expect(auth.isEmailValid, isFalse);
      expect(auth.canSubmit, isFalse);
      auth.emailController.text = 'sara@example.com';
      auth.touch();
      expect(auth.canSubmit, isTrue);
    });

    test('buildUser carries every field', () {
      auth.nameController.text = '  Sara ';
      auth.dailyLimitController.text = '1,250';
      auth.selectCurrency(CurrencyModel.byCode('JOD'));
      auth.setPin('4321');
      final user = auth.buildUser();
      expect(user.name, 'Sara');
      expect(user.dailyLimit, 1250);
      expect(user.currencyCode, 'JOD');
      expect(user.pin, '4321');
    });
  });

  group('PinController', () {
    test('asks twice and returns the PIN when both match', () {
      final PinController pin = PinController();
      for (final String d in <String>['1', '2', '3']) {
        expect(pin.push(d), isNull);
      }
      expect(pin.push('4'), isNull);
      expect(pin.isConfirming, isTrue);
      expect(pin.entered.value, isEmpty);
      for (final String d in <String>['1', '2', '3']) {
        pin.push(d);
      }
      expect(pin.push('4'), '1234');
    });

    test('a mismatch flags an error and starts over', () {
      final PinController pin = PinController();
      for (final String d in <String>['1', '2', '3', '4']) {
        pin.push(d);
      }
      for (final String d in <String>['9', '9', '9']) {
        pin.push(d);
      }
      expect(pin.push('9'), isNull);
      expect(pin.error.value, isTrue);
      expect(pin.isConfirming, isFalse);
      pin.push('1');
      expect(pin.error.value, isFalse);
    });

    test('backspace removes the last digit only', () {
      final PinController pin = PinController();
      pin.backspace();
      pin.push('5');
      pin.push('6');
      pin.backspace();
      expect(pin.entered.value, '5');
    });
  });
}
