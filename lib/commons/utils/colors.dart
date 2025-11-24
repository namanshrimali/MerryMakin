import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Future<Color> extractGradientFromImage(String imageUrl, mounted) async {
  if (imageUrl.isEmpty) {
    return Colors.black;
  }
  try {
    final imageProvider = CachedNetworkImageProvider(imageUrl);
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

        // Sample from bottom 40% of the image where text will be positioned
        final sampleStartY = (height * 0.6).toInt();
        final sampleEndY = height;

        int totalR = 0, totalG = 0, totalB = 0;
        int sampleCount = 0;
        int vibrantR = 0, vibrantG = 0, vibrantB = 0;
        int vibrantCount = 0;
        int brightR = 0, brightG = 0, brightB = 0;
        int brightCount = 0;

        // Sample pixels in the bottom portion
        for (int y = sampleStartY; y < sampleEndY; y += 2) {
          for (int x = 0; x < width; x += 2) {
            final index = (y * width + x) * 4;
            if (index + 3 < bytes.length) {
              final r = bytes[index];
              final g = bytes[index + 1];
              final b = bytes[index + 2];
              
              // Calculate brightness
              final brightness = (r * 0.299 + g * 0.587 + b * 0.114);
              final saturation = _calculateSaturation(r, g, b);
              
              totalR += r;
              totalG += g;
              totalB += b;
              sampleCount++;

              // Prefer bright, vibrant colors (brightness > 100, saturation > 0.2)
              if (brightness > 100 && saturation > 0.2) {
                brightR += r;
                brightG += g;
                brightB += b;
                brightCount++;
                
                // Even better: very bright and vibrant colors
                if (brightness > 130 && saturation > 0.3) {
                  vibrantR += r;
                  vibrantG += g;
                  vibrantB += b;
                  vibrantCount++;
                }
              }
            }
          }
        }

        if (sampleCount > 0 && mounted) {
          int finalR, finalG, finalB;
          
          // Prioritize: very bright vibrant > bright vibrant > average (but brightened)
          if (vibrantCount > 0) {
            // Use very bright, vibrant colors
            finalR = (vibrantR / vibrantCount).round();
            finalG = (vibrantG / vibrantCount).round();
            finalB = (vibrantB / vibrantCount).round();
            
            // Enhance saturation for more vibrant look
            final avgBrightness = (finalR + finalG + finalB) / 3;
            finalR = ((finalR - avgBrightness) * 1.3 + avgBrightness).round().clamp(0, 255);
            finalG = ((finalG - avgBrightness) * 1.25 + avgBrightness).round().clamp(0, 255);
            finalB = ((finalB - avgBrightness) * 1.1 + avgBrightness).round().clamp(0, 255);
          } else if (brightCount > 0) {
            // Use bright colors
            finalR = (brightR / brightCount).round();
            finalG = (brightG / brightCount).round();
            finalB = (brightB / brightCount).round();
            
            // Enhance saturation
            final avgBrightness = (finalR + finalG + finalB) / 3;
            finalR = ((finalR - avgBrightness) * 1.25 + avgBrightness).round().clamp(0, 255);
            finalG = ((finalG - avgBrightness) * 1.2 + avgBrightness).round().clamp(0, 255);
            finalB = ((finalB - avgBrightness) * 1.05 + avgBrightness).round().clamp(0, 255);
          } else {
            // Fallback: use average but brighten significantly
            finalR = (totalR / sampleCount).round();
            finalG = (totalG / sampleCount).round();
            finalB = (totalB / sampleCount).round();
            
            // Brighten significantly to avoid dark colors
            finalR = (finalR * 1.4).round().clamp(0, 255);
            finalG = (finalG * 1.35).round().clamp(0, 255);
            finalB = (finalB * 1.3).round().clamp(0, 255);
            
            // Boost saturation
            final avgBrightness = (finalR + finalG + finalB) / 3;
            finalR = ((finalR - avgBrightness) * 1.2 + avgBrightness).round().clamp(0, 255);
            finalG = ((finalG - avgBrightness) * 1.15 + avgBrightness).round().clamp(0, 255);
            finalB = ((finalB - avgBrightness) * 1.05 + avgBrightness).round().clamp(0, 255);
          }

          // Ensure colors are always bright and lively (minimum brightness: 140)
          final brightness = (finalR * 0.299 + finalG * 0.587 + finalB * 0.114);
          if (brightness < 140) {
            // Boost to ensure minimum brightness of 140
            final boost = (140 - brightness) / brightness;
            finalR = (finalR * (1 + boost * 0.8)).round().clamp(0, 255);
            finalG = (finalG * (1 + boost * 0.8)).round().clamp(0, 255);
            finalB = (finalB * (1 + boost * 0.8)).round().clamp(0, 255);
          } else if (brightness > 220) {
            // Slightly tone down very bright colors but keep them vibrant
            finalR = (finalR * 0.95).round().clamp(0, 255);
            finalG = (finalG * 0.95).round().clamp(0, 255);
            finalB = (finalB * 0.95).round().clamp(0, 255);
          }
          
          // Final check: ensure we have a bright, lively color
          final finalBrightness = (finalR * 0.299 + finalG * 0.587 + finalB * 0.114);
          if (finalBrightness < 140) {
            final boost = (150 - finalBrightness) / finalBrightness;
            finalR = (finalR * (1 + boost)).round().clamp(0, 255);
            finalG = (finalG * (1 + boost)).round().clamp(0, 255);
            finalB = (finalB * (1 + boost)).round().clamp(0, 255);
          }

          // Extract bright color first, then darken it for gradient backgrounds
          final brightColor = Color.fromRGBO(finalR, finalG, finalB, 1.0);
          // Darken to appropriate level for white text readability
          return _darkenForGradient(brightColor, targetBrightness: 100.0);
        } 
      }
    }
  } catch (e) {
    return Colors.black;
  }
  return Colors.black;
}

