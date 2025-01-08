import 'package:flutter/material.dart';
import '../../widgets/pro_text.dart';

class BarOfTheChart extends StatelessWidget {
  final double height;
  final String? topLabel;
  final String? bottomLabel;
  final double fractionFilled;
  final double width;
  final bool isColumn;
  final Color? color;
  const BarOfTheChart(
      {super.key,
      this.bottomLabel,
      required this.fractionFilled,
      this.isColumn = true,
      required this.width,
      this.color,
      required this.height,
      this.topLabel});

  Widget buildChartBar(BuildContext context) {
    if (isColumn) {
      return SizedBox(
        height: height,
        child: Column(
          children: <Widget>[
            Spacer(),
            if (topLabel != null) ProText(topLabel!),
            SizedBox(
              height: height * 0.78 * fractionFilled,
              width: width,
              child: Container(
                decoration: BoxDecoration(
                  color: color ?? Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (bottomLabel != null)
              SizedBox(
                height: height * 0.05,
              ),
            if (bottomLabel != null)
              ProText(
                bottomLabel!,
                textStyle: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      );
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: <Widget>[
              SizedBox(
                width: constraints.maxWidth * (1 - fractionFilled),
              ),
              SizedBox(
                width: constraints.maxWidth * fractionFilled,
                height: 70,
                child: Container(
                  decoration: BoxDecoration(
                    color: color ?? Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              if (bottomLabel != null)
                SizedBox(
                  width: constraints.maxWidth * 0.05,
                ),
              if (bottomLabel != null)
                ProText(
                  bottomLabel!,
                ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildChartBar(context);
  }
}
