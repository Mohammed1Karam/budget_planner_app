import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// The app mark: a wallet glyph on a lime tile with a small emerald coin.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: p.accent,
              borderRadius: BorderRadius.circular(size * 0.3),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: size * 0.3,
                  offset: Offset(0, size * 0.1),
                ),
              ],
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: size * 0.5,
              color: p.onAccent,
            ),
          ),
          PositionedDirectional(
            end: -size * 0.08,
            top: -size * 0.08,
            child: Container(
              width: size * 0.32,
              height: size * 0.32,
              decoration: BoxDecoration(
                color: p.heroEnd,
                shape: BoxShape.circle,
                border: Border.all(color: p.accent, width: size * 0.04),
              ),
              child: Icon(
                Icons.attach_money_rounded,
                size: size * 0.2,
                color: p.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
