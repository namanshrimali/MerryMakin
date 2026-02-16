import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../service/image_service.dart';
import '../utils/constants.dart';
import 'pro_text.dart';

/// Scrollable list of category cards: first category = hero card, rest = 2-per-row grid.
/// Tapping a card calls [onCategoryTap]; no inline expansion. The parent shows that category's grid.
class CategorizedImagesView extends StatelessWidget {
  final ImageService imageService;
  final List<String> categoriesToShow;
  final void Function(String category) onCategoryTap;

  const CategorizedImagesView({
    super.key,
    required this.imageService,
    required this.categoriesToShow,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categoriesToShow.isEmpty) {
      return const Center(child: ProText('No categories'));
    }
    final heroCategory = categoriesToShow.first;
    final restCategories = categoriesToShow.length > 1
        ? categoriesToShow.sublist(1)
        : <String>[];

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: generalAppLevelPadding / 2,
        vertical: generalAppLevelPadding / 2,
      ),
      children: [
        _HeroCategoryCard(
          categoryName: heroCategory,
          imageUrls: imageService.getFilteredImages(heroCategory),
          onTap: () => onCategoryTap(heroCategory),
        ),
        if (restCategories.isNotEmpty) ...[
          const SizedBox(height: generalAppLevelPadding / 2),
          for (var i = 0; i < restCategories.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: generalAppLevelPadding / 2),
              child: Row(
                children: [
                  Expanded(
                    child: _GridCategoryCard(
                      categoryName: restCategories[i],
                      imageUrls: imageService.getFilteredImages(restCategories[i]),
                      onTap: () => onCategoryTap(restCategories[i]),
                    ),
                  ),
                  if (i + 1 < restCategories.length) ...[
                    const SizedBox(width: generalAppLevelPadding / 2),
                    Expanded(
                      child: _GridCategoryCard(
                        categoryName: restCategories[i + 1],
                        imageUrls: imageService.getFilteredImages(restCategories[i + 1]),
                        onTap: () => onCategoryTap(restCategories[i + 1]),
                      ),
                    ),
                  ] else
                    const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

/// Full-width hero card: category name, count, rich preview. Tap calls [onTap].
class _HeroCategoryCard extends StatelessWidget {
  final String categoryName;
  final List<String> imageUrls;
  final VoidCallback onTap;

  const _HeroCategoryCard({
    required this.categoryName,
    required this.imageUrls,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final previewUrl = imageUrls.isNotEmpty ? imageUrls.first : null;
    return Semantics(
      label: '$categoryName, ${imageUrls.length} images',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(generalAppLevelPadding * 2),
            color: Colors.grey[300],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(generalAppLevelPadding * 2),
            child: Stack(
              alignment: Alignment.bottomLeft,
              fit: StackFit.expand,
              children: [
                if (previewUrl != null)
                  CachedNetworkImage(
                    imageUrl: previewUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
                  ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: generalAppLevelPadding / 2,
                    vertical: generalAppLevelPadding / 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ProText(
                          categoryName,
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      ProText(
                        '${imageUrls.length} images',
                        textStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Square grid card: preview + semi-transparent label at bottom. Tap calls [onTap].
class _GridCategoryCard extends StatelessWidget {
  final String categoryName;
  final List<String> imageUrls;
  final VoidCallback onTap;

  const _GridCategoryCard({
    required this.categoryName,
    required this.imageUrls,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final previewUrl = imageUrls.isNotEmpty ? imageUrls.first : null;
    return Semantics(
      label: '$categoryName, ${imageUrls.length} images',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(generalAppLevelPadding * 2),
              color: Colors.grey[300],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(generalAppLevelPadding * 2),
              child: Stack(
                alignment: Alignment.bottomCenter,
                fit: StackFit.expand,
                children: [
                  if (previewUrl != null)
                    CachedNetworkImage(
                      imageUrl: previewUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                            child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: generalAppLevelPadding / 2,
                      vertical: generalAppLevelPadding,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    child: ProText(
                      categoryName,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
