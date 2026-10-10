import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/app_controller.dart';
import '../../getx_controller/auth_controller.dart';
import '../../models/currency_model.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_theme.dart';
import '../../widget/app_back_button.dart';
import '../../widget/app_logo.dart';
import '../../widget/app_sheets.dart';
import '../../widget/hero_surface.dart';
import '../../widget/money_field.dart';
import '../../widget/primary_button.dart';

/// Sign-up: a gradient header, then name, optional email, currency, daily
/// limit and PIN. The button lights up once everything required is in.
class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());
    final AppController app = Get.find<AppController>();
    final p = context.palette;

    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _Header(
                    onLanguage: () => app.changeLocale(
                      app.isArabic ? 'en_US' : 'ar_JO',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.screenPadding,
                      24,
                      AppDimens.screenPadding,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        AppTextField(
                          label: 'name'.tr,
                          hint: 'name_hint'.tr,
                          icon: Icons.person_outline_rounded,
                          controller: controller.nameController,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => controller.touch(),
                        ),
                        const SizedBox(height: 18),
                        Obx(() {
                          controller.revision.value;
                          return AppTextField(
                            label: 'email_optional'.tr,
                            hint: 'email_hint'.tr,
                            icon: Icons.alternate_email_rounded,
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            errorText: controller.isEmailValid
                                ? null
                                : 'email_invalid'.tr,
                            onChanged: (_) => controller.touch(),
                          );
                        }),
                        const SizedBox(height: 18),
                        Obx(
                          () => AppPickerField(
                            label: 'currency'.tr,
                            value:
                                '${controller.currency.value.name} (${controller.currency.value.code})',
                            leading: Text(
                              controller.currency.value.flag,
                              style: const TextStyle(fontSize: 20),
                            ),
                            onTap: () async {
                              final CurrencyModel? picked =
                                  await showCurrencySheet(
                                context,
                                selected: controller.currency.value,
                              );
                              if (picked != null) {
                                controller.selectCurrency(picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        Obx(
                          () => AppTextField(
                            label: 'daily_limit'.tr,
                            hint: '50',
                            prefixText:
                                '${controller.currency.value.symbol}  ',
                            controller: controller.dailyLimitController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: amountFormatters,
                            onChanged: (_) => controller.touch(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 6,
                            top: 6,
                          ),
                          child: Text(
                            'daily_limit_help'.tr,
                            style: context.text.bodySmall,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Obx(
                          () => AppPickerField(
                            label: 'pin_code'.tr,
                            value: controller.pin.value.isEmpty
                                ? 'set_your_pin'.tr
                                : 'pin_is_set'.tr,
                            placeholder: controller.pin.value.isEmpty,
                            icon: controller.pin.value.isEmpty
                                ? Icons.lock_outline_rounded
                                : Icons.verified_user_rounded,
                            onTap: () async {
                              final Object? pin =
                                  await Get.toNamed<Object?>(AppRoutes.pinCode);
                              if (pin is String) controller.setPin(pin);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.screenPadding,
                8,
                AppDimens.screenPadding,
                16,
              ),
              child: Obx(
                () => PrimaryButton(
                  label: 'create_account'.tr,
                  loading: controller.loading.value,
                  onPressed: controller.canSubmit ? controller.submit : null,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: p.background,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onLanguage});

  final VoidCallback onLanguage;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return HeroSurface(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(AppDimens.radiusHero + 8),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.screenPadding,
            8,
            AppDimens.screenPadding,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const AppLogo(size: 52),
                  const Spacer(),
                  AppIconButton(
                    icon: Icons.translate_rounded,
                    tooltip: 'language'.tr,
                    color: p.onHero,
                    background: Colors.white.withValues(alpha: 0.12),
                    onTap: onLanguage,
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Text(
                'create_account_title'.tr,
                style: context.text.headlineMedium?.copyWith(color: p.onHero),
              ),
              const SizedBox(height: 8),
              Text(
                'create_account_intro'.tr,
                style: context.text.bodyMedium?.copyWith(
                  color: p.onHero.withValues(alpha: 0.78),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
