import 'package:firebase_database/firebase_database.dart';
import '../Model/hotel.dart';
import '../Model/flight.dart';
import '../Model/transport.dart';
import '../Model/attraction_model.dart';
import '../services/mock_hotel_service.dart';
import '../services/mock_flight_service.dart';

class TripRequest {
  final Set<String> selectedStates;
  final String origin;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfPax;
  final double maxBudget;
  final TripType tripType;
  final FlexibilityLevel flexibility;

  TripRequest({
    required this.selectedStates,
    required this.origin,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfPax,
    required this.maxBudget,
    required this.tripType,
    required this.flexibility,
  });

  int get tripDuration => checkOutDate.difference(checkInDate).inDays;
}

enum TripType { adventure, chill, mix }
enum FlexibilityLevel { flexible, normal, full }

class ItineraryDay {
  final DateTime date;
  final String state;
  final Hotel? hotel;
  final List<Attraction> attractions;
  final List<Transport> transports;
  final Flight? flight;
  final double totalCost;
  final Duration totalActivityTime;
  final Duration restTime;
  final List<ScheduledActivity> schedule;

  ItineraryDay({
    required this.date,
    required this.state,
    this.hotel,
    required this.attractions,
    required this.transports,
    this.flight,
    required this.totalCost,
    required this.totalActivityTime,
    required this.restTime,
    required this.schedule,
  });
}

class ScheduledActivity {
  final DateTime startTime;
  final DateTime endTime;
  final String activityType; // 'transport', 'attraction', 'meal', 'rest', 'checkin', 'checkout'
  final String title;
  final String description;
  final String? location;
  final double? cost;

  ScheduledActivity({
    required this.startTime,
    required this.endTime,
    required this.activityType,
    required this.title,
    required this.description,
    this.location,
    this.cost,
  });

  Duration get duration => endTime.difference(startTime);
  String get timeRange => '${_formatTime(startTime)} - ${_formatTime(endTime)}';

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class GeneratedItinerary {
  final List<ItineraryDay> days;
  final double totalCost;
  final TripRequest originalRequest;
  final DateTime generatedAt;

  GeneratedItinerary({
    required this.days,
    required this.totalCost,
    required this.originalRequest,
    required this.generatedAt,
  });

  bool get isWithinBudget => totalCost <= originalRequest.maxBudget;
}

// Firebase Realtime Database service
class FirebaseItineraryService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Map state names to match your Firebase data
  final Map<String, String> _stateMapping = {
    'Kuala Lumpur': 'Kuala Lumpur',
    'Johor': 'Johor',
    'Kedah': 'Kedah',
    'Kelantan': 'Kelantan',
    'Labuan': 'Labuan',
    'Malacca': 'Melaka',
    'Negeri Sembilan': 'Negeri Sembilan',
    'Pahang': 'Pahang',
    'Penang': 'Penang',
    'Perak': 'Perak',
    'Perlis': 'Perlis',
    'Putrajaya': 'Putrajaya',
    'Sabah': 'Sabah',
    'Sarawak': 'Sarawak',
    'Selangor': 'Selangor',
    'Terengganu': 'Terengganu',
  };

  Future<List<Hotel>> searchHotels({
    required List<String> states,
    required double maxPricePerNight,
    required int numberOfPax,
  }) async {
    try {
      // Use mock service for hotels as you already have comprehensive data
      List<Hotel> allHotels = [];

      for (String state in states) {
        String mappedState = _stateMapping[state] ?? state;
        List<Hotel> stateHotels = await MockMalaysiaHotelService.searchHotels(
          destination: mappedState,
          maxPrice: maxPricePerNight,
        );
        allHotels.addAll(stateHotels);
      }

      // Filter by capacity (basic assumption: 2 people per room for most room types)
      return allHotels.where((hotel) {
        // Check if hotel has suitable room types for the number of pax
        if (hotel.roomTypes != null) {
          return hotel.roomTypes!.any((roomType) {
            String roomName = roomType['name'].toLowerCase();
            // Simple logic: family rooms for 3+, doubles for 2, singles for 1
            if (numberOfPax >= 3) return roomName.contains('family') || roomName.contains('three') || roomName.contains('penthouse');
            if (numberOfPax == 2) return !roomName.contains('single');
            return true; // Single occupancy can use any room
          });
        }
        return true;
      }).toList();
    } catch (e) {
      print('Error searching hotels: $e');
      return [];
    }
  }

