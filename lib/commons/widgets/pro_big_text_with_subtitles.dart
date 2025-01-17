import 'package:flutter/material.dart';
import '../widgets/pro_text.dart';

class ProTextWithSubtitles extends StatelessWidget {
  final String primaryText;
  final String subtitleText;
  const ProTextWithSubtitles(
      {super.key, required this.primaryText, required this.subtitleText});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProText(primaryText, textStyle: Theme.of(context).textTheme.displaySmall),
        const SizedBox(
          height: 48, // TODO remove constants
        ),
        ProText(
          subtitleText,
          textStyle: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }
}
