import 'package:flutter/material.dart';
import '../main.dart';

class ScanAnimationPainter extends CustomPainter {
  final double progress;
  ScanAnimationPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.lightGreen
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final sweepAngle = 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      sweepAngle,
      false,
      paint,
    );

    if (progress > 0) {
      final linePaint = Paint()
        ..color = AppTheme.lightGreen
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      final angle = -3.14159 / 2 + sweepAngle;
      final endX = center.dx + radius * 1.1 * (angle).clamp(-1.0, 1.0);
      final endY = center.dy + radius * 1.1 * (angle).clamp(-1.0, 1.0);

      canvas.drawLine(center, Offset(endX, endY), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
