import 'dart:ui';
import 'package:flutter/material.dart';

class Point {
  final Offset position;
  final Color color;
  final double size;

  Point(this.position, this.color, this.size);
}

class SketchPainter extends CustomPainter {
  final List<Point> points;
  final Color currentColor;
  final double currentSize;
  final Offset? currentPosition;

  SketchPainter({
    required this.points,
    this.currentColor = Colors.blue,
    this.currentSize = 2.0,
    this.currentPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the path of points
    if (points.isNotEmpty) {
      final path = Path();
      path.moveTo(points[0].position.dx, points[0].position.dy);

      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].position.dx, points[i].position.dy);
      }

      final paint =
          Paint()
            ..color = points[0].color
            ..strokeWidth = points[0].size
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..style = PaintingStyle.stroke;

      canvas.drawPath(path, paint);
    }

    // Draw the cursor
    if (currentPosition != null) {
      // Draw outer glow
      final outerGlowPaint =
          Paint()
            ..color = Colors.red.withOpacity(0.2)
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(currentPosition!, 20.0, outerGlowPaint);

      // Draw middle circle
      final middleCirclePaint =
          Paint()
            ..color = Colors.red.withOpacity(0.5)
            ..style = PaintingStyle.fill;
      canvas.drawCircle(currentPosition!, 10.0, middleCirclePaint);

      // Draw inner circle
      final innerCirclePaint =
          Paint()
            ..color = Colors.red
            ..style = PaintingStyle.fill;
      canvas.drawCircle(currentPosition!, 5.0, innerCirclePaint);

      // Draw crosshair
      final crosshairPaint =
          Paint()
            ..color = Colors.white
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke;

      // Horizontal line
      canvas.drawLine(
        Offset(currentPosition!.dx - 12, currentPosition!.dy),
        Offset(currentPosition!.dx + 12, currentPosition!.dy),
        crosshairPaint,
      );

      // Vertical line
      canvas.drawLine(
        Offset(currentPosition!.dx, currentPosition!.dy - 12),
        Offset(currentPosition!.dx, currentPosition!.dy + 12),
        crosshairPaint,
      );
    }
  }

  @override
  bool shouldRepaint(SketchPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.currentPosition != currentPosition;
  }
}
