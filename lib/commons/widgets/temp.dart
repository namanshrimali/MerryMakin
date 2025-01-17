import 'package:flutter/material.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
class BottomSheetDropdown extends StatefulWidget {
  @override
  _BottomSheetDropdownState createState() => _BottomSheetDropdownState();
}

class _BottomSheetDropdownState extends State<BottomSheetDropdown> {
  String? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return CustomDropdownButtonFormField<String>(
      value: _selectedItem,
      onChanged: (String? newValue) {
        setState(() {
          _selectedItem = newValue;
        });
      },
      items: <String>['Item 1', 'Item 2', 'Item 3', 'Item 4']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: ProText(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Select Item',
        border: OutlineInputBorder(),
      ),
    );
  }
}

class CustomDropdownButtonFormField<T> extends StatefulWidget {
  final T? value;
  final ValueChanged<T?>? onChanged;
  final List<DropdownMenuItem<T>> items;
  final InputDecoration? decoration;

  const CustomDropdownButtonFormField({
    Key? key,
    this.value,
    this.onChanged,
    required this.items,
    this.decoration,
  }) : super(key: key);

  @override
  _CustomDropdownButtonFormFieldState<T> createState() =>
      _CustomDropdownButtonFormFieldState<T>();
}

class _CustomDropdownButtonFormFieldState<T>
    extends State<CustomDropdownButtonFormField<T>> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              children: widget.items.map((item) {
                return ListTile(
                  title: item.child,
                  onTap: () {
                    widget.onChanged?.call(item.value);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            );
          },
        );
      },
      child: InputDecorator(
        decoration: widget.decoration!,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ProText(widget.value?.toString() ?? ''),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}