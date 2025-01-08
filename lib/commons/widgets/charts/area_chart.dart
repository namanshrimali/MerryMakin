import 'package:flutter/material.dart';

class AreaChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    Paint areaPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    List<Offset> dataPoints = [
      const Offset(0, 1),
      const Offset(50, 3),
      const Offset(100, 2),
      const Offset(150, 5),
      const Offset(200, 4),
      const Offset(250, 6),
      const Offset(300, 8),
    ];

    Path path = Path();

    path.moveTo(dataPoints.first.dx, size.height);
    path.lineTo(dataPoints.first.dx, dataPoints.first.dy);

    for (int i = 1; i < dataPoints.length; i++) {
      path.lineTo(dataPoints[i].dx, dataPoints[i].dy);
    }

    path.lineTo(dataPoints.last.dx, size.height);
    path.close();

    canvas.drawPath(path, areaPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
