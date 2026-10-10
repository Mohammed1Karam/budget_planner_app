import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../preferences/app_preferences.dart';
import '../utils/app_routes.dart';

/// Drives the three onboarding pages.
class OnboardingController extends GetxController {
  final PageController pageController = PageController();

  final RxInt page = 0.obs;

  static const List<OnboardingPage> pages = <OnboardingPage>[
    OnboardingPage(
      titleKey: 'onboarding_title_0',
      bodyKey: 'onboarding_body_0',
      icon: Icons.account_balance_wallet_rounded,
      chips: <IconData>[Icons.savings_rounded, Icons.payments_rounded],
    ),
    OnboardingPage(
      titleKey: 'onboarding_title_1',
      bodyKey: 'onboarding_body_1',
      icon: Icons.donut_large_rounded,
      chips: <IconData>[Icons.restaurant_rounded, Icons.shopping_bag_rounded],
    ),
    OnboardingPage(
      titleKey: 'onboarding_title_2',
      bodyKey: 'onboarding_body_2',
      icon: Icons.speed_rounded,
      chips: <IconData>[Icons.lock_rounded, Icons.trending_up_rounded],
    ),
  ];

  bool get isLast => page.value == pages.length - 1;

  String get actionKey => isLast ? 'get_started' : 'next';

  void onPageChanged(int index) => page.value = index;

  void next() {
    if (isLast) {
      finish();
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> finish() async {
    await AppPreferences.instance.setOnboardingSeen();
    await Get.offAllNamed<void>(AppRoutes.createAccount);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

/// The copy and artwork for one onboarding page.
class OnboardingPage {
  const OnboardingPage({
    required this.titleKey,
    required this.bodyKey,
    required this.icon,
    required this.chips,
  });

  final String titleKey;
  final String bodyKey;

  /// The large glyph in the centre of the artwork.
  final IconData icon;

  /// The two smaller glyphs floating around it.
  final List<IconData> chips;
}
