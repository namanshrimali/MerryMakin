import 'package:flutter/material.dart';
import './pro_text.dart';

class ProFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final int? count;
  final bool isEnabled;
  const ProFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.backgroundColor,
    this.selectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.count,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProText(
            label[0].toUpperCase() + label.substring(1),
            textStyle: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.onPrimary : unselectedTextColor,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? selectedTextColor?.withOpacity(0.2) : unselectedTextColor?.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ProText(
                count.toString(),
                textStyle: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Theme.of(context).colorScheme.onPrimary : unselectedTextColor,
                ),
              ),
            ),
          ],
        ],
      ),
      onSelected: isEnabled ? onSelected : null,
      // backgroundColor: backgroundColor ?? Colors.grey[200],
      selectedColor: selectedColor ?? Theme.of(context).primaryColor,
    );
  }
} 