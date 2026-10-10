import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/app_controller.dart';
import '../../preferences/app_preferences.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_theme.dart';
import '../../widget/app_logo.dart';
import '../../widget/hero_surface.dart';

/// The mark on the brand gradient, held for a beat while the app decides
/// where to go: onboarding, sign-up, the PIN lock, or straight in.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Where the app goes from here, read from what is stored on the device.
  static String nextRoute() {
    final AppPreferences prefs = AppPreferences.instance;
    final bool hasAccount = Get.find<AppController>().hasAccount;
    if (!prefs.onboardingSeen) return AppRoutes.onboarding;
    if (!hasAccount) return AppRoutes.createAccount;
    if (prefs.isLoggedIn) return AppRoutes.shell;
    return AppRoutes.lock;
  }

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    await Get.offAllNamed<void>(SplashScreen.nextRoute());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      body: HeroSurface(
        intensity: 1.2,
        child: SizedBox.expand(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutBack,
            builder: (BuildContext context, double t, Widget? child) =>
                Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: Transform.scale(scale: 0.85 + 0.15 * t, child: child),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const AppLogo(size: 104),
                const SizedBox(height: 28),
                Text(
                  'app_name'.tr,
                  style: context.text.headlineMedium
                      ?.copyWith(color: p.onHero),
                ),
                const SizedBox(height: 6),
                Text(
                  'app_tagline'.tr,
                  style: context.text.bodyMedium?.copyWith(
                    color: p.onHero.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
