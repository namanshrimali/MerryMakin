import 'package:flutter/material.dart';

class ProTextField extends StatelessWidget {
  final String? initialValue;
  final String? label;
  final String? hintText;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final TextInputType? keyboardType;
  final Function? onChanged;
  final bool autofocus;
  final TextEditingController? textEditingController;
  final Function? onSubmitted;
  final Function? onValidationCallback;
  final Function? onSaved;
  final double? width;
  final double? height;
  final bool multiline;
  final int? maxLines;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextStyle? hintStyle;
  const ProTextField({
    super.key,
    this.label,
    this.hintText,
    this.keyboardType,
    this.autofocus = true,
    this.textEditingController,
    this.onSubmitted,
    this.onChanged,
    this.suffixWidget,
    this.prefixWidget,
    this.onValidationCallback,
    this.initialValue,
    this.onSaved,
    this.width,
    this.height,
    this.multiline = false,
    this.maxLines,
    this.style,
    this.textAlign,
    this.hintStyle,
  });

  Widget buildNewType() {
    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        autofocus: autofocus,
        controller: textEditingController,
        style: style,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.only(left: 8, right: 8, bottom: 18, top: 18),
          labelText: label,
          hintText: hintText,
          suffix: suffixWidget,
          prefix: prefixWidget,
        ),
        keyboardType: multiline ? TextInputType.multiline : keyboardType,
        maxLines: multiline ? (maxLines ?? null) : 1,
        initialValue: initialValue,
        onSaved: (value) {
          if (onSaved != null) {
            onSaved!(value);
          }
        },
        onChanged: ((value) {
          if (onChanged != null) {
            onChanged!(value);
          }
        }),
        validator: (value) {
          if (onValidationCallback != null) {
            return onValidationCallback!(value);
          }
          return null;
        },
        textAlign: textAlign ?? TextAlign.start,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildNewType();
    // return TextField(
    //   keyboardType: keyboardType,
    //   controller: textEditingController,
    //   onChanged: (value) => onChanged != null ? onChanged!(value) : null,
    //   onSubmitted: (_) => onSubmitted != null ? onSubmitted!() : null,
    //   inputFormatters: keyboardType == TextInputType.number
    //       ? <TextInputFormatter>[
    //           FilteringTextInputFormatter.allow(RegExp(
    //               r'^\d+\.?\d{0,2}')), // Allow only non-negative numbers with up to 2 decimal places
    //         ]
    //       : null,
    //   decoration: InputDecoration(
    //       border: const OutlineInputBorder(),
    //       contentPadding:
    //           const EdgeInsets.only(left: 8, right: 8, bottom: 18, top: 18),
    //       labelText: label,
    //       hintText: hintText,
    //       suffix: suffixWidget,
    //       prefix: prefixWidget),
    //   autofocus: autofocus,
    // );
  }
}
