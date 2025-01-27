import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../themes/pro_themes.dart';
import '../widgets/pro_font_selector.dart';
import '../widgets/pro_theme_effects.dart';
import 'dart:math';

import 'date_time.dart';

class ShareImageGenerator {
  static Future<ui.Image> generateEventShareImage({
    required Event event,
    required ProThemeType themeType,
    required ProEffectType effectType,
    required Size size,
    bool usePrimaryBackground = false,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final theme = ProThemes.themes[themeType]!.theme;
    final rect = Offset.zero & size;

    // Draw background with specified color
    final paint = Paint()
      ..color = usePrimaryBackground 
          ? theme.primaryColor 
          : theme.colorScheme.background;
    canvas.drawRect(rect, paint);

    // Draw theme effects with even distribution
    final random = Random();
    final effectPainter = EffectPainter(
      themeType: themeType,
      effectType: effectType,
      progress: 0.5,
      effects: List.generate(30, (index) => EffectItem(
        position: Offset(
          random.nextDouble() * size.width,  // Random X position
          random.nextDouble() * size.height, // Random Y position
        ),
        size: 40,
        speed: 1,
      )),
    );
    
    // Paint effects multiple times for better visibility
    for (int i = 0; i < 3; i++) {
      effectPainter.paint(canvas, size);
    }

    // Load and draw event image
    final eventImage = await _loadNetworkImage(event.imageUrl);
    if (eventImage != null) {
      // Calculate aspect ratio
      final imageRatio = eventImage.width / eventImage.height;
      final targetHeight = size.height * 0.6;
      final targetWidth = targetHeight * imageRatio;

      final imageRect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.35),
        width: targetWidth,
        height: targetHeight,
      );
      
      canvas.drawImageRect(
        eventImage,
        Rect.fromLTWH(0, 0, eventImage.width.toDouble(), eventImage.height.toDouble()),
        imageRect,
        Paint()..filterQuality = FilterQuality.high,
      );
    }

    // Calculate available space for text
    final imageSpace = size.height * 0.5; // Space taken by image
    final brandingSpace = size.height * 0.1; // Space for branding at bottom
    final remainingSpace = size.height - imageSpace - brandingSpace;
    
    // Draw event name with theme primary color or inverse primary color
    final nameHeight = event.startDateTime != null 
        ? size.height * 0.1 // Fixed height when date is present
        : remainingSpace * 0.8; // Larger height when no date
    final maxWidth = size.width * 0.8;
    double fontSize = 128; // Starting font size
    TextPainter textPainter;
    
    // Dynamically adjust font size until text fits
    do {
      textPainter = TextPainter(
        text: TextSpan(
          text: event.name,
          style: TextStyle(
            color: usePrimaryBackground 
                ? theme.colorScheme.inversePrimary 
                : theme.primaryColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: event.font != null 
                ? ProFontType.values.firstWhere(
                    (type) => type.toString() == event.font,
                    orElse: () => ProFontType.system,
                  ).fontFamily
                : null,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: maxWidth);
      
      if (textPainter.height > nameHeight) {
        fontSize -= 4; // Reduce font size and try again
      }
    } while (textPainter.height > nameHeight && fontSize > 24);

    // Calculate vertical position
    final nameY = event.startDateTime != null
        ? size.height * 0.7 // Original position when date is present
        : imageSpace + (remainingSpace - textPainter.height) / 2; // Centered in remaining space

    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        nameY,
      ),
    );

