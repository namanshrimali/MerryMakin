import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../pro_text.dart';

class ProOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const ProOutlinedButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonContent = ProText(text);
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(generalAppLevelPadding),
      ),
      child: buttonContent,
    );
  }
}
