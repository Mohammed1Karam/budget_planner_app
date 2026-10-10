import 'package:flutter/material.dart';

import '../utils/app_dimens.dart';
import '../utils/app_theme.dart';

enum ButtonTone { filled, tonal, danger, ghost }

/// The one button shape in the app: a 56pt rounded bar.
///
/// A null [onPressed] renders it disabled; [loading] swaps the label for a
/// spinner and blocks taps.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.tone = ButtonTone.filled,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final ButtonTone tone;
  final bool expand;

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (Color bg, Color fg) = switch (tone) {
      ButtonTone.filled => (p.primary, p.onPrimary),
      ButtonTone.tonal => (p.primarySoft, p.primary),
      ButtonTone.danger => (p.dangerSoft, p.danger),
      ButtonTone.ghost => (Colors.transparent, p.textSecondary),
    };
    final Color background =
        _enabled || loading ? bg : p.surfaceAlt;
    final Color foreground = _enabled || loading ? fg : p.textMuted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: expand ? double.infinity : null,
      height: AppDimens.buttonHeight,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        boxShadow: tone == ButtonTone.filled && _enabled
            ? <BoxShadow>[
                BoxShadow(
                  color: p.primary.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: foreground,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (icon != null) ...<Widget>[
                          Icon(icon, size: 20, color: foreground),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.labelLarge
                                ?.copyWith(color: foreground),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
