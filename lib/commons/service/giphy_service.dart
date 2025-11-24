import 'dart:convert';
import 'package:http/http.dart' as http;

class GiphyGif {
  final String id;
  final String url;
  final String title;
  final String previewUrl;
  final String fullSizeUrl;

  GiphyGif({
    required this.id,
    required this.url,
    required this.title,
    required this.previewUrl,
    required this.fullSizeUrl,
  });

  factory GiphyGif.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as Map<String, dynamic>;
    final preview = images['preview_gif'] ?? images['fixed_height_small'] ?? images['downsized'];
    final original = images['original'] ?? images['fixed_height'] ?? images['downsized'];
    
    return GiphyGif(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String? ?? '',
      previewUrl: preview['url'] as String,
      fullSizeUrl: original['url'] as String,
    );
  }
}

class GiphyService {
  // GIPHY API Configuration
  // To get your free API key:
  // 1. Go to https://developers.giphy.com/
  // 2. Sign up for a free account
  // 3. Create a new app
  // 4. Copy your API key and replace the value below
  // 
  // Note: The free tier allows 42 requests per hour, which is sufficient for most use cases.
  static const String _apiKey = 'YOUR_GIPHY_API_KEY_HERE';
  static const String _baseUrl = 'https://api.giphy.com/v1/gifs';

  Future<List<GiphyGif>> searchGifs(String query, {int limit = 25, int offset = 0}) async {
    if (_apiKey == 'YOUR_GIPHY_API_KEY_HERE') {
      throw Exception('Please set your GIPHY API key in lib/commons/service/giphy_service.dart');
    }

    try {
      final uri = Uri.parse('$_baseUrl/search')
          .replace(queryParameters: {
        'api_key': _apiKey,
        'q': query,
        'limit': limit.toString(),
        'offset': offset.toString(),
        'rating': 'g', // General audience rating
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final gifs = data['data'] as List;
        return gifs.map((gif) => GiphyGif.fromJson(gif as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load GIFs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching GIFs: $e');
    }
  }

  Future<List<GiphyGif>> getTrendingGifs({int limit = 25, int offset = 0}) async {
    if (_apiKey == 'YOUR_GIPHY_API_KEY_HERE') {
      throw Exception('Please set your GIPHY API key in lib/commons/service/giphy_service.dart');
    }

    try {
      final uri = Uri.parse('$_baseUrl/trending')
          .replace(queryParameters: {
        'api_key': _apiKey,
        'limit': limit.toString(),
        'offset': offset.toString(),
        'rating': 'g',
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final gifs = data['data'] as List;
        return gifs.map((gif) => GiphyGif.fromJson(gif as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load trending GIFs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching trending GIFs: $e');
    }
  }
}

