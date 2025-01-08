import 'package:flutter/material.dart';
import '../widgets/pro_text.dart';

class ProHeadlineWithButton extends StatelessWidget {
  final String headlineText;
  final String buttonText;
  final Function? onPressed;
  const ProHeadlineWithButton(
      {super.key,
      required this.headlineText,
      required this.buttonText,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ProText(
          headlineText,
          textStyle: Theme.of(context).textTheme.headlineSmall,
        ),
        if (onPressed != null)
          TextButton(
              onPressed: () {
                onPressed!();
              },
              child: ProText(buttonText)),
      ],
    );
  }
}
