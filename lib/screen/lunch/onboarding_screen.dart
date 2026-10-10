import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/onboarding_controller.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_theme.dart';
import '../../widget/primary_button.dart';

/// Three pages introducing the app, each an illustration drawn from icons on
/// the brand gradient, with a title and a line of copy under it.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.put(OnboardingController());
    final p = context.palette;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Obx(
                  () => AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: controller.isLast ? 0 : 1,
                    child: TextButton(
                      onPressed: controller.isLast ? null : controller.finish,
                      child: Text(
                        'skip'.tr,
                        style: context.text.labelLarge
                            ?.copyWith(color: p.textSecondary),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: OnboardingController.pages.length,
                itemBuilder: (BuildContext context, int index) =>
                    _Page(page: OnboardingController.pages[index]),
              ),
            ),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                  OnboardingController.pages.length,
                  (int i) {
                    final bool on = i == controller.page.value;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: on ? 26 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: on ? p.primary : p.border,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusPill),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.screenPadding,
              ),
              child: Obx(
                () => PrimaryButton(
                  label: controller.actionKey.tr,
                  icon: controller.isLast
                      ? Icons.rocket_launch_rounded
                      : null,
                  onPressed: controller.next,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.page});

  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double art =
            (constraints.maxHeight * 0.55).clamp(160.0, 300.0);
        return SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _Artwork(page: page, size: art),
                const SizedBox(height: 36),
                Text(
                  page.titleKey.tr,
                  textAlign: TextAlign.center,
                  style: context.text.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  page.bodyKey.tr,
                  textAlign: TextAlign.center,
                  style: context.text.bodyLarge
                      ?.copyWith(color: context.palette.textSecondary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A gradient disc holding the page's glyph, with two small chips orbiting it.
class _Artwork extends StatelessWidget {
  const _Artwork({required this.page, required this.size});

  final OnboardingPage page;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget chip(IconData icon, Color bg, Color fg) => Container(
          width: size * 0.24,
          height: size * 0.24,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(size * 0.08),
            boxShadow: p.cardShadow,
          ),
          child: Icon(icon, color: fg, size: size * 0.12),
        );

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: p.primarySoft,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: size * 0.66,
            height: size * 0.66,
            decoration: BoxDecoration(
              gradient: p.heroGradient,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: p.heroEnd.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Icon(page.icon, color: p.accent, size: size * 0.3),
          ),
          PositionedDirectional(
            top: size * 0.04,
            end: size * 0.02,
            child: chip(page.chips[0], p.accent, p.onAccent),
          ),
          PositionedDirectional(
            bottom: size * 0.06,
            start: 0,
            child: chip(page.chips[1], p.surface, p.primary),
          ),
        ],
      ),
    );
  }
}
