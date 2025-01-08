import 'package:flutter/material.dart';
import '../utils/constants.dart';
import './pro_text.dart';

class ProImageCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final Widget? thirdRow;
  final double width;
  final double imageHeight;
  final VoidCallback? onTap;

  const ProImageCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.width = 280,
    this.imageHeight = 162,
    this.onTap, this.thirdRow,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: generalAppLevelPadding),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Column(
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
              Padding(
                padding: const EdgeInsets.all(generalAppLevelPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProText(
                      title,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: generalAppLevelPadding),
                          const SizedBox(width: 4),
                          ProText(
                            subtitle!,
                            textStyle: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                    if (thirdRow != null) ...[
                      const SizedBox(height: 8),
                      thirdRow!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 