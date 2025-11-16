import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../pro_text.dart';

class ProIconButton extends StatelessWidget {
  // final FaIcon? faIcon;
  final IconData? icon;
  final String? label;
  final VoidCallback onPressed;
  final ButtonStyle? style;
  final Color? iconColor;
  final double size;
  final bool isSelected;
  final Color? selectedBackgroundColor;
  final Color? selectedTextColor;
  final Color? textColor;
  final ShapeBorder? shape;
  const ProIconButton(
      {super.key,
      // this.faIcon,
      this.icon ,
      required this.onPressed,
      this.style,
      this.size = 32,
      this.label,
      this.isSelected = false,
      this.selectedBackgroundColor,
      this.selectedTextColor,
      this.textColor,
      this.shape,
      this.iconColor});

  @override
  Widget build(BuildContext context) {
    final Widget child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: size, color: iconColor),
        const SizedBox(height: 4),
        if (label != null) ...[
          ProText(label!, textStyle: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );

    return TextButton(
      onPressed: () {
        onPressed();
      },
      style: ButtonStyle(
        backgroundColor: isSelected
            ? MaterialStatePropertyAll<Color>(selectedBackgroundColor!)
            : null,
        foregroundColor: isSelected
            ? MaterialStatePropertyAll<Color>(selectedTextColor!)
            : textColor != null
                ? MaterialStatePropertyAll<Color>(textColor!)
                : null,
        shape: MaterialStatePropertyAll<OutlinedBorder>(
          shape is OutlinedBorder ? shape as OutlinedBorder : const CircleBorder(),
        ),
      ),
      child: child,
    );
  }
}
