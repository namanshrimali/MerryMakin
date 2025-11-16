import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class ProSegmentedButton<T> extends StatelessWidget {
  final Set<T> selected;
  final List<ProButtonSegment<T>> segments;
  final Function(Set<T>) onSelectionChanged;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final Color? textColor;
  final Color? selectedTextColor;

  const ProSegmentedButton({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.textColor,
    this.selectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: segments.map((segment) {
        final bool isSelected =
            selected.any((element) => segment.value == element);
    
        final Widget child = Padding(
          padding: const EdgeInsets.all(generalAppLevelPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (segment.icon != null) ...[
                segment.icon!,
                const SizedBox(height: 4),
              ],
              segment.label,
            ],
          ),
        );
    
        return TextButton(
          onPressed: () {
            onSelectionChanged({segment.value});
          },
          style: ButtonStyle(
            backgroundColor: isSelected
                ? MaterialStatePropertyAll<Color>(selectedBackgroundColor!)
                : null,
            foregroundColor: isSelected
                ? MaterialStatePropertyAll<Color>(selectedTextColor!)
                : textColor != null
                    ? MaterialStatePropertyAll<Color>(textColor!)
                    : null,
            shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
          child: child,
        );
      }).toList(),
    );
  }
}

class ProButtonSegment<T> {
  final T value;
  final Icon? icon;
  final Widget label;
  ProButtonSegment({
    required this.value,
    required this.label,
    this.icon,
  });
}
