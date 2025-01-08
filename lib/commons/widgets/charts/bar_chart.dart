import 'package:flutter/material.dart';
import '../../utils/math.dart';
import '../../widgets/charts/bar_of_the_chart.dart';
import '../../models/chart_data.dart';

class BarChart extends StatelessWidget {
  final List<ChartData> chartData;
  final double barHeight;
  final double? barWidth;
  final bool showYValAtBarTop;

  const BarChart(
    this.chartData,
    this.barHeight, {
    this.barWidth,
    this.showYValAtBarTop = false,
    super.key,
  });

  double get total {
    return chartData.fold(0.0, (sum, item) {
      return sum + (item.y as double);
    });
  }

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder(builder: (context, constraints) {});
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: chartData.map((data) {
              return BarOfTheChart(
                  height: barHeight,
                  width: barWidth ?? (constraints.maxWidth / chartData.length) * 0.8,
                  bottomLabel: (data.xToString),
                  topLabel: showYValAtBarTop && (data.y as double) > 0 && data.yToString != null ? data.yToString : null,
                  fractionFilled: compareDoubles(total, 0) == 0
                      ? 0
                      : (data.y as double) / total);
            }).toList(),
          ),
        ],
      );
    });
  }
}
