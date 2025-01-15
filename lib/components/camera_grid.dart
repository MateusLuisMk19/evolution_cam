import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5) // Cor e opacidade da grade
      ..strokeWidth = 1.0;

    // Linhas verticais
    for (double i = size.width / 3; i < size.width; i += size.width / 3) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Linhas horizontais
    for (double i = size.height / 3; i < size.height; i += size.height / 3) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
