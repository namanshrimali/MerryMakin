import 'package:flutter/material.dart';
import 'package:merrymakin/commons/utils/constants.dart';

class ProListView extends StatelessWidget {
  final List<dynamic> listItems;
  final double height;
  final double? width;
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
    this.width
  });

  @override
  Widget build(BuildContext context) {
    // If there's only one item and we're scrolling horizontally, center it
    if (listItems.length == 1 && scrollDirection == Axis.horizontal) {
      return SizedBox(
        height: height,
        width: width,
        child: Container(
          padding: EdgeInsets.only(left: generalAppLevelPadding),
          child: listItems.first,
        ),
      );
    }

    // Use PageView for horizontal scrolling with peek effect
    if (scrollDirection == Axis.horizontal &&
        viewportFraction != null &&
        viewportFraction! < 1.0) {
      final controller = pageController ??
          PageController(viewportFraction: viewportFraction!);

      return SizedBox(
        height: height,
        width: width,
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
