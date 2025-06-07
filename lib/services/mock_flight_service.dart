import '../Model/flight.dart';

class MockMalaysiaFlightService {
  static final List<Map<String, dynamic>> _mockFlights = [
    {
      'id': 1,
      'flight_number': 'AK6022',
      'airline': 'AirAsia',
      'aircraft': 'A320',
      'route': {
        'from': 'KUL',
        'to': 'PEN'
      },
      'schedule': {
        'departure_time': '07:30',
        'arrival_time': '08:50',
        'duration': '1h 20m',
        'days': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
      },
      'pricing': {
        'Economy': {
          'price_myr': 189,
          'currency': 'MYR'
        },
        'Economy Premium': {
          'price_myr': 389,
          'currency': 'MYR'
        }
      }
    },
    {
      'id': 2,
      'flight_number': 'MH1026',
      'airline': 'Malaysia Airlines',
      'aircraft': 'B737-800',
      'route': {
        'from': 'KUL',
        'to': 'PEN'
      },
      'schedule': {
        'departure_time': '09:15',
        'arrival_time': '10:30',
        'duration': '1h 15m',
        'days': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
      },
      'pricing': {
        'Economy': {
          'price_myr': 298,
          'currency': 'MYR'
        },
        'Economy Premium': {
          'price_myr': 598,
          'currency': 'MYR'
        },
        'Business Class': {
          'price_myr': 998,
          'currency': 'MYR'
        }
      }
    },
    {
      'id': 3,
      'flight_number': 'AK5104',
      'airline': 'AirAsia',
      'aircraft': 'A321',
      'route': {
        'from': 'KUL',
        'to': 'BKI'
      },
      'schedule': {
        'departure_time': '14:25',
        'arrival_time': '17:10',
        'duration': '2h 45m',
        'days': ['Monday', 'Wednesday', 'Friday', 'Saturday', 'Sunday']
      },
      'pricing': {
        'Economy': {
          'price_myr': 429,
          'currency': 'MYR'
        },
        'Economy Premium': {
          'price_myr': 729,
          'currency': 'MYR'
        }
      }
    },
    {
      'id': 4,
      'flight_number': 'MH2602',
      'airline': 'Malaysia Airlines',
      'aircraft': 'A330',
      'route': {
        'from': 'KUL',
        'to': 'BKI'
      },
      'schedule': {
        'departure_time': '11:45',
        'arrival_time': '14:30',
        'duration': '2h 45m',
        'days': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
      },
      'pricing': {
        'Economy': {
          'price_myr': 548,
          'currency': 'MYR'
        },
        'Economy Premium': {
          'price_myr': 898,
          'currency': 'MYR'
        },
        'Business Class': {
          'price_myr': 1598,
          'currency': 'MYR'
        }
      }
    },
    {
      'id': 5,
      'flight_number': 'AK5206',
      'airline': 'AirAsia',
      'aircraft': 'A320',
      'route': {
        'from': 'KUL',
        'to': 'KCH'
      },
      'schedule': {
        'departure_time': '16:40',
        'arrival_time': '18:15',
        'duration': '1h 35m',
        'days': ['Tuesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
      },
      'pricing': {
        'Economy': {
          'price_myr': 359,
          'currency': 'MYR'
        },
        'Economy Premium': {
          'price_myr': 659,
          'currency': 'MYR'
        }
      }
    },
    {
      'id': 6,
      'flight_number': 'MH2714',
      'airline': 'Malaysia Airlines',
      'aircraft': 'B737-800',
      'route': {
        'from': 'KUL',
        'to': 'KCH'
      },
      'schedule': {
        'departure_time': '13:20',
        'arrival_time': '14:55',
        'duration': '1h 35m',
        'days': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
      },
      'pricing': {
        'Economy': {
          'price_myr': 468,
          'currency': 'MYR'
        },
        'Economy Premium': {
          'price_myr': 768,
          'currency': 'MYR'
        },
        'Business Class': {
          'price_myr': 1268,
          'currency': 'MYR'
        }
      }
    },
    {
      'id': 7,
      'flight_number': 'AK6112',
      'airline': 'AirAsia',
      'aircraft': 'A320',
      'route': {
        'from': 'PEN',
        'to': 'JHB'
      },
      'schedule': {
        'departure_time': '12:10',
        'arrival_time': '13:20',
        'duration': '1h 10m',
        'days': ['Monday', 'Wednesday', 'Friday', 'Sunday']
      },
      'pricing': {
        'Economy': {
          'price_myr': 219,
          'currency': 'MYR'
        },
        'Economy Premium': {
          'price_myr': 419,
          'currency': 'MYR'
        }
      }
    },
    {
      'id': 8,
      'flight_number': 'MH1142',
      'airline': 'Malaysia Airlines',
      'aircraft': 'B737-800',
      'route': {
        'from': 'PEN',
        'to': 'JHB'
      },
      'schedule': {
        'departure_time': '15:35',
        'arrival_time': '16:45',
        'duration': '1h 10m',
        'days': ['Tuesday', 'Thursday', 'Saturday', 'Sunday']
      },
      'pricing': {
        'Economy': {
          'price_myr': 328,
          'currency': 'MYR'
        },
        'Economy Premium': {
          'price_myr': 528,
          'currency': 'MYR'
        },
        'Business Class': {
          'price_myr': 928,
          'currency': 'MYR'
        }
      }
    },
    {
      'id': 9,
      'flight_number': 'AK5324',
      'airline': 'AirAsia',
      'aircraft': 'A321',
      'route': {
        'from': 'BKI',
        'to': 'SDK'
      },
      'schedule': {
        'departure_time': '08:45',
        'arrival_time': '09:30',
        'duration': '45m',
        'days': ['Monday', 'Tuesday', 'Thursday', 'Saturday']
      },
      'pricing': {
        'Economy': {
          'price_myr': 159,
          'currency': 'MYR'
        },
        'Economy Premium': {
          'price_myr': 289,
          'currency': 'MYR'
        }
      }
    },
    {
      'id': 10,
      'flight_number': 'MH3082',
      'airline': 'Malaysia Airlines',
      'aircraft': 'B737-800',
      'route': {
        'from': 'BKI',
        'to': 'SDK'
      },
      'schedule': {
        'departure_time': '17:20',
        'arrival_time': '18:05',
        'duration': '45m',
        'days': ['Wednesday', 'Friday', 'Sunday']
      },
      'pricing': {
        'Economy': {
          'price_myr': 248,
          'currency': 'MYR'
        },
        'Economy Premium': {
          'price_myr': 398,
          'currency': 'MYR'
        },
        'Business Class': {
          'price_myr': 698,
          'currency': 'MYR'
        }
      }
    },
    {
      'id': 11,
      'flight_number': 'AK5418',
      'airline': 'AirAsia',
      'aircraft': 'A320',
      'route': {
        'from': 'BKI',
        'to': 'TWU'
      },
      'schedule': {
        'departure_time': '19:10',
        'arrival_time': '20:20',
        'duration': '1h 10m',
        'days': ['Monday', 'Wednesday', 'Friday', 'Sunday']
      },
      'pricing': {
        'Economy': {
          'price_myr': 189,
          'currency': 'MYR'
        },
        'Economy Premium': {
          'price_myr': 359,
          'currency': 'MYR'
        }
      }
    },
    {
      'id': 12,
      'flight_number': 'MH3184',
      'airline': 'Malaysia Airlines',
      'aircraft': 'B737-800',
      'route': {
        'from': 'BKI',
        'to': 'TWU'
      },
      'schedule': {
        'departure_time': '10:30',
        'arrival_time': '11:40',
        'duration': '1h 10m',
        'days': ['Tuesday', 'Thursday', 'Saturday']
      },
      'pricing': {
        'Economy': {
          'price_myr': 278,
          'currency': 'MYR'
        },
        'Economy Premium': {
          'price_myr': 478,
          'currency': 'MYR'
        },
        'Business Class': {
          'price_myr': 778,
          'currency': 'MYR'
        }
      }
    },
    {
      'id': 13,
      'flight_number': 'AK5520',
      'airline': 'AirAsia',
      'aircraft': 'A320',
      'route': {
        'from': 'KCH',
        'to': 'SBW'
      },
      'schedule': {
        'departure_time': '06:30',
        'arrival_time': '07:25',
        'duration': '55m',
        'days': ['Monday', 'Tuesday', 'Wednesday', 'Friday', 'Sunday']
      },
      'pricing': {
        'Economy': {
          'price_myr': 169,
          'currency': 'MYR'
        },
        'Economy Premium': {
          'price_myr': 319,
          'currency': 'MYR'
        }
      }
    },
    {
      'id': 14,
      'flight_number': 'MH2850',
      'airline': 'Malaysia Airlines',
      'aircraft': 'B737-800',
      'route': {
        'from': 'KCH',
        'to': 'SBW'
      },
      'schedule': {
        'departure_time': '14:50',
        'arrival_time': '15:45',
        'duration': '55m',
        'days': ['Thursday', 'Saturday', 'Sunday']
      },
      'pricing': {
        'Economy': {
          'price_myr': 238,
          'currency': 'MYR'
        },
        'Economy Premium': {
          'price_myr': 438,
          'currency': 'MYR'
        },
        'Business Class': {
          'price_myr': 738,
          'currency': 'MYR'
        }
      }
    },
    {
      'id': 15,
      'flight_number': 'AK6218',
      'airline': 'AirAsia',
      'aircraft': 'A321',
      'route': {
        'from': 'JHB',
        'to': 'KUL'
      },
      'schedule': {
        'departure_time': '20:45',
        'arrival_time': '21:55',
        'duration': '1h 10m',
        'days': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
      },
      'pricing': {
        'Economy': {
          'price_myr': 199,
          'currency': 'MYR'
        },
        'Economy Premium': {
          'price_myr': 399,
          'currency': 'MYR'
        }
      }
    },
    {
      'id': 16,
      'flight_number': 'MH1246',
      'airline': 'Malaysia Airlines',
      'aircraft': 'A350',
      'route': {
        'from': 'JHB',
        'to': 'KUL'
      },
      'schedule': {
        'departure_time': '18:25',
        'arrival_time': '19:35',
        'duration': '1h 10m',
        'days': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
      },
      'pricing': {
        'Economy': {
          'price_myr': 318,
          'currency': 'MYR'
        },
        'Economy Premium': {
          'price_myr': 618,
          'currency': 'MYR'
        },
        'Business Class': {
          'price_myr': 1118,
          'currency': 'MYR'
        }
      }
    }
  ];

  static final Map<String, dynamic> _airlineInfo = {
    'AirAsia': {
      'code': 'AK',
      'aircraft_types': ['A320', 'A321'],
      'classes': ['Economy', 'Economy Premium'],
      'amenities': {
        'Economy': {
          'free_meal': false,
          'free_wifi': false,
          'carry_on': {'pieces': 1, 'weight_kg': 7},
          'checked_baggage_included': false
        },
        'Economy Premium': {
          'free_meal': true,
          'free_wifi': true,
          'carry_on': {'pieces': 2, 'weight_kg': 14},
          'checked_baggage_included': true
        }
      }
    },
    'Malaysia Airlines': {
      'code': 'MH',
      'aircraft_types': ['A330', 'B737-800', 'A350'],
      'classes': ['Economy', 'Economy Premium', 'Business Class'],
      'amenities': {
        'Economy': {
          'free_meal': true,
          'free_wifi': false,
          'carry_on': {'pieces': 1, 'weight_kg': 7},
          'checked_baggage_included': true
        },
        'Economy Premium': {
          'free_meal': true,
          'free_wifi': true,
          'carry_on': {'pieces': 2, 'weight_kg': 10},
          'checked_baggage_included': true
        },
        'Business Class': {
          'free_meal': true,
          'free_wifi': true,
          'carry_on': {'pieces': 2, 'weight_kg': 15},
          'checked_baggage_included': true
        }
      }
    }
  };

  static final Map<String, dynamic> _airportInfo = {
    'KUL': {
      'code': 'KUL',
      'name': 'Kuala Lumpur International Airport',
      'city': 'Kuala Lumpur'
    },
    'JHB': {
      'code': 'JHB',
      'name': 'Senai International Airport',
      'city': 'Johor Bahru'
    },
    'PEN': {
      'code': 'PEN',
      'name': 'Penang International Airport',
      'city': 'Penang'
    },
    'BKI': {
      'code': 'BKI',
      'name': 'Kota Kinabalu International Airport',
      'city': 'Kota Kinabalu'
    },
    'SDK': {
      'code': 'SDK',
      'name': 'Sandakan Airport',
      'city': 'Sandakan'
    },
    'TWU': {
      'code': 'TWU',
      'name': 'Tawau Airport',
      'city': 'Tawau'
    },
    'SBW': {
      'code': 'SBW',
      'name': 'Sibu Airport',
      'city': 'Sibu'
    },
    'KCH': {
      'code': 'KCH',
      'name': 'Kuching International Airport',
      'city': 'Kuching'
    }
  };

  static Future<List<Flight>> searchFlights({
    String? from,
    String? to,
    String? airline,
    double? minPrice,
    double? maxPrice,
    String? flightClass,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 1500));

    List<Map<String, dynamic>> filteredFlights = _mockFlights;

    if (from != null && from.isNotEmpty) {
      filteredFlights = filteredFlights.where((flight) {
        return flight['route']['from'].toString().toLowerCase() == from.toLowerCase();
      }).toList();
    }

    if (to != null && to.isNotEmpty) {
      filteredFlights = filteredFlights.where((flight) {
        return flight['route']['to'].toString().toLowerCase() == to.toLowerCase();
      }).toList();
    }

    if (airline != null && airline.isNotEmpty) {
      filteredFlights = filteredFlights.where((flight) {
        return flight['airline'].toString().toLowerCase().contains(airline.toLowerCase());
      }).toList();
    }

    if (minPrice != null || maxPrice != null || flightClass != null) {
      filteredFlights = filteredFlights.where((flight) {
        Map<String, dynamic> pricing = flight['pricing'];

        if (flightClass != null) {
          if (!pricing.containsKey(flightClass)) return false;

          double price = pricing[flightClass]['price_myr'].toDouble();
          if (minPrice != null && price < minPrice) return false;
          if (maxPrice != null && price > maxPrice) return false;
        } else {
          // If no specific class, check all available classes
          bool priceMatches = false;
          for (var classPrice in pricing.values) {
            double price = classPrice['price_myr'].toDouble();
            bool withinRange = true;
            if (minPrice != null && price < minPrice) withinRange = false;
            if (maxPrice != null && price > maxPrice) withinRange = false;
            if (withinRange) {
              priceMatches = true;
              break;
            }
          }
          if (!priceMatches) return false;
        }

        return true;
      }).toList();
    }

    return filteredFlights.map((json) => Flight.fromJson(json)).toList();
  }

  static Future<Flight?> getFlightById(int id) async {
    await Future.delayed(Duration(milliseconds: 500));

    try {
      final flightData = _mockFlights.firstWhere((flight) => flight['id'] == id);
      return Flight.fromJson(flightData);
    } catch (e) {
      return null;
    }
  }

  static List<String> getPopularRoutes() {
    Set<String> routes = {};
    for (var flight in _mockFlights) {
      String from = flight['route']['from'];
      String to = flight['route']['to'];
      routes.add('$from-$to');
    }
    return routes.toList();
  }

  static List<String> getAirlines() {
    return _airlineInfo.keys.toList();
  }

  static List<String> getAirports() {
    return _airportInfo.keys.toList();
  }

  static Map<String, dynamic> getAirportInfo(String code) {
    return _airportInfo[code] ?? {};
  }

  static Map<String, dynamic> getAirlineInfo(String airline) {
    return _airlineInfo[airline] ?? {};
  }

  static List<String> getFlightClasses(String airline) {
    var airlineData = _airlineInfo[airline];
    if (airlineData != null) {
      return List<String>.from(airlineData['classes'] ?? []);
    }
    return [];
  }

  static Map<String, dynamic> getFlightStats() {
    return {
      'totalFlights': _mockFlights.length,
      'totalRoutes': getPopularRoutes().length,
      'airlines': getAirlines().length,
      'airports': getAirports().length,
    };
  }

