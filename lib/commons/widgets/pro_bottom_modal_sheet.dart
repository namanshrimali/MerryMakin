import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../themes/pro_themes.dart';
import '../widgets/pro_theme_effects.dart';
import '../../utils/event_gradient_helper.dart';

// Constants for bottom sheet sizing
const double _sheetBorderRadius = 32.0;
const double _dragHandleHeight = 4.0;
const double _titleAreaHeight = 60.0;
const double _minSheetSize = 0.1;
const double _maxSheetSize = 0.90;
const int _keyboardAnimationDuration = 250;
const int _contentAnimationDuration = 200;

Future openProBottomModalSheet(BuildContext context, Widget childWidget,
    {bool isFullScreen = false,
    ThemeData? themeData,
    ProThemeType? themeType,
    List<Color>? gradientColors}) {
  return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_sheetBorderRadius),
                  topRight: Radius.circular(_sheetBorderRadius))),
      builder: (_) {
        return ProBottomModalSheetContent(
          isFullScreen: isFullScreen,
          child: childWidget,
          theme: themeData,
          themeType: themeType,
          gradientColors: gradientColors,
        );
      });
}

void closeProBottomModalSheet(BuildContext context) {
  Navigator.of(context).pop();
}

class ProBottomModalSheetContent extends StatefulWidget {
  final Widget child;
  final bool isFullScreen;
  final ThemeData? theme;
  final ProThemeType? themeType;
  final List<Color>? gradientColors;
  const ProBottomModalSheetContent(
      {super.key,
      required this.child,
      required this.isFullScreen,
      this.theme,
      this.themeType,
      this.gradientColors});

  @override
  State<ProBottomModalSheetContent> createState() =>
      _ProBottomModalSheetContentState();
}