  Future<List<Attraction>> searchAttractions({
    required List<String> states,
    required TripType tripType,
    required double maxPrice,
  }) async {
    try {
      List<Attraction> attractions = [];

      for (String state in states) {
        String mappedState = _stateMapping[state] ?? state;

        // Get all attractions from Realtime Database
        final DatabaseReference attractionsRef = _database.child('Attractions');
        final DataSnapshot snapshot = await attractionsRef.get();

        if (snapshot.exists) {
          Map<String, dynamic> allAttractions = Map<String, dynamic>.from(snapshot.value as Map);

          allAttractions.forEach((key, value) {
            if (value is Map) {
              Map<String, dynamic> attractionData = Map<String, dynamic>.from(value);

              // Check if attraction matches our criteria
              String attractionState = attractionData['state']?.toString() ?? '';
              bool isHidden = attractionData['hide'] == true;

              if (attractionState == mappedState && !isHidden) {
                Attraction attraction = Attraction.fromMap(key, attractionData);

                // Filter by trip type
                bool matchesTripType = false;
                if (tripType == TripType.mix) {
                  matchesTripType = true;
                } else {
                  String targetType = tripType == TripType.adventure ? 'Adventure' : 'Chill';
                  matchesTripType = attraction.type.contains(targetType);
                }

                // Filter by price - use lowest pricing option
                bool withinBudget = false;
                if (attraction.pricing.isNotEmpty) {
                  double lowestPrice = attraction.pricing
                      .map((p) => p.price)
                      .reduce((a, b) => a < b ? a : b);
                  withinBudget = lowestPrice <= maxPrice;
                } else {
                  withinBudget = true; // Free attractions
                }

                if (matchesTripType && withinBudget) {
                  attractions.add(attraction);
                }
              }
            }
          });
        }
      }

      // Sort by price (ascending) to prioritize budget-friendly options
      attractions.sort((a, b) {
        double priceA = a.pricing.isNotEmpty ? a.pricing.first.price : 0;
        double priceB = b.pricing.isNotEmpty ? b.pricing.first.price : 0;
        return priceA.compareTo(priceB);
      });

      return attractions;
    } catch (e) {
      print('Error searching attractions: $e');
      return [];
    }
  }

