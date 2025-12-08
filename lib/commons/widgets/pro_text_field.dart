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
  final FocusNode? focusNode;
  final bool filled;
  final Color? fillColor;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final EdgeInsetsGeometry? contentPadding;
  final Function? onTap;
  const ProTextField({
    super.key,
    this.label,
    this.hintText,
    this.keyboardType,
    this.autofocus = false,
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
    this.focusNode,
    this.filled = false,
    this.fillColor,
    this.border,
    this.focusedBorder,
    this.enabledBorder,
    this.contentPadding,
    this.onTap,
  });

  Widget buildNewType(context) {

    final OutlineInputBorder overlayBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(32),
      borderSide: BorderSide(color: fillColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.5)),
    );

    final OutlineInputBorder overlayFocusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(32),
      borderSide: BorderSide(color: fillColor ?? Theme.of(context).colorScheme.primary),
    );

    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        onTap: onTap != null ? () => onTap!() : null,
        focusNode: focusNode,
        autofocus: autofocus,
        controller: textEditingController,
        style: style,
        decoration: InputDecoration(
          border: border ?? overlayBorder,
          focusedBorder: focusedBorder ?? overlayFocusedBorder,
          enabledBorder: enabledBorder ?? overlayBorder,
          contentPadding: contentPadding ??
              const EdgeInsets.only(left: 8, right: 8, bottom: 18, top: 18),
          labelText: label,
          hintText: hintText,
          suffixIcon: suffixWidget != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: suffixWidget,
                )
              : null,
          suffixIconConstraints:
              const BoxConstraints(minHeight: 0, minWidth: 0),
          prefixIcon: prefixWidget != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: prefixWidget,
                )
              : null,
          prefixIconConstraints:
              const BoxConstraints(minHeight: 0, minWidth: 0),
          filled: filled,
          fillColor: fillColor,
          hintStyle: hintStyle,
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
    return buildNewType(context);
  }
}