double _calculateSaturation(int r, int g, int b) {
  final max = r > g ? (r > b ? r : b) : (g > b ? g : b);
  final min = r < g ? (r < b ? r : b) : (g < b ? g : b);
  if (max == 0) return 0.0;
  return (max - min) / max;
}

/// Darkens a bright color to an appropriate level for gradient backgrounds
/// while maintaining its hue and saturation characteristics for white text readability
Color _darkenForGradient(Color brightColor, {double targetBrightness = 100.0}) {
  final r = brightColor.red;
  final g = brightColor.green;
  final b = brightColor.blue;

  // Calculate current brightness
  final currentBrightness = (r * 0.299 + g * 0.587 + b * 0.114);

  // Only darken colors that are too bright for white text; never lighten or clamp to black
  if (currentBrightness <= targetBrightness) {
    return brightColor;
  }

  // Darken proportionally towards the target brightness
  final double darkenFactor = (targetBrightness / currentBrightness).clamp(0.0, 1.0);

  final newR = (r * darkenFactor).round().clamp(0, 255);
  final newG = (g * darkenFactor).round().clamp(0, 255);
  final newB = (b * darkenFactor).round().clamp(0, 255);

  return Color.fromRGBO(newR, newG, newB, 1.0);
}

Future<List<Color>> extractMultipleColorsFromImage(String imageUrl, mounted, {int colorCount = 3}) async {
  if (imageUrl.isEmpty) {
    return List.generate(colorCount, (_) => Colors.black);
  }
  try {
    final imageProvider = CachedNetworkImageProvider(imageUrl);
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

        // Sample from different regions of the image for dominant color extraction
        final regions = [
          {'startY': 0, 'endY': (height * 0.33).toInt(), 'name': 'top'}, // Top third
          {'startY': (height * 0.33).toInt(), 'endY': (height * 0.66).toInt(), 'name': 'middle'}, // Middle third
          {'startY': (height * 0.66).toInt(), 'endY': height, 'name': 'bottom'}, // Bottom third
        ];

        final List<Map<String, dynamic>> colorBuckets = [];
        
        for (final region in regions) {
          final sampleStartY = region['startY'] as int;
          final sampleEndY = region['endY'] as int;
          
          int totalR = 0, totalG = 0, totalB = 0;
          int sampleCount = 0;
          int vibrantR = 0, vibrantG = 0, vibrantB = 0;
          int vibrantCount = 0;
          int brightR = 0, brightG = 0, brightB = 0;
          int brightCount = 0;
          // Use a color frequency map to find truly dominant colors in this region
          final Map<String, Map<String, int>> dominantColorMap = {};

          // Sample pixels in this region
          for (int y = sampleStartY; y < sampleEndY; y += 3) {
            for (int x = 0; x < width; x += 3) {
              final index = (y * width + x) * 4;
              if (index + 3 < bytes.length) {
                final r = bytes[index];
                final g = bytes[index + 1];
                final b = bytes[index + 2];
                
                // Calculate brightness
                final brightness = (r * 0.299 + g * 0.587 + b * 0.114);
                final saturation = _calculateSaturation(r, g, b);
                
                totalR += r;
                totalG += g;
                totalB += b;
                sampleCount++;

                // Prefer bright, vibrant colors (brightness > 100, saturation > 0.2)
                if (brightness > 50 && saturation > 0.2) {
                  brightR += r;
                  brightG += g;
                  brightB += b;
                  brightCount++;
                  
                  // Track dominant colors by quantizing to reduce color space
                  // Quantize to 16 levels per channel for dominant color detection
                  final quantizedR = (r ~/ 16) * 16;
                  final quantizedG = (g ~/ 16) * 16;
                  final quantizedB = (b ~/ 16) * 16;
                  final colorKey = '$quantizedR,$quantizedG,$quantizedB';
                  
                  if (!dominantColorMap.containsKey(colorKey)) {
                    dominantColorMap[colorKey] = {'r': 0, 'g': 0, 'b': 0, 'count': 0};
                  }
                  dominantColorMap[colorKey]!['r'] = (dominantColorMap[colorKey]!['r'] as int) + r;
                  dominantColorMap[colorKey]!['g'] = (dominantColorMap[colorKey]!['g'] as int) + g;
                  dominantColorMap[colorKey]!['b'] = (dominantColorMap[colorKey]!['b'] as int) + b;
                  dominantColorMap[colorKey]!['count'] = (dominantColorMap[colorKey]!['count'] as int) + 1;
                  
                  // Even better: very bright and vibrant colors
                  if (brightness > 130 && saturation > 0.3) {
                    vibrantR += r;
                    vibrantG += g;
                    vibrantB += b;
                    vibrantCount++;
                  }
                }
              }
            }
          }

          if (sampleCount > 0) {
            int finalR, finalG, finalB;
            
            // Try to use dominant colors from the region if available
            if (dominantColorMap.isNotEmpty) {
              // Sort by frequency to get most dominant colors
              final sortedDominant = dominantColorMap.entries.toList()
                ..sort((a, b) => (b.value['count'] as int).compareTo(a.value['count'] as int));
              
              // Use the most dominant bright color
              final mostDominant = sortedDominant.first;
              final dominantR = (mostDominant.value['r'] as int) ~/ (mostDominant.value['count'] as int);
              final dominantG = (mostDominant.value['g'] as int) ~/ (mostDominant.value['count'] as int);
              final dominantB = (mostDominant.value['b'] as int) ~/ (mostDominant.value['count'] as int);
              
              final dominantBrightness = (dominantR * 0.299 + dominantG * 0.587 + dominantB * 0.114);
              
              // Use dominant color if it's bright enough
              if (dominantBrightness > 100) {
                finalR = dominantR;
                finalG = dominantG;
                finalB = dominantB;
              } else {
                // Fall through to vibrant/bright extraction
                if (vibrantCount > 0) {
                  finalR = (vibrantR / vibrantCount).round();
                  finalG = (vibrantG / vibrantCount).round();
                  finalB = (vibrantB / vibrantCount).round();
                } else if (brightCount > 0) {
                  finalR = (brightR / brightCount).round();
                  finalG = (brightG / brightCount).round();
                  finalB = (brightB / brightCount).round();
                } else {
                  finalR = (totalR / sampleCount).round();
                  finalG = (totalG / sampleCount).round();
                  finalB = (totalB / sampleCount).round();
                  finalR = (finalR * 1.4).round().clamp(0, 255);
                  finalG = (finalG * 1.35).round().clamp(0, 255);
                  finalB = (finalB * 1.3).round().clamp(0, 255);
                }
              }
            } else {
              // Prioritize: very bright vibrant > bright vibrant > average (but brightened)
              if (vibrantCount > 0) {
                // Use very bright, vibrant colors
                finalR = (vibrantR / vibrantCount).round();
                finalG = (vibrantG / vibrantCount).round();
                finalB = (vibrantB / vibrantCount).round();
                
                // Enhance saturation more aggressively for lively, fun colors
                final avgBrightness = (finalR + finalG + finalB) / 3;
                finalR = ((finalR - avgBrightness) * 1.35 + avgBrightness).round().clamp(0, 255);
                finalG = ((finalG - avgBrightness) * 1.3 + avgBrightness).round().clamp(0, 255);
                finalB = ((finalB - avgBrightness) * 1.15 + avgBrightness).round().clamp(0, 255);
              } else if (brightCount > 0) {
                // Use bright colors
                finalR = (brightR / brightCount).round();
                finalG = (brightG / brightCount).round();
                finalB = (brightB / brightCount).round();
                
                // Enhance saturation and ensure brightness
                final avgBrightness = (finalR + finalG + finalB) / 3;
                finalR = ((finalR - avgBrightness) * 1.3 + avgBrightness).round().clamp(0, 255);
                finalG = ((finalG - avgBrightness) * 1.25 + avgBrightness).round().clamp(0, 255);
                finalB = ((finalB - avgBrightness) * 1.1 + avgBrightness).round().clamp(0, 255);
              } else {
                // Fallback: use average but brighten significantly
                finalR = (totalR / sampleCount).round();
                finalG = (totalG / sampleCount).round();
                finalB = (totalB / sampleCount).round();
                
                // Brighten significantly to avoid dark colors
                finalR = (finalR * 1.4).round().clamp(0, 255);
                finalG = (finalG * 1.35).round().clamp(0, 255);
                finalB = (finalB * 1.3).round().clamp(0, 255);
                
                // Boost saturation
                final avgBrightness = (finalR + finalG + finalB) / 3;
                finalR = ((finalR - avgBrightness) * 1.25 + avgBrightness).round().clamp(0, 255);
                finalG = ((finalG - avgBrightness) * 1.2 + avgBrightness).round().clamp(0, 255);
                finalB = ((finalB - avgBrightness) * 1.1 + avgBrightness).round().clamp(0, 255);
              }
            }

            // Ensure colors are always bright and lively (minimum brightness: 140)
            final brightness = (finalR * 0.299 + finalG * 0.587 + finalB * 0.114);
            if (brightness < 140) {
              // Boost to ensure minimum brightness of 140
              final boost = (140 - brightness) / brightness;
              finalR = (finalR * (1 + boost * 0.8)).round().clamp(0, 255);
              finalG = (finalG * (1 + boost * 0.8)).round().clamp(0, 255);
              finalB = (finalB * (1 + boost * 0.8)).round().clamp(0, 255);
            } else if (brightness > 220) {
              // Slightly tone down very bright colors but keep them vibrant
              finalR = (finalR * 0.95).round().clamp(0, 255);
              finalG = (finalG * 0.95).round().clamp(0, 255);
              finalB = (finalB * 0.95).round().clamp(0, 255);
            }
            
            // Final check: ensure we have a bright, lively color (target: 140-200 range)
            final finalBrightness = (finalR * 0.299 + finalG * 0.587 + finalB * 0.114);
            if (finalBrightness < 140) {
              final boost = (150 - finalBrightness) / finalBrightness;
              finalR = (finalR * (1 + boost)).round().clamp(0, 255);
              finalG = (finalG * (1 + boost)).round().clamp(0, 255);
              finalB = (finalB * (1 + boost)).round().clamp(0, 255);
            }

            colorBuckets.add({
              'r': finalR,
              'g': finalG,
              'b': finalB,
              'region': region['name'] as String,
            });
          }
        }

        if (colorBuckets.isNotEmpty && mounted) {
          // Sort by region (top to bottom) and return colors
          colorBuckets.sort((a, b) {
            final order = {'top': 0, 'middle': 1, 'bottom': 2};
            return (order[a['region'] as String] ?? 0).compareTo(order[b['region'] as String] ?? 0);
          });

          // Extract bright colors first, then darken them for gradients
          final brightColors = colorBuckets
              .take(colorCount)
              .map((bucket) => Color.fromRGBO(
                    bucket['r'] as int,
                    bucket['g'] as int,
                    bucket['b'] as int,
                    1.0,
                  ))
              .toList();

          // If we have fewer colors than requested, duplicate the last one
          while (brightColors.length < colorCount) {
            brightColors.add(brightColors.isNotEmpty ? brightColors.last : (brightColors.isNotEmpty ? brightColors.last : Colors.black));
          }

          // Darken colors for gradient backgrounds (darker shades for white text readability)
          // Use slightly different target brightness for variety
          final darkenedColors = brightColors.asMap().entries.map((entry) {
            final index = entry.key;
            final brightColor = entry.value;
            // Vary target brightness slightly for gradient depth (90-110 range)
            final targetBrightness = 90.0 + (index * 10.0 / (colorCount - 1).clamp(1, colorCount));
            return _darkenForGradient(brightColor, targetBrightness: targetBrightness);
          }).toList();

          return darkenedColors;
        }
      }
    }
  } catch (e) {
    // Return default colors
  }
  return List.generate(colorCount, (_) => Colors.black);
}

/// Returns three colors: dominant colors from the top, middle, and bottom sections of the image.
/// Order: [topDominant, middleDominant, bottomDominant]
Future<List<Color>> extractSectionDominantColors(String imageUrl, bool mounted) async {
  const int sections = 3;
  final List<Color> fallback = List.generate(sections, (_) => Colors.black);
  if (imageUrl.isEmpty) return fallback;
  try {
    final imageProvider = CachedNetworkImageProvider(imageUrl);
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
    if (image == null || !mounted) return fallback;

    final pixelData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (pixelData == null) return fallback;

    final bytes = pixelData.buffer.asUint8List();
    final width = image.width;
    final height = image.height;

    // Define top, middle, bottom thirds
    final regions = [
      {'startY': 0, 'endY': (height * 0.33).toInt()}, // top
      {'startY': (height * 0.33).toInt(), 'endY': (height * 0.66).toInt()}, // middle
      {'startY': (height * 0.66).toInt(), 'endY': height}, // bottom
    ];

    final List<Color> results = [];

    for (final region in regions) {
      final int startY = region['startY'] as int;
      final int endY = region['endY'] as int;

      // Quantized color histogram (16 levels per channel)
      final Map<String, Map<String, int>> histogram = {};

      // Sample every 3px to keep it fast
      for (int y = startY; y < endY; y += 3) {
        for (int x = 0; x < width; x += 3) {
          final index = (y * width + x) * 4;
          if (index + 3 >= bytes.length) continue;
          final r = bytes[index];
          final g = bytes[index + 1];
          final b = bytes[index + 2];

          // Quantize to reduce noise and group similar colors
          final qr = (r ~/ 16) * 16;
          final qg = (g ~/ 16) * 16;
          final qb = (b ~/ 16) * 16;
          final key = '$qr,$qg,$qb';

          histogram.putIfAbsent(key, () => {'r': 0, 'g': 0, 'b': 0, 'count': 0});
          histogram[key]!['r'] = (histogram[key]!['r'] as int) + r;
          histogram[key]!['g'] = (histogram[key]!['g'] as int) + g;
          histogram[key]!['b'] = (histogram[key]!['b'] as int) + b;
          histogram[key]!['count'] = (histogram[key]!['count'] as int) + 1;
        }
      }

      if (histogram.isEmpty) {
        // Reuse previous color if possible; avoid adding black
        results.add(results.isNotEmpty ? results.last : Colors.black);
        continue;
      }

      // Choose the most frequent quantized bucket, but avoid duplicates with already selected colors
      final entries = histogram.entries.toList()
        ..sort((a, b) => (b.value['count'] as int).compareTo(a.value['count'] as int));

      Color? selectedColor;
      // RGB distance threshold to consider colors "too similar"
      const int similarityThreshold = 35;

      for (final entry in entries) {
        final bucket = entry.value;
        final count = (bucket['count'] as int).clamp(1, 1 << 30);
        final avgR = (bucket['r'] as int) ~/ count;
        final avgG = (bucket['g'] as int) ~/ count;
        final avgB = (bucket['b'] as int) ~/ count;
        final candidate = Color.fromRGBO(
          avgR.clamp(0, 255),
          avgG.clamp(0, 255),
          avgB.clamp(0, 255),
          1.0,
        );

        bool isDistinct = true;
        for (final existing in results) {
          final dr = (candidate.red - existing.red).abs();
          final dg = (candidate.green - existing.green).abs();
          final db = (candidate.blue - existing.blue).abs();
          // Use max channel distance as a cheap distinctness metric
          final maxDelta = [dr, dg, db].reduce((a, b) => a > b ? a : b);
          if (maxDelta < similarityThreshold) {
            isDistinct = false;
            break;
          }
        }
        if (isDistinct) {
          selectedColor = candidate;
          break;
        }
      }

      // If all buckets are similar, fall back to the very top bucket
      selectedColor ??= () {
        final bucket = entries.first.value;
        final count = (bucket['count'] as int).clamp(1, 1 << 30);
        final avgR = (bucket['r'] as int) ~/ count;
        final avgG = (bucket['g'] as int) ~/ count;
        final avgB = (bucket['b'] as int) ~/ count;
        return Color.fromRGBO(
          avgR.clamp(0, 255),
          avgG.clamp(0, 255),
          avgB.clamp(0, 255),
          1.0,
        );
      }();

      results.add(selectedColor);
    }

    // Ensure exactly three colors
    while (results.length < sections) {
      results.add(results.isNotEmpty ? results.last : (results.isNotEmpty ? results.last : Colors.black));
    }
    if (results.length > sections) {
      results.removeRange(sections, results.length);
    }

    // Darken only overly bright colors for readability
    final List<Color> adjusted = results.asMap().entries.map((entry) {
      // Slight variation by section can add depth if used in gradients
      final int index = entry.key;
      final Color c = entry.value;
      final double target = 100.0 + (index * 5); // 100, 105, 110
      return _darkenForGradient(c, targetBrightness: target);
    }).toList();

    return adjusted;
  } catch (e) {
    return fallback;
  }
}
