import 'package:get/get.dart';

/// Setting a new PIN: enter it, then enter it again to confirm.
///
/// [push] returns the finished PIN once both entries match, so the screen can
/// pop with it; a mismatch clears both and flags [error].
class PinController extends GetxController {
  final RxString entered = ''.obs;

  /// The first entry, held while the user confirms it.
  final RxString first = ''.obs;

  final RxBool error = false.obs;

  static const int length = 4;

  bool get isConfirming => first.value.isNotEmpty;

  String? push(String digit) {
    if (entered.value.length >= length) return null;
    error.value = false;
    entered.value += digit;
    if (entered.value.length < length) return null;

    if (!isConfirming) {
      first.value = entered.value;
      entered.value = '';
      return null;
    }
    if (entered.value == first.value) return entered.value;

    error.value = true;
    first.value = '';
    entered.value = '';
    return null;
  }

  void backspace() {
    final String value = entered.value;
    if (value.isEmpty) return;
    entered.value = value.substring(0, value.length - 1);
  }

  void restart() {
    first.value = '';
    entered.value = '';
    error.value = false;
  }
}
