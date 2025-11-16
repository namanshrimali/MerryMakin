import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ProOutlinedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isBig;
  const ProOutlinedButton({
    super.key, this.isBig = false,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(generalAppLevelPadding),
      ),
      child: child,
    );
    return isBig
        ? SizedBox(
            width: double.infinity,
            // height: generalAppLevelPadding * 3,
            child: button,
          )
        : button;
  }
}
