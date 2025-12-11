import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';

class ProPill extends StatelessWidget {
  final Widget label;
  final isSelected;
  final int? count;
  final VoidCallback? onSelected;
  const ProPill({super.key, required this.label, required this.isSelected, this.onSelected, this.count});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (onSelected != null) {
                onSelected!();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  label,
                  if (count != null) ...[
                    const SizedBox(width: 4),
                    ProText(
                      count.toString(),
                      textStyle: const TextStyle(fontSize: 12),
                      weight: FontWeight.w600,
                    ),
                  ],
                ],
              ),
            ),
          );
  }
}