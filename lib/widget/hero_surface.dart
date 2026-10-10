import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// The black hero surface: an ink gradient with a lime glow rising from one
/// corner and an orange one from the other, plus a hairline sheen on the edge.
///
/// This is the one splash of colour in an otherwise monochrome UI, used for
/// the cards that matter most -- today's budget, the month summary, the
/// profile, and the splash / sign-up headers.
class HeroSurface extends StatelessWidget {
  const HeroSurface({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.padding = EdgeInsets.zero,
    this.intensity = 1,
    this.onTap,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  /// Scales the glows; lower it for small surfaces.
  final double intensity;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget glow(Color color, double alpha) => DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: <Color>[
                color.withValues(alpha: alpha * intensity),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: p.glowB.withValues(alpha: 0.18 * intensity),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: p.heroGradient,
              borderRadius: borderRadius,
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: InkWell(
              onTap: onTap,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints c) {
                        final double size = c.biggest.longestSide * 0.9;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            PositionedDirectional(
                              end: -size * 0.35,
                              top: -size * 0.45,
                              width: size,
                              height: size,
                              child: glow(p.glowA, 0.34),
                            ),
                            PositionedDirectional(
                              start: -size * 0.4,
                              bottom: -size * 0.55,
                              width: size,
                              height: size,
                              child: glow(p.glowB, 0.42),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(padding: padding, child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