  Future<List<Transport>> searchTransport({
    required String fromState,
    required String toState,
    required double maxPrice,
  }) async {
    try {
      List<Transport> transports = [];

      // Get all transports from Realtime Database
      final DatabaseReference transportsRef = _database.child('Transports');
      final DataSnapshot snapshot = await transportsRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> allTransports = Map<String, dynamic>.from(snapshot.value as Map);

        allTransports.forEach((key, value) {
          if (value is Map) {
            Map<String, dynamic> transportData = Map<String, dynamic>.from(value);

            bool isHidden = transportData['hide'] == true;

            if (!isHidden) {
              Transport transport = Transport.fromMap(key, transportData);

              // Check if transport matches route and budget
              bool matchesRoute = transport.matchesSearch(
                searchOrigin: fromState,
                searchDestination: toState,
              );

              bool withinBudget = transport.price <= maxPrice;

              if (matchesRoute && withinBudget) {
                transports.add(transport);
              }
            }
          }
        });
      }

      // Also search flights using mock service for inter-state travel
      if (fromState != toState) {
        String fromCode = _getAirportCode(fromState);
        String toCode = _getAirportCode(toState);

        if (fromCode.isNotEmpty && toCode.isNotEmpty) {
          List<Flight> flights = await MockMalaysiaFlightService.searchFlights(
            from: fromCode,
            to: toCode,
            maxPrice: maxPrice,
            flightClass: 'Economy',
          );

          // Convert flights to transport objects for compatibility
          for (Flight flight in flights) {
            double economyPrice = flight.getPricingForClass('Economy')?.priceMyr ?? 0;
            if (economyPrice <= maxPrice) {
              Transport flightTransport = Transport(
                id: flight.id.toString(),
                name: '${flight.airline} ${flight.flightNumber}',
                type: 'Flight',
                origin: fromState,
                destination: toState,
                price: economyPrice,
                description: 'Flight from ${flight.route.from} to ${flight.route.to}',
                additionalInfo: {
                  'airline': flight.airline,
                  'flightNumber': flight.flightNumber,
                  'duration': flight.schedule.duration,
                  'departureTime': flight.schedule.departureTime,
                  'arrivalTime': flight.schedule.arrivalTime,
                },
              );
              transports.add(flightTransport);
            }
          }
        }
      }

      return transports;
    } catch (e) {
      print('Error searching transport: $e');
      return [];
    }
  }

  // Alternative method using orderBy and filtering for better performance
  Future<List<Attraction>> searchAttractionsOptimized({
    required List<String> states,
    required TripType tripType,
    required double maxPrice,
  }) async {
    try {
      List<Attraction> attractions = [];

      for (String state in states) {
        String mappedState = _stateMapping[state] ?? state;

        // Use orderByChild to filter by state - returns Query, not DatabaseReference
        final Query attractionsQuery = _database
            .child('Attractions')
            .orderByChild('state')
            .equalTo(mappedState);

        final DataSnapshot snapshot = await attractionsQuery.get();

        if (snapshot.exists) {
          Map<String, dynamic> stateAttractions = Map<String, dynamic>.from(snapshot.value as Map);

          stateAttractions.forEach((key, value) {
            if (value is Map) {
              Map<String, dynamic> attractionData = Map<String, dynamic>.from(value);

              bool isHidden = attractionData['hide'] == true;

              if (!isHidden) {
                Attraction attraction = Attraction.fromMap(key, attractionData);

                // Filter by trip type
                bool matchesTripType = false;
                if (tripType == TripType.mix) {
                  matchesTripType = true;
                } else {
                  String targetType = tripType == TripType.adventure ? 'Adventure' : 'Chill';
                  matchesTripType = attraction.type.contains(targetType);
                }

                // Filter by price - use lowest pricing option
                bool withinBudget = false;
                if (attraction.pricing.isNotEmpty) {
                  double lowestPrice = attraction.pricing
                      .map((p) => p.price)
                      .reduce((a, b) => a < b ? a : b);
                  withinBudget = lowestPrice <= maxPrice;
                } else {
                  withinBudget = true; // Free attractions
                }

                if (matchesTripType && withinBudget) {
                  attractions.add(attraction);
                }
              }
            }
          });
        }
      }

      // Sort by price (ascending) to prioritize budget-friendly options
      attractions.sort((a, b) {
        double priceA = a.pricing.isNotEmpty ? a.pricing.first.price : 0;
        double priceB = b.pricing.isNotEmpty ? b.pricing.first.price : 0;
        return priceA.compareTo(priceB);
      });

      return attractions;
    } catch (e) {
      print('Error searching attractions (optimized): $e');
      return [];
    }
  }

  // Helper method to map states to airport codes
  String _getAirportCode(String state) {
    Map<String, String> airportMapping = {
      'Kuala Lumpur': 'KUL',
      'Johor': 'JHB',
      'Penang': 'PEN',
      'Sabah': 'BKI',
      'Sarawak': 'KCH',
      'Kedah': 'LGK', // Langkawi for Kedah
    };
    return airportMapping[state] ?? '';
  }

  // Method to listen to real-time changes for attractions
  Stream<List<Attraction>> listenToAttractions({
    required String state,
    required TripType tripType,
    required double maxPrice,
  }) {
    String mappedState = _stateMapping[state] ?? state;

    final Query attractionsQuery = _database
        .child('Attractions')
        .orderByChild('state')
        .equalTo(mappedState);

    return attractionsQuery
        .onValue
        .map((event) {
      List<Attraction> attractions = [];

      if (event.snapshot.exists) {
        Map<String, dynamic> attractionsData = Map<String, dynamic>.from(event.snapshot.value as Map);

        attractionsData.forEach((key, value) {
          if (value is Map) {
            Map<String, dynamic> attractionData = Map<String, dynamic>.from(value);

            bool isHidden = attractionData['hide'] == true;

            if (!isHidden) {
              Attraction attraction = Attraction.fromMap(key, attractionData);

              // Filter by trip type
              bool matchesTripType = false;
              if (tripType == TripType.mix) {
                matchesTripType = true;
              } else {
                String targetType = tripType == TripType.adventure ? 'Adventure' : 'Chill';
                matchesTripType = attraction.type.contains(targetType);
              }

              // Filter by price
              bool withinBudget = false;
              if (attraction.pricing.isNotEmpty) {
                double lowestPrice = attraction.pricing
                    .map((p) => p.price)
                    .reduce((a, b) => a < b ? a : b);
                withinBudget = lowestPrice <= maxPrice;
              } else {
                withinBudget = true;
              }

              if (matchesTripType && withinBudget) {
                attractions.add(attraction);
              }
            }
          }
        });
      }

      return attractions;
    });
  }
}