class _ProBottomModalSheetContentState
    extends State<ProBottomModalSheetContent> {
  DraggableScrollableController? _scrollableController;
  double _previousKeyboardHeight = 0;
  double? _contentHeight;
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollableController = DraggableScrollableController();
  }

  @override
  void dispose() {
    _scrollableController?.dispose();
    super.dispose();
  }

  /// Checks if controller is available and attached
  bool get _isControllerReady =>
      mounted &&
      _scrollableController != null &&
      _scrollableController!.isAttached;

  /// Gets theme color with fallback to context theme
  Color _getThemeColor(BuildContext context) =>
      widget.theme?.colorScheme.primary ?? Theme.of(context).colorScheme.primary;

  /// Measures content height if not already measured
  void _measureContent() {
    if (_contentHeight != null || !mounted) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final RenderBox? renderBox =
          _contentKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.size.height > 0) {
        setState(() {
          _contentHeight = renderBox.size.height;
        });
      }
    });
  }

  /// Handles keyboard appearance by expanding sheet to max size
  void _handleKeyboardChange(double keyboardHeight, double maxSize) {
    if (!_isControllerReady) return;

    // If keyboard just appeared (was 0, now > 0), expand to max
    if (_previousKeyboardHeight == 0 && keyboardHeight > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isControllerReady) {
          _scrollableController!.animateTo(
            maxSize,
            duration: const Duration(milliseconds: _keyboardAnimationDuration),
            curve: Curves.easeOut,
          );
        }
      });
    }

    _previousKeyboardHeight = keyboardHeight;
  }

  /// Calculates max size based on available height (excluding keyboard)
  double _calculateMaxSize(double maxHeight, double safeAreaTop) {
    final availableHeight = maxHeight - safeAreaTop;
    return (availableHeight / maxHeight).clamp(_minSheetSize, _maxSheetSize);
  }

  /// Calculates initial size based on content or fullscreen mode
  double _calculateInitialSize(
      double maxHeight, double minSize, double maxSize) {
    if (widget.isFullScreen) {
      return maxSize;
    }

    if (_contentHeight != null && _contentHeight! > 0) {
      final headerHeight = _dragHandleHeight +
          _titleAreaHeight +
          generalAppLevelPadding * 2;
      final totalContentHeight = _contentHeight! + headerHeight;
      return (totalContentHeight / maxHeight).clamp(minSize, maxSize);
    }

    _measureContent();
    return minSize;
  }

  /// Animates sheet to fit content when measured
  void _animateToContentSize(double initialSize) {
    if (widget.isFullScreen ||
        _contentHeight == null ||
        _contentHeight! <= 0 ||
        !_isControllerReady ||
        _scrollableController!.size >= initialSize) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isControllerReady) {
        _scrollableController!.animateTo(
          initialSize,
          duration: const Duration(milliseconds: _contentAnimationDuration),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildTitleArea(BuildContext context) {
    final themeColor = _getThemeColor(context);
    return Row(
      children: [
        const Spacer(),
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: themeColor.withOpacity(0.1),
            foregroundColor: themeColor,
          ),
          key: const Key("close_button"),
          iconSize: 32,
          focusColor: themeColor,
          onPressed: () => closeProBottomModalSheet(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  /// Builds the sheet content with gradient and theme effects
  Widget _buildSheetContent(
      BuildContext builderContext,
      ScrollController scrollController,
      List<Color> gradientColors,
      ProThemeType themeType,
      Size screenSize) {
    Widget content = Container(
      decoration: BoxDecoration(
        gradient: buildFullScreenGradient(gradientColors, allowTransparency: false),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(_sheetBorderRadius),
          topRight: Radius.circular(_sheetBorderRadius),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: generalAppLevelPadding / 2),
            child: Container(
              height: _dragHandleHeight,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title area (fixed, not scrollable)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: generalAppLevelPadding),
            child: _buildTitleArea(builderContext),
          ),
          // Scrollable content
          Expanded(
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: generalAppLevelPadding,
                    right: generalAppLevelPadding,
                    top: generalAppLevelPadding / 2,
                    bottom: generalAppLevelPadding * 2,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Builder(
                      key: _contentKey,
                      builder: (context) => widget.child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Apply theme effects if themeType is provided
    if (widget.themeType != null) {
      content = ProThemeEffects(
        themeType: themeType,
        effectType: ProEffectType.none,
        size: screenSize,
        child: content,
      );
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = widget.theme ?? Theme.of(context);
    final currentThemeType = widget.themeType ?? ProThemeType.classic;
    final currentGradientColors = widget.gradientColors ??
        [
          Theme.of(context).colorScheme.surface,
          Theme.of(context).colorScheme.surface,
          Theme.of(context).colorScheme.surface
        ];
    final screenSize = MediaQuery.of(context).size;

    return Theme(
      data: currentTheme,
      child: NotificationListener<DraggableScrollableNotification>(
        onNotification: (DraggableScrollableNotification notification) {
          // Close the sheet when dragged to minimum extent
          if (notification.extent <= notification.minExtent &&
              notification.shouldCloseOnMinExtent) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            });
          }
          return false;
        },
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final mediaQuery = MediaQuery.of(context);
            final keyboardHeight = mediaQuery.viewInsets.bottom;
            final safeAreaTop = mediaQuery.padding.top;
            final maxHeight = constraints.maxHeight;

            // Calculate sizes: maxSize stays constant regardless of keyboard state
            // The Padding widget below pushes the sheet above keyboard while maintaining same height
            final maxSize = _calculateMaxSize(maxHeight, safeAreaTop);
            final minSize = widget.isFullScreen ? maxSize : _minSheetSize;
            final initialSize = _calculateInitialSize(maxHeight, minSize, maxSize);

            // Handle keyboard change to expand sheet to max when keyboard appears
            _handleKeyboardChange(keyboardHeight, maxSize);

            // Animate to content size if content was just measured
            _animateToContentSize(initialSize);

            return Padding(
              // Push entire sheet up above keyboard
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: DraggableScrollableSheet(
                controller: _scrollableController,
                initialChildSize: initialSize,
                minChildSize: minSize,
                maxChildSize: maxSize,
                expand: false,
                snap: true,
                snapSizes: [initialSize],
                shouldCloseOnMinExtent: true,
                builder: (BuildContext builderContext, ScrollController scrollController) {
                  return _buildSheetContent(
                    builderContext,
                    scrollController,
                    currentGradientColors,
                    currentThemeType,
                    screenSize,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
