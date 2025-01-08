import 'package:flutter/material.dart';

import '../utils/math.dart';

class ProCircularProgressBarIndicator extends StatelessWidget {
  final double value;
  final double? radius;
  const ProCircularProgressBarIndicator(
      {super.key, required this.value, this.radius});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(141, 255, 255, 255),
            shape: BoxShape.circle,
          ),
          height: radius,
          width: radius,
          child: CircularProgressIndicator(
            value: value,
            backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
            semanticsLabel: 'Circular progress indicator',
          ),
        ),
        Text("${formatNumberWithoutDecimals(value * 100)}%"),
      ],
    );
  }
}