// Main itinerary generator (rest of the class remains the same)
class ItineraryGenerator {
  final FirebaseItineraryService _firebaseService = FirebaseItineraryService();

  Future<GeneratedItinerary?> generateItinerary(TripRequest request) async {
    try {
      // Calculate budget allocation
      double hotelBudget = request.maxBudget * 0.4; // 40% for accommodation
      double transportBudget = request.maxBudget * 0.25; // 25% for transport
      double attractionBudget = request.maxBudget * 0.35; // 35% for attractions

      print('Budget allocation - Hotel: $hotelBudget, Transport: $transportBudget, Attractions: $attractionBudget');

      // Search for products using optimized method
      List<Hotel> availableHotels = await _firebaseService.searchHotels(
        states: request.selectedStates.toList(),
        maxPricePerNight: hotelBudget / request.tripDuration,
        numberOfPax: request.numberOfPax,
      );

      List<Attraction> availableAttractions = await _firebaseService.searchAttractionsOptimized(
        states: request.selectedStates.toList(),
        tripType: request.tripType,
        maxPrice: attractionBudget / request.tripDuration / _getMaxAttractionsPerDay(request.flexibility),
      );

      print('Found ${availableHotels.length} hotels, ${availableAttractions.length} attractions');

      // Generate daily itinerary
      List<ItineraryDay> days = [];
      double totalCost = 0;
      List<String> statesList = request.selectedStates.toList();

      for (int i = 0; i < request.tripDuration; i++) {
        DateTime currentDate = request.checkInDate.add(Duration(days: i));
        String currentState = statesList[i % statesList.length];

        // Select hotel for the day
        Hotel? dayHotel = _selectBestHotel(
          availableHotels,
          currentState,
          hotelBudget / request.tripDuration,
          request.numberOfPax,
        );

        // Select attractions based on flexibility
        List<Attraction> dayAttractions = _selectAttractions(
          availableAttractions,
          currentState,
          request.flexibility,
          attractionBudget / request.tripDuration,
        );

        // Select transport (if changing states)
        List<Transport> dayTransports = [];
        if (i > 0) {
          String previousState = statesList[(i - 1) % statesList.length];
          if (previousState != currentState) {
            List<Transport> transports = await _firebaseService.searchTransport(
              fromState: previousState,
              toState: currentState,
              maxPrice: transportBudget / 2, // Allow for return transport
            );
            if (transports.isNotEmpty) {
              dayTransports.add(transports.first); // Select best transport option
            }
          }
        }

        // Calculate costs
        double hotelCost = dayHotel != null ? _getHotelPrice(dayHotel, request.numberOfPax) : 0;
        double attractionCost = dayAttractions.fold(0, (sum, attraction) {
          double price = attraction.pricing.isNotEmpty ? attraction.pricing.first.price : 0;
          return sum + (price * request.numberOfPax);
        });
        double transportCost = dayTransports.fold(0, (sum, transport) => sum + (transport.price * request.numberOfPax));

        double dayCost = hotelCost + attractionCost + transportCost;

        // Calculate activity and rest time based on flexibility
        Duration totalActivityTime = Duration(hours: dayAttractions.length * 2); // Assume 2 hours per attraction
        Duration restTime = _calculateRestTime(request.flexibility, totalActivityTime);

        // Generate detailed schedule for the day
        List<ScheduledActivity> daySchedule = _generateDaySchedule(
          currentDate,
          dayHotel,
          dayAttractions,
          dayTransports,
          request.flexibility,
          i == 0, // isFirstDay
          i == request.tripDuration - 1, // isLastDay
        );

        ItineraryDay day = ItineraryDay(
          date: currentDate,
          state: currentState,
          hotel: dayHotel,
          attractions: dayAttractions,
          transports: dayTransports,
          totalCost: dayCost,
          totalActivityTime: totalActivityTime,
          restTime: restTime,
          schedule: daySchedule,
        );

        days.add(day);
        totalCost += dayCost;

        // Check if we're exceeding budget
        if (totalCost > request.maxBudget) {
          print('Exceeding budget at day ${i + 1}. Current total: $totalCost, Budget: ${request.maxBudget}');
          break;
        }
      }

      return GeneratedItinerary(
        days: days,
        totalCost: totalCost,
        originalRequest: request,
        generatedAt: DateTime.now(),
      );

    } catch (e) {
      print('Error generating itinerary: $e');
      return null;
    }
  }

