import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/app_controller.dart';
import '../../getx_controller/home_controller.dart';
import '../../models/category_model.dart';
import '../../models/operation_model.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_theme.dart';
import '../../widget/app_card.dart';
import '../../widget/app_sheets.dart';
import '../../widget/money_field.dart';
import '../../widget/operation_tile.dart';
import '../../widget/segmented_toggle.dart';

/// Every transaction, searchable, filterable by side, grouped by day with each
/// day's net total. Tap a row to edit it; swipe it away to delete.
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _search = TextEditingController();

  String _query = '';

  /// null shows both sides.
  OperationType? _filter;

  HomeController get _controller => Get.find<HomeController>();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(OperationModel o) {
    if (_filter != null && o.category.type != _filter) return false;
    if (_query.isEmpty) return true;
    final String q = _query.toLowerCase();
    return o.category.displayName.toLowerCase().contains(q) ||
        o.category.name.toLowerCase().contains(q) ||
        o.note.toLowerCase().contains(q) ||
        o.amount.toString().contains(q);
  }

  Future<bool> _confirmDelete(OperationModel operation) {
    return showConfirmDialog(
      context,
      title: 'delete_transaction_title'.tr,
      message: 'delete_transaction_body'.tr,
      confirmLabel: 'delete'.tr,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppController app = Get.find<AppController>();
    final p = context.palette;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 16),
            Text('transactions'.tr, style: context.text.headlineMedium),
            const SizedBox(height: 16),
            SearchField(
              controller: _search,
              hint: 'search_transactions'.tr,
              onChanged: (String v) => setState(() => _query = v.trim()),
            ),
            const SizedBox(height: 12),
            SegmentedToggle(
              labels: <String>['all'.tr, 'expenses'.tr, 'income'.tr],
              selectedIndex: _filter == null
                  ? 0
                  : _filter == OperationType.expense
                      ? 1
                      : 2,
              colors: <Color>[p.primary, p.expense, p.income],
              onChanged: (int i) => setState(
                () => _filter = i == 0
                    ? null
                    : i == 1
                        ? OperationType.expense
                        : OperationType.income,
              ),
            ),
            Expanded(
              child: Obx(() {
                final String symbol = app.currencySymbol;
                final bool hasAny = _controller.operations.isNotEmpty;
                final Map<DateTime, List<OperationModel>> grouped =
                    HomeController.groupByDay(
                  _controller.operations.where(_matches),
                );

                if (grouped.isEmpty) {
                  return ListView(
                    children: <Widget>[
                      EmptyState(
                        icon: hasAny
                            ? Icons.search_off_rounded
                            : Icons.receipt_long_rounded,
                        title: hasAny
                            ? 'no_results'.tr
                            : 'no_transactions_title'.tr,
                        message: hasAny
                            ? 'no_results_body'.tr
                            : 'no_transactions_body'.tr,
                      ),
                    ],
                  );
                }

                return ListView(
                  padding: const EdgeInsets.only(bottom: 120),
                  children: <Widget>[
                    for (final MapEntry<DateTime, List<OperationModel>> day
                        in grouped.entries) ...<Widget>[
                      OperationDayHeader(
                        date: day.key,
                        net: day.value.fold<double>(
                          0,
                          (double sum, OperationModel o) =>
                              sum + o.signedAmount,
                        ),
                        currencySymbol: symbol,
                      ),
                      AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Column(
                          children: <Widget>[
                            for (final OperationModel o in day.value)
                              Dismissible(
                                key: ValueKey<String>(o.id),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (_) => _confirmDelete(o),
                                onDismissed: (_) => _controller.delete(o.id),
                                background: Container(
                                  alignment: AlignmentDirectional.centerEnd,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    color: p.dangerSoft,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    color: p.danger,
                                  ),
                                ),
                                child: OperationTile(
                                  operation: o,
                                  currencySymbol: symbol,
                                  onTap: () => Get.toNamed<void>(
                                    AppRoutes.transactionForm,
                                    arguments: o,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
