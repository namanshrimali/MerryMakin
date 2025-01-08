import 'package:flutter/material.dart';
import '../utils/date_time.dart';

class ProDateTimePicker extends StatefulWidget {
  final DateTime? initialValue;
  final DateTime firstDate;
  final DateTime lastDate;
  final String hintText;
  final ValueChanged<DateTime>? onDateTimeSelected;

  const ProDateTimePicker({
    super.key,
    this.initialValue,
    this.onDateTimeSelected,
    required this.firstDate,
    required this.lastDate,
    this.hintText = 'Select date and time',
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
          : prettifyDateWithTime(widget.initialValue!),
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
    return TextFormField(
      controller: _controller,
      readOnly: true,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.event),
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