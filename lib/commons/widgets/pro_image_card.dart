import 'package:flutter/material.dart';
import '../utils/constants.dart';
import './pro_text.dart';

class ProImageCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final Widget? subtitle;
  final Widget? thirdRow;
  final double width;
  final double? imageHeight;
  final VoidCallback? onTap;

  const ProImageCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.width = 280,
    this.imageHeight,
    this.onTap,
    this.thirdRow,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.only(right: generalAppLevelPadding),
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: width,
            minWidth: width,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    child: Image.network(
                      imageUrl,
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: imageHeight,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Padding(
                      padding: const EdgeInsets.all(generalAppLevelPadding),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: ProText(
                              title,
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: generalAppLevelPadding / 2),
                            Flexible(
                              child: subtitle!,
                            ),
                          ],
                          if (thirdRow != null) ...[
                            const SizedBox(height: generalAppLevelPadding / 2),
                            Flexible(
                              child: thirdRow!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }
} 