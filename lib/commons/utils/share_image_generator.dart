import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../themes/pro_themes.dart';
import '../widgets/pro_font_selector.dart';
import '../widgets/pro_theme_effects.dart';
import 'dart:math';

import 'date_time.dart';
import '../../utils/event_gradient_helper.dart';
import 'colors.dart';

class ShareImageGenerator {

  static generateDateTimeImage(Event event, Size size, ThemeData theme, bool usePrimaryBackground, Canvas canvas) {
    final dateTime = event.startDateTime!;
    final textColor = usePrimaryBackground ? theme.colorScheme.surface : theme.primaryColor;
    
    // Format time with AM/PM
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    
    // Calculate section dimensions
    final sectionWidth = size.width * 0.75;
    final columnWidth = sectionWidth * 0.33;
    final columnHeight = size.height * 0.1;
    final columnTop = size.height * 0.8;
    final leftOffset = (size.width - sectionWidth) / 2;

    // Helper to paint centered text in a column
    void paintColumnText(String text, double xOffset, double fontSize, {FontWeight? fontWeight}) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight ?? FontWeight.normal,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      painter.layout(maxWidth: columnWidth);
      painter.paint(
        canvas,
        Offset(
          leftOffset + xOffset + (columnWidth - painter.width) / 2,
          columnTop + (columnHeight - painter.height) / 2,
        ),
      );
    }

    // Left column: Day
    paintColumnText(getDayName(dateTime.weekday), 0, 48, fontWeight: FontWeight.w500);

    // Middle column: Month, Date, Year
    final middlePainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(text: '${getMonthName(dateTime.month)}\n', style: TextStyle(color: textColor, fontSize: 48, fontWeight: FontWeight.w500)),
          TextSpan(text: '${dateTime.day}\n', style: TextStyle(color: textColor, fontSize: 64)),
          TextSpan(text: dateTime.year.toString(), style: TextStyle(color: textColor, fontSize: 48)),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    middlePainter.layout(maxWidth: columnWidth);
    middlePainter.paint(
      canvas,
      Offset(
        leftOffset + columnWidth + (columnWidth - middlePainter.width) / 2,
        columnTop + (columnHeight - middlePainter.height) / 2,
      ),
    );

    // Right column: Time
    final timePainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(text: '$hour ', style: TextStyle(color: textColor, fontSize: 48)),
          TextSpan(text: amPm, style: TextStyle(color: textColor, fontSize: 48)),
        ],
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    timePainter.layout(maxWidth: columnWidth);
    timePainter.paint(
      canvas,
      Offset(
        leftOffset + columnWidth * 2 + (columnWidth - timePainter.width) / 2,
        columnTop + (columnHeight - timePainter.height) / 2,
      ),
    );
  }
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
    
    // Cache repeated calculations
    final halfWidth = size.width / 2;
    final textColor = usePrimaryBackground 
        ? theme.colorScheme.surface 
        : theme.textTheme.bodyLarge?.color ?? Colors.black;
    final fontFamily = event.font != null 
        ? ProFontType.values.firstWhere(
            (type) => type.toString() == event.font,
            orElse: () => ProFontType.system,
          ).fontFamily
        : null;

    // Compute gradient colors and load image in parallel
    final gradientColors = await extractSectionDominantColors(event.imageUrl, true);
    final eventImage = await _loadNetworkImage(event.imageUrl);

    // Draw background gradient
    final backgroundPaint = Paint()
      ..shader = buildFullScreenGradient(gradientColors).createShader(rect);
    canvas.drawRect(rect, backgroundPaint);

    // Draw theme effects (reduced from 3x to 1x for performance)
    final random = Random();
    final effectPainter = EffectPainter(
      themeType: themeType,
      effectType: effectType,
      progress: 0.5,
      effects: List.generate(15, (index) => EffectItem(
        angle: random.nextDouble(),
        position: Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        size: 40,
        speed: 1,
      )),
    );
    effectPainter.paint(canvas, size);

    // Draw event image with overlay
    double usedImageHeight = 0;
    if (eventImage != null) {
      final imageRatio = eventImage.width / eventImage.height;
      final targetHeight = size.width / imageRatio;
      final imageRect = Rect.fromCenter(
        center: Offset(halfWidth, size.height * 0.35),
        width: size.width,
        height: targetHeight,
      );
      usedImageHeight = imageRect.height;

      canvas.drawImageRect(
        eventImage,
        Rect.fromLTWH(0, 0, eventImage.width.toDouble(), eventImage.height.toDouble()),
        imageRect,
        Paint()..filterQuality = FilterQuality.high,
      );

      final heroPaint = Paint()
        ..shader = buildHeroGradient(gradientColors).createShader(imageRect);
      canvas.drawRect(imageRect, heroPaint);
    }

    // Calculate text layout
    final imageSpace = usedImageHeight > 0 ? usedImageHeight : size.height * 0.7;
    final brandingSpace = size.height * 0.1;
    final remainingSpace = size.height - imageSpace - brandingSpace;
    final nameHeight = event.startDateTime != null ? size.height * 0.1 : remainingSpace * 0.8;
    final maxWidth = size.width * 0.8;
    
    // Binary search for optimal font size (faster than linear decrement)
    double minFontSize = 24;
    double maxFontSize = 128;
    double fontSize = maxFontSize;
    TextPainter? textPainter;
    
    while (maxFontSize - minFontSize > 2) {
      fontSize = (minFontSize + maxFontSize) / 2;
      textPainter = TextPainter(
        text: TextSpan(
          text: event.name,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: maxWidth);
      
      if (textPainter.height > nameHeight) {
        maxFontSize = fontSize;
      } else {
        minFontSize = fontSize;
      }
    }
    
    // Final layout with optimal size
    textPainter = TextPainter(
      text: TextSpan(
        text: event.name,
        style: TextStyle(
          color: textColor,
          fontSize: minFontSize,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);

    final nameY = event.startDateTime != null
        ? size.height * 0.75
        : imageSpace + (remainingSpace - textPainter.height) / 2;
    textPainter.paint(canvas, Offset((size.width - textPainter.width) / 2, nameY));

    // Helper to paint centered text and return height
    double paintText(String text, double fontSize, double yOffset) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: TextStyle(color: textColor, fontSize: fontSize)),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      painter.layout(maxWidth: size.width);
      painter.paint(canvas, Offset((size.width - painter.width) / 2, yOffset));
      return painter.height;
    }

    double currentY = nameY + textPainter.height;
    if (event.startDateTime != null) {
      currentY += 4;
      currentY += paintText(event.fullFormattedStartDateTime, 48, currentY);
    }

    if (event.location != null && event.location!.isNotEmpty) {
      currentY += 4;
      paintText(event.location!, 48, currentY);
    }

    // Draw branding
    paintText('RSVP on MerryMakin', 32, size.height * 0.95);

    return recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
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