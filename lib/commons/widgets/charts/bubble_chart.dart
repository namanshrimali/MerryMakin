import 'dart:math';

import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/media_queries.dart';
import '../../widgets/pro_text.dart';

class BubbleChart<T> extends StatelessWidget {
  final List<BubbleChartData> data;
  final Function(BubbleChartData) onBubbleTap;
  final T? focussedBubbleType;

  const BubbleChart(
      {super.key,
      required this.data,
      required this.onBubbleTap,
      this.focussedBubbleType,});

  Widget getComplexBuild(BuildContext context) {
    final List<List<double>> coordinatesAndPercentageAllocated = [
      [
        0.25,
        0.6,
        0.25,
      ],
      [0.6, 0.82, 0.2],
      [0.83, 0.55, 0.16],
      [0.3, 0.18, 0.16],
      [0.6, 0.35, 0.16],
    ];
    int index = -1;
    return Column(
      children: [
        SizedBox(
          height: getBubbleChartHeight(context),
          child: LayoutBuilder(builder: (context, constraints) {
            if (data.isEmpty) {
              return const Center(child: ProText("No data"),);
            }
            return Stack(
              children: data.map((bubbleData) {
                index = index + 1;
                double percentageAllocated = min(
                        max(bubbleData.percentageAllocated,
                            coordinatesAndPercentageAllocated[index][2]),
                        0.25) *
                    constraints.maxHeight;
                return Positioned(
                  left:
                      coordinatesAndPercentageAllocated[index][0] * constraints.maxWidth -
                          percentageAllocated,
                  top:
                      coordinatesAndPercentageAllocated[index][1] * constraints.maxHeight -
                          percentageAllocated,
                  child: GestureDetector(
                    onTap: () => onBubbleTap(bubbleData),
                    child: Container(
                      width: percentageAllocated * 2,
                      height: percentageAllocated * 2,
                      decoration: BoxDecoration(
                        color: bubbleData.type == focussedBubbleType
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.inversePrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(padding: const EdgeInsets.only(
                    left: generalAppLevelPadding / 4,
                    right: generalAppLevelPadding / 4), child: bubbleData.child,),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return getComplexBuild(context);
  }
}

class BubbleChartData<T> {
  final double percentageAllocated;
  final Widget child;
  final T type;

  BubbleChartData({
    required this.percentageAllocated,
    required this.type,
    required this.child,
  });
}