  Hotel? _selectBestHotel(List<Hotel> hotels, String state, double maxPrice, int numberOfPax) {
    List<Hotel> stateHotels = hotels.where((hotel) {
      bool matchesState = hotel.city.toLowerCase().contains(state.toLowerCase()) ||
          hotel.address.toLowerCase().contains(state.toLowerCase());

      double hotelPrice = _getHotelPrice(hotel, numberOfPax);
      bool withinBudget = hotelPrice <= maxPrice;

      return matchesState && withinBudget;
    }).toList();

    if (stateHotels.isEmpty) return null;

    // Sort by rating (descending) then by price (ascending)
    stateHotels.sort((a, b) {
      int ratingComparison = b.rating.compareTo(a.rating);
      if (ratingComparison != 0) return ratingComparison;

      double priceA = _getHotelPrice(a, numberOfPax);
      double priceB = _getHotelPrice(b, numberOfPax);
      return priceA.compareTo(priceB);
    });

    return stateHotels.first;
  }

  double _getHotelPrice(Hotel hotel, int numberOfPax) {
    if (hotel.roomTypes == null || hotel.roomTypes!.isEmpty) {
      return hotel.price;
    }

    // Select appropriate room type based on number of pax
    var suitableRooms = hotel.roomTypes!.where((room) {
      String roomName = room['name'].toLowerCase();
      if (numberOfPax >= 4) return roomName.contains('family') || roomName.contains('three') || roomName.contains('four') || roomName.contains('penthouse');
      if (numberOfPax == 3) return roomName.contains('family') || roomName.contains('three') || !roomName.contains('single');
      if (numberOfPax == 2) return !roomName.contains('single');
      return true;
    }).toList();

    if (suitableRooms.isEmpty) {
      suitableRooms = hotel.roomTypes!;
    }

    // Return the cheapest suitable room
    return suitableRooms.map((room) => room['price'] as double).reduce((a, b) => a < b ? a : b);
  }

  List<Attraction> _selectAttractions(
      List<Attraction> attractions,
      String state,
      FlexibilityLevel flexibility,
      double budget,
      ) {
    List<Attraction> stateAttractions = attractions
        .where((attraction) => attraction.state.toLowerCase().contains(state.toLowerCase()))
        .toList();

    int maxAttractions = _getMaxAttractionsPerDay(flexibility);

    List<Attraction> selected = [];
    double currentCost = 0;

    for (Attraction attraction in stateAttractions) {
      if (selected.length >= maxAttractions) break;

      double attractionPrice = attraction.pricing.isNotEmpty ? attraction.pricing.first.price : 0;

      if (currentCost + attractionPrice <= budget) {
        selected.add(attraction);
        currentCost += attractionPrice;
      }
    }

    return selected;
  }

  int _getMaxAttractionsPerDay(FlexibilityLevel flexibility) {
    switch (flexibility) {
      case FlexibilityLevel.full:
        return 4; // Packed schedule
      case FlexibilityLevel.flexible:
        return 1; // Relaxed schedule
      case FlexibilityLevel.normal:
      default:
        return 2; // Balanced schedule
    }
  }

  Duration _calculateRestTime(FlexibilityLevel flexibility, Duration activityTime) {
    switch (flexibility) {
      case FlexibilityLevel.full:
        return Duration(hours: 2); // Minimal rest
      case FlexibilityLevel.flexible:
        return Duration(hours: 6); // Lots of rest
      case FlexibilityLevel.normal:
      default:
        return Duration(hours: 4); // Balanced rest
    }
  }

