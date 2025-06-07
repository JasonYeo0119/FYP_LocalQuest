class Hotel {
  final int id;
  final String name;
  final String address;
  final String city;
  final String country;
  final double rating;
  final double price; // This will be the base price (lowest room type price)
  final String currency;
  final String type;
  final String imageUrl;
  final List<String> amenities;
  final List<Map<String, dynamic>>? roomTypes; // New field for room types

  Hotel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.country,
    required this.rating,
    required this.price,
    required this.currency,
    required this.type,
    required this.imageUrl,
    required this.amenities,
    this.roomTypes,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      rating: json['rating'].toDouble(),
      price: json['price'].toDouble(),
      currency: json['currency'],
      type: json['type'],
      imageUrl: json['imageUrl'],
      amenities: List<String>.from(json['amenities']),
      roomTypes: json['roomTypes'] != null
          ? List<Map<String, dynamic>>.from(json['roomTypes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'country': country,
      'rating': rating,
      'price': price,
      'currency': currency,
      'type': type,
      'imageUrl': imageUrl,
      'amenities': amenities,
      'roomTypes': roomTypes,
    };
  }

  // Helper method to get price range
  String getPriceRange() {
    if (roomTypes == null || roomTypes!.isEmpty) {
      return 'MYR ${price.toStringAsFixed(0)}';
    }

    double minPrice = roomTypes!.map((room) => room['price'] as double).reduce((a, b) => a < b ? a : b);
    double maxPrice = roomTypes!.map((room) => room['price'] as double).reduce((a, b) => a > b ? a : b);

    if (minPrice == maxPrice) {
      return 'MYR ${minPrice.toStringAsFixed(0)}';
    } else {
      return 'MYR ${minPrice.toStringAsFixed(0)} - ${maxPrice.toStringAsFixed(0)}';
    }
  }

  // Helper method to get total room count
  int getTotalRoomCount() {
    if (roomTypes == null || roomTypes!.isEmpty) {
      return 0;
    }

    return roomTypes!.fold(0, (total, room) => total + (room['quantity'] as int));
  }

  // Helper method to check if hotel has multiple room types
  bool hasMultipleRoomTypes() {
    return roomTypes != null && roomTypes!.length > 1;
  }
}