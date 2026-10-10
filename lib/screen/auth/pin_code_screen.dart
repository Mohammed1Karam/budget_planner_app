import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/pin_controller.dart';
import '../../utils/app_theme.dart';
import '../../widget/app_scaffold.dart';
import '../../widget/fill_or_scroll.dart';
import '../../widget/pin_keypad.dart';

/// Sets a new PIN: type it, then type it again. Pops with the PIN once both
/// entries match.
class PinCodeScreen extends StatefulWidget {
  const PinCodeScreen({super.key});

  @override
  State<PinCodeScreen> createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  final PinController _controller = PinController();
  int _errorTick = 0;

  void _onDigit(String digit) {
    final String? done = _controller.push(digit);
    if (_controller.error.value) setState(() => _errorTick++);
    if (done != null) Get.back<String>(result: done);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppScaffold(
      body: FillOrScroll(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 12),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: p.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.lock_rounded, color: p.primary, size: 30),
            ),
            const SizedBox(height: 20),
            Obx(
              () => Text(
                _controller.isConfirming
                    ? 'confirm_pin'.tr
                    : 'create_pin'.tr,
                style: context.text.headlineSmall,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                _controller.error.value
                    ? 'pin_mismatch'.tr
                    : _controller.isConfirming
                        ? 'confirm_pin_body'.tr
                        : 'create_pin_body'.tr,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: _controller.error.value ? p.danger : null,
                ),
              ),
            ),
            const SizedBox(height: 36),
            Obx(
              () => PinDots(
                length: PinController.length,
                filled: _controller.entered.value.length,
                error: _controller.error.value,
                errorTick: _errorTick,
              ),
            ),
            const Spacer(),
            const SizedBox(height: 32),
            PinKeypad(
              onDigit: _onDigit,
              onBackspace: _controller.backspace,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
