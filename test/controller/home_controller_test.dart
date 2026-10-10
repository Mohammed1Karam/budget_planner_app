import 'package:budget_planner/getx_controller/home_controller.dart';
import 'package:budget_planner/models/operation_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

void main() {
  late HomeController controller;

  Future<void> setup(List<OperationModel> ops, {double limit = 100}) async {
    await seed(
      user: testUser.copyWith(dailyLimit: limit),
      operations: ops,
    );
    controller = Get.put(HomeController());
    await controller.load();
  }

  tearDown(Get.reset);

  test('an empty ledger keeps the whole limit', () async {
    await setup(<OperationModel>[]);
    expect(controller.spentToday, 0);
    expect(controller.remainingToday, 100);
    expect(controller.todayProgress, 0);
    expect(controller.hasReachedLimit, isFalse);
  });

  test('only today\'s expenses count, income does not offset them', () async {
    final DateTime now = DateTime.now();
    await setup(<OperationModel>[
      op(food, 30, now),
      op(food, 20, now),
      op(salary, 1000, now),
      op(food, 999, DateTime(now.year, now.month, now.day - 2)),
    ]);
    expect(controller.spentToday, 50);
    expect(controller.remainingToday, 50);
    expect(controller.todayProgress, closeTo(0.5, 1e-9));
  });

  test('near and reached limit flags', () async {
    final DateTime now = DateTime.now();
    await setup(<OperationModel>[op(food, 85, now)]);
    expect(controller.isNearLimit, isTrue);
    expect(controller.hasReachedLimit, isFalse);

    await setup(<OperationModel>[op(food, 120, now)]);
    expect(controller.hasReachedLimit, isTrue);
    expect(controller.isNearLimit, isFalse);
    expect(controller.remainingToday, 0);
    expect(controller.todayProgress, 1);
  });

  test('no limit means no progress and no flags', () async {
    await setup(<OperationModel>[op(food, 50, DateTime.now())], limit: 0);
    expect(controller.todayProgress, 0);
    expect(controller.hasReachedLimit, isFalse);
  });

  test('month totals ignore other months', () async {
    final DateTime now = DateTime.now();
    await setup(<OperationModel>[
      op(food, 40, now),
      op(salary, 500, now),
      op(food, 70, DateTime(now.year, now.month - 1, 10)),
    ]);
    expect(controller.monthExpenses, 40);
    expect(controller.monthIncome, 500);
  });

  test('operations load newest first and recent holds five', () async {
    final DateTime now = DateTime.now();
    await setup(<OperationModel>[
      for (int i = 0; i < 8; i++)
        op(food, i + 1.0, now.subtract(Duration(hours: i))),
    ]);
    expect(controller.operations.first.amount, 1);
    expect(controller.recent, hasLength(5));
  });

  test('groupByDay buckets per calendar day, newest day first', () async {
    final DateTime now = DateTime.now();
    final DateTime yesterday = DateTime(now.year, now.month, now.day - 1, 9);
    await setup(<OperationModel>[
      op(food, 1, now),
      op(food, 2, yesterday),
      op(food, 3, yesterday.add(const Duration(hours: 1))),
    ]);
    final Map<DateTime, List<OperationModel>> g = controller.groupedByDay;
    expect(g.keys.first.day, now.day);
    expect(g.values.elementAt(1), hasLength(2));
  });

  test('save, delete and clearAll persist', () async {
    await setup(<OperationModel>[]);
    final OperationModel o = op(food, 12, DateTime.now());
    await controller.save(o);
    expect(controller.operations, hasLength(1));

    await controller.delete(o.id);
    expect(controller.operations, isEmpty);

    await controller.save(op(food, 1, DateTime.now()));
    await controller.clearAll();
    await controller.load();
    expect(controller.operations, isEmpty);
  });
}
