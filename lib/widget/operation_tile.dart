import 'package:flutter/material.dart';

import '../models/operation_model.dart';
import '../utils/app_format.dart';
import '../utils/app_theme.dart';
import 'category_tile.dart';

/// One transaction: category avatar, name over note (or time), and the signed
/// amount at the end.
class OperationTile extends StatelessWidget {
  const OperationTile({
    super.key,
    required this.operation,
    required this.currencySymbol,
    this.onTap,
    this.showDate = false,
  });

  final OperationModel operation;
  final String currencySymbol;
  final VoidCallback? onTap;

  /// Shows the day instead of the time, for lists not grouped by day.
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final String when = showDate
        ? AppFormat.relativeDay(operation.date)
        : AppFormat.time(operation.date);
    final String subtitle =
        operation.note.isEmpty ? when : '${operation.note} · $when';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: <Widget>[
            CategoryAvatar(category: operation.category),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    operation.category.displayName,
                    style: context.text.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.text.bodySmall
                        ?.copyWith(color: p.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppFormat.money(
                operation.amount,
                currencySymbol,
                income: operation.isIncome,
              ),
              textDirection: TextDirection.ltr,
              style: context.text.titleSmall?.copyWith(
                color: operation.isIncome ? p.income : p.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The header over one day of transactions, with that day's net total.
class OperationDayHeader extends StatelessWidget {
  const OperationDayHeader({
    super.key,
    required this.date,
    required this.net,
    required this.currencySymbol,
  });

  final DateTime date;
  final double net;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              AppFormat.relativeDay(date),
              style: context.text.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            AppFormat.money(net, currencySymbol),
            textDirection: TextDirection.ltr,
            style: context.text.labelMedium?.copyWith(
              color: net >= 0 ? p.income : p.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
