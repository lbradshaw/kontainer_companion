import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/tote.dart';

class ApiService {
  String baseUrl = 'http://localhost:3818';

  Future<List<Tote>> getTotes() async {
    final response = await http.get(Uri.parse('$baseUrl/api/totes'));
    
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Tote.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load totes');
    }
  }

  Future<Tote> getTote(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/tote/$id'));
    
    if (response.statusCode == 200) {
      return Tote.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load tote');
    }
  }

  Future<Tote> createTote(Tote tote) async {
    final Map<String, dynamic> body = {
      'name': tote.name,
      'items': tote.items,
    };
    
    if (tote.images.isNotEmpty) {
      body['images'] = tote.images.map((img) => base64Encode(img)).toList();
    }
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/totes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out - images may be too large');
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Tote.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create tote: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> updateTote(Tote tote) async {
    final Map<String, dynamic> body = {
      'name': tote.name,
      'items': tote.items,
    };
    
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/tote/${tote.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(
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
  
  Future<void> addImagesToTote(int toteId, List<Uint8List> images) async {
    try {
      for (final imageData in images) {
        final response = await http.post(
          Uri.parse('$baseUrl/api/tote/$toteId/add-image'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'image_data': base64Encode(imageData),
          }),
        ).timeout(
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
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/tote-image/$imageId'),
      ).timeout(
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
    final response = await http.delete(Uri.parse('$baseUrl/api/tote/$id'));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete tote');
    }
  }

  void setBaseUrl(String url) {
    baseUrl = url;
  }
}
