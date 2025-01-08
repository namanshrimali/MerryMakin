import 'package:flutter/material.dart';

class ProText extends StatelessWidget {
  final String data;
  final FontStyle fontStyle;
  final Color? color;
  final TextStyle? textStyle;
  final double? height;
  final FontWeight? weight;
  final bool hideOverflownDataWithEllipses;

  const ProText(this.data,
      {super.key,
      this.color,
      this.fontStyle = FontStyle.normal,
      this.weight,
      this.height,
      this.textStyle, 
      this.hideOverflownDataWithEllipses = false});

  TextStyle get textStyleForProText {
    return textStyle != null
        ? textStyle!.copyWith(color: color)
        : TextStyle(fontStyle: fontStyle, color: color, fontWeight: weight);
  }

  @override
  Widget build(BuildContext context) {
    final String textToBeShown = hideOverflownDataWithEllipses ? addEllipsisIfTooLong(data) : data;
    Widget textBox = Text(textToBeShown, style: textStyleForProText);
    return height == null
        ? textBox
        : SizedBox(
            height: height,
            child: textBox,
          );
  }

  String addEllipsisIfTooLong(String word) {
  if (word.length > 30) {
    return word.substring(0, 30 - 3) + "...";
  } else {
    return word;
  }
}
}
