import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ProCard extends StatelessWidget {
  final Widget child;
  final double? elevation;
  final onlyBottomRounded;
  final bool applyPadding;
  const ProCard(
      {super.key,
      required this.child,
      this.elevation,
      this.onlyBottomRounded = false,
      this.applyPadding = true});

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
      margin: EdgeInsets.only(bottom: generalAppLevelPadding / 2),
      elevation: elevation ?? 2,
      shape: onlyBottomRounded
          ? bottomRoundedRectangleBorder
          : roundedRectangleBorder,
      child: Padding(
        padding: edgeInsets,
        child: child,
      ),
    );
  }
}
