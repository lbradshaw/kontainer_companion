import 'dart:convert';
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
    final response = await http.get(Uri.parse('$baseUrl/api/totes/$id'));
    
    if (response.statusCode == 200) {
      return Tote.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load tote');
    }
  }

  Future<Tote> createTote(String name, String items) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/totes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'items': items,
      }),
    );
    
    if (response.statusCode == 200) {
      return Tote.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create tote');
    }
  }

  Future<void> updateTote(int id, String name, String items) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/totes/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'items': items,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to update tote');
    }
  }

  Future<void> deleteTote(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/totes/$id'));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete tote');
    }
  }

  void setBaseUrl(String url) {
    baseUrl = url;
  }
}
