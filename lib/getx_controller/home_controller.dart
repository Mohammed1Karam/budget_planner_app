import 'package:get/get.dart';

import '../api/budget_api.dart';
import '../models/category_model.dart';
import '../models/operation_model.dart';
import '../utils/app_format.dart';
import 'app_controller.dart';

/// The transaction ledger, and everything Home and Transactions read from it.
class HomeController extends GetxController {
  HomeController({BudgetApi? api}) : _api = api ?? BudgetApi();

  final BudgetApi _api;

  /// Newest first.
  final RxList<OperationModel> operations = <OperationModel>[].obs;
  final RxBool loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      operations.assignAll(await _api.fetchOperations());
    } finally {
      loading.value = false;
    }
  }

  AppController get _app => Get.find<AppController>();

  double get dailyLimit => _app.user.value.dailyLimit;

  String get currencySymbol => _app.currencySymbol;

  /// Only expenses count towards the daily limit; income does not top it up.
  double get spentToday {
    final DateTime now = DateTime.now();
    return operations
        .where((o) => !o.isIncome && AppFormat.sameDay(o.date, now))
        .fold<double>(0, (sum, o) => sum + o.amount);
  }

  double get remainingToday =>
      dailyLimit <= 0 ? 0 : (dailyLimit - spentToday).clamp(0, dailyLimit);

  /// How much of today's limit is used, 0..1.
  double get todayProgress =>
      dailyLimit <= 0 ? 0 : (spentToday / dailyLimit).clamp(0.0, 1.0);

  bool get hasReachedLimit => dailyLimit > 0 && spentToday >= dailyLimit;

  /// Crossed 80% but not yet the limit.
  bool get isNearLimit => !hasReachedLimit && todayProgress >= 0.8;

  List<OperationModel> get recent => operations.take(5).toList();

  bool _inMonth(OperationModel o, DateTime month) =>
      o.date.year == month.year && o.date.month == month.month;

  double totalIn(DateTime month, OperationType type) => operations
      .where((o) => o.category.type == type && _inMonth(o, month))
      .fold<double>(0, (sum, o) => sum + o.amount);

  double get monthIncome => totalIn(DateTime.now(), OperationType.income);

  double get monthExpenses => totalIn(DateTime.now(), OperationType.expense);

  /// Groups [source] by calendar day, newest day first.
  static Map<DateTime, List<OperationModel>> groupByDay(
    Iterable<OperationModel> source,
  ) {
    final Map<DateTime, List<OperationModel>> grouped =
        <DateTime, List<OperationModel>>{};
    for (final OperationModel o in source) {
      final DateTime day = DateTime(o.date.year, o.date.month, o.date.day);
      grouped.putIfAbsent(day, () => <OperationModel>[]).add(o);
    }
    final List<DateTime> days = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    return <DateTime, List<OperationModel>>{
      for (final DateTime day in days) day: grouped[day]!,
    };
  }

  Map<DateTime, List<OperationModel>> get groupedByDay =>
      groupByDay(operations);

  Future<void> save(OperationModel operation) async {
    await _api.saveOperation(operation);
    await load();
  }

  Future<void> delete(String id) async {
    await _api.deleteOperation(id);
    operations.removeWhere((o) => o.id == id);
  }

  Future<void> clearAll() async {
    await _api.clearOperations();
    operations.clear();
  }
}
