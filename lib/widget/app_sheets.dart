import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/currency_model.dart';
import '../utils/app_dimens.dart';
import '../utils/app_theme.dart';
import 'primary_button.dart';

/// A bottom sheet listing options with a check on the current one; resolves
/// to the picked value, or null if dismissed.
Future<T?> showOptionSheet<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required T selected,
  required String Function(T) labelOf,
  Widget Function(T)? leadingOf,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) {
      final p = sheetContext.palette;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.75,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(title, style: sheetContext.text.titleLarge),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  children: <Widget>[
                    for (final T option in options)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Material(
                          color: option == selected
                              ? p.primarySoft
                              : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusMedium),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusMedium,
                              ),
                            ),
                            leading: leadingOf?.call(option),
                            title: Text(
                              labelOf(option),
                              style: sheetContext.text.titleSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: option == selected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: p.primary,
                                  )
                                : null,
                            onTap: () =>
                                Navigator.of(sheetContext).pop(option),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<CurrencyModel?> showCurrencySheet(
  BuildContext context, {
  required CurrencyModel selected,
}) {
  return showOptionSheet<CurrencyModel>(
    context,
    title: 'currency'.tr,
    options: CurrencyModel.all,
    selected: selected,
    labelOf: (CurrencyModel c) => '${c.name} (${c.code})',
    leadingOf: (CurrencyModel c) =>
        Text(c.flag, style: const TextStyle(fontSize: 26)),
  );
}

/// A confirmation dialog; resolves to true only when the user confirms.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = true,
  IconData icon = Icons.delete_outline_rounded,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      final p = dialogContext.palette;
      final Color accent = destructive ? p.danger : p.primary;
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: dialogContext.text.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: dialogContext.text.bodyMedium,
              ),
              const SizedBox(height: 22),
              Row(
                children: <Widget>[
                  Expanded(
                    child: PrimaryButton(
                      label: 'cancel'.tr,
                      tone: ButtonTone.ghost,
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryButton(
                      label: confirmLabel,
                      tone: destructive ? ButtonTone.danger : ButtonTone.filled,
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}

/// A short floating confirmation at the bottom of the screen.
void showToast(String message, {IconData icon = Icons.check_circle_rounded}) {
  final BuildContext? context = Get.context;
  if (context == null) return;
  final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final p = context.palette;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 2200),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        content: Row(
          children: <Widget>[
            Icon(icon, color: p.accent, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}
