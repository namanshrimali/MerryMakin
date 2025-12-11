import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merrymakin/commons/widgets/pro_user_comment_constants.dart';

/// A floating reaction picker widget that displays emoji reactions.
class ProCommentReactionPicker extends StatefulWidget {
  final List<String> availableReactions;
  final List<String>? currentUserReaction;
  final Function(String emoji) onReactionSelected;
  final VoidCallback onShowEmojiKeyboard;

  const ProCommentReactionPicker({
    super.key,
    this.availableReactions = ProUserCommentConstants.defaultReactions,
    this.currentUserReaction = const [],
    required this.onReactionSelected,
    required this.onShowEmojiKeyboard,
  });

  @override
  State<ProCommentReactionPicker> createState() =>
      _ProCommentReactionPickerState();
}

class _ProCommentReactionPickerState extends State<ProCommentReactionPicker>
    with TickerProviderStateMixin {
  final Map<String, AnimationController> _entranceControllers = {};
  final Map<String, AnimationController> _pressControllers = {};
  AnimationController? _addButtonController;

  @override
  void initState() {
    super.initState();
    // Initialize entrance animation controllers for each emoji
    for (final emoji in widget.availableReactions) {
      _entranceControllers[emoji] = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
      _pressControllers[emoji] = AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      );
    }
    _addButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // Trigger entrance animations with stagger
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < widget.availableReactions.length; i++) {
        final emoji = widget.availableReactions[i];
        Future.delayed(Duration(milliseconds: i * 50), () {
          if (mounted) {
            _entranceControllers[emoji]?.forward();
          }
        });
      }
      Future.delayed(
        Duration(milliseconds: widget.availableReactions.length * 50),
        () {
          if (mounted) {
            _addButtonController?.forward();
          }
        },
      );
    });
  }

  @override
  void dispose() {
    for (final controller in _entranceControllers.values) {
      controller.dispose();
    }
    for (final controller in _pressControllers.values) {
      controller.dispose();
    }
    _addButtonController?.dispose();
    super.dispose();
  }

  void _animateEmojiPress(String emoji) {
    final controller = _pressControllers[emoji];
    if (controller != null) {
      controller.forward(from: 0.0).then((_) {
        controller.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final edgePadding = ProUserCommentConstants.reactionPickerEdgePadding * 2;
    final maxWidth = screenWidth - edgePadding;
    final calculatedWidth = ProUserCommentConstants.reactionPickerWidth.clamp(
      0.0,
      maxWidth,
    );
    
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          minWidth: 200,
        ),
        height: ProUserCommentConstants.reactionPickerHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: calculatedWidth < maxWidth ? 6 : 8,
          vertical: 8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...widget.availableReactions.asMap().entries.map((entry) {
              final emoji = entry.value;
              final isSelected = widget.currentUserReaction?.contains(emoji) ?? false;
              final entranceController = _entranceControllers[emoji]!;
              final pressController = _pressControllers[emoji]!;
              
              return ListenableBuilder(
                listenable: Listenable.merge([entranceController, pressController]),
                builder: (context, child) {
                  // Entrance animation: scale from 0 to 1 with elastic curve
                  final entranceScale = Curves.elasticOut.transform(entranceController.value);
                  // Press animation: scale up to 1.4 when pressed
                  final pressScale = 1.0 + (pressController.value * 0.4);
                  final scale = entranceScale * pressScale;
                  
                  return GestureDetector(
                    onTapDown: (_) {
                      _animateEmojiPress(emoji);
                      HapticFeedback.lightImpact();
                    },
                    onTap: () {
                      widget.onReactionSelected(emoji);
                    },
                    child: Transform.scale(
                      scale: scale,
                      child: AnimatedContainer(
                        duration: ProUserCommentConstants.reactionAnimationDuration,
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.all(
                          calculatedWidth < maxWidth ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          emoji,
                          style: TextStyle(
                            fontSize: calculatedWidth < maxWidth ? 24 : 28,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
            SizedBox(width: calculatedWidth < maxWidth ? 2 : 4),
            Container(
              width: 1,
              height: 40,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              margin: EdgeInsets.symmetric(
                horizontal: calculatedWidth < maxWidth ? 2 : 4,
              ),
            ),
            SizedBox(width: calculatedWidth < maxWidth ? 2 : 4),
            GestureDetector(
              onTapDown: (_) {
                _addButtonController?.forward();
                HapticFeedback.lightImpact();
              },
              onTapUp: (_) {
                _addButtonController?.reverse();
                widget.onShowEmojiKeyboard();
              },
              onTapCancel: () {
                _addButtonController?.reverse();
              },
              child: AnimatedBuilder(
                animation: _addButtonController!,
                builder: (context, child) {
                  final scale = 1.0 - (_addButtonController!.value * 0.1);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: EdgeInsets.all(
                        calculatedWidth < maxWidth ? 6 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.add,
                        size: calculatedWidth < maxWidth ? 20 : 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
