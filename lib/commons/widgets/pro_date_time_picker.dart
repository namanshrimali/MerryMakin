import 'package:flutter/material.dart';

class ProDateTimePicker extends StatelessWidget {
  final DateTime? initialValue;
  final DateTime firstDate;
  final DateTime lastDate;
  final String hintText;
  final ValueChanged<DateTime>? onDateTimeSelected;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final bool filled;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextAlign? textAlign;
  final TextEditingController? textEditingController;
  const ProDateTimePicker({
    super.key,
    this.initialValue,
    this.onDateTimeSelected,
    required this.firstDate,
    required this.lastDate,
    this.hintText = 'Select date and time',
    this.style,
    this.hintStyle,
    this.border,
    this.focusedBorder,
    this.enabledBorder,
    this.filled = false,
    this.fillColor,
    this.contentPadding,
    this.prefixIcon,
    this.suffixIcon,
    this.textAlign,
    this.textEditingController,
  });

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialValue ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate == null) return;

    if (!context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialValue != null
          ? TimeOfDay.fromDateTime(initialValue!)
          : TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    final DateTime pickedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (pickedDateTime == initialValue) return;
    onDateTimeSelected?.call(pickedDateTime);
  }

  @override
  Widget build(BuildContext context) {

        final OutlineInputBorder overlayBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: fillColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.5)),
    );

    final OutlineInputBorder overlayFocusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: fillColor ?? Theme.of(context).colorScheme.primary),
    );


    return TextFormField(
      controller: textEditingController,
      readOnly: true,
      style: style,
      textAlign: textAlign ?? TextAlign.start,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle,
        border: border ?? overlayBorder,
        focusedBorder: focusedBorder ?? overlayFocusedBorder,
        enabledBorder: enabledBorder ?? overlayBorder,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon ?? const Icon(Icons.event),
        filled: filled,
        fillColor: fillColor,
        contentPadding: contentPadding,
      ),
      onTap: () => _selectDateTime(context),
    );
  }
}
