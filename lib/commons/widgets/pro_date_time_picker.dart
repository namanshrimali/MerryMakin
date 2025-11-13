import 'package:flutter/material.dart';
import '../utils/date_time.dart';

class ProDateTimePicker extends StatefulWidget {
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
  });

  @override
  State<ProDateTimePicker> createState() => _ProDateTimePickerState();
}

class _ProDateTimePickerState extends State<ProDateTimePicker> {
  late TextEditingController _controller;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialValue;
    _controller = TextEditingController(
      text: widget.initialValue == null
          ? ''
          : fullDateWithTimeString(widget.initialValue!),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );

    if (pickedDate == null) return;

    if (!context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedDateTime != null
          ? TimeOfDay.fromDateTime(_selectedDateTime!)
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

    if (pickedDateTime == _selectedDateTime) return;

    setState(() {
      _selectedDateTime = pickedDateTime;
      _controller.text = prettifyDateWithTime(_selectedDateTime!);
    });

    widget.onDateTimeSelected?.call(pickedDateTime);
  }

  @override
  Widget build(BuildContext context) {

        final OutlineInputBorder overlayBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: widget.fillColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.5)),
    );

    final OutlineInputBorder overlayFocusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: widget.fillColor ?? Theme.of(context).colorScheme.primary),
    );


    return TextFormField(
      controller: _controller,
      readOnly: true,
      style: widget.style,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: widget.hintStyle,
        border: widget.border ?? overlayBorder,
        focusedBorder: widget.focusedBorder ?? overlayFocusedBorder,
        enabledBorder: widget.enabledBorder ?? overlayBorder,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon ?? const Icon(Icons.event),
        filled: widget.filled,
        fillColor: widget.fillColor,
        contentPadding: widget.contentPadding,
      ),
      onTap: () => _selectDateTime(context),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
