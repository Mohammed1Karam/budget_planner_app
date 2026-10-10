import 'package:budget_planner/getx_controller/home_controller.dart';
import 'package:budget_planner/getx_controller/stats_controller.dart';
import 'package:budget_planner/models/category_model.dart';
import 'package:budget_planner/models/operation_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

void main() {
  const CategoryModel shopping = CategoryModel(
    id: 'shopping',
    name: 'Shopping',
    emoji: '🛍️',
    type: OperationType.expense,
  );

  late StatsController stats;

  Future<void> setup(List<OperationModel> ops) async {
    await seed(operations: ops);
    await Get.put(HomeController()).load();
    stats = Get.put(StatsController());
  }

  tearDown(Get.reset);

  test('month totals, net and count', () async {
    final DateTime now = DateTime.now();
    await setup(<OperationModel>[
      op(food, 30, now),
      op(shopping, 70, now),
      op(salary, 1000, now),
      op(food, 999, DateTime(now.year, now.month - 1, 3)),
    ]);
    expect(stats.expenses, 100);
    expect(stats.income, 1000);
    expect(stats.net, 900);
    expect(stats.count, 3);
  });

  test('breakdown groups by category, largest first, distinct colours',
      () async {
    final DateTime now = DateTime.now();
    await setup(<OperationModel>[
      op(food, 30, now),
      op(food, 20, now),
      op(shopping, 70, now),
      op(salary, 1000, now),
    ]);
    final List<CategorySlice> slices = stats.breakdown;
    expect(slices.map((CategorySlice s) => s.category.id),
        <String>['shopping', 'food']);
    expect(slices.last.amount, 50);
    expect(slices.last.count, 2);
    expect(slices.first.color, isNot(slices.last.color));

    stats.setType(OperationType.income);
    expect(stats.breakdown.single.category.id, 'salary');
  });

  test('month navigation stops at the current month', () async {
    await setup(<OperationModel>[]);
    expect(stats.isCurrentMonth, isTrue);
    stats.nextMonth();
    expect(stats.isCurrentMonth, isTrue);

    final DateTime before = stats.month.value;
    stats.previousMonth();
    expect(stats.month.value.isBefore(before), isTrue);
    expect(stats.isCurrentMonth, isFalse);
    stats.nextMonth();
    expect(stats.month.value, before);
  });

  test('last seven days ends today and sums only expenses', () async {
    final DateTime now = DateTime.now();
    await setup(<OperationModel>[
      op(food, 10, now),
      op(food, 5, DateTime(now.year, now.month, now.day - 6, 12)),
      op(food, 99, DateTime(now.year, now.month, now.day - 7, 12)),
      op(salary, 500, now),
    ]);
    final List<DayTotal> week = stats.lastSevenDays;
    expect(week, hasLength(7));
    expect(week.last.amount, 10);
    expect(week.first.amount, 5);
    expect(week.fold<double>(0, (double s, DayTotal d) => s + d.amount), 15);
  });
}
