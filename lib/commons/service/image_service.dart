import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class ImageService {
  ImageService(final String jsonUrl) {
    initialize(jsonUrl);
  }

  Map<String, List<String>> _imageData = {};
  bool _isInitialized = false;
  String? _error;

  bool get isInitialized => _isInitialized;
  String? get error => _error;
  Map<String, List<String>> get imageData => _imageData;

  Future<void> initialize(String jsonUrl) async {

    try {
      final response = await http.get(Uri.parse(jsonUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['images'] is Map) {
          _imageData = Map<String, List<String>>.from(
            data['images'].map(
              (key, value) => MapEntry(
                key,
                List<String>.from(value),
              ),
            ),
          );
          _isInitialized = true;
        } else {
          throw Exception('Invalid JSON format');
        }
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  List<String> getFilteredImages(String? category) {
    if (category == null) {
      return _imageData.values.expand((images) => images).toList();
    }
    return _imageData[category] ?? [];
  }

  List<String> getCategories() {
    return _imageData.keys.toList();
  }

  String getRandomImage() {
    final randomCategory =
        _imageData.keys.elementAt(Random().nextInt(_imageData.keys.length));
    final randomImage = _imageData[randomCategory]!
        .elementAt(Random().nextInt(_imageData[randomCategory]!.length));
    return randomImage;
  }
}
