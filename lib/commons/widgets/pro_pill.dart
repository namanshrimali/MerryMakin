import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';

class ProPill extends StatefulWidget {
  final Widget label;
  final isSelected;
  final int? count;
  final VoidCallback? onSelected;
  const ProPill({
    super.key,
    required this.label,
    required this.isSelected,
    this.onSelected,
    this.count,
  });

  @override
  State<ProPill> createState() => _ProPillState();
}

class _ProPillState extends State<ProPill> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void didUpdateWidget(ProPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animate when selection state changes
    if (widget.isSelected != oldWidget.isSelected) {
      _controller.forward(from: 0.0).then((_) {
        _controller.reverse();
      });
    }
    // Animate when count changes
    if (widget.count != null &&
        oldWidget.count != null &&
        widget.count != oldWidget.count) {
      _controller.forward(from: 0.0).then((_) {
        _controller.reverse();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
      },
      onTap: () {
        if (widget.onSelected != null) {
          widget.onSelected!();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = _scaleAnimation.value;
          return Transform.scale(
            scale: scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: widget.isSelected
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
                  widget.label,
                  if (widget.count != null) ...[
                    const SizedBox(width: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: ProText(
                        widget.count.toString(),
                        key: ValueKey(widget.count),
                        textStyle: const TextStyle(fontSize: 12),
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}