  // New method to get available classes for a specific flight
  static List<String> getAvailableClassesForFlight(int flightId) {
    try {
      final flightData = _mockFlights.firstWhere((flight) => flight['id'] == flightId);
      Map<String, dynamic> pricing = flightData['pricing'];
      return pricing.keys.toList();
    } catch (e) {
      return [];
    }
  }

  // New method to check seat availability
  static Future<Map<String, dynamic>> checkSeatAvailability(
      int flightId,
      String flightClass,
      DateTime departureDate
      ) async {
    await Future.delayed(Duration(milliseconds: 800));

    try {
      final flightData = _mockFlights.firstWhere((flight) => flight['id'] == flightId);
      Map<String, dynamic> pricing = flightData['pricing'];

      if (!pricing.containsKey(flightClass)) {
        return {'available': false, 'message': 'Flight class not found'};
      }

      // Simulate random availability (75% chance of being available)
      final isAvailable = DateTime.now().microsecond % 10 < 7;
      final availableSeats = isAvailable ? 15 + (DateTime.now().microsecond % 25) : 0;

      return {
        'available': isAvailable && availableSeats > 0,
        'availableSeats': availableSeats,
        'price': pricing[flightClass]['price_myr'],
        'currency': pricing[flightClass]['currency'],
        'flightClass': flightClass,
        'departureDate': departureDate.toIso8601String(),
      };
    } catch (e) {
      return {'available': false, 'message': 'Flight not found'};
    }
  }

  // New method to get flight amenities by class
  static Map<String, dynamic> getFlightAmenities(String airline, String flightClass) {
    var airlineData = _airlineInfo[airline];
    if (airlineData != null && airlineData['amenities'] != null) {
      return airlineData['amenities'][flightClass] ?? {};
    }
    return {};
  }
}