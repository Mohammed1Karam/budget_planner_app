import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../models/currency_model.dart';
import '../models/user_model.dart';
import '../preferences/app_preferences.dart';
import '../utils/app_routes.dart';
import 'app_controller.dart';

/// The create-account form.
///
/// The account lives on this device only, so signing up is a name, the
/// currency, a daily spending limit and a PIN; the email is optional.
class AuthController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dailyLimitController = TextEditingController();

  final Rx<CurrencyModel> currency = CurrencyModel.usd.obs;
  final RxString pin = ''.obs;

  /// Bumped on every field change so the button's enabled state re-evaluates.
  final RxInt revision = 0.obs;

  final RxBool loading = false.obs;

  static const int pinLength = 4;

  void touch() => revision.value++;

  String get _email => emailController.text.trim();

  /// Empty is fine -- the email is optional -- but a typed one must be valid.
  bool get isEmailValid => _email.isEmpty || GetUtils.isEmail(_email);

  double get dailyLimit =>
      double.tryParse(dailyLimitController.text.replaceAll(',', '')) ?? 0;

  bool get canSubmit {
    revision.value; // read so Obx rebuilds when a field changes
    return nameController.text.trim().isNotEmpty &&
        isEmailValid &&
        dailyLimit > 0 &&
        pin.value.length == pinLength;
  }

  UserModel buildUser() => UserModel(
        name: nameController.text.trim(),
        email: _email,
        currencyCode: currency.value.code,
        dailyLimit: dailyLimit,
        pin: pin.value,
      );

  void selectCurrency(CurrencyModel value) {
    currency.value = value;
    touch();
  }

  void setPin(String value) {
    pin.value = value;
    touch();
  }

  Future<void> submit() async {
    if (!canSubmit) return;
    loading.value = true;
    try {
      await Get.find<AppController>().saveUser(buildUser());
      await AppPreferences.instance.setLoggedIn(true);
      await Get.offAllNamed<void>(AppRoutes.shell);
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    dailyLimitController.dispose();
    super.onClose();
  }
}