  // Generate detailed daily schedule with specific times
  List<ScheduledActivity> _generateDaySchedule(
      DateTime date,
      Hotel? hotel,
      List<Attraction> attractions,
      List<Transport> transports,
      FlexibilityLevel flexibility,
      bool isFirstDay,
      bool isLastDay,
      ) {
    List<ScheduledActivity> schedule = [];
    DateTime currentTime = DateTime(date.year, date.month, date.day, 8, 0); // Start at 8:00 AM

    // Check-in (first day only)
    if (isFirstDay && hotel != null) {
      DateTime checkInStart = DateTime(date.year, date.month, date.day, 15, 0); // 3:00 PM
      DateTime checkInEnd = checkInStart.add(Duration(minutes: 30));
      schedule.add(ScheduledActivity(
        startTime: checkInStart,
        endTime: checkInEnd,
        activityType: 'checkin',
        title: 'Hotel Check-in',
        description: 'Check into ${hotel.name}',
        location: hotel.address,
      ));
    }

    // Transport (if any)
    for (Transport transport in transports) {
      DateTime transportEnd = currentTime.add(Duration(hours: 2)); // Assume 2 hours for transport
      schedule.add(ScheduledActivity(
        startTime: currentTime,
        endTime: transportEnd,
        activityType: 'transport',
        title: transport.name,
        description: 'Travel from ${transport.origin} to ${transport.destination}',
        location: transport.route,
        cost: transport.price,
      ));
      currentTime = transportEnd.add(Duration(minutes: 30)); // 30min buffer
    }

    // Morning activities
    if (attractions.isNotEmpty) {
      // Breakfast
      DateTime breakfastEnd = currentTime.add(Duration(hours: 1));
      schedule.add(ScheduledActivity(
        startTime: currentTime,
        endTime: breakfastEnd,
        activityType: 'meal',
        title: 'Breakfast',
        description: 'Local breakfast near hotel or attraction',
        location: 'Local restaurant',
      ));
      currentTime = breakfastEnd;

      // First attraction
      if (attractions.isNotEmpty) {
        Attraction firstAttraction = attractions[0];
        DateTime activityEnd = currentTime.add(_getAttractionsTime(flexibility));
        schedule.add(ScheduledActivity(
          startTime: currentTime,
          endTime: activityEnd,
          activityType: 'attraction',
          title: firstAttraction.name,
          description: firstAttraction.description,
          location: firstAttraction.address,
          cost: firstAttraction.pricing.isNotEmpty ? firstAttraction.pricing.first.price : 0,
        ));
        currentTime = activityEnd;
      }

      // Lunch break
      DateTime lunchEnd = currentTime.add(Duration(hours: 1, minutes: 30));
      schedule.add(ScheduledActivity(
        startTime: currentTime,
        endTime: lunchEnd,
        activityType: 'meal',
        title: 'Lunch',
        description: 'Local cuisine lunch',
        location: 'Local restaurant',
      ));
      currentTime = lunchEnd;

      // Rest time based on flexibility
      Duration restDuration = _getRestDuration(flexibility);
      if (restDuration.inMinutes > 0) {
        DateTime restEnd = currentTime.add(restDuration);
        schedule.add(ScheduledActivity(
          startTime: currentTime,
          endTime: restEnd,
          activityType: 'rest',
          title: 'Rest Time',
          description: flexibility == FlexibilityLevel.flexible
              ? 'Extended rest and leisure time'
              : 'Short break and relaxation',
          location: hotel?.name ?? 'Rest area',
        ));
        currentTime = restEnd;
      }

      // Afternoon attractions
      for (int i = 1; i < attractions.length; i++) {
        Attraction attraction = attractions[i];
        DateTime activityEnd = currentTime.add(_getAttractionsTime(flexibility));
        schedule.add(ScheduledActivity(
          startTime: currentTime,
          endTime: activityEnd,
          activityType: 'attraction',
          title: attraction.name,
          description: attraction.description,
          location: attraction.address,
          cost: attraction.pricing.isNotEmpty ? attraction.pricing.first.price : 0,
        ));
        currentTime = activityEnd.add(Duration(minutes: 30)); // Buffer between activities
      }

      // Dinner
      if (currentTime.hour < 19) {
        currentTime = DateTime(date.year, date.month, date.day, 19, 0); // Ensure dinner at 7 PM
      }
      DateTime dinnerEnd = currentTime.add(Duration(hours: 2));
      schedule.add(ScheduledActivity(
        startTime: currentTime,
        endTime: dinnerEnd,
        activityType: 'meal',
        title: 'Dinner',
        description: 'Local dinner and evening leisure',
        location: 'Local restaurant',
      ));
    } else {
      // If no attractions, create a rest day schedule
      schedule.add(ScheduledActivity(
        startTime: currentTime,
        endTime: currentTime.add(Duration(hours: 8)),
        activityType: 'rest',
        title: 'Free Day',
        description: 'Relax and explore at your own pace',
        location: hotel?.name ?? 'Leisure time',
      ));
    }

    // Check-out (last day only)
    if (isLastDay && hotel != null) {
      DateTime checkOutStart = DateTime(date.year, date.month, date.day, 11, 0); // 11:00 AM
      DateTime checkOutEnd = checkOutStart.add(Duration(minutes: 30));
      schedule.add(ScheduledActivity(
        startTime: checkOutStart,
        endTime: checkOutEnd,
        activityType: 'checkout',
        title: 'Hotel Check-out',
        description: 'Check out from ${hotel.name}',
        location: hotel.address,
      ));
    }

    // Sort schedule by start time
    schedule.sort((a, b) => a.startTime.compareTo(b.startTime));
    return schedule;
  }

