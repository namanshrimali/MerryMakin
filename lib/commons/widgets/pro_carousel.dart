import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ProCarousel extends StatefulWidget {
  final List<Widget> items;
  final bool showIndicators;
  final double height;
  final bool padEnds;
  final double? viewportFraction;

  const ProCarousel({super.key, required this.items, required this.height, this.padEnds = false, this.showIndicators=true, this.viewportFraction});

  @override
  State<ProCarousel> createState() => _ProCarouselState();
}

class _ProCarouselState extends State<ProCarousel> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            padEnds: widget.padEnds,
            controller: PageController(viewportFraction: widget.viewportFraction ?? 1),
            itemCount: widget.items.length,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return widget.items[index];
            },
          ),
        ),
        if (widget.items.length > 1)
          const SizedBox(
            height: generalAppLevelPadding/2,
          ),
        if (widget.items.length > 1 && widget.showIndicators) buildIndicators(),
      ],
    );
  }

  Widget buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.items.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          width: 4.0,
          height: 4.0,
          decoration: BoxDecoration(
            shape: currentPage == index ? BoxShape.circle : BoxShape.circle,
            color: currentPage == index
                ? Theme.of(context).primaryColor
                : Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ),
    );
  }
}
