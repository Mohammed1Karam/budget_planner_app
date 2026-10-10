import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/app_controller.dart';
import '../../preferences/app_preferences.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_theme.dart';
import '../../widget/app_sheets.dart';
import '../../widget/fill_or_scroll.dart';
import '../../widget/pin_keypad.dart';

/// The PIN lock a returning user opens the app with. Four digits unlock it
/// straight away; a wrong PIN shakes the dots and clears them.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  static const int _length = 4;

  String _entered = '';
  bool _error = false;
  int _errorTick = 0;

  AppController get _app => Get.find<AppController>();

  Future<void> _onDigit(String digit) async {
    if (_entered.length >= _length) return;
    setState(() {
      _error = false;
      _entered += digit;
    });
    if (_entered.length < _length) return;

    if (_app.verifyPin(_entered)) {
      await AppPreferences.instance.setLoggedIn(true);
      await Get.offAllNamed<void>(AppRoutes.shell);
      return;
    }
    setState(() {
      _error = true;
      _errorTick++;
      _entered = '';
    });
  }

  void _onBackspace() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _forgot() async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'forgot_pin_title'.tr,
      message: 'forgot_pin_body'.tr,
      confirmLabel: 'reset'.tr,
      icon: Icons.restart_alt_rounded,
    );
    if (!confirmed) return;
    await _app.deleteAccount();
    await Get.offAllNamed<void>(AppRoutes.createAccount);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final String name = _app.user.value.name;

    return Scaffold(
      body: SafeArea(
        child: FillOrScroll(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 40),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: p.heroGradient,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  name.isEmpty ? '🙂' : name.characters.first.toUpperCase(),
                  style: context.text.headlineMedium
                      ?.copyWith(color: p.accent),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'welcome_back_name'.trParams(<String, String>{'name': name}),
                textAlign: TextAlign.center,
                style: context.text.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _error ? 'wrong_pin'.tr : 'enter_pin_to_unlock'.tr,
                style: context.text.bodyMedium
                    ?.copyWith(color: _error ? p.danger : null),
              ),
              const SizedBox(height: 36),
              PinDots(
                length: _length,
                filled: _entered.length,
                error: _error,
                errorTick: _errorTick,
              ),
              const Spacer(),
              const SizedBox(height: 32),
              PinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _forgot,
                child: Text(
                  'forgot_pin'.tr,
                  style: context.text.labelLarge?.copyWith(color: p.primary),
                ),
              ),
              const SizedBox(height: AppDimens.gap12),
            ],
          ),
        ),
      ),
    );
  }
}
