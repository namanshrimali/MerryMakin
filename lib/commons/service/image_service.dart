import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:merrymakin/commons/service/cookies_service.dart';

import '../resources.dart';

class ImageService {
  ImageService(final String jsonUrl) {
    initialize(jsonUrl);
  }
  Map<String, List<String>> _imageData = {};
  bool _isInitialized = false;
  String? _error;

  bool get isInitialized => _isInitialized;
  String? get error => _error;

  Future<void> initialize(final String jsonUrl) async {
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

  Future<String?> uploadImage(File imageFile) async {
    try {
      final uri = Uri(
        scheme: 'http',
        host: DEV_HOST,
        port: DEV_PORT,
        path: 'image-service/api/v1/image',
      );
      var request = http.MultipartRequest('POST', uri);


      // add jwt token in header
      final jwtToken = CookiesService.locallyAvailableJwtToken;
      request.headers['access-token'] = '$jwtToken';
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      )); 

      var response = await request.send();

      var responseData = await response.stream.bytesToString();
  
      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      _error = e.toString();
      return null;
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
    if (_imageData.isEmpty) {
      return '';
    }
    final randomCategory =
        _imageData.keys.elementAt(Random().nextInt(_imageData.keys.length));
    final randomImage = _imageData[randomCategory]!
        .elementAt(Random().nextInt(_imageData[randomCategory]!.length));
    return randomImage;
  }
}
