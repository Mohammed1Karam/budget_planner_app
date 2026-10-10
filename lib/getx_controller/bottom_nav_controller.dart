import 'package:get/get.dart';

/// Which of the four tabs is showing.
class BottomNavController extends GetxController {
  final RxInt index = 0.obs;

  static const int home = 0;
  static const int transactions = 1;
  static const int statistics = 2;
  static const int settings = 3;

  void select(int value) => index.value = value;
}
