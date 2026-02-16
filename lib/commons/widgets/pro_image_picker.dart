import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merrymakin/commons/widgets/pro_filter_chip.dart';
import './pro_snackbar.dart';
import 'dart:io';
import '../service/image_service.dart';
import '../utils/constants.dart';
import './buttons/pro_outlined_button.dart';
import './pro_text.dart';
import './pro_image_picker_categorized_view.dart';

class ProImagePicker extends StatefulWidget {
  final Function(String) onImageSelected;
  final int crossAxisCount;
  final double spacing;
  final ImageService imageService;
  final bool canUpload;
  final bool showAll;
  final bool useCategorizedFirstTab;

  const ProImagePicker({
    super.key,
    required this.onImageSelected,
    required this.imageService,
    this.crossAxisCount = 3,
    this.spacing = generalAppLevelPadding / 2,
    this.canUpload = true,
    this.showAll = true,
    this.useCategorizedFirstTab = false,
  });

  @override
  State<ProImagePicker> createState() => _ProImagePickerState();
}

class _ProImagePickerState extends State<ProImagePicker> {
  String? _selectedCategory;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.showAll ? null : widget.imageService.getCategories().first;
  }

  Future<void> _uploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isUploading = true);

      try {
        final imageUrl =
            await widget.imageService.uploadImage(File(image.path));
        if (imageUrl != null) {
          widget.onImageSelected(imageUrl);
        } else {
          showSnackBar(context, "Failed to upload image");
        }
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

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
          padding: const EdgeInsets.symmetric(
              horizontal: generalAppLevelPadding / 2),
          child: Row(
            children: [
              if (widget.showAll)
                Padding(
                  padding:
                      const EdgeInsets.only(right: generalAppLevelPadding / 2),
                  child: ProFilterChip(
                    label: widget.useCategorizedFirstTab ? 'Suggested' : 'Trending',
                    isSelected: _selectedCategory == null,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                  ),
                ),
              ...widget.imageService.getCategories().map((category) {
                return Padding(
                  padding:
                      const EdgeInsets.only(right: generalAppLevelPadding / 2),
                  child: ProFilterChip(
                    label: category,
                    isSelected: _selectedCategory == category,
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
        const SizedBox(height: generalAppLevelPadding),

        // Body: categorized cards (Suggested) or tab grid
        Expanded(
          child: widget.useCategorizedFirstTab && _selectedCategory == null
              ? CategorizedImagesView(
                  imageService: widget.imageService,
                  categoriesToShow: widget.imageService.getCategories(),
                  onCategoryTap: (category) {
                    setState(() => _selectedCategory = category);
                  },
                )
              : GridView.builder(
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
                        borderRadius: BorderRadius.circular(
                            generalAppLevelPadding / 2),
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

        // Upload button
        if (widget.canUpload) ...[
          Padding(
            padding: const EdgeInsets.all(generalAppLevelPadding),
            child: ProOutlinedButton(
              onPressed: _isUploading ? null : _uploadImage,
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload),
                        SizedBox(width: 8),
                        ProText('Choose From Library'),
                      ],
                    ),
            ),
          ),
        ],
      ],
    );
  }
}
