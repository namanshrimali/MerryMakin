import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../service/giphy_service.dart';
import '../utils/constants.dart';
import 'pro_text.dart';
import 'pro_text_field.dart';

class ProGiphyGifPicker extends StatefulWidget {
  final Function(String gifUrl) onGifSelected;

  const ProGiphyGifPicker({super.key, required this.onGifSelected});

  @override
  State<ProGiphyGifPicker> createState() => _ProGiphyGifPickerState();
}

class _ProGiphyGifPickerState extends State<ProGiphyGifPicker> {
  final GiphyService _giphyService = GiphyService();
  final TextEditingController _searchController = TextEditingController();
  List<GiphyGif> _gifs = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String _errorMessage = '';
  int _currentOffset = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTrendingGifs();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreGifs();
    }
  }

  Future<void> _loadTrendingGifs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _isSearching = false;
      _currentOffset = 0;
    });

    try {
      final gifs = await _giphyService.getTrendingGifs(limit: 25, offset: 0);
      setState(() {
        _gifs = gifs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _searchGifs(String query) async {
    if (query.trim().isEmpty) {
      _loadTrendingGifs();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _isSearching = true;
      _currentOffset = 0;
    });

    try {
      final gifs = await _giphyService.searchGifs(query.trim(), limit: 25, offset: 0);
      setState(() {
        _gifs = gifs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreGifs() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newOffset = _currentOffset + 25;
      List<GiphyGif> newGifs;

      if (_isSearching && _searchController.text.trim().isNotEmpty) {
        newGifs = await _giphyService.searchGifs(
          _searchController.text.trim(),
          limit: 25,
          offset: newOffset,
        );
      } else {
        newGifs = await _giphyService.getTrendingGifs(limit: 25, offset: newOffset);
      }

      setState(() {
        _gifs.addAll(newGifs);
        _currentOffset = newOffset;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        Row(
          children: [
            Expanded(
              child: ProTextField(
                hintText: 'Search GIFs...',
                textEditingController: _searchController,
                prefixWidget: const Icon(Icons.search),
                onChanged: (value) {
                  // Debounce search
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_searchController.text == value) {
                      _searchGifs(value ?? '');
                    }
                  });
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _searchGifs(_searchController.text),
              tooltip: 'Search',
            ),
          ],
        ),
        const SizedBox(height: generalAppLevelPadding / 2),

        // Error message
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(generalAppLevelPadding),
            child: ProText(
              _errorMessage,
              textStyle: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),

        // GIF grid
        Expanded(
          child: _isLoading && _gifs.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _gifs.isEmpty
                  ? Center(
                      child: ProText(
                        _isSearching
                            ? 'No GIFs found. Try a different search.'
                            : 'No GIFs available.',
                      ),
                    )
                  : GridView.builder(
                      controller: _scrollController,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: generalAppLevelPadding / 2,
                        mainAxisSpacing: generalAppLevelPadding / 2,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _gifs.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _gifs.length) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final gif = _gifs[index];
                        return GestureDetector(
                          onTap: () {
                            widget.onGifSelected(gif.fullSizeUrl);
                            Navigator.pop(context);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              generalAppLevelPadding / 2,
                            ),
                            child: CachedNetworkImage(
                              imageUrl: gif.previewUrl,
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

