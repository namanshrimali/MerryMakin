import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import './pro_text.dart';

enum TextPosition {
  top,
  center,
  bottom,
}

class ProImageCard extends StatefulWidget {
  final String imageUrl;
  final String title;
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
    try {
      final imageProvider = NetworkImage(widget.imageUrl);
      final imageStream = imageProvider.resolve(ImageConfiguration.empty);

      final completer = Completer<ui.Image?>();
      late ImageStreamListener listener;

      listener = ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          completer.complete(info.image);
          imageStream.removeListener(listener);
        },
        onError: (exception, stackTrace) {
          completer.complete(null);
          imageStream.removeListener(listener);
        },
      );

      imageStream.addListener(listener);
      final image = await completer.future;

      if (image != null && mounted) {
        // Sample pixels based on text position
        final pixelData =
            await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        if (pixelData != null) {
          final bytes = pixelData.buffer.asUint8List();
          final width = image.width;
          final height = image.height;

          int sampleStartY;
          int sampleEndY;

          // Sample from the area where text will be positioned
          switch (widget.textPosition) {
            case TextPosition.top:
              // Sample from top 30% of the image
              sampleStartY = 0;
              sampleEndY = (height * 0.3).toInt();
              break;
            case TextPosition.center:
              // Sample from center 30% of the image
              sampleStartY = (height * 0.35).toInt();
              sampleEndY = (height * 0.65).toInt();
              break;
            case TextPosition.bottom:
              // Sample from bottom 30% of the image
              sampleStartY = (height * 0.7).toInt();
              sampleEndY = height;
              break;
          }

          int totalR = 0, totalG = 0, totalB = 0;
          int sampleCount = 0;

          // Sample pixels in the relevant portion
          for (int y = sampleStartY; y < sampleEndY; y += 2) {
            for (int x = 0; x < width; x += 2) {
              final index = (y * width + x) * 4;
              if (index + 3 < bytes.length) {
                totalR += bytes[index];
                totalG += bytes[index + 1];
                totalB += bytes[index + 2];
                sampleCount++;
              }
            }
          }

          if (sampleCount > 0 && mounted) {
            // Darken the color slightly to ensure text readability
            final avgR = (totalR / sampleCount).round();
            final avgG = (totalG / sampleCount).round();
            final avgB = (totalB / sampleCount).round();

            setState(() {
              _gradientColor = Color.fromRGBO(
                (avgR * 0.7).round().clamp(0, 255),
                (avgG * 0.7).round().clamp(0, 255),
                (avgB * 0.7).round().clamp(0, 255),
                1.0,
              );
            });
          }
        }
      }
    } catch (e) {
      // If extraction fails, use default dark color
      if (mounted) {
        setState(() {
          _gradientColor = Colors.black;
        });
      }
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
            Colors.transparent,
            Colors.transparent,
            gradientColor.withOpacity(0.3),
            gradientColor.withOpacity(0.3),
            Colors.transparent,
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 0.45, 0.55, 0.65, 1.0],
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
          ],
          stops: const [0.0, 0.5, 0.75, 1.0],
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
            widget.title,
            textStyle: const TextStyle(
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
            final gradientColor = _gradientColor ?? Colors.black;

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
                        Image.network(
                          widget.imageUrl,
                          height: effectiveHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
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
