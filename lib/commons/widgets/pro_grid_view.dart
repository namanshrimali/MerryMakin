import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ProGridView extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final Axis scrollDirection;
  final bool canScroll;
  const ProGridView(
      {super.key, required this.children, required this.crossAxisCount, this.canScroll = false, this.scrollDirection = Axis.vertical});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        scrollDirection: scrollDirection,
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1,
        crossAxisSpacing: generalAppLevelPadding/2,
        mainAxisSpacing: generalAppLevelPadding/2,
        physics: canScroll ? null :
            const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
        shrinkWrap: true, // You won't see infinite size error
        children: children);
  }
}
