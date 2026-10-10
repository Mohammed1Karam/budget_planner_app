import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_dimens.dart';
import '../utils/app_theme.dart';

/// A label over a filled input, with an optional leading icon.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.keyboardType,
    this.onChanged,
    this.inputFormatters,
    this.errorText,
    this.prefixText,
    this.maxLines = 1,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final String? prefixText;
  final int maxLines;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            label,
            style:
                context.text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          textInputAction: textInputAction,
          style: context.text.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            // A currency symbol takes the icon slot so it is always visible,
            // not only once the field is focused as prefixText would be.
            prefixIcon: prefixText != null
                ? SizedBox(
                    width: 48,
                    child: Center(
                      child: Text(
                        prefixText!.trim(),
                        style: context.text.titleSmall
                            ?.copyWith(color: p.primary),
                      ),
                    ),
                  )
                : icon == null
                    ? null
                    : Icon(icon, color: p.textMuted, size: 21),
          ),
        ),
      ],
    );
  }
}

/// A tappable row styled like [AppTextField], for values chosen from a sheet
/// or another screen rather than typed.
class AppPickerField extends StatelessWidget {
  const AppPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.icon,
    this.leading,
    this.placeholder = false,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData? icon;

  /// Shown instead of [icon], e.g. a flag.
  final Widget? leading;

  /// Renders [value] in the hint colour, for "not set yet".
  final bool placeholder;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            label,
            style:
                context.text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Material(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            child: SizedBox(
              height: AppDimens.fieldHeight,
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 24,
                    child: Center(
                      child: leading ??
                          (icon == null
                              ? const SizedBox.shrink()
                              : Icon(icon, color: p.textMuted, size: 21)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyLarge?.copyWith(
                        color: placeholder ? p.textMuted : p.textPrimary,
                      ),
                    ),
                  ),
                  Icon(Icons.expand_more_rounded, color: p.textMuted),
                  const SizedBox(width: 14),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The search box over a list.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.onChanged,
    required this.hint,
    this.controller,
  });

  final ValueChanged<String> onChanged;
  final String hint;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: context.text.bodyLarge,
      decoration: InputDecoration(
        hintText: hint,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        prefixIcon: Icon(Icons.search_rounded, color: p.textMuted),
      ),
    );
  }
}

/// Only digits and one decimal separator.
final List<TextInputFormatter> amountFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d{0,2}')),
  LengthLimitingTextInputFormatter(12),
];
