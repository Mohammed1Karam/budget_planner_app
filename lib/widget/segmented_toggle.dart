import 'package:flutter/material.dart';

import '../utils/app_dimens.dart';
import '../utils/app_theme.dart';

/// A two-or-more way switch: the selected segment slides on a raised pill.
///
/// [colors] tints each segment's selected state, so Expense can go red and
/// Income green; without it every segment uses the primary colour.
class SegmentedToggle extends StatelessWidget {
  const SegmentedToggle({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.icons,
    this.colors,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<IconData>? icons;
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
      ),
      child: Row(
        children: List<Widget>.generate(labels.length, (int index) {
          final bool selected = index == selectedIndex;
          final Color accent = colors?[index] ?? p.primary;
          return Expanded(
            child: Semantics(
              button: true,
              selected: selected,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? p.surface : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusSmall),
                    boxShadow: selected ? p.cardShadow : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (icons != null) ...<Widget>[
                        Icon(
                          icons![index],
                          size: 18,
                          color: selected ? accent : p.textMuted,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          labels[index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.labelLarge?.copyWith(
                            fontSize: 14,
                            color: selected ? p.textPrimary : p.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
