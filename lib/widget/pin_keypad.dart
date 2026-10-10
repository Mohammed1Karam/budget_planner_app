import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_dimens.dart';
import '../utils/app_theme.dart';

/// The 3x4 number pad: nine digits, then an empty slot, zero and backspace.
class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  static const List<List<String>> _rows = <List<String>>[
    <String>['1', '2', '3'],
    <String>['4', '5', '6'],
    <String>['7', '8', '9'],
  ];

  @override
  Widget build(BuildContext context) {
    // Digits read left-to-right in every language, like a phone dialler.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final List<String> row in _rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (final String digit in row)
                    _Key(
                      label: digit,
                      onTap: () => onDigit(digit),
                    ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(width: AppDimens.keypadKey + 28),
              _Key(label: '0', onTap: () => onDigit('0')),
              _Key(
                icon: Icons.backspace_outlined,
                onTap: onBackspace,
                plain: true,
                semanticLabel: 'backspace',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    this.label,
    this.icon,
    required this.onTap,
    this.plain = false,
    this.semanticLabel,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool plain;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Material(
        color: plain ? Colors.transparent : p.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: SizedBox(
            width: AppDimens.keypadKey,
            height: AppDimens.keypadKey,
            child: Center(
              child: icon != null
                  ? Icon(
                      icon,
                      color: p.textSecondary,
                      semanticLabel: semanticLabel,
                    )
                  : Text(
                      label!,
                      style: context.text.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A row of dots showing how many digits are in; shakes and turns red when
/// [errorTick] changes.
class PinDots extends StatelessWidget {
  const PinDots({
    super.key,
    required this.length,
    required this.filled,
    this.error = false,
    this.errorTick = 0,
  });

  final int length;
  final int filled;
  final bool error;

  /// Bump to replay the shake.
  final int errorTick;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return TweenAnimationBuilder<double>(
      key: ValueKey<int>(errorTick),
      tween: Tween<double>(begin: errorTick == 0 ? 1 : 0, end: 1),
      duration: const Duration(milliseconds: 420),
      builder: (BuildContext context, double t, Widget? child) {
        final double dx = math.sin(t * math.pi * 6) * (1 - t) * 14;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(length, (int index) {
          final bool on = index < filled;
          final Color color = error ? p.danger : p.primary;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: on ? 18 : 16,
            height: on ? 18 : 16,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: on || error ? color : Colors.transparent,
              border: Border.all(
                color: on || error ? color : p.textMuted,
                width: 2,
              ),
            ),
          );
        }),
      ),
    );
  }
}
