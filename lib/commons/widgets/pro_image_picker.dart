import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import '../service/image_service.dart';
import '../utils/constants.dart';

class ProImagePicker extends StatefulWidget {
  final Function(String) onImageSelected;
  final int crossAxisCount;
  final double spacing;
  final ImageService imageService;

  const ProImagePicker({
    super.key,
    required this.onImageSelected,
    this.crossAxisCount = 3,
    this.spacing = generalAppLevelPadding / 2, required this.imageService,
  });

  @override
  State<ProImagePicker> createState() => _ProImagePickerState();
}

class _ProImagePickerState extends State<ProImagePicker> {
  String? _selectedCategory;

  List<String> _getFilteredImages() {
    return widget.imageService.getFilteredImages(_selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.imageService.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.imageService.error != null) {
      return Center(child: ProText('Error: ${widget.imageService.error}'));
    }

    return Column(
      children: [
        // Category filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: generalAppLevelPadding / 2),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: generalAppLevelPadding / 2),
                child: FilterChip(
                  label: const ProText('All'),
                  selected: _selectedCategory == null,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                ),
              ),
              ...widget.imageService.getCategories().map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: generalAppLevelPadding / 2),
                  child: FilterChip(
                    label: ProText(category),
                    selected: _selectedCategory == category,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        ),

        // Image grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(generalAppLevelPadding / 2),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.crossAxisCount,
              crossAxisSpacing: widget.spacing,
              mainAxisSpacing: widget.spacing,
            ),
            itemCount: _getFilteredImages().length,
            itemBuilder: (context, index) {
              final imageUrl = _getFilteredImages()[index];
              return GestureDetector(
                onTap: () => widget.onImageSelected(imageUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(generalAppLevelPadding / 2),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 