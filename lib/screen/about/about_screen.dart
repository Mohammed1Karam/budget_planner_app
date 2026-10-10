import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/app_theme.dart';
import '../../widget/app_card.dart';
import '../../widget/app_logo.dart';
import '../../widget/app_scaffold.dart';

/// About: the mark, the product name, what it does, and the version.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  /// Kept here so the screen stays a pure widget; wire it to
  /// package_info_plus when the build number matters.
  static const String version = '2.0.0';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget feature(IconData icon, String key) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: p.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: p.primary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(key.tr, style: context.text.bodyLarge)),
            ],
          ),
        );

    return AppScaffold(
      title: 'about_app'.tr,
      body: ListView(
        padding: const EdgeInsets.only(top: 24, bottom: 32),
        children: <Widget>[
          const Center(child: AppLogo(size: 96)),
          const SizedBox(height: 22),
          Text(
            'app_name'.tr,
            textAlign: TextAlign.center,
            style: context.text.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'version_value'.trParams(<String, String>{'version': version}),
            textAlign: TextAlign.center,
            style: context.text.bodySmall,
          ),
          const SizedBox(height: 22),
          Text(
            'about_body'.tr,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium,
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              children: <Widget>[
                feature(Icons.speed_rounded, 'about_feature_limit'),
                feature(Icons.pie_chart_rounded, 'about_feature_stats'),
                feature(Icons.lock_rounded, 'about_feature_private'),
                feature(Icons.translate_rounded, 'about_feature_language'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
