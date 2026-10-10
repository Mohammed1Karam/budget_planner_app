import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/app_controller.dart';
import '../../getx_controller/home_controller.dart';
import '../../models/user_model.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_format.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_theme.dart';
import '../../widget/app_sheets.dart';
import '../../widget/hero_surface.dart';
import '../../widget/setting_tile.dart';

/// Settings: the profile card, preferences, categories, security, data and
/// about -- every row does something real.
class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  static const Map<String, String> _languages = <String, String>{
    'en_US': 'English',
    'ar_JO': 'العربية',
  };

  @override
  Widget build(BuildContext context) {
    final AppController app = Get.find<AppController>();
    final p = context.palette;

    return SafeArea(
      bottom: false,
      child: Obx(() {
        final UserModel user = app.user.value;
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.screenPadding,
            16,
            AppDimens.screenPadding,
            120,
          ),
          children: <Widget>[
            Text('settings'.tr, style: context.text.headlineMedium),
            const SizedBox(height: 16),
            _ProfileCard(user: user, symbol: app.currencySymbol),
            const SizedBox(height: 24),
            SettingsGroup(
              title: 'preferences'.tr,
              children: <Widget>[
                SettingTile(
                  icon: Icons.translate_rounded,
                  label: 'language'.tr,
                  value: _languages[app.localeCode.value] ?? 'English',
                  onTap: () async {
                    final String? code = await showOptionSheet<String>(
                      context,
                      title: 'language'.tr,
                      options: _languages.keys.toList(),
                      selected: app.localeCode.value,
                      labelOf: (String c) => _languages[c]!,
                    );
                    if (code != null) await app.changeLocale(code);
                  },
                ),
                SettingTile(
                  icon: Icons.dark_mode_outlined,
                  label: 'appearance'.tr,
                  value: 'theme_${app.themeMode.value.name}'.tr,
                  onTap: () async {
                    final ThemeMode? mode = await showOptionSheet<ThemeMode>(
                      context,
                      title: 'appearance'.tr,
                      options: ThemeMode.values,
                      selected: app.themeMode.value,
                      labelOf: (ThemeMode m) => 'theme_${m.name}'.tr,
                      leadingOf: (ThemeMode m) => Icon(switch (m) {
                        ThemeMode.light => Icons.light_mode_rounded,
                        ThemeMode.dark => Icons.dark_mode_rounded,
                        ThemeMode.system => Icons.brightness_auto_rounded,
                      }, color: p.primary),
                    );
                    if (mode != null) await app.changeThemeMode(mode);
                  },
                ),
                SettingTile(
                  icon: Icons.category_outlined,
                  label: 'categories'.tr,
                  onTap: () => Get.toNamed<void>(AppRoutes.categories),
                ),
              ],
            ),
            SettingsGroup(
              title: 'security'.tr,
              children: <Widget>[
                SettingTile(
                  icon: Icons.password_rounded,
                  label: 'change_pin'.tr,
                  onTap: () async {
                    final Object? pin = await Get.toNamed<Object?>(
                      AppRoutes.pinCode,
                    );
                    if (pin is String) {
                      await app.changePin(pin);
                      showToast('pin_changed'.tr);
                    }
                  },
                ),
                SettingTile(
                  icon: Icons.lock_outline_rounded,
                  label: 'lock_app'.tr,
                  showChevron: false,
                  onTap: () async {
                    await app.logout();
                    await Get.offAllNamed<void>(AppRoutes.lock);
                  },
                ),
              ],
            ),
            SettingsGroup(
              title: 'data'.tr,
              children: <Widget>[
                SettingTile(
                  icon: Icons.cleaning_services_outlined,
                  label: 'clear_transactions'.tr,
                  color: p.warningInk,
                  tintLabel: false,
                  showChevron: false,
                  onTap: () async {
                    final bool ok = await showConfirmDialog(
                      context,
                      title: 'clear_transactions'.tr,
                      message: 'clear_transactions_body'.tr,
                      confirmLabel: 'clear'.tr,
                      icon: Icons.cleaning_services_outlined,
                    );
                    if (!ok) return;
                    await Get.find<HomeController>().clearAll();
                    showToast('transactions_cleared'.tr);
                  },
                ),
                SettingTile(
                  icon: Icons.person_remove_outlined,
                  label: 'delete_account'.tr,
                  color: p.danger,
                  showChevron: false,
                  onTap: () async {
                    final bool ok = await showConfirmDialog(
                      context,
                      title: 'delete_account_title'.tr,
                      message: 'delete_account_body'.tr,
                      confirmLabel: 'delete'.tr,
                      icon: Icons.person_remove_outlined,
                    );
                    if (!ok) return;
                    await app.deleteAccount();
                    await Get.offAllNamed<void>(AppRoutes.createAccount);
                  },
                ),
              ],
            ),
            SettingsGroup(
              children: <Widget>[
                SettingTile(
                  icon: Icons.info_outline_rounded,
                  label: 'about_app'.tr,
                  onTap: () => Get.toNamed<void>(AppRoutes.about),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user, required this.symbol});

  final UserModel user;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return HeroSurface(
      onTap: () => Get.toNamed<void>(AppRoutes.profile),
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
      intensity: 0.8,
      child: Row(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.accent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              user.name.isEmpty
                  ? '🙂'
                  : user.name.characters.first.toUpperCase(),
              style: context.text.headlineSmall?.copyWith(color: p.onAccent),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleLarge?.copyWith(color: p.onHero),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email.isNotEmpty
                      ? user.email
                      : 'daily_limit_value'.trParams(<String, String>{
                          'value': AppFormat.money(user.dailyLimit, symbol),
                        }),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    color: p.onHero.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.edit_rounded, color: p.onHero, size: 18),
          ),
        ],
      ),
    );
  }
}
