class Tote {
  final int id;
  final String name;
  final String items;
  final String? qrCode;

  Tote({
    required this.id,
    required this.name,
    required this.items,
    this.qrCode,
  });

  factory Tote.fromJson(Map<String, dynamic> json) {
    return Tote(
      id: json['id'],
      name: json['name'],
      items: json['items'],
      qrCode: json['qr_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items,
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
