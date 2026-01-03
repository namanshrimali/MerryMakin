import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/colors.dart';
import './pro_text.dart';

enum TextPosition {
  top,
  center,
  bottom,
}

class ProImageCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final TextStyle? titleStyle;
  final Widget? subtitle;
  final Widget? thirdRow;
  final double width;
  final double? imageHeight;
  final VoidCallback? onTap;
  final double radius;
  final TextPosition textPosition;

  const ProImageCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.titleStyle,
    this.subtitle,
    this.width = 280,
    this.imageHeight,
    this.onTap,
    this.thirdRow,
    this.radius = generalAppLevelPadding,
    this.textPosition = TextPosition.bottom,
  });

  @override
  State<ProImageCard> createState() => _ProImageCardState();
}

class _ProImageCardState extends State<ProImageCard> {
  Color? _gradientColor;

  @override
  void initState() {
    super.initState();
    _extractColorFromImage();
  }

  Future<void> _extractColorFromImage() async {
    if (widget.imageUrl.isEmpty) {
      return;
    }
    // Use the improved color extraction from colors.dart
    final color = await extractGradientFromImage(widget.imageUrl, mounted);
    if (mounted) {
      setState(() {
        _gradientColor = color;
      });
    }
  }

  LinearGradient _buildGradient(Color gradientColor) {
    switch (widget.textPosition) {
      case TextPosition.top:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            gradientColor.withOpacity(0.7),
            gradientColor.withOpacity(0.3),
            Colors.transparent,
            Colors.transparent,
          ],
          stops: const [0.0, 0.25, 0.5, 1.0],
        );
      case TextPosition.center:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
                        gradientColor,
                                    gradientColor.withOpacity(0.9),


            gradientColor.withOpacity(0.7),
          ],
          stops: const [0.0, 0.5, 1.0],
        );
      case TextPosition.bottom:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            gradientColor.withOpacity(0.3),
            gradientColor.withOpacity(0.7),
            gradientColor.withOpacity(0.85),
          ],
          stops: const [0.0, 0.5, 0.7, 0.85, 1.0],
        );
    }
  }

  Widget _buildTextContent() {
    final textWidget = Container(
      padding: const EdgeInsets.all(generalAppLevelPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProText(
            textAlign: TextAlign.center,
            widget.title,
            textStyle: widget.titleStyle?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24) ?? TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: generalAppLevelPadding / 2),
            DefaultTextStyle(
              style: const TextStyle(color: Colors.white),
              child: widget.subtitle!,
            ),
          ],
          if (widget.thirdRow != null) ...[
            const SizedBox(height: generalAppLevelPadding / 2),
            DefaultTextStyle(
              style: const TextStyle(color: Colors.white),
              child: widget.thirdRow!,
            ),
          ],
        ],
      ),
    );

    switch (widget.textPosition) {
      case TextPosition.top:
        return Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: textWidget,
        );
      case TextPosition.center:
        return Positioned.fill(
          child: Center(
            child: textWidget,
          ),
        );
      case TextPosition.bottom:
        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: textWidget,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.radius),
      ),
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.only(right: generalAppLevelPadding),
      child: InkWell(
        onTap: widget.onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: widget.width,
            minWidth: widget.width,
          ),
          child: LayoutBuilder(builder: (context, constraints) {
            final effectiveHeight = widget.imageHeight ?? 200.0;
            final gradientColor = _gradientColor ?? Theme.of(context).colorScheme.primary;

            return ClipRRect(
              borderRadius: BorderRadius.circular(widget.radius),
              child: SizedBox(
                height: effectiveHeight,
                width: double.infinity,
                child: Stack(
                  children: [
                    // Image with gradient overlay
                    Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.imageUrl,
                          height: effectiveHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) {
                            return Container(
                              height: effectiveHeight,
                              width: constraints.maxWidth,
                              color: Colors.blueGrey.withOpacity(0.1),
                              // child: const Icon(Icons.error),
                            );
                          },
                        ),
                        // Gradient overlay matching image color based on text position
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: _buildGradient(gradientColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Text content positioned based on textPosition
                    _buildTextContent(),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
