class Flight {
  final int id;
  final String flightNumber;
  final String airline;
  final String aircraft;
  final FlightRoute route;
  final FlightSchedule schedule;
  final Map<String, FlightPricing> pricing;

  Flight({
    required this.id,
    required this.flightNumber,
    required this.airline,
    required this.aircraft,
    required this.route,
    required this.schedule,
    required this.pricing,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    Map<String, FlightPricing> pricingMap = {};

    if (json['pricing'] != null) {
      Map<String, dynamic> pricingData = json['pricing'];
      pricingData.forEach((key, value) {
        pricingMap[key] = FlightPricing.fromJson(value);
      });
    }

    return Flight(
      id: json['id'] ?? 0,
      flightNumber: json['flight_number'] ?? '',
      airline: json['airline'] ?? '',
      aircraft: json['aircraft'] ?? '',
      route: FlightRoute.fromJson(json['route'] ?? {}),
      schedule: FlightSchedule.fromJson(json['schedule'] ?? {}),
      pricing: pricingMap,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> pricingJson = {};
    pricing.forEach((key, value) {
      pricingJson[key] = value.toJson();
    });

    return {
      'id': id,
      'flight_number': flightNumber,
      'airline': airline,
      'aircraft': aircraft,
      'route': route.toJson(),
      'schedule': schedule.toJson(),
      'pricing': pricingJson,
    };
  }

  // Helper methods
  List<String> get availableClasses => pricing.keys.toList();

  double get lowestPrice {
    if (pricing.isEmpty) return 0.0;
    return pricing.values.map((p) => p.priceMyr).reduce((a, b) => a < b ? a : b);
  }

  double get highestPrice {
    if (pricing.isEmpty) return 0.0;
    return pricing.values.map((p) => p.priceMyr).reduce((a, b) => a > b ? a : b);
  }

  FlightPricing? getPricingForClass(String flightClass) {
    return pricing[flightClass];
  }

  bool isAvailableOnDay(String day) {
    return schedule.days.contains(day);
  }

  @override
  String toString() {
    return 'Flight{id: $id, flightNumber: $flightNumber, airline: $airline, route: ${route.from}-${route.to}}';
  }
}

class FlightRoute {
  final String from;
  final String to;

  FlightRoute({
    required this.from,
    required this.to,
  });

  factory FlightRoute.fromJson(Map<String, dynamic> json) {
    return FlightRoute(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
    };
  }

  String get routeString => '$from-$to';

  @override
  String toString() {
    return routeString;
  }
}

class FlightSchedule {
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final List<String> days;

  FlightSchedule({
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.days,
  });

  factory FlightSchedule.fromJson(Map<String, dynamic> json) {
    return FlightSchedule(
      departureTime: json['departure_time'] ?? '',
      arrivalTime: json['arrival_time'] ?? '',
      duration: json['duration'] ?? '',
      days: List<String>.from(json['days'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departure_time': departureTime,
      'arrival_time': arrivalTime,
      'duration': duration,
      'days': days,
    };
  }

  bool get isDaily => days.length == 7;

  bool get isWeekdaysOnly => days.length == 5 &&
      !days.contains('Saturday') && !days.contains('Sunday');

  bool get isWeekendsOnly => days.length == 2 &&
      days.contains('Saturday') && days.contains('Sunday');

  @override
  String toString() {
    return 'Schedule{departure: $departureTime, arrival: $arrivalTime, duration: $duration}';
  }
}

class FlightPricing {
  final double priceMyr;
  final String currency;

  FlightPricing({
    required this.priceMyr,
    required this.currency,
  });

  factory FlightPricing.fromJson(Map<String, dynamic> json) {
    return FlightPricing(
      priceMyr: (json['price_myr'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'MYR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price_myr': priceMyr,
      'currency': currency,
    };
  }

  String get formattedPrice => '$currency ${priceMyr.toStringAsFixed(2)}';

  @override
  String toString() {
    return formattedPrice;
  }
}

// Additional helper classes for extended functionality

class Airport {
  final String code;
  final String name;
  final String city;

  Airport({
    required this.code,
    required this.name,
    required this.city,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'city': city,
    };
  }

  @override
  String toString() {
    return '$code - $name, $city';
  }
}

class Airline {
  final String name;
  final String code;
  final List<String> aircraftTypes;
  final List<String> classes;
  final Map<String, AirlineAmenities> amenities;

  Airline({
    required this.name,
    required this.code,
    required this.aircraftTypes,
    required this.classes,
    required this.amenities,
  });

  factory Airline.fromJson(String name, Map<String, dynamic> json) {
    Map<String, AirlineAmenities> amenitiesMap = {};

    if (json['amenities'] != null) {
      Map<String, dynamic> amenitiesData = json['amenities'];
      amenitiesData.forEach((key, value) {
        amenitiesMap[key] = AirlineAmenities.fromJson(value);
      });
    }

    return Airline(
      name: name,
      code: json['code'] ?? '',
      aircraftTypes: List<String>.from(json['aircraft_types'] ?? []),
      classes: List<String>.from(json['classes'] ?? []),
      amenities: amenitiesMap,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> amenitiesJson = {};
    amenities.forEach((key, value) {
      amenitiesJson[key] = value.toJson();
    });

    return {
      'code': code,
      'aircraft_types': aircraftTypes,
      'classes': classes,
      'amenities': amenitiesJson,
    };
  }

  AirlineAmenities? getAmenitiesForClass(String flightClass) {
    return amenities[flightClass];
  }

  @override
  String toString() {
    return '$name ($code)';
  }
}

class AirlineAmenities {
  final bool freeMeal;
  final bool freeWifi;
  final CarryOnInfo carryOn;
  final bool checkedBaggageIncluded;

  AirlineAmenities({
    required this.freeMeal,
    required this.freeWifi,
    required this.carryOn,
    required this.checkedBaggageIncluded,
  });

  factory AirlineAmenities.fromJson(Map<String, dynamic> json) {
    return AirlineAmenities(
      freeMeal: json['free_meal'] ?? false,
      freeWifi: json['free_wifi'] ?? false,
      carryOn: CarryOnInfo.fromJson(json['carry_on'] ?? {}),
      checkedBaggageIncluded: json['checked_baggage_included'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'free_meal': freeMeal,
      'free_wifi': freeWifi,
      'carry_on': carryOn.toJson(),
      'checked_baggage_included': checkedBaggageIncluded,
    };
  }

  List<String> get includedAmenities {
    List<String> amenities = [];
    if (freeMeal) amenities.add('Free Meal');
    if (freeWifi) amenities.add('Free WiFi');
    if (checkedBaggageIncluded) amenities.add('Checked Baggage');
    amenities.add('Carry-on: ${carryOn.pieces} piece(s), ${carryOn.weightKg}kg');
    return amenities;
  }
}

class CarryOnInfo {
  final int pieces;
  final int weightKg;

  CarryOnInfo({
    required this.pieces,
    required this.weightKg,
  });

  factory CarryOnInfo.fromJson(Map<String, dynamic> json) {
    return CarryOnInfo(
      pieces: json['pieces'] ?? 0,
      weightKg: json['weight_kg'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pieces': pieces,
      'weight_kg': weightKg,
    };
  }

  @override
  String toString() {
    return '$pieces piece(s), ${weightKg}kg';
  }
}