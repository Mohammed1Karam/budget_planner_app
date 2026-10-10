import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/app_controller.dart';
import '../../getx_controller/home_controller.dart';
import '../../getx_controller/stats_controller.dart';
import '../../models/category_model.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_format.dart';
import '../../utils/app_theme.dart';
import '../../widget/app_back_button.dart';
import '../../widget/app_card.dart';
import '../../widget/category_tile.dart';
import '../../widget/charts.dart';
import '../../widget/hero_surface.dart';
import '../../widget/segmented_toggle.dart';

/// Statistics: pick a month, see income vs expenses and net, where the money
/// went by category, and the last seven days against the daily limit.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StatsController stats = Get.find<StatsController>();
    final HomeController home = Get.find<HomeController>();
    final AppController app = Get.find<AppController>();
    final p = context.palette;

    return SafeArea(
      bottom: false,
      child: Obx(() {
        // Read so the tab rebuilds when a transaction is added or removed.
        home.operations.length;
        final String symbol = app.currencySymbol;
        final List<CategorySlice> slices = stats.breakdown;
        final double sliceTotal =
            slices.fold<double>(0, (double s, CategorySlice c) => s + c.amount);
        final List<DayTotal> week = stats.lastSevenDays;
        final bool expense = stats.type.value == OperationType.expense;

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.screenPadding,
            16,
            AppDimens.screenPadding,
            120,
          ),
          children: <Widget>[
            Text('statistics'.tr, style: context.text.headlineMedium),
            const SizedBox(height: 16),
            _MonthSwitcher(stats: stats),
            const SizedBox(height: 16),
            _Summary(stats: stats, symbol: symbol),
            const SizedBox(height: 24),
            SectionHeader(title: 'by_category'.tr),
            SegmentedToggle(
              labels: <String>['expenses'.tr, 'income'.tr],
              icons: const <IconData>[
                Icons.north_east_rounded,
                Icons.south_west_rounded,
              ],
              colors: <Color>[p.expense, p.income],
              selectedIndex: expense ? 0 : 1,
              onChanged: (int i) => stats.setType(
                i == 0 ? OperationType.expense : OperationType.income,
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              padding: const EdgeInsets.all(20),
              child: slices.isEmpty
                  ? EmptyState(
                      icon: Icons.donut_large_rounded,
                      title: 'no_data_month'.tr,
                      message: 'no_data_month_body'.tr,
                    )
                  : Column(
                      children: <Widget>[
                        DonutChart(
                          key: ValueKey<String>(
                            '${stats.month.value}-${stats.type.value}',
                          ),
                          values: <double>[
                            for (final CategorySlice s in slices) s.amount,
                          ],
                          colors: <Color>[
                            for (final CategorySlice s in slices) s.color,
                          ],
                          center: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                expense ? 'total_spent'.tr : 'total_earned'.tr,
                                style: context.text.labelMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppFormat.money(sliceTotal, symbol),
                                textDirection: TextDirection.ltr,
                                style: context.text.titleLarge,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        for (final CategorySlice s in slices)
                          _SliceRow(
                            slice: s,
                            share: sliceTotal == 0 ? 0 : s.amount / sliceTotal,
                            symbol: symbol,
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'last_7_days'.tr),
            AppCard(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'spent_this_week'.tr,
                    style: context.text.labelMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppFormat.money(
                      week.fold<double>(
                        0,
                        (double s, DayTotal d) => s + d.amount,
                      ),
                      symbol,
                    ),
                    textDirection: TextDirection.ltr,
                    style: context.text.titleLarge,
                  ),
                  const SizedBox(height: 18),
                  WeeklyBars(
                    values: <double>[for (final DayTotal d in week) d.amount],
                    labels: <String>[
                      for (final DayTotal d in week)
                        AppFormat.weekdayShort(d.day),
                    ],
                    limit: home.dailyLimit,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _MonthSwitcher extends StatelessWidget {
  const _MonthSwitcher({required this.stats});

  final StatsController stats;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: <Widget>[
        AppIconButton(
          icon: Icons.chevron_left_rounded,
          tooltip: 'previous_month'.tr,
          onTap: stats.previousMonth,
        ),
        Expanded(
          child: Text(
            AppFormat.monthYear(stats.month.value),
            textAlign: TextAlign.center,
            style: context.text.titleMedium,
          ),
        ),
        AppIconButton(
          icon: Icons.chevron_right_rounded,
          tooltip: 'next_month'.tr,
          color: stats.isCurrentMonth ? p.textMuted : null,
          onTap: stats.isCurrentMonth ? null : stats.nextMonth,
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.stats, required this.symbol});

  final StatsController stats;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final double net = stats.net;
    return HeroSurface(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(AppDimens.radiusHero),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'net_balance'.tr,
            style: context.text.bodyMedium
                ?.copyWith(color: p.onHero.withValues(alpha: 0.72)),
          ),
          const SizedBox(height: 4),
          Text(
            AppFormat.money(net, symbol),
            textDirection: TextDirection.ltr,
            style: context.text.displaySmall?.copyWith(
              color: net >= 0 ? p.accent : const Color(0xFFFFA3A5),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: _Pill(
                  icon: Icons.south_west_rounded,
                  label: 'income'.tr,
                  value: AppFormat.money(stats.income, symbol),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Pill(
                  icon: Icons.north_east_rounded,
                  label: 'expenses'.tr,
                  value: AppFormat.money(stats.expenses, symbol),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'transactions_count'.trParams(
              <String, String>{'count': '${stats.count}'},
            ),
            style: context.text.labelSmall
                ?.copyWith(color: p.onHero.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: p.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: context.text.labelSmall
                      ?.copyWith(color: p.onHero.withValues(alpha: 0.65)),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    value,
                    textDirection: TextDirection.ltr,
                    style:
                        context.text.titleSmall?.copyWith(color: p.onHero),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SliceRow extends StatelessWidget {
  const _SliceRow({
    required this.slice,
    required this.share,
    required this.symbol,
  });

  final CategorySlice slice;
  final double share;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: <Widget>[
          CategoryAvatar(category: slice.category, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        slice.category.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleSmall,
                      ),
                    ),
                    Text(
                      AppFormat.money(slice.amount, symbol),
                      textDirection: TextDirection.ltr,
                      style: context.text.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusPill),
                        child: LinearProgressIndicator(
                          value: share,
                          minHeight: 6,
                          backgroundColor: p.surfaceAlt,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(slice.color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${(share * 100).round()}%',
                        textAlign: TextAlign.end,
                        style: context.text.labelSmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
