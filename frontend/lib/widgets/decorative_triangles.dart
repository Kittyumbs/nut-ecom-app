import 'package:flutter/material.dart';
import 'dart:math' as math;

class DecorativeTriangles extends StatelessWidget {
  const DecorativeTriangles({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TrianglePainter(),
      child: Container(),
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFF4E6) // Vàng nhạt
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // Seed để tạo pattern nhất quán

    // Vẽ các tam giác ngẫu nhiên
    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.3; // Chỉ ở phần trên
      final sizeTriangle = 20 + random.nextDouble() * 30;

      final path = Path()
        ..moveTo(x, y)
        ..lineTo(x + sizeTriangle, y)
        ..lineTo(x + sizeTriangle / 2, y - sizeTriangle * 0.866)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

