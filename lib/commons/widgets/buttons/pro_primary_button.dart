import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ProPrimaryButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isBig;
  final bool disabled;
  const ProPrimaryButton(this.child,
      {super.key, this.onPressed, this.isBig = false, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    Widget button = FilledButton(onPressed: disabled ? null : onPressed, child: child);
    return isBig
        ? SizedBox(
            width: double.infinity,
            height: generalAppLevelPadding * 3,
            child: button,
          )
        : button;
  }
}