  Duration _getAttractionsTime(FlexibilityLevel flexibility) {
    switch (flexibility) {
      case FlexibilityLevel.full:
        return Duration(hours: 1, minutes: 30); // Quick visits
      case FlexibilityLevel.flexible:
        return Duration(hours: 3); // Leisurely visits
      case FlexibilityLevel.normal:
      default:
        return Duration(hours: 2); // Standard visits
    }
  }

  Duration _getRestDuration(FlexibilityLevel flexibility) {
    switch (flexibility) {
      case FlexibilityLevel.full:
        return Duration(minutes: 30); // Minimal rest
      case FlexibilityLevel.flexible:
        return Duration(hours: 2); // Extended rest
      case FlexibilityLevel.normal:
      default:
        return Duration(hours: 1); // Standard rest
    }
  }

  // Method to modify itinerary based on user preferences
  Future<GeneratedItinerary?> modifyItinerary(
      GeneratedItinerary currentItinerary,
      int dayIndex,
      {Hotel? newHotel, List<Attraction>? newAttractions}
      ) async {
    List<ItineraryDay> modifiedDays = List.from(currentItinerary.days);

    if (dayIndex >= 0 && dayIndex < modifiedDays.length) {
      ItineraryDay currentDay = modifiedDays[dayIndex];

      double newDayCost = 0;
      if (newHotel != null) {
        newDayCost += _getHotelPrice(newHotel, currentItinerary.originalRequest.numberOfPax);
      }
      if (newAttractions != null) {
        newDayCost += newAttractions.fold(0, (sum, attraction) {
          double price = attraction.pricing.isNotEmpty ? attraction.pricing.first.price : 0;
          return sum + (price * currentItinerary.originalRequest.numberOfPax);
        });
      }

      // Add transport costs
      newDayCost += currentDay.transports.fold(0, (sum, transport) =>
      sum + (transport.price * currentItinerary.originalRequest.numberOfPax));

      // Check if modification fits budget
      double otherDaysCost = currentItinerary.totalCost - currentDay.totalCost;
      if (otherDaysCost + newDayCost <= currentItinerary.originalRequest.maxBudget) {

        Duration newActivityTime = newAttractions != null
            ? Duration(hours: newAttractions.length * 2)
            : currentDay.totalActivityTime;

        // Regenerate schedule for modified day
        List<ScheduledActivity> newSchedule = _generateDaySchedule(
          currentDay.date,
          newHotel ?? currentDay.hotel,
          newAttractions ?? currentDay.attractions,
          currentDay.transports,
          currentItinerary.originalRequest.flexibility,
          dayIndex == 0, // isFirstDay
          dayIndex == currentItinerary.days.length - 1, // isLastDay
        );

        ItineraryDay modifiedDay = ItineraryDay(
          date: currentDay.date,
          state: currentDay.state,
          hotel: newHotel ?? currentDay.hotel,
          attractions: newAttractions ?? currentDay.attractions,
          transports: currentDay.transports,
          totalCost: newDayCost,
          totalActivityTime: newActivityTime,
          restTime: _calculateRestTime(
            currentItinerary.originalRequest.flexibility,
            newActivityTime,
          ),
          schedule: newSchedule,
        );

        modifiedDays[dayIndex] = modifiedDay;

        return GeneratedItinerary(
          days: modifiedDays,
          totalCost: otherDaysCost + newDayCost,
          originalRequest: currentItinerary.originalRequest,
          generatedAt: DateTime.now(),
        );
      }
    }

    return null; // Modification failed
  }
}