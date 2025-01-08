import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/buttons/pro_primary_button.dart';

class ProButtonWithIconAndText extends StatelessWidget {
  final IconData? icon;
  final String text;
  final bool iconAtPrefix;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const ProButtonWithIconAndText(
      {super.key,
      this.icon,
      required this.onPressed,
      required this.text,
      this.iconAtPrefix = false,
      this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    Widget buttonContent = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconAtPrefix && icon != null) Icon(icon),
          Text(
            text,
          ),
          if (!iconAtPrefix && icon != null) Icon(icon),
        ],
      );
    return isPrimary ? ProPrimaryButton(buttonContent, onPressed: onPressed,) : OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(generalAppLevelPadding),
      ),
      child: buttonContent
    );
  }
}
