class Transport {
  final String id;
  final String name;
  final String type; // Bus, Train, Flight, Car, Ferry
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
    String transportType = data['type'] ?? 'Unknown';

    // Handle different data structures based on transport type
    String origin = '';
    String destination = '';
    double price = 0.0;

    if (transportType == 'Car') {
      // For cars, use location field or default to empty
      origin = data['location'] ?? data['origin'] ?? '';
      destination = data['location'] ?? data['destination'] ?? '';
      price = (data['price'] ?? 0.0).toDouble();
    } else if (transportType == 'Ferry') {
      // For ferries, handle dual pricing
      origin = data['origin'] ?? '';
      destination = data['destination'] ?? '';
      // Use pedestrian price as default, can be overridden in additionalInfo
      price = (data['pedestrianPrice'] ?? data['price'] ?? 0.0).toDouble();
    } else {
      // For other transport types (Bus, Train, Flight)
      origin = data['origin'] ?? '';
      destination = data['destination'] ?? '';
      price = (data['price'] ?? 0.0).toDouble();
    }

    return Transport(
      id: id,
      name: data['name'] ?? 'Unnamed Transport',
      type: transportType,
      origin: origin,
      destination: destination,
      price: price,
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
      additionalInfo: _buildAdditionalInfo(data, transportType),
    );
  }

  // Helper method to build additionalInfo based on transport type
  static Map<String, dynamic>? _buildAdditionalInfo(Map<String, dynamic> data, String type) {
    Map<String, dynamic> additionalInfo = {};

    if (type == 'Car') {
      // Car-specific fields
      if (data['plateNumber'] != null) additionalInfo['plateNumber'] = data['plateNumber'];
      if (data['location'] != null) additionalInfo['location'] = data['location'];
      if (data['color'] != null) additionalInfo['color'] = data['color'];
      if (data['driverIncluded'] != null) additionalInfo['driverIncluded'] = data['driverIncluded'];
      if (data['maxPassengers'] != null) additionalInfo['maxPassengers'] = data['maxPassengers'];
      if (data['priceType'] != null) additionalInfo['priceType'] = data['priceType'];
    } else if (type == 'Ferry') {
      // Ferry-specific fields
      if (data['pedestrianPrice'] != null) additionalInfo['pedestrianPrice'] = data['pedestrianPrice'];
      if (data['vehiclePrice'] != null) additionalInfo['vehiclePrice'] = data['vehiclePrice'];
      if (data['priceType'] != null) additionalInfo['priceType'] = data['priceType'];
    }

    // Add any other fields that might be useful
    if (data['createdAt'] != null) additionalInfo['createdAt'] = data['createdAt'];

    // Include original additionalInfo if it exists
    if (data['additionalInfo'] != null) {
      additionalInfo.addAll(Map<String, dynamic>.from(data['additionalInfo']));
    }

    return additionalInfo.isEmpty ? null : additionalInfo;
  }

  // Convert Transport to Map for Firebase
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'name': name,
      'type': type,
      'price': price,
      'imageUrl': imageUrl,
      'hide': isHidden,
      'operatingDays': operatingDays,
      'timeSlots': timeSlots,
      'availableSeats': availableSeats,
      'totalSeats': totalSeats,
      'description': description,
    };

    // Add type-specific fields
    if (type == 'Car') {
      // For cars, add location instead of origin/destination
      if (additionalInfo != null && additionalInfo!['location'] != null) {
        map['location'] = additionalInfo!['location'];
      } else {
        map['origin'] = origin;
        map['destination'] = destination;
      }

      // Add car-specific fields from additionalInfo
      if (additionalInfo != null) {
        if (additionalInfo!['plateNumber'] != null) map['plateNumber'] = additionalInfo!['plateNumber'];
        if (additionalInfo!['color'] != null) map['color'] = additionalInfo!['color'];
        if (additionalInfo!['driverIncluded'] != null) map['driverIncluded'] = additionalInfo!['driverIncluded'];
        if (additionalInfo!['maxPassengers'] != null) map['maxPassengers'] = additionalInfo!['maxPassengers'];
        if (additionalInfo!['priceType'] != null) map['priceType'] = additionalInfo!['priceType'];
      }
    } else if (type == 'Ferry') {
      map['origin'] = origin;
      map['destination'] = destination;

      // Add ferry-specific pricing
      if (additionalInfo != null) {
        if (additionalInfo!['pedestrianPrice'] != null) map['pedestrianPrice'] = additionalInfo!['pedestrianPrice'];
        if (additionalInfo!['vehiclePrice'] != null) map['vehiclePrice'] = additionalInfo!['vehiclePrice'];
        if (additionalInfo!['priceType'] != null) map['priceType'] = additionalInfo!['priceType'];
      }
    } else {
      // For other transport types
      map['origin'] = origin;
      map['destination'] = destination;
    }

    if (additionalInfo != null) {
      map['additionalInfo'] = additionalInfo;
    }

    return map;
  }

  // Helper methods
  bool get hasAvailableSeats => availableSeats.isNotEmpty;

  bool get hasTimeSlots => timeSlots.isNotEmpty;

  bool get isAvailableToday {
    final today = DateTime.now();
    final dayName = _getDayName(today.weekday);
    return operatingDays.contains(dayName);
  }

  String get route {
    if (type == 'Car') {
      // For cars, show location instead of route
      return additionalInfo?['location'] ?? origin;
    }
    return '$origin → $destination';
  }

  String get formattedPrice {
    if (type == 'Car') {
      String priceType = additionalInfo?['priceType'] ?? 'per_day';
      return 'MYR ${price.toStringAsFixed(2)} ${priceType == 'per_day' ? 'per day' : ''}';
    } else if (type == 'Ferry') {
      return 'MYR ${price.toStringAsFixed(2)} (Pedestrian)';
    }
    return 'MYR ${price.toStringAsFixed(2)}';
  }

  // Check if transport matches search criteria
  bool matchesSearch({
    String? searchOrigin,
    String? searchDestination,
    String? searchType,
  }) {
    bool matchesOrigin = false;
    bool matchesDestination = false;

    if (type == 'Car') {
      // For cars, check location field
      String carLocation = additionalInfo?['location'] ?? origin;
      matchesOrigin = searchOrigin == null ||
          carLocation.toLowerCase().contains(searchOrigin.toLowerCase()) ||
          searchOrigin.toLowerCase().contains(carLocation.toLowerCase());
      matchesDestination = searchDestination == null ||
          carLocation.toLowerCase().contains(searchDestination.toLowerCase()) ||
          searchDestination.toLowerCase().contains(carLocation.toLowerCase());
    } else {
      matchesOrigin = searchOrigin == null ||
          origin.toLowerCase().contains(searchOrigin.toLowerCase());
      matchesDestination = searchDestination == null ||
          destination.toLowerCase().contains(searchDestination.toLowerCase());
    }

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