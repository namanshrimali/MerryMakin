import 'package:flutter/material.dart';
import '../utils/date_time.dart';

class ProDatePicker extends StatefulWidget {
  final DateTime? initialValue;
  final DateTime firstDate;
  final DateTime lastDate;
  final String hintText;
  final ValueChanged<DateTime>? onDateSelected;

  const ProDatePicker({
    super.key,
    this.initialValue,
    this.onDateSelected,
    required this.firstDate,
    required this.lastDate,
    this.hintText = 'Select a date',
  });

  @override
  State<ProDatePicker> createState() => _ProDatePickerState();
}

class _ProDatePickerState extends State<ProDatePicker> {
  late TextEditingController _controller;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    _controller = widget.initialValue == null ? TextEditingController() : TextEditingController(text: prettifyDate(widget.initialValue!));
  }

  Future<void> _selectDate(BuildContext context) async {
    showDatePicker(
      context: context,
      initialDate: widget.initialValue == null ? DateTime.now() : widget.initialValue!,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    ).then((pickedDate) {
      if (pickedDate == null || pickedDate == _selectedDate) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
        _controller.text = prettifyDate(_selectedDate!);
      });

      if (widget.onDateSelected != null) {
        widget.onDateSelected!(pickedDate);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () => _selectDate(context),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
