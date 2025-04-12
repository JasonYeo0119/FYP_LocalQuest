// attraction_model.dart
class Attraction {
  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String description;
  final double adultPrice;
  final double kidPrice;
  final double foreignAdultPrice;
  final double foreignKidPrice;
  final List<String> types;
  final String imageUrl;

  Attraction({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.description,
    required this.adultPrice,
    required this.kidPrice,
    required this.foreignAdultPrice,
    required this.foreignKidPrice,
    required this.types,
    required this.imageUrl,
  });

  factory Attraction.fromMap(Map<String, dynamic> data, String id) {
    return Attraction(
      id: id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      description: data['description'] ?? '',
      adultPrice: (data['adultprice'] ?? 0).toDouble(),
      kidPrice: (data['kidprice'] ?? 0).toDouble(),
      foreignAdultPrice: (data['foreignadultprice'] ?? 0).toDouble(),
      foreignKidPrice: (data['foreignkidprice'] ?? 0).toDouble(),
      types: _parseTypes(data['type']),
      imageUrl: data['image'] ?? '',
    );
  }

  static List<String> _parseTypes(dynamic typeData) {
    if (typeData is Map) {
      return typeData.values.whereType<String>().toList();
    }
    return [];
  }
}