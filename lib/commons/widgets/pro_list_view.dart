import 'package:flutter/material.dart';

class ProListView extends StatelessWidget {
  final List<dynamic> listItems;
  final double height;
  final ScrollController? scrollController;
  final Axis scrollDirection;
  final double? viewportFraction;
  final PageController? pageController;

  const ProListView({
    super.key,
    required this.listItems,
    this.scrollController,
    required this.height,
    this.scrollDirection = Axis.vertical,
    this.viewportFraction,
    this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    // Use PageView for horizontal scrolling with peek effect
    if (scrollDirection == Axis.horizontal &&
        viewportFraction != null &&
        viewportFraction! < 1.0) {
      final controller = pageController ??
          PageController(viewportFraction: viewportFraction!);

      return SizedBox(
        height: height,
        child: PageView.builder(
          controller: controller,
          itemCount: listItems.length,
          itemBuilder: (BuildContext context, int index) {
            return listItems[index];
          },
        ),
      );
    }

    // Default ListView behavior
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: scrollDirection,
        controller: scrollController,
        itemCount: listItems.length,
        itemBuilder: (BuildContext context, int index) {
          return listItems[index];
        },
      ),
    );
  }
}
