import 'package:flutter/material.dart';

/// Lays a column out to fill the screen when there is room, and lets it scroll
/// when there is not.
///
/// The Figma board is drawn at 414x896. A shorter phone — a 12 mini at 375x812,
/// an SE at 375x667 — has less height than that, and a column sized for the
/// design overflows. Wrapping it here keeps [Spacer] and [Expanded] working at
/// full height while degrading to a scroll view rather than a RenderFlex error.
class FillOrScroll extends StatelessWidget {
  const FillOrScroll({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  /// Usually a [Column]; it may use [Spacer] and [Expanded] as normal.
  final Widget child;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight -
                  padding.resolve(Directionality.of(context)).vertical,
            ),
            // IntrinsicHeight is what lets the column keep using Spacer: it
            // gives the unbounded scroll child a definite height to divide up.
            child: IntrinsicHeight(child: child),
          ),
        );
      },
    );
  }
}
