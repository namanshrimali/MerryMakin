import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ProOutlinedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const ProOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(generalAppLevelPadding),
      ),
      child: child,
    );
  }
}
