import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

class SemiCircularGauge extends StatelessWidget {
  final double percentage; // 0.0 to 1.0
  final StyleTokens tokens;

  const SemiCircularGauge({
    super.key,
    required this.percentage,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 55,
      child: CustomPaint(
        painter: _SemiCircularGaugePainter(
          percentage: percentage.clamp(0.0, 1.0),
          fillColor: tokens.accent,
          trackColor: tokens.border,
        ),
      ),
    );
  }
}

class _SemiCircularGaugePainter extends CustomPainter {
  final double percentage;
  final Color fillColor;
  final Color trackColor;

  _SemiCircularGaugePainter({
    required this.percentage,
    required this.fillColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height;
    final double radius = size.width / 2 - 6;

    final Paint trackPaint = Paint()
      ..color = trackColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final Rect rect = Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: radius,
    );

    // Draw the background arc (top half: 180 to 360 degrees, which is PI radians)
    canvas.drawArc(rect, math.pi, math.pi, false, trackPaint);

    // Draw the fill arc
    if (percentage > 0.0) {
      canvas.drawArc(rect, math.pi, math.pi * percentage, false, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SemiCircularGaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.trackColor != trackColor;
  }
}
