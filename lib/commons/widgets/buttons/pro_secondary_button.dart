import 'package:flutter/material.dart';
import '../../widgets/pro_text.dart';

class SecondaryButton extends StatelessWidget {
  final String data;
  final VoidCallback? onPressed;
  final bool isBig;
  const SecondaryButton(this.data,
      {super.key, this.onPressed, this.isBig = false});

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: () {},
      child: ProText(data),
    );
  }
}
