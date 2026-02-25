import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tote.dart';

class ApiService {
  ApiService();
  String baseUrl = 'http://localhost:3818';

  Future<String> _getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    // Multi-URL support: get list and selected index
    final urlsJson = prefs.getString('server_urls');
    final selectedIdx = prefs.getInt('selected_server_url_idx') ?? 0;
    if (urlsJson != null) {
      final List urls = json.decode(urlsJson);
      if (urls.isNotEmpty && selectedIdx >= 0 && selectedIdx < urls.length) {
        final entry = urls[selectedIdx];
        if (entry is Map && entry.containsKey('url')) {
          return entry['url']?.toString() ?? 'http://localhost:3818';
        } else if (entry is String) {
          return entry;
        }
      }
    }
    // Fallback to old single URL
    return prefs.getString('server_url') ?? 'http://localhost:3818';
  }

  // Get top-level containers only (for main list)
  Future<List<Tote>> getTotes() async {
    final url = await _getBaseUrl();
    final response = await http.get(Uri.parse('$url/api/totes'));

    if (response.statusCode == 200) {
      // Handle empty or null response
      if (response.body.isEmpty || response.body == 'null') {
        return [];
      }

      final decoded = json.decode(response.body);

      // If null or not a list, return empty list
      if (decoded == null || decoded is! List) {
        return [];
      }

      return decoded.map<Tote>((json) => Tote.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load totes');
    }
  }

  // Get ALL containers including sub-containers (for search)
  Future<List<Tote>> getTotesAll() async {
    final url = await _getBaseUrl();
    final response = await http.get(Uri.parse('$url/api/totes/all'));

    if (response.statusCode == 200) {
      // Handle empty or null response
      if (response.body.isEmpty || response.body == 'null') {
        return [];
      }

      final decoded = json.decode(response.body);

      // If null or not a list, return empty list
      if (decoded == null || decoded is! List) {
        return [];
      }

      return decoded.map<Tote>((json) => Tote.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load all totes');
    }
  }

  Future<Tote> getTote(int id) async {
    final url = await _getBaseUrl();
    final response = await http.get(Uri.parse('$url/api/tote/$id'));

    if (response.statusCode == 200) {
      return Tote.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load tote');
    }
  }

  Future<Tote> getToteByQRCode(String qrCode) async {
    final url = await _getBaseUrl();
    final response = await http.get(Uri.parse('$url/api/tote/qr/$qrCode'));

    if (response.statusCode == 200) {
      return Tote.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Tote not found');
    } else {
      throw Exception('Failed to load tote');
    }
  }

  Future<Tote> createTote(Tote tote,
      {List<String>? imageMimeTypes, int? parentId}) async {
    final url = await _getBaseUrl();
    final Map<String, dynamic> body = {
      'name': tote.name,
      'items': tote.items,
      'location': tote.location ?? '',
    };

    // Add parent_id if creating a sub-container
    if (parentId != null) {
      body['parent_id'] = parentId;
    }

    // Add images in data URI format if provided
    if (tote.images.isNotEmpty) {
      final List<String> imageDataUris = [];
      final List<String> mimeTypes = [];

      for (int i = 0; i < tote.images.length; i++) {
        final mimeType = (imageMimeTypes != null && i < imageMimeTypes.length)
            ? imageMimeTypes[i]
            : 'image/jpeg';

        final base64Data = base64Encode(tote.images[i]);
        final dataUri = 'data:$mimeType;base64,$base64Data';

        imageDataUris.add(dataUri);
        mimeTypes.add(mimeType);
      }

      body['image_paths'] = imageDataUris;
      body['image_types'] = mimeTypes;
    }

    try {
      final response = await http
          .post(
        Uri.parse(
            '$url/api/tote'), // Changed from /api/totes to /api/tote (singular)
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out - images may be too large');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Tote.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to create tote: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> updateTote(Tote tote) async {
    final url = await _getBaseUrl();
    final Map<String, dynamic> body = {
      'name': tote.name,
      'items': tote.items,
      'location': tote.location ?? '',
    };

    try {
      final response = await http
          .put(
        Uri.parse('$url/api/tote/${tote.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update tote: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> addImagesToTote(
      int toteId, List<Uint8List> images, List<String> mimeTypes) async {
    final url = await _getBaseUrl();
    try {
      for (int i = 0; i < images.length; i++) {
        final imageData = images[i];
        final mimeType = i < mimeTypes.length ? mimeTypes[i] : 'image/jpeg';

        // Convert to base64 and create data URI format that backend expects
        final base64Data = base64Encode(imageData);
        final dataUri = 'data:$mimeType;base64,$base64Data';

        final response = await http
            .post(
          Uri.parse('$url/api/tote/$toteId/add-image'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'image_data': dataUri,
          }),
        )
            .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Request timed out - image may be too large');
          },
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to add image: ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteImage(int imageId) async {
    final url = await _getBaseUrl();
    try {
      final response = await http
          .delete(
        Uri.parse('$url/api/tote-image/$imageId'),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete image: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteTote(int id) async {
    final url = await _getBaseUrl();
    final response = await http.delete(Uri.parse('$url/api/tote/$id'));

    // Backend returns 204 No Content on successful delete
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete tote');
    }
  }

  void setBaseUrl(String url) {
    baseUrl = url;
  }
}