    if (event.startDateTime != null) {
      // Draw date information
      final dateTime = event.startDateTime;

      // Format time with AM/PM
      final hour = dateTime!.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
      // final minutes = dateTime.minute.toString().padLeft(2, '0');
      
      // Calculate section dimensions
      final sectionWidth = size.width * 0.75; // 80% of total width
      final columnWidth = sectionWidth * 0.33; // Each column takes 1/3 of section width
      final columnHeight = size.height * 0.1;
      final columnTop = size.height * 0.8;
      final leftOffset = (size.width - sectionWidth) / 2; // Center the entire section

      // // Draw horizontal lines for Day column
      // final linePaint = Paint()
      //   ..color = usePrimaryBackground 
      //       ? theme.colorScheme.surface 
      //       : theme.primaryColor
      //   ..strokeWidth = 2;
      
      // Day column lines
      // canvas.drawLine(
      //   Offset(leftOffset, columnTop + columnHeight * 0.2),
      //   Offset(leftOffset + columnWidth, columnTop + columnHeight * 0.2),
      //   linePaint,
      // );
      // canvas.drawLine(
      //   Offset(leftOffset, columnTop + columnHeight * 0.8),
      //   Offset(leftOffset + columnWidth, columnTop + columnHeight * 0.8),
      //   linePaint,
      // );

      // Time column lines
      // canvas.drawLine(
      //   Offset(leftOffset + columnWidth * 2, columnTop + columnHeight * 0.2),
      //   Offset(leftOffset + columnWidth * 3, columnTop + columnHeight * 0.2),
      //   linePaint,
      // );
      // canvas.drawLine(
      //   Offset(leftOffset + columnWidth * 2, columnTop + columnHeight * 0.8),
      //   Offset(leftOffset + columnWidth * 3, columnTop + columnHeight * 0.8),
      //   linePaint,
      // );

      // Left column: Day
      final leftColumnPainter = TextPainter(
        text: TextSpan(
          text: getDayName(dateTime.weekday),
          style: TextStyle(
            color: usePrimaryBackground 
                ? theme.colorScheme.surface 
                : theme.primaryColor,
            fontSize: 48,
            fontWeight: FontWeight.w500,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      // Middle column: Month, Date, Year
      final middleColumnPainter = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${getMonthName(dateTime.month)}\n',
              style: TextStyle(
                color: usePrimaryBackground 
                    ? theme.colorScheme.surface 
                    : theme.primaryColor,
                fontSize: 48,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: '${dateTime.day}\n',
              style: TextStyle(
                color: usePrimaryBackground 
                    ? theme.colorScheme.surface 
                    : theme.primaryColor,
                fontSize: 64,
              ),
            ),
            TextSpan(
              text: dateTime.year.toString(),
              style: TextStyle(
                color: usePrimaryBackground 
                    ? theme.colorScheme.surface 
                    : theme.primaryColor,
                fontSize: 48,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      // Right column: Time
      final rightColumnPainter = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$hour ',
              style: TextStyle(
                color: usePrimaryBackground 
                    ? theme.colorScheme.surface 
                    : theme.primaryColor,
                fontSize: 48,
              ),
            ),
            TextSpan(
              text: amPm,
              style: TextStyle(
                color: usePrimaryBackground 
                    ? theme.colorScheme.surface 
                    : theme.primaryColor,
                fontSize: 48,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );

      // Layout and paint left column (Day)
      leftColumnPainter.layout(maxWidth: columnWidth);
      leftColumnPainter.paint(
        canvas,
        Offset(
          leftOffset + (columnWidth - leftColumnPainter.width) / 2,
          columnTop + (columnHeight - leftColumnPainter.height) / 2,
        ),
      );

      // Layout and paint middle column (Month, Date, Year)
      middleColumnPainter.layout(maxWidth: columnWidth);
      middleColumnPainter.paint(
        canvas,
        Offset(
          leftOffset + columnWidth + (columnWidth - middleColumnPainter.width) / 2,
          columnTop + (columnHeight - middleColumnPainter.height) / 2,
        ),
      );

      // Layout and paint right column (Time)
      rightColumnPainter.layout(maxWidth: columnWidth);
      rightColumnPainter.paint(
        canvas,
        Offset(
          leftOffset + columnWidth * 2 + (columnWidth - rightColumnPainter.width) / 2,
          columnTop + (columnHeight - rightColumnPainter.height) / 2,
        ),
      );
    }

    // Draw app branding
    final brandingPainter = TextPainter(
      text: TextSpan(
        text: 'RSVP on MerryMakin',
        style: TextStyle(
          color: usePrimaryBackground 
              ? theme.colorScheme.surface 
              : theme.textTheme.bodyLarge?.color,
          fontSize: 32,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    brandingPainter.layout(maxWidth: size.width);
    brandingPainter.paint(
      canvas,
      Offset(
        (size.width - brandingPainter.width) / 2,
        size.height * 0.95,
      ),
    );

    return recorder.endRecording().toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
  }

  static Future<ui.Image?> _loadNetworkImage(String imageUrl) async {
    try {
      final encodedUrl = Uri.encodeFull(imageUrl);
      final imageProvider = NetworkImage(encodedUrl);
      final imageStream = imageProvider.resolve(ImageConfiguration.empty);
      final Completer<ui.Image?> completer = Completer<ui.Image?>();
      
      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          completer.complete(info.image);
          imageStream.removeListener(listener);
        },
        onError: (exception, stackTrace) {
          print('Error loading image: $exception');
          completer.complete(null);
          imageStream.removeListener(listener);
        },
      );
      
      imageStream.addListener(listener);
      return await completer.future;
    } catch (e) {
      print('Error in _loadNetworkImage: $e');
      return null;
    }
  }
} 