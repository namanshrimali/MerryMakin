import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

Future<Color> extractGradientFromImage(String imageUrl, mounted) async {
  if (imageUrl.isEmpty) {
    return Colors.black;
  }
  try {
    final imageProvider = NetworkImage(imageUrl);
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
      final pixelData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (pixelData != null) {
        final bytes = pixelData.buffer.asUint8List();
        final width = image.width;
        final height = image.height;

        // Sample from bottom 30% of the image where text will be positioned
        final sampleStartY = (height * 0.7).toInt();
        final sampleEndY = height;

        int totalR = 0, totalG = 0, totalB = 0;
        int sampleCount = 0;

        // Sample pixels in the bottom portion
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

          return Color.fromRGBO(
            (avgR * 0.7).round().clamp(0, 255),
            (avgG * 0.7).round().clamp(0, 255),
            (avgB * 0.7).round().clamp(0, 255),
            1.0,
          );
        } 
      }
    }
  } catch (e) {
    return Colors.black;
  }
  return Colors.black;
}
