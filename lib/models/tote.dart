import 'dart:convert';
import 'dart:typed_data';

class Tote {
  final int id;
  final String name;
  final String items;
  final String? location;
  final String? qrCode;
  final List<Uint8List> images;
  final List<int> imageIds;

  Tote({
    required this.id,
    required this.name,
    required this.items,
    this.location,
    this.qrCode,
    this.images = const [],
    this.imageIds = const [],
  });

  factory Tote.fromJson(Map<String, dynamic> json) {
    List<Uint8List> imagesList = [];
    List<int> imageIdsList = [];
    if (json['images'] != null && json['images'] is List) {
      for (var img in json['images']) {
        // Handle both old format (string) and new format (object with image_data)
        String? base64Data;
        int? imageId;
        if (img is String) {
          base64Data = img;
        } else if (img is Map<String, dynamic> && img['image_data'] != null) {
          base64Data = img['image_data'] as String;
          imageId = img['id'] as int?;
        }
        
        if (base64Data != null && base64Data.isNotEmpty) {
          try {
            // Check if it's a data URI
            if (base64Data.startsWith('data:')) {
              final bytes = Uri.parse(base64Data).data?.contentAsBytes();
              if (bytes != null) {
                imagesList.add(bytes);
                if (imageId != null) imageIdsList.add(imageId);
              }
            } else {
              // Plain base64 string - decode it
              final bytes = base64Decode(base64Data);
              imagesList.add(bytes);
              if (imageId != null) imageIdsList.add(imageId);
            }
          } catch (e) {
            print('Error decoding image: $e');
          }
        }
      }
    }
    
    return Tote(
      id: json['id'],
      name: json['name'],
      items: json['items'] ?? '',
      location: json['location'],
      qrCode: json['qr_code'],
      images: imagesList,
      imageIds: imageIdsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items,
      'location': location ?? '',
      'qr_code': qrCode,
    };
  }

  String getPreviewItems() {
    List<String> lines = items.split('\n');
    if (lines.length <= 3) {
      return items;
    }
    return '${lines.take(3).join('\n')}...';
  }
}
