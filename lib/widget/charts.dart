import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/app_format.dart';
import '../utils/app_theme.dart';

/// A ring split into coloured arcs, one per value, with [center] inside.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.values,
    required this.colors,
    required this.center,
    this.size = 200,
    this.stroke = 22,
  });

  final List<double> values;
  final List<Color> colors;
  final Widget center;
  final double size;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (BuildContext context, double t, Widget? child) {
          return CustomPaint(
            painter: _DonutPainter(
              values: values,
              colors: colors,
              track: context.palette.surfaceAlt,
              stroke: stroke,
              progress: t,
            ),
            child: child,
          );
        },
        child: Center(child: center),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.values,
    required this.colors,
    required this.track,
    required this.stroke,
    required this.progress,
  });

  final List<double> values;
  final List<Color> colors;
  final Color track;
  final double stroke;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (size.shortestSide - stroke) / 2,
    );
    final Paint base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    canvas.drawArc(rect, 0, math.pi * 2, false, base..color = track);

    final double total = values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return;

    // A small gap between arcs, unless there is only one.
    final double gap = values.length > 1 ? 0.035 : 0;
    double start = -math.pi / 2;
    final double sweepAll = math.pi * 2 * progress;
    for (int i = 0; i < values.length; i++) {
      final double sweep = sweepAll * (values[i] / total);
      if (sweep > gap) {
        canvas.drawArc(
          rect,
          start + gap / 2,
          sweep - gap,
          false,
          base
            ..color = colors[i % colors.length]
            ..strokeCap = values.length > 1 ? StrokeCap.butt : StrokeCap.round,
        );
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress ||
      old.values != values ||
      old.track != track;
}

/// Seven vertical bars for the last week, with the daily limit as a dashed
/// line when there is one. A bar over the limit turns the expense colour.
class WeeklyBars extends StatelessWidget {
  const WeeklyBars({
    super.key,
    required this.values,
    required this.labels,
    this.limit = 0,
    this.height = 150,
  });

  final List<double> values;
  final List<String> labels;
  final double limit;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final double top = math.max(
      values.fold<double>(0, math.max),
      limit,
    );
    final double scale = top <= 0 ? 1 : top * 1.15;

    return SizedBox(
      height: height + 24,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                for (int i = 0; i < values.length; i++)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 0,
                            end: (values[i] / scale) * height,
                          ),
                          duration: Duration(milliseconds: 500 + i * 60),
                          curve: Curves.easeOutCubic,
                          builder: (BuildContext context, double h, _) {
                            final bool over = limit > 0 && values[i] > limit;
                            final bool today = i == values.length - 1;
                            return Container(
                              width: 22,
                              height: math.max(h, 6),
                              decoration: BoxDecoration(
                                color: over
                                    ? p.expense
                                    : today
                                        ? p.primary
                                        : p.primary.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 16,
                          child: Text(
                            labels[i],
                            style: context.text.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (limit > 0 && top > 0)
              Positioned(
                left: 0,
                right: 0,
                bottom: 24 + (limit / scale) * height,
                child: Row(
                  children: <Widget>[
                    Expanded(child: _Dashes(color: p.warning)),
                    const SizedBox(width: 4),
                    Text(
                      AppFormat.compact(limit),
                      style: context.text.labelSmall
                          ?.copyWith(color: p.textSecondary),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Dashes extends StatelessWidget {
  const _Dashes({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final int count = (c.maxWidth / 8).floor();
        return Row(
          children: List<Widget>.generate(
            count,
            (_) => Container(
              width: 4,
              height: 1.5,
              margin: const EdgeInsets.only(right: 4),
              color: color,
            ),
          ),
        );
      },
    );
  }
}
