import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ProCard extends StatelessWidget {
  final Widget child;
  final double? elevation;
  final onlyBottomRounded;
  final Color? surfaceTintColor;
  final bool applyPadding;
  final double? radius;
  const ProCard(
      {super.key,
      required this.child,
      this.elevation,
      this.onlyBottomRounded = false,
      this.applyPadding = true,
      this.surfaceTintColor,
      this.radius});

  @override
  Widget build(BuildContext context) {
    EdgeInsets edgeInsets = applyPadding
        ? const EdgeInsets.only(
            left: generalAppLevelPadding,
            right: generalAppLevelPadding,
            top: generalAppLevelPadding,
            bottom: generalAppLevelPadding)
        : const EdgeInsets.all(0);
    return Card(
      color: surfaceTintColor,
      margin: EdgeInsets.only(bottom: generalAppLevelPadding / 2),
      elevation: elevation ?? 2,
      shape: onlyBottomRounded
          ? bottomRoundedRectangleBorder
          : radius != null
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(radius!)))
              : roundedRectangleBorder,
      child: Padding(
        padding: edgeInsets,
        child: child,
      ),
    );
  }
}
