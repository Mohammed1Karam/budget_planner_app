import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/app_controller.dart';
import '../../getx_controller/bottom_nav_controller.dart';
import '../../getx_controller/home_controller.dart';
import '../../models/operation_model.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_format.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_theme.dart';
import '../../widget/app_card.dart';
import '../../widget/hero_surface.dart';
import '../../widget/operation_tile.dart';
import '../../widget/primary_button.dart';

/// Home: a greeting, today's budget on the gradient card, this month's
/// income and expenses, and the latest transactions.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final AppController app = Get.find<AppController>();

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: controller.load,
        child: Obx(() {
          final String symbol = app.currencySymbol;
          final List<OperationModel> recent = controller.recent;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.screenPadding,
              12,
              AppDimens.screenPadding,
              120,
            ),
            children: <Widget>[
              _Greeting(name: app.user.value.name),
              const SizedBox(height: 20),
              _BudgetCard(controller: controller, symbol: symbol),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _MonthStat(
                      label: 'month_income'.tr,
                      amount: controller.monthIncome,
                      symbol: symbol,
                      income: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MonthStat(
                      label: 'month_expenses'.tr,
                      amount: controller.monthExpenses,
                      symbol: symbol,
                      income: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SectionHeader(
                title: 'recent_transactions'.tr,
                actionLabel: recent.isEmpty ? null : 'see_all'.tr,
                onAction: () => Get.find<BottomNavController>()
                    .select(BottomNavController.transactions),
              ),
              if (recent.isEmpty)
                AppCard(
                  child: EmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: 'no_transactions_title'.tr,
                    message: 'no_transactions_body'.tr,
                    action: PrimaryButton(
                      label: 'add_transaction'.tr,
                      icon: Icons.add_rounded,
                      tone: ButtonTone.tonal,
                      expand: false,
                      onPressed: () =>
                          Get.toNamed<void>(AppRoutes.transactionForm),
                    ),
                  ),
                )
              else
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Column(
                    children: <Widget>[
                      for (final OperationModel operation in recent)
                        OperationTile(
                          operation: operation,
                          currencySymbol: symbol,
                          showDate: true,
                          onTap: () => Get.toNamed<void>(
                            AppRoutes.transactionForm,
                            arguments: operation,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name});

  final String name;

  String get _greetingKey {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning';
    if (hour < 18) return 'good_afternoon';
    return 'good_evening';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: () => Get.toNamed<void>(AppRoutes.profile),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: p.heroGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              name.isEmpty ? '🙂' : name.characters.first.toUpperCase(),
              style: context.text.titleLarge?.copyWith(color: p.accent),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_greetingKey.tr, style: context.text.bodyMedium),
              Text(
                name.isEmpty ? 'app_name'.tr : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleLarge,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.calendar_today_rounded, size: 14, color: p.primary),
              const SizedBox(width: 6),
              Text(
                AppFormat.dayMonthShort(DateTime.now()),
                style: context.text.labelMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Today's budget on the brand gradient: what is left, a progress bar, and
/// spent vs limit underneath.
class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.controller, required this.symbol});

  final HomeController controller;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bool noLimit = controller.dailyLimit <= 0;
    final bool reached = controller.hasReachedLimit;
    final bool near = controller.isNearLimit;
    final Color onHero = p.onHero;
    final Color soft = onHero.withValues(alpha: 0.72);
    final Color barColor =
        reached ? p.expense : (near ? p.warning : p.accent);

    return HeroSurface(
      padding: const EdgeInsets.all(22),
      borderRadius: BorderRadius.circular(AppDimens.radiusHero),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          // Decorative rings in the corner.
          PositionedDirectional(
            end: -60,
            top: -70,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: onHero.withValues(alpha: 0.08),
                  width: 26,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      noLimit ? 'spent_today'.tr : 'left_today'.tr,
                      style: context.text.bodyMedium?.copyWith(color: soft),
                    ),
                  ),
                  if (reached || near)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: (reached ? p.expense : p.warning)
                            .withValues(alpha: 0.9),
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            reached
                                ? Icons.error_outline_rounded
                                : Icons.warning_amber_rounded,
                            size: 14,
                            // Dark ink on the gold chip; white only reads on
                            // the red one.
                            color: reached ? Colors.white : p.onAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            reached ? 'limit_reached'.tr : 'near_limit'.tr,
                            style: context.text.labelSmall?.copyWith(
                              color: reached ? Colors.white : p.onAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppFormat.money(
                  noLimit ? controller.spentToday : controller.remainingToday,
                  symbol,
                ),
                textDirection: TextDirection.ltr,
                style: context.text.displayMedium?.copyWith(color: onHero),
              ),
              const SizedBox(height: 18),
              if (noLimit)
                Text(
                  'no_limit_set'.tr,
                  style: context.text.bodyMedium?.copyWith(color: soft),
                )
              else ...<Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(end: controller.todayProgress),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (BuildContext context, double v, _) =>
                        LinearProgressIndicator(
                      value: v,
                      minHeight: 10,
                      backgroundColor: onHero.withValues(alpha: 0.14),
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _HeroFigure(
                        label: 'spent_today'.tr,
                        value: AppFormat.money(controller.spentToday, symbol),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 34,
                      color: onHero.withValues(alpha: 0.16),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _HeroFigure(
                        label: 'daily_limit'.tr,
                        value: AppFormat.money(controller.dailyLimit, symbol),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroFigure extends StatelessWidget {
  const _HeroFigure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: context.text.labelSmall
              ?.copyWith(color: p.onHero.withValues(alpha: 0.65)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textDirection: TextDirection.ltr,
          style: context.text.titleMedium?.copyWith(color: p.onHero),
        ),
      ],
    );
  }
}

class _MonthStat extends StatelessWidget {
  const _MonthStat({
    required this.label,
    required this.amount,
    required this.symbol,
    required this.income,
  });

  final String label;
  final double amount;
  final String symbol;
  final bool income;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final Color accent = income ? p.income : p.expense;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: income ? p.incomeSoft : p.expenseSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              income
                  ? Icons.south_west_rounded
                  : Icons.north_east_rounded,
              size: 18,
              color: accent,
            ),
          ),
          const SizedBox(height: 12),
          Text(label, style: context.text.labelMedium),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              AppFormat.money(amount, symbol),
              textDirection: TextDirection.ltr,
              style: context.text.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}
