class Hotel {
  final int id;
  final String name;
  final String address;
  final double rating;
  final double price;
  final String currency;
  final String imageUrl;
  final List<String> amenities;
  final String city;
  final String country;

  Hotel({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.price,
    required this.currency,
    required this.imageUrl,
    required this.amenities,
    required this.city,
    required this.country,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      rating: json['rating'].toDouble(),
      price: json['price'].toDouble(),
      currency: json['currency'],
      imageUrl: json['imageUrl'],
      amenities: List<String>.from(json['amenities']),
      city: json['city'],
      country: json['country'],
    );
  }
}
