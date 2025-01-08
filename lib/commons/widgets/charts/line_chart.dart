import 'dart:math';

import 'package:flutter/material.dart';
import '../../utils/date_time.dart';
import '../../models/chart_data.dart';

class LineChart extends StatelessWidget {
  final List<ChartData<DateTime, double>> dataPoints;
  final DateTime plotTill;
  final Color lineColour;
  final Color baseLineColour;
  final double? height;

  const LineChart(
      {super.key,
      required this.dataPoints,
      required this.lineColour,
      required this.baseLineColour,
      this.height, required this.plotTill});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150, // TODO remove height and width from line chart
      height: height ?? 30,
      child: CustomPaint(
        painter: LineChartPainter(
            dataPoints, lineColour, baseLineColour, plotTill, height),
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<ChartData<DateTime, double>> dataPoints;
  final double lineWidth = 2.0;
  final Color lineColor;
  final Color baseLineColour;
  final DateTime plotTill;

  LineChartPainter(this.dataPoints, this.lineColor, this.baseLineColour, this.plotTill,
      [double? height]);

  void paintBaseline(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = baseLineColour
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;
    int dataPointCount = 20;
    final dataPointInterval = size.width / dataPointCount;

    for (int i = 0; i < dataPointCount - 1; i += 2) {
      double x1 = i * dataPointInterval;
      double y1 = size.height;

      double x2 = (i + 1) * dataPointInterval;
      double y2 = size.height;
      // print("${dataPoints[i]} : (${x1},${y1}), ${dataPoints[i+1]} : (${x2},${y2}),");
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  void paintDataPoints(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    final dataPointCount = dataPoints.length;
    // final dataPointInterval = size.width / (dataPointCount - 1);
    final dataPointInterval = size.width / dataPoints.length;

    final double dataPointMax = dataPoints
    .map((dataPoint) => dataPoint.y)
        .reduce((value, element) => value > element ? value : element);

    final double dataPointMin = dataPoints
        .map((dataPoint) => dataPoint.y)
        .reduce((value, element) => value < element ? value : element);
    // final double dataPointMid = (dataPointMax+dataPointMin)/2;
    for (int i = 0; i < dataPointCount - 1; i++) {
      if (compareDates(dataPoints[i].x, plotTill) == 1) {
        break;
      }
      double normalizedDataPointY1 =
          (dataPoints[i].y - dataPointMin) / max(dataPointMax - dataPointMin, 1);
      double x1 = i * dataPointInterval;
      double y1 = size.height - (size.height * normalizedDataPointY1);
      double normalizedDataPointY2 = (dataPoints[i + 1].y - dataPointMin) /
          max(dataPointMax - dataPointMin, 1);

      double x2 = (i + 1) * dataPointInterval;
      double y2 = size.height - (size.height * normalizedDataPointY2);
      // print("${dataPoints[i]} : (${x1},${y1}), ${dataPoints[i+1]} : (${x2},${y2}),");
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.length > 1) {
      paintDataPoints(canvas, size);
    } else {
      paintBaseline(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
