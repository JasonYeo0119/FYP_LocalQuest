class Transport {
  final String id;
  final String name;
  final String type; // Bus, Train, Flight, Car
  final String origin;
  final String destination;
  final double price;
  final String? imageUrl;
  final bool isHidden;
  final List<String> operatingDays;
  final List<String> timeSlots;
  final List<int> availableSeats;
  final int totalSeats;
  final String? description;
  final Map<String, dynamic>? additionalInfo;

  Transport({
    required this.id,
    required this.name,
    required this.type,
    required this.origin,
    required this.destination,
    required this.price,
    this.imageUrl,
    this.isHidden = false,
    this.operatingDays = const [],
    this.timeSlots = const [],
    this.availableSeats = const [],
    this.totalSeats = 33,
    this.description,
    this.additionalInfo,
  });

  // Factory constructor to create Transport from Firebase data
  factory Transport.fromMap(String id, Map<String, dynamic> data) {
    return Transport(
      id: id,
      name: data['name'] ?? 'Unnamed Transport',
      type: data['type'] ?? 'Unknown',
      origin: data['origin'] ?? '',
      destination: data['destination'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'],
      isHidden: data['hide'] ?? false,
      operatingDays: data['operatingDays'] != null
          ? List<String>.from(data['operatingDays'])
          : [],
      timeSlots: data['timeSlots'] != null
          ? List<String>.from(data['timeSlots'])
          : [],
      availableSeats: data['availableSeats'] != null
          ? List<int>.from(data['availableSeats'])
          : [],
      totalSeats: data['totalSeats'] ?? 33,
      description: data['description'],
      additionalInfo: data['additionalInfo'],
    );
  }

  // Convert Transport to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'origin': origin,
      'destination': destination,
      'price': price,
      'imageUrl': imageUrl,
      'hide': isHidden,
      'operatingDays': operatingDays,
      'timeSlots': timeSlots,
      'availableSeats': availableSeats,
      'totalSeats': totalSeats,
      'description': description,
      'additionalInfo': additionalInfo,
    };
  }

  // Helper methods
  bool get hasAvailableSeats => availableSeats.isNotEmpty;

  bool get hasTimeSlots => timeSlots.isNotEmpty;

  bool get isAvailableToday {
    final today = DateTime.now();
    final dayName = _getDayName(today.weekday);
    return operatingDays.contains(dayName);
  }

  String get route => '$origin → $destination';

  String get formattedPrice => 'MYR ${price.toStringAsFixed(2)}';

  // Check if transport matches search criteria
  bool matchesSearch({
    String? searchOrigin,
    String? searchDestination,
    String? searchType,
  }) {
    bool matchesOrigin = searchOrigin == null ||
        origin.toLowerCase().contains(searchOrigin.toLowerCase());

    bool matchesDestination = searchDestination == null ||
        destination.toLowerCase().contains(searchDestination.toLowerCase());

    bool matchesType = searchType == null ||
        type.toLowerCase() == searchType.toLowerCase();

    return matchesOrigin && matchesDestination && matchesType && !isHidden;
  }

  // Helper method to get day name
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }

  // Copy method for updating transport
  Transport copyWith({
    String? id,
    String? name,
    String? type,
    String? origin,
    String? destination,
    double? price,
    String? imageUrl,
    bool? isHidden,
    List<String>? operatingDays,
    List<String>? timeSlots,
    List<int>? availableSeats,
    int? totalSeats,
    String? description,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Transport(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isHidden: isHidden ?? this.isHidden,
      operatingDays: operatingDays ?? this.operatingDays,
      timeSlots: timeSlots ?? this.timeSlots,
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      description: description ?? this.description,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  @override
  String toString() {
    return 'Transport(id: $id, name: $name, type: $type, route: $route, price: $formattedPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transport && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}