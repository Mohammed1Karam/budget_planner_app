import 'package:flutter/material.dart';

import '../utils/app_dimens.dart';
import '../utils/app_theme.dart';

/// A titled card holding a run of [SettingTile]s separated by hairlines.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.gap20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 6, bottom: 8),
              child: Text(
                title!,
                style: context.text.labelMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
              boxShadow: p.cardShadow,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < children.length; i++) ...<Widget>[
                    children[i],
                    if (i < children.length - 1)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 64),
                        child: Divider(color: p.border),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A row with a tinted icon, a label, and an optional value or chevron.
class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.value,
    this.trailing,
    this.color,
    this.tintLabel = true,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  /// A short read-out before the chevron, e.g. the current language.
  final String? value;

  /// Replaces the value and chevron, for a row that carries a switch.
  final Widget? trailing;

  /// Tints the icon and label, e.g. red for destructive rows.
  final Color? color;

  /// Off to tint only the icon, for a colour too light to read as text.
  final bool tintLabel;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final Color accent = color ?? p.primary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              ),
              child: Icon(icon, size: 20, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleSmall?.copyWith(
                  color: tintLabel ? (color ?? p.textPrimary) : p.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else ...<Widget>[
              if (value != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: Text(value!, style: context.text.bodyMedium),
                ),
              if (showChevron)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 4),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: p.textMuted,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
