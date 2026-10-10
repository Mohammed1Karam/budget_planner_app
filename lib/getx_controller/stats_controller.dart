import 'package:flutter/painting.dart';
import 'package:get/get.dart';

import '../models/category_model.dart';
import '../models/operation_model.dart';
import '../utils/app_colors.dart';
import 'home_controller.dart';

/// The Statistics tab: one month at a time, broken down by category, plus the
/// last seven days of spending.
///
/// Everything is computed from the ledger in [HomeController], so the numbers
/// always match what was actually recorded.
class StatsController extends GetxController {
  final Rx<DateTime> month = _monthOf(DateTime.now()).obs;
  final Rx<OperationType> type = OperationType.expense.obs;

  static DateTime _monthOf(DateTime d) => DateTime(d.year, d.month);

  HomeController get _home => Get.find<HomeController>();

  bool get isCurrentMonth => month.value == _monthOf(DateTime.now());

  void previousMonth() =>
      month.value = DateTime(month.value.year, month.value.month - 1);

  void nextMonth() {
    if (isCurrentMonth) return;
    month.value = DateTime(month.value.year, month.value.month + 1);
  }

  void setType(OperationType value) => type.value = value;

  Iterable<OperationModel> get _inMonth => _home.operations.where(
        (o) =>
            o.date.year == month.value.year &&
            o.date.month == month.value.month,
      );

  double get income => _home.totalIn(month.value, OperationType.income);

  double get expenses => _home.totalIn(month.value, OperationType.expense);

  double get net => income - expenses;

  int get count => _inMonth.length;

  /// Per-category totals for the selected side, largest first.
  List<CategorySlice> get breakdown {
    final Map<String, CategorySlice> byId = <String, CategorySlice>{};
    for (final OperationModel o
        in _inMonth.where((o) => o.category.type == type.value)) {
      final CategorySlice? existing = byId[o.category.id];
      byId[o.category.id] = CategorySlice(
        category: o.category,
        amount: (existing?.amount ?? 0) + o.amount,
        count: (existing?.count ?? 0) + 1,
      );
    }
    final List<CategorySlice> sorted = byId.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    // Colours go by rank so neighbouring slices never share one.
    return <CategorySlice>[
      for (int i = 0; i < sorted.length; i++)
        CategorySlice(
          category: sorted[i].category,
          amount: sorted[i].amount,
          count: sorted[i].count,
          color: AppPalette.categoryTints[i % AppPalette.categoryTints.length],
        ),
    ];
  }

  /// Spending for each of the last seven days, oldest first.
  List<DayTotal> get lastSevenDays {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    return List<DayTotal>.generate(7, (int i) {
      final DateTime day = DateTime(today.year, today.month, today.day - 6 + i);
      final double total = _home.operations
          .where(
            (o) =>
                !o.isIncome &&
                o.date.year == day.year &&
                o.date.month == day.month &&
                o.date.day == day.day,
          )
          .fold<double>(0, (sum, o) => sum + o.amount);
      return DayTotal(day: day, amount: total);
    });
  }
}

class CategorySlice {
  const CategorySlice({
    required this.category,
    required this.amount,
    required this.count,
    this.color = const Color(0xFF12996A),
  });

  final CategoryModel category;
  final double amount;
  final int count;
  final Color color;
}

class DayTotal {
  const DayTotal({required this.day, required this.amount});

  final DateTime day;
  final double amount;
}
