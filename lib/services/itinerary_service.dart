import 'package:firebase_database/firebase_database.dart';
import '../Model/hotel.dart';
import '../Model/flight.dart';
import '../Model/transport.dart';
import '../Model/attraction_model.dart';
import '../services/mock_hotel_service.dart';
import '../services/mock_flight_service.dart';
import 'dart:math' as math;

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

  // Add missing toJson method
  Map<String, dynamic> toJson() {
    return {
      'selectedStates': selectedStates.toList(),
      'origin': origin,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'numberOfPax': numberOfPax,
      'maxBudget': maxBudget,
      'tripType': tripType.toString(),
      'flexibility': flexibility.toString(),
    };
  }

  // Add missing fromJson factory constructor
  factory TripRequest.fromJson(Map<String, dynamic> json) {
    return TripRequest(
      selectedStates: Set<String>.from(json['selectedStates'] as List),
      origin: json['origin'],
      checkInDate: DateTime.parse(json['checkInDate']),
      checkOutDate: DateTime.parse(json['checkOutDate']),
      numberOfPax: json['numberOfPax'],
      maxBudget: json['maxBudget'].toDouble(),
      tripType: _tripTypeFromString(json['tripType']),
      flexibility: _flexibilityFromString(json['flexibility']),
    );
  }

  static TripType _tripTypeFromString(String str) {
    switch (str) {
      case 'TripType.adventure':
        return TripType.adventure;
      case 'TripType.chill':
        return TripType.chill;
      case 'TripType.mix':
        return TripType.mix;
      default:
        return TripType.mix;
    }
  }

  static FlexibilityLevel _flexibilityFromString(String str) {
    switch (str) {
      case 'FlexibilityLevel.flexible':
        return FlexibilityLevel.flexible;
      case 'FlexibilityLevel.normal':
        return FlexibilityLevel.normal;
      case 'FlexibilityLevel.full':
        return FlexibilityLevel.full;
      default:
        return FlexibilityLevel.normal;
    }
  }
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

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'state': state,
      'schedule': schedule.map((activity) => activity.toJson()).toList(),
      'attractions': attractions.map((attraction) => attraction.toJson()).toList(),
      'transports': transports.map((transport) => transport.toJson()).toList(),
      'hotel': hotel?.toJson(),
      'totalCost': totalCost,
      'totalActivityTime': totalActivityTime.inMinutes,
      'restTime': restTime.inMinutes,
    };
  }

  // Fixed fromJson factory constructor
  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    return ItineraryDay(
      date: DateTime.parse(json['date']),
      state: json['state'],
      schedule: (json['schedule'] as List).map((activityJson) => ScheduledActivity.fromJson(activityJson)).toList(),
      attractions: (json['attractions'] as List).map((attractionJson) => Attraction.fromJson(attractionJson)).toList(),
      transports: (json['transports'] as List).map((transportJson) => Transport.fromJson(transportJson)).toList(),
      hotel: json['hotel'] != null ? Hotel.fromJson(json['hotel']) : null,
      totalCost: json['totalCost'].toDouble(),
      totalActivityTime: Duration(minutes: json['totalActivityTime'] ?? 0),
      restTime: Duration(minutes: json['restTime'] ?? 0),
    );
  }
}

class ScheduledActivity {
  final DateTime startTime;
  final DateTime endTime;
  final String activityType;
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

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'timeRange': timeRange,
      'title': title,
      'description': description,
      'location': location,
      'activityType': activityType,
      'cost': cost,
    };
  }

  // Fixed fromJson factory constructor
  factory ScheduledActivity.fromJson(Map<String, dynamic> json) {
    return ScheduledActivity(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      title: json['title'],
      description: json['description'],
      location: json['location'],
      activityType: json['activityType'],
      cost: json['cost']?.toDouble(),
    );
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

  Map<String, dynamic> toJson() {
    return {
      'days': days.map((day) => day.toJson()).toList(),
      'totalCost': totalCost,
      'isWithinBudget': isWithinBudget,
      'originalRequest': originalRequest.toJson(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  // Fixed fromJson factory constructor
  factory GeneratedItinerary.fromJson(Map<String, dynamic> json) {
    return GeneratedItinerary(
      days: (json['days'] as List).map((dayJson) => ItineraryDay.fromJson(dayJson)).toList(),
      totalCost: json['totalCost'].toDouble(),
      originalRequest: TripRequest.fromJson(json['originalRequest']),
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }
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
                bool withinBudget = true;

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

  Future<List<Attraction>> searchAttractionsOptimized({
    required List<String> states,
    required TripType tripType,
    required double maxPrice,
  }) async {
    try {
      print('=== ATTRACTION SEARCH (FIXED) ===');
      print('Searching states: $states');
      print('Trip type: $tripType');
      print('Max price: RM$maxPrice');

      List<Attraction> attractions = [];

      // USE GENERAL SEARCH INSTEAD OF OPTIMIZED QUERY
      final DatabaseReference attractionsRef = _database.child('Attractions');
      final DataSnapshot snapshot = await attractionsRef.get();

      if (!snapshot.exists) {
        print('❌ No attractions data in Firebase');
        return [];
      }

      Map<String, dynamic> allAttractions = Map<String, dynamic>.from(snapshot.value as Map);
      print('Total attractions in database: ${allAttractions.length}');

      for (String state in states) {
        String mappedState = _stateMapping[state] ?? state;
        print('\n--- Searching for: $state (mapped: $mappedState) ---');

        int found = 0;

        allAttractions.forEach((key, value) {
          if (value is Map) {
            Map<String, dynamic> attractionData = Map<String, dynamic>.from(value);

            String attractionState = attractionData['state']?.toString() ?? '';
            bool isHidden = attractionData['hide'] == true;

            // More flexible state matching
            bool stateMatches = false;
            if (attractionState.isNotEmpty) {
              stateMatches = attractionState.toLowerCase() == mappedState.toLowerCase() ||
                  attractionState.toLowerCase() == state.toLowerCase() ||
                  attractionState.toLowerCase().contains(mappedState.toLowerCase()) ||
                  mappedState.toLowerCase().contains(attractionState.toLowerCase());
            }

            if (stateMatches && !isHidden) {
              try {
                Attraction attraction = Attraction.fromMap(key, attractionData);

                // More lenient trip type filtering
                bool matchesTripType = true; // Default to true for mix
                if (tripType != TripType.mix) {
                  String targetType = tripType == TripType.adventure ? 'adventure' : 'chill';
                  matchesTripType = attraction.type.any((type) =>
                  type.toLowerCase().contains(targetType) ||
                      type.toLowerCase().contains('nature') ||
                      type.toLowerCase().contains('culture') ||
                      type.toLowerCase().contains('heritage')
                  );
                }

                // More lenient price filtering
                bool withinBudget = true;

                if (matchesTripType && withinBudget) {
                  attractions.add(attraction);
                  found++;
                  print('✅ Added: ${attraction.name} (${attraction.state}) - ${attraction.type.join(', ')}');
                }
              } catch (e) {
                print('❌ Error parsing attraction $key: $e');
              }
            }
          }
        });

        print('Found $found attractions for $state');
      }

      print('\n=== SEARCH COMPLETE ===');
      print('Total attractions found: ${attractions.length}');

      // Sort by price (free attractions first)
      attractions.sort((a, b) {
        double priceA = a.pricing.isNotEmpty ? a.pricing.first.price : 0;
        double priceB = b.pricing.isNotEmpty ? b.pricing.first.price : 0;
        return priceA.compareTo(priceB);
      });

      return attractions;
    } catch (e) {
      print('❌ Error in attraction search: $e');
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
class SmartItineraryGenerator {
  final FirebaseItineraryService _firebaseService = FirebaseItineraryService();

  Future<GeneratedItinerary?> generateItinerary(TripRequest request) async {
    try {
      print('=== SMART ITINERARY WITH DYNAMIC BUDGET ===');

      // Initial budget allocation
      Map<String, double> initialAllocation = _smartBudgetAllocation(request);
      SmartBudgetManager budgetManager = SmartBudgetManager(request.maxBudget, initialAllocation);

      // Optimize state order
      List<String> optimizedStates = _optimizeStateOrder(request.selectedStates, request.origin);

      // Pre-search all resources with generous budgets
      List<Hotel> availableHotels = await _firebaseService.searchHotels(
        states: optimizedStates,
        maxPricePerNight: request.maxBudget, // Use full budget for hotel search
        numberOfPax: request.numberOfPax,
      );

      List<Attraction> availableAttractions = await _firebaseService.searchAttractionsOptimized(
        states: optimizedStates,
        tripType: request.tripType,
        maxPrice: request.maxBudget, // Use full budget for attraction search
      );

      print('Found ${availableHotels.length} hotels, ${availableAttractions.length} attractions');

      // Generate itinerary with dynamic budget reallocation per day
      List<ItineraryDay> days = [];

      for (int i = 0; i < request.tripDuration; i++) {
        DateTime currentDate = request.checkInDate.add(Duration(days: i));
        String currentState = optimizedStates[i % optimizedStates.length];

        print('\n--- Day ${i + 1}: $currentState ---');
        print('Available budget: RM${budgetManager.getTotalRemaining().toStringAsFixed(2)}');

        ItineraryDay day = await _generateDayWithDynamicBudget(
          currentDate,
          currentState,
          availableHotels,
          availableAttractions,
          request,
          budgetManager,
          i,
          optimizedStates,
        );

        days.add(day);

        // Reallocate unused budget for remaining days
        if (i < request.tripDuration - 1) {
          budgetManager.reallocateUnusedBudget();
        }
      }

      double totalCost = budgetManager.getTotalSpent();

      print('\n=== FINAL BUDGET SUMMARY ===');
      print('Original budget: RM${request.maxBudget}');
      print('Total spent: RM${totalCost.toStringAsFixed(2)}');
      print('Remaining: RM${(request.maxBudget - totalCost).toStringAsFixed(2)}');
      print('Budget efficiency: ${((totalCost / request.maxBudget) * 100).toStringAsFixed(1)}%');

      return GeneratedItinerary(
        days: days,
        totalCost: totalCost,
        originalRequest: request,
        generatedAt: DateTime.now(),
      );

    } catch (e) {
      print('❌ Error generating dynamic itinerary: $e');
      return null;
    }
  }

  Future<ItineraryDay> _generateDayWithDynamicBudget(
      DateTime date,
      String state,
      List<Hotel> availableHotels,
      List<Attraction> availableAttractions,
      TripRequest request,
      SmartBudgetManager budgetManager,
      int dayIndex,
      List<String> optimizedStates,
      ) async {
    print('\n=== DYNAMIC DAY GENERATION: Day ${dayIndex + 1} - $state ===');

    double dailyHotelBudget = budgetManager.remainingBudget['hotel']! / (request.tripDuration - dayIndex);
    double dailyAttractionBudget = budgetManager.remainingBudget['attraction']! / (request.tripDuration - dayIndex);
    double dailyTransportBudget = budgetManager.remainingBudget['transport']! / (request.tripDuration - dayIndex);
    double dailyMealBudget = budgetManager.remainingBudget['meal']! / (request.tripDuration - dayIndex);

    print('Daily budgets - Hotel: RM${dailyHotelBudget.toStringAsFixed(2)}, Attractions: RM${dailyAttractionBudget.toStringAsFixed(2)}, Transport: RM${dailyTransportBudget.toStringAsFixed(2)}');

    // 1. SELECT HOTEL FIRST
    List<Transport> dayTransports = [];
    double actualTransportCost = 0;

    if (dayIndex == 0) {
      // FIRST DAY: Transport from origin to first destination
      print('First day: Searching transport from ${request.origin} to $state');

      List<Transport> originTransports = await _firebaseService.searchTransport(
        fromState: request.origin,
        toState: state,
        maxPrice: dailyTransportBudget * 2, // Allow higher budget for first day travel
      );

      if (originTransports.isNotEmpty) {
        Transport bestTransport = _selectBestTransport(originTransports, dailyTransportBudget);
        dayTransports.add(bestTransport);
        actualTransportCost = bestTransport.price * request.numberOfPax;
        budgetManager.recordSpending('transport', actualTransportCost);
        print('✅ First day transport selected: ${bestTransport.name} - RM$actualTransportCost');
      } else {
        print('⚠️ No transport found from ${request.origin} to $state');
        // For first day, we still need some transport cost even if none found in database
        // Assume a reasonable cost for planning purposes
        actualTransportCost = dailyTransportBudget * 0.5;
        budgetManager.recordSpending('transport', actualTransportCost);
        print('💡 Estimated transport cost: RM$actualTransportCost');
      }
    } else {
      // SUBSEQUENT DAYS: Transport between destination states
      String previousState = optimizedStates[(dayIndex - 1) % optimizedStates.length];
      if (previousState != state) {
        print('Day ${dayIndex + 1}: Searching transport from $previousState to $state');

        List<Transport> transports = await _firebaseService.searchTransport(
          fromState: previousState,
          toState: state,
          maxPrice: dailyTransportBudget * 2,
        );

        if (transports.isNotEmpty) {
          Transport bestTransport = _selectBestTransport(transports, dailyTransportBudget);
          dayTransports.add(bestTransport);
          actualTransportCost = bestTransport.price * request.numberOfPax;
          budgetManager.recordSpending('transport', actualTransportCost);
          print('✅ Transport selected: ${bestTransport.name} - RM$actualTransportCost');
        } else {
          print('⚠️ No transport found from $previousState to $state');
        }
      } else {
        print('Same state as previous day, no transport needed');
      }
    }

    double transportSavings = dailyTransportBudget - actualTransportCost;
    print('Transport savings: RM${transportSavings.toStringAsFixed(2)}');


    // 2. REALLOCATE HOTEL SAVINGS TO ATTRACTIONS
    print('\nSelecting hotel for Day ${dayIndex + 1} in $state');

    Hotel? selectedHotel = _selectBestHotelWithBudget(
      availableHotels,
      state,
      dailyHotelBudget,
      request.numberOfPax,
    );

    double actualHotelCost = 0;
    if (selectedHotel != null) {
      actualHotelCost = _getHotelPrice(selectedHotel, request.numberOfPax);
      budgetManager.recordSpending('hotel', actualHotelCost);
      print('✅ Hotel selected: ${selectedHotel.name} - RM$actualHotelCost');
    } else {
      print('❌ No suitable hotel found for $state within budget RM${dailyHotelBudget.toStringAsFixed(2)}');
      // Try with higher budget if available
      if (budgetManager.getTotalRemaining() > dailyHotelBudget) {
        selectedHotel = _selectBestHotelWithBudget(
          availableHotels,
          state,
          dailyHotelBudget * 1.5, // 50% higher budget
          request.numberOfPax,
        );
        if (selectedHotel != null) {
          actualHotelCost = _getHotelPrice(selectedHotel, request.numberOfPax);
          budgetManager.recordSpending('hotel', actualHotelCost);
          print('✅ Hotel selected with extended budget: ${selectedHotel.name} - RM$actualHotelCost');
        }
      }
    }

    double hotelSavings = dailyHotelBudget - actualHotelCost;
    print('Hotel savings: RM${hotelSavings.toStringAsFixed(2)}');

    // 3. SELECT TRANSPORT
    double enhancedAttractionBudget = dailyAttractionBudget + (hotelSavings * 0.6) + (transportSavings * 0.7);
    double enhancedMealBudget = dailyMealBudget + (hotelSavings * 0.4) + (transportSavings * 0.3);

    print('Enhanced budgets after reallocation:');
    print('- Attractions: RM${enhancedAttractionBudget.toStringAsFixed(2)} (was RM${dailyAttractionBudget.toStringAsFixed(2)})');
    print('- Meals: RM${enhancedMealBudget.toStringAsFixed(2)} (was RM${dailyMealBudget.toStringAsFixed(2)})');

    // 4. SELECT ATTRACTIONS WITH ENHANCED BUDGET
    List<Attraction> selectedAttractions = _selectAttractionsWithEnhancedBudget(
      availableAttractions,
      state,
      enhancedAttractionBudget,
      request.flexibility,
      request.tripType,
      request.numberOfPax,
    );

    double actualAttractionCost = selectedAttractions.fold(0, (sum, attraction) {
      double price = attraction.pricing.isNotEmpty ? attraction.pricing.first.price : 0;
      return sum + (price * request.numberOfPax);
    });
    budgetManager.recordSpending('attraction', actualAttractionCost);

    // 5. RECORD MEAL SPENDING
    budgetManager.recordSpending('meal', enhancedMealBudget);

    double totalDayCost = actualHotelCost + actualAttractionCost + actualTransportCost + enhancedMealBudget;

    // 6. GENERATE SCHEDULE
    List<ScheduledActivity> daySchedule = _generateScheduleWithFirstDay(
      date,
      selectedHotel,
      selectedAttractions,
      dayTransports,
      request.flexibility,
      dayIndex == 0,
      dayIndex == request.tripDuration - 1,
      enhancedMealBudget,
      hotelSavings > 50,
      request.origin, // Pass origin for first day
      state,
    );

    print('\n--- Day ${dayIndex + 1} Summary ---');
    print('Total cost: RM${totalDayCost.toStringAsFixed(2)}');
    print('- Transport: RM${actualTransportCost.toStringAsFixed(2)}');
    print('- Hotel: RM${actualHotelCost.toStringAsFixed(2)} (${selectedHotel?.name ?? 'None'})');
    print('- Attractions (${selectedAttractions.length}): RM${actualAttractionCost.toStringAsFixed(2)}');
    print('- Meals: RM${enhancedMealBudget.toStringAsFixed(2)}');
    if (selectedAttractions.isNotEmpty) {
      print('Attractions: ${selectedAttractions.map((a) => a.name).join(', ')}');
    }

    return ItineraryDay(
      date: date,
      state: state,
      hotel: selectedHotel,
      attractions: selectedAttractions,
      transports: dayTransports,
      totalCost: totalDayCost,
      totalActivityTime: Duration(hours: selectedAttractions.length * 2),
      restTime: _calculateRestTime(request.flexibility, Duration(hours: selectedAttractions.length * 2)),
      schedule: daySchedule,
    );
  }

  List<ScheduledActivity> _generateScheduleWithFirstDay(
      DateTime date,
      Hotel? hotel,
      List<Attraction> attractions,
      List<Transport> transports,
      FlexibilityLevel flexibility,
      bool isFirstDay,
      bool isLastDay,
      double mealBudget,
      bool hasPremiumBudget,
      String origin,
      String destination,
      ) {
    List<ScheduledActivity> schedule = [];
    DateTime currentTime = DateTime(date.year, date.month, date.day, 8, 0);

    if (isFirstDay) {
      print('\n=== FIRST DAY SCHEDULE GENERATION ===');
      print('Origin: $origin → Destination: $destination');

      // FIRST DAY: Start with transport from origin
      if (transports.isNotEmpty) {
        Transport originTransport = transports.first;

        // Determine travel time based on transport type
        Duration travelDuration;
        switch (originTransport.type.toLowerCase()) {
          case 'flight':
            travelDuration = Duration(hours: 2); // Including airport time
            break;
          case 'bus':
            travelDuration = Duration(hours: 4);
            break;
          case 'train':
            travelDuration = Duration(hours: 3);
            break;
          default:
            travelDuration = Duration(hours: 3);
        }

        DateTime travelEnd = currentTime.add(travelDuration);
        schedule.add(ScheduledActivity(
          startTime: currentTime,
          endTime: travelEnd,
          activityType: 'transport',
          title: 'Travel to $destination',
          description: 'Journey from $origin to $destination via ${originTransport.name}',
          location: 'From $origin to $destination',
          cost: originTransport.price,
        ));
        currentTime = travelEnd.add(Duration(minutes: 30)); // Buffer time

        print('✅ First day travel: ${originTransport.name} (${travelDuration.inHours}h)');
      } else {
        // Estimated travel time if no transport found
        Duration estimatedTravel = Duration(hours: 3);
        DateTime travelEnd = currentTime.add(estimatedTravel);
        schedule.add(ScheduledActivity(
          startTime: currentTime,
          endTime: travelEnd,
          activityType: 'transport',
          title: 'Travel to $destination',
          description: 'Journey from $origin to $destination',
          location: 'From $origin to $destination',
          cost: 0,
        ));
        currentTime = travelEnd.add(Duration(minutes: 30));

        print('💡 Estimated travel time: ${estimatedTravel.inHours}h');
      }

      // Arrival lunch (first meal in destination)
      if (currentTime.hour >= 11 && currentTime.hour <= 14) {
        String arrivalMeal = currentTime.hour <= 11 ? 'Late Breakfast' : 'Arrival Lunch';
        double mealCost = mealBudget * 0.3;

        schedule.add(ScheduledActivity(
          startTime: currentTime,
          endTime: currentTime.add(Duration(hours: 1)),
          activityType: 'meal',
          title: arrivalMeal,
          description: 'Welcome meal in $destination',
          location: 'Local restaurant',
          cost: mealCost,
        ));
        currentTime = currentTime.add(Duration(hours: 1));
      }
    } else {
      // SUBSEQUENT DAYS: Regular inter-state transport
      for (Transport transport in transports) {
        Duration travelTime = transport.type.toLowerCase() == 'flight'
            ? Duration(hours: 2)
            : Duration(hours: 3);

        DateTime transportEnd = currentTime.add(travelTime);
        schedule.add(ScheduledActivity(
          startTime: currentTime,
          endTime: transportEnd,
          activityType: 'transport',
          title: transport.name,
          description: 'Travel via ${transport.type}',
          location: transport.route,
          cost: transport.price,
        ));
        currentTime = transportEnd.add(Duration(minutes: 30));
      }
    }

    // HOTEL CHECK-IN (Every day including first day)
    if (hotel != null) {
      // Standard check-in time is 3 PM, but adjust based on arrival time
      DateTime checkInTime = DateTime(date.year, date.month, date.day, 15, 0);

      // If arriving late, allow immediate check-in
      if (currentTime.isAfter(checkInTime) || isFirstDay) {
        checkInTime = currentTime;
      }

      schedule.add(ScheduledActivity(
        startTime: checkInTime,
        endTime: checkInTime.add(Duration(minutes: 30)),
        activityType: 'checkin',
        title: 'Hotel Check-in',
        description: 'Check into ${hotel.name}',
        location: hotel.address,
      ));
      currentTime = checkInTime.add(Duration(minutes: 30));

      print('✅ Hotel check-in scheduled: ${hotel.name}');
    }

    // REST OF DAY ACTIVITIES
    if (attractions.isNotEmpty && currentTime.hour < 18) {
      // Afternoon/evening activities for first day
      int remainingAttractions = attractions.length;

      // If it's late in the day, reduce number of attractions
      if (currentTime.hour >= 15) {
        remainingAttractions = math.min(2, attractions.length);
        print('Late arrival - limiting to $remainingAttractions attractions');
      }

      for (int i = 0; i < remainingAttractions; i++) {
        Attraction attraction = attractions[i];
        Duration visitTime = isFirstDay && currentTime.hour >= 15
            ? Duration(hours: 1, minutes: 30) // Shorter visits on late arrival
            : _getAttractionsTime(flexibility);

        // Don't schedule too late
        if (currentTime.add(visitTime).hour > 19) break;

        schedule.add(ScheduledActivity(
          startTime: currentTime,
          endTime: currentTime.add(visitTime),
          activityType: 'attraction',
          title: attraction.name,
          description: attraction.description,
          location: attraction.address,
          cost: attraction.pricing.isNotEmpty ? attraction.pricing.first.price : 0,
        ));
        currentTime = currentTime.add(visitTime).add(Duration(minutes: 30));
      }
    }

    // DINNER
    if (currentTime.hour < 19) {
      currentTime = DateTime(date.year, date.month, date.day, 19, 0);
    }

    String dinnerDescription = isFirstDay
        ? 'Welcome dinner in $destination'
        : hasPremiumBudget
        ? 'Premium dining experience with local specialties'
        : 'Local dinner and evening leisure';

    double dinnerCost = mealBudget * (hasPremiumBudget ? 0.4 : 0.5);

    schedule.add(ScheduledActivity(
      startTime: currentTime,
      endTime: currentTime.add(Duration(hours: 2)),
      activityType: 'meal',
      title: 'Dinner',
      description: dinnerDescription,
      location: hasPremiumBudget ? 'Premium local restaurant' : 'Local restaurant',
      cost: dinnerCost,
    ));

    // HOTEL CHECK-OUT (Last day only)
    if (isLastDay && hotel != null) {
      DateTime checkOutTime = DateTime(date.year, date.month, date.day, 11, 0);
      schedule.add(ScheduledActivity(
        startTime: checkOutTime,
        endTime: checkOutTime.add(Duration(minutes: 30)),
        activityType: 'checkout',
        title: 'Hotel Check-out',
        description: 'Check out from ${hotel.name}',
        location: hotel.address,
      ));
    }

    schedule.sort((a, b) => a.startTime.compareTo(b.startTime));
    print('✅ Schedule generated with ${schedule.length} activities');

    return schedule;
  }

  // ENHANCED HOTEL SELECTION WITH BUDGET OPTIMIZATION
  Hotel? _selectBestHotelWithBudget(
      List<Hotel> hotels,
      String state,
      double budget,
      int numberOfPax,
      ) {
    print('\n=== HOTEL SELECTION FOR $state ===');
    print('Budget: RM${budget.toStringAsFixed(2)}, Pax: $numberOfPax');

    List<Hotel> stateHotels = hotels.where((hotel) {
      String hotelState = _extractStateFromHotel(hotel);
      bool matchesState = hotelState.toLowerCase() == state.toLowerCase() ||
          hotel.city.toLowerCase().contains(state.toLowerCase()) ||
          hotel.address.toLowerCase().contains(state.toLowerCase()) ||
          hotel.name.toLowerCase().contains(state.toLowerCase()); // Additional matching

      return matchesState;
    }).toList();

    print('Hotels found in $state: ${stateHotels.length}');

    if (stateHotels.isEmpty) {
      print('❌ No hotels found for $state');
      // Show available hotel locations for debugging
      print('Available hotel locations:');
      Set<String> locations = hotels.map((h) => _extractStateFromHotel(h)).toSet();
      print(locations.take(10).join(', '));
      return null;
    }

    // Show available hotels
    print('Available hotels:');
    for (var hotel in stateHotels.take(5)) {
      double price = _getHotelPrice(hotel, numberOfPax);
      print('- ${hotel.name}: RM$price (${hotel.city})');
    }

    // Filter by budget and categorize
    List<Hotel> budgetHotels = [];
    List<Hotel> midRangeHotels = [];
    List<Hotel> luxuryHotels = [];
    List<Hotel> overBudgetHotels = [];

    for (Hotel hotel in stateHotels) {
      double price = _getHotelPrice(hotel, numberOfPax);
      if (price <= budget * 0.6) {
        budgetHotels.add(hotel);
      } else if (price <= budget * 0.9) {
        midRangeHotels.add(hotel);
      } else if (price <= budget) {
        luxuryHotels.add(hotel);
      } else {
        overBudgetHotels.add(hotel);
      }
    }

    print('Categorized hotels:');
    print('- Budget (≤60%): ${budgetHotels.length}');
    print('- Mid-range (60-90%): ${midRangeHotels.length}');
    print('- Luxury (90-100%): ${luxuryHotels.length}');
    print('- Over budget: ${overBudgetHotels.length}');

    // Smart selection: prefer budget hotels to save money for attractions
    List<Hotel> preferredList = budgetHotels.isNotEmpty ? budgetHotels :
    midRangeHotels.isNotEmpty ? midRangeHotels :
    luxuryHotels.isNotEmpty ? luxuryHotels :
    overBudgetHotels; // Last resort

    if (preferredList.isEmpty) return null;

    // Sort by value (rating/price ratio)
    preferredList.sort((a, b) {
      double priceA = _getHotelPrice(a, numberOfPax);
      double priceB = _getHotelPrice(b, numberOfPax);
      double valueA = a.rating / (priceA + 1);
      double valueB = b.rating / (priceB + 1);
      return valueB.compareTo(valueA);
    });

    Hotel selected = preferredList.first;
    double selectedPrice = _getHotelPrice(selected, numberOfPax);
    print('✅ Selected: ${selected.name} - RM$selectedPrice');

    return selected;
  }

  // ENHANCED ATTRACTION SELECTION WITH DYNAMIC BUDGET
  List<Attraction> _selectAttractionsWithEnhancedBudget(
      List<Attraction> availableAttractions,
      String state,
      double enhancedBudget,
      FlexibilityLevel flexibility,
      TripType tripType,
      int numberOfPax,
      ) {
    print('\n=== ENHANCED ATTRACTION SELECTION ===');
    print('Enhanced budget: RM${enhancedBudget.toStringAsFixed(2)}');

    // Filter by state
    List<Attraction> stateAttractions = availableAttractions.where((attraction) {
      return attraction.state.toLowerCase() == state.toLowerCase() ||
          attraction.address.toLowerCase().contains(state.toLowerCase()) ||
          state.toLowerCase().contains(attraction.state.toLowerCase());
    }).toList();

    if (stateAttractions.isEmpty) return [];

    // Determine max attractions based on flexibility and budget
    int baseMaxAttractions = _getMaxAttractionsPerDay(flexibility);
    int enhancedMaxAttractions = enhancedBudget > 200 ? baseMaxAttractions + 1 : baseMaxAttractions;

    print('Base max attractions: $baseMaxAttractions, Enhanced max: $enhancedMaxAttractions');

    // Categorize attractions by price for better selection
    List<Attraction> freeAttractions = [];
    List<Attraction> lowCostAttractions = [];
    List<Attraction> midCostAttractions = [];
    List<Attraction> highCostAttractions = [];

    for (Attraction attraction in stateAttractions) {
      double price = attraction.pricing.isNotEmpty ? attraction.pricing.first.price : 0;
      if (price == 0) {
        freeAttractions.add(attraction);
      } else if (price <= 20) {
        lowCostAttractions.add(attraction);
      } else if (price <= 50) {
        midCostAttractions.add(attraction);
      } else {
        highCostAttractions.add(attraction);
      }
    }

    List<Attraction> selected = [];
    double currentCost = 0;

    // Smart selection strategy: mix free, low-cost, and some premium attractions
    List<List<Attraction>> priorityLists = [freeAttractions, lowCostAttractions, midCostAttractions, highCostAttractions];

    for (List<Attraction> priceCategory in priorityLists) {
      if (selected.length >= enhancedMaxAttractions) break;

      for (Attraction attraction in priceCategory) {
        if (selected.length >= enhancedMaxAttractions) break;

        double attractionCost = attraction.pricing.isNotEmpty
            ? attraction.pricing.first.price * numberOfPax
            : 0;

        if (currentCost + attractionCost <= enhancedBudget) {
          selected.add(attraction);
          currentCost += attractionCost;
          print('✅ Selected: ${attraction.name} - RM$attractionCost');
        }
      }
    }

    print('Final selection: ${selected.length} attractions, cost: RM${currentCost.toStringAsFixed(2)} / RM${enhancedBudget.toStringAsFixed(2)}');
    return selected;
  }

  // BETTER TRANSPORT SELECTION
  Transport _selectBestTransport(List<Transport> transports, double budget) {
    // Sort by value: balance price and speed/comfort
    transports.sort((a, b) {
      // Prioritize flights for long distance, then consider price
      if (a.type == 'Flight' && b.type != 'Flight' && budget > 100) return -1;
      if (a.type != 'Flight' && b.type == 'Flight' && budget > 100) return 1;
      return a.price.compareTo(b.price);
    });

    // Select the best option within budget, or closest to budget
    for (Transport transport in transports) {
      if (transport.price <= budget * 1.2) { // Allow 20% over budget for better transport
        return transport;
      }
    }

    return transports.first; // Fallback to cheapest
  }

  // Keep existing helper methods...
  String _extractStateFromHotel(Hotel hotel) {
    // [Previous implementation]
    String address = hotel.address.toLowerCase();
    String city = hotel.city.toLowerCase();

    Map<String, String> stateKeywords = {
      'kuala lumpur': 'Kuala Lumpur',
      'kl': 'Kuala Lumpur',
      'johor': 'Johor',
      'kedah': 'Kedah',
      'kelantan': 'Kelantan',
      'labuan': 'Labuan',
      'malacca': 'Malacca',
      'melaka': 'Malacca',
      'negeri sembilan': 'Negeri Sembilan',
      'pahang': 'Pahang',
      'penang': 'Penang',
      'perak': 'Perak',
      'perlis': 'Perlis',
      'putrajaya': 'Putrajaya',
      'sabah': 'Sabah',
      'sarawak': 'Sarawak',
      'selangor': 'Selangor',
      'terengganu': 'Terengganu',
    };

    for (String keyword in stateKeywords.keys) {
      if (address.contains(keyword) || city.contains(keyword)) {
        return stateKeywords[keyword]!;
      }
    }

    return hotel.city;
  }

  List<String> _optimizeStateOrder(Set<String> selectedStates, String origin) {
    List<String> states = selectedStates.toList();

    Map<String, List<String>> regions = {
      'North': ['Kedah', 'Penang', 'Perlis'],
      'Central': ['Kuala Lumpur', 'Selangor', 'Putrajaya'],
      'South': ['Johor', 'Malacca', 'Negeri Sembilan'],
      'East Coast': ['Kelantan', 'Terengganu', 'Pahang'],
      'East Malaysia': ['Sabah', 'Sarawak', 'Labuan'],
    };

    String originRegion = '';
    for (String region in regions.keys) {
      if (regions[region]!.contains(origin)) {
        originRegion = region;
        break;
      }
    }

    states.sort((a, b) {
      bool aInOriginRegion = regions[originRegion]?.contains(a) ?? false;
      bool bInOriginRegion = regions[originRegion]?.contains(b) ?? false;

      if (aInOriginRegion && !bInOriginRegion) return -1;
      if (!aInOriginRegion && bInOriginRegion) return 1;

      return 0;
    });

    return states;
  }

  Map<String, double> _smartBudgetAllocation(TripRequest request) {
    double totalBudget = request.maxBudget;

    // Base allocation that will be dynamically adjusted
    return {
      'hotel': totalBudget * 0.35,
      'attraction': totalBudget * 0.40,
      'transport': totalBudget * 0.15,
      'meal': totalBudget * 0.10,
    };
  }

  double _getHotelPrice(Hotel hotel, int numberOfPax) {
    if (hotel.roomTypes == null || hotel.roomTypes!.isEmpty) {
      return hotel.price;
    }

    var suitableRooms = hotel.roomTypes!.where((room) {
      String roomName = room['name'].toLowerCase();
      if (numberOfPax >= 4) return roomName.contains('family') || roomName.contains('penthouse') || roomName.contains('suite');
      if (numberOfPax == 3) return !roomName.contains('single');
      if (numberOfPax == 2) return !roomName.contains('single');
      return true;
    }).toList();

    if (suitableRooms.isEmpty) {
      suitableRooms = hotel.roomTypes!;
    }

    return suitableRooms.map((room) => room['price'] as double).reduce((a, b) => a < b ? a : b);
  }

  int _getMaxAttractionsPerDay(FlexibilityLevel flexibility) {
    switch (flexibility) {
      case FlexibilityLevel.full:
        return 4;
      case FlexibilityLevel.flexible:
        return 2;
      case FlexibilityLevel.normal:
      default:
        return 3;
    }
  }

  Duration _calculateRestTime(FlexibilityLevel flexibility, Duration activityTime) {
    switch (flexibility) {
      case FlexibilityLevel.full:
        return Duration(hours: 1);
      case FlexibilityLevel.flexible:
        return Duration(hours: 4);
      case FlexibilityLevel.normal:
      default:
        return Duration(hours: 2);
    }
  }

  Duration _getAttractionsTime(FlexibilityLevel flexibility) {
    switch (flexibility) {
      case FlexibilityLevel.full:
        return Duration(hours: 1, minutes: 30);
      case FlexibilityLevel.flexible:
        return Duration(hours: 3);
      case FlexibilityLevel.normal:
      default:
        return Duration(hours: 2, minutes: 30);
    }
  }
}

class SmartBudgetManager {
  Map<String, double> originalAllocation = {};
  Map<String, double> actualSpent = {};
  Map<String, double> remainingBudget = {};
  double totalBudget = 0;

  SmartBudgetManager(double budget, Map<String, double> allocation) {
    totalBudget = budget;
    originalAllocation = Map.from(allocation);
    actualSpent = {
      'hotel': 0,
      'attraction': 0,
      'transport': 0,
      'meal': 0,
    };
    remainingBudget = Map.from(allocation);
  }

  void recordSpending(String category, double amount) {
    actualSpent[category] = (actualSpent[category] ?? 0) + amount;
    remainingBudget[category] = (remainingBudget[category] ?? 0) - amount;
  }

  double getTotalRemaining() {
    return remainingBudget.values.fold(0, (sum, amount) => sum + amount);
  }

  double getTotalSpent() {
    return actualSpent.values.fold(0, (sum, amount) => sum + amount);
  }

  // Reallocate unused budget from one category to others
  void reallocateUnusedBudget() {
    double totalUnused = getTotalRemaining();
    print('\n=== BUDGET REALLOCATION ===');
    print('Total unused budget: RM${totalUnused.toStringAsFixed(2)}');

    if (totalUnused > 50) { // Only reallocate if significant amount left
      // Priority order for reallocation: attractions > hotel upgrade > transport upgrade > meals
      List<String> reallocationPriority = ['attraction', 'hotel', 'transport', 'meal'];

      for (String category in reallocationPriority) {
        if (totalUnused > 20) { // Minimum threshold for reallocation
          double extraAllocation = totalUnused * _getReallocationWeight(category);
          remainingBudget[category] = (remainingBudget[category] ?? 0) + extraAllocation;
          totalUnused -= extraAllocation;
          print('Allocated extra RM${extraAllocation.toStringAsFixed(2)} to $category');
        }
      }
    }
  }

  double _getReallocationWeight(String category) {
    switch (category) {
      case 'attraction': return 0.50; // 50% of unused goes to attractions
      case 'hotel': return 0.25; // 25% for hotel upgrades
      case 'transport': return 0.15; // 15% for better transport
      case 'meal': return 0.10; // 10% for meals
      default: return 0;
    }
  }
}

// REQUIREMENT-DRIVEN BUDGET SYSTEM
// Budget follows user requirements, not the other way around

class RequirementBasedItineraryGenerator {
  final FirebaseItineraryService _firebaseService = FirebaseItineraryService();
  final AttractionDistributionManager _attractionManager = AttractionDistributionManager();

  Future<GeneratedItinerary?> generateItinerary(TripRequest request) async {
    try {
      print('=== REQUIREMENT-DRIVEN ITINERARY GENERATION ===');
      print('User Requirements:');
      print('- States: ${request.selectedStates.join(', ')}');
      print('- Duration: ${request.tripDuration} days');
      print('- Pax: ${request.numberOfPax}');
      print('- Trip Type: ${request.tripType}');
      print('- Flexibility: ${request.flexibility}');
      print('- Stated Budget: RM${request.maxBudget}');

      // Step 1: Generate IDEAL itinerary with proper attraction distribution
      IdealItinerary idealItinerary = await _generateIdealItineraryWithUniqueAttractions(request);

      // Step 2: Calculate what this ACTUALLY costs
      double actualCostNeeded = idealItinerary.totalCost;

      print('\n=== COST ANALYSIS ===');
      print('Ideal itinerary cost: RM${actualCostNeeded.toStringAsFixed(2)}');
      print('User budget: RM${request.maxBudget}');
      print('Difference: RM${(actualCostNeeded - request.maxBudget).toStringAsFixed(2)}');

      // Step 3: Decide strategy based on budget vs requirements
      if (actualCostNeeded <= request.maxBudget * 1.1) {
        print('✅ Requirements fit within budget! Generating ideal itinerary...');
        return await _buildFinalItinerary(idealItinerary, request);
      } else if (actualCostNeeded <= request.maxBudget * 1.5) {
        print('⚠️ Requirements exceed budget by ${((actualCostNeeded/request.maxBudget - 1) * 100).toStringAsFixed(0)}%');
        return await _generateOptimizedItinerary(idealItinerary, request);
      } else {
        print('❌ Requirements exceed budget significantly. Showing alternatives...');
        return await _generateAlternativeItinerary(idealItinerary, request);
      }

    } catch (e) {
      print('❌ Error generating requirement-driven itinerary: $e');
      return null;
    }
  }

  // Generate ideal itinerary with unique attractions per day
  Future<IdealItinerary> _generateIdealItineraryWithUniqueAttractions(TripRequest request) async {
    print('\n=== GENERATING IDEAL ITINERARY WITH UNIQUE ATTRACTIONS ===');

    // Optimize state order for travel efficiency
    List<String> optimizedStates = _optimizeStateOrder(request.selectedStates, request.origin);

    // Smart allocation of days to states
    List<DayStateAllocation> dayAllocations = SmartStateAllocation.allocateStatesAcrossDays(
        optimizedStates,
        request.tripDuration,
        request.origin
    );

    // Search ALL available options (no budget filter)
    List<Hotel> allHotels = await _firebaseService.searchHotels(
      states: optimizedStates,
      maxPricePerNight: 99999,
      numberOfPax: request.numberOfPax,
    );

    List<Attraction> allAttractions = await _firebaseService.searchAttractionsOptimized(
      states: optimizedStates,
      tripType: request.tripType,
      maxPrice: 99999,
    );

    print('Found ${allHotels.length} hotels, ${allAttractions.length} attractions (no budget filter)');

    // Initialize attraction manager for each state
    for (String state in optimizedStates) {
      List<Attraction> stateAttractions = allAttractions.where((attraction) {
        return attraction.state.toLowerCase() == state.toLowerCase() ||
            attraction.address.toLowerCase().contains(state.toLowerCase());
      }).toList();

      _attractionManager.initializeState(state, stateAttractions);
    }

    List<IdealDay> idealDays = [];
    double totalCost = 0;

    for (DayStateAllocation dayAllocation in dayAllocations) {
      DateTime currentDate = request.checkInDate.add(Duration(days: dayAllocation.dayIndex));

      print('\n--- Ideal Day ${dayAllocation.dayIndex + 1}: ${dayAllocation.state} (Day ${dayAllocation.dayInState}/${dayAllocation.totalDaysInState}) ---');

      IdealDay day = await _generateIdealDayWithUniqueAttractions(
        currentDate,
        dayAllocation,
        allHotels,
        request,
        dayAllocations,
      );

      idealDays.add(day);
      totalCost += day.totalCost;

      print('Ideal day cost: RM${day.totalCost.toStringAsFixed(2)}');
      print('Unique attractions selected: ${day.attractions.map((a) => a.name).join(', ')}');
    }

    return IdealItinerary(
      days: idealDays,
      totalCost: totalCost,
      originalRequest: request,
    );
  }

  // Generate single ideal day with unique attraction selection
  Future<IdealDay> _generateIdealDayWithUniqueAttractions(
      DateTime date,
      DayStateAllocation dayAllocation,
      List<Hotel> allHotels,
      TripRequest request,
      List<DayStateAllocation> allAllocations,
      ) async {

    String state = dayAllocation.state;

    // 1. TRANSPORT LOGIC (only on first day in state or moving between states)
    List<Transport> dayTransports = [];
    double transportCost = 0;

    if (dayAllocation.dayIndex == 0) {
      // Very first day: origin to first destination
      List<Transport> originTransports = await _firebaseService.searchTransport(
        fromState: request.origin,
        toState: state,
        maxPrice: 99999,
      );

      if (originTransports.isNotEmpty) {
        Transport bestTransport = _selectBestQualityTransport(originTransports);
        dayTransports.add(bestTransport);
        transportCost = bestTransport.price * request.numberOfPax;
        print('✅ First day transport: ${bestTransport.name} - RM$transportCost');
      }
    } else if (dayAllocation.isFirstDayInState) {
      // First day in a new state (not origin)
      DayStateAllocation previousDay = allAllocations[dayAllocation.dayIndex - 1];
      String previousState = previousDay.state;

      if (previousState != state) {
        List<Transport> transports = await _firebaseService.searchTransport(
          fromState: previousState,
          toState: state,
          maxPrice: 99999,
        );

        if (transports.isNotEmpty) {
          Transport bestTransport = _selectBestQualityTransport(transports);
          dayTransports.add(bestTransport);
          transportCost = bestTransport.price * request.numberOfPax;
          print('✅ Inter-state transport: ${bestTransport.name} - RM$transportCost');
        }
      }
    } else {
      // Subsequent days in same state - no transport needed
      print('✅ Same state continuation - no transport needed');
    }

    // 2. HOTEL LOGIC (same hotel for consecutive days in same state)
    Hotel? selectedHotel;
    double hotelCost = 0;

    if (dayAllocation.isFirstDayInState) {
      // Select hotel for the entire stay in this state
      selectedHotel = _selectBestQualityHotel(allHotels, state, request.numberOfPax);
      hotelCost = selectedHotel != null ? _getHotelPrice(selectedHotel, request.numberOfPax) : 0;
      print('✅ Hotel for ${dayAllocation.totalDaysInState} days: ${selectedHotel?.name} - RM$hotelCost/night');
    } else {
      // Use same hotel as previous day - cost will be calculated later
      selectedHotel = null; // Will be resolved in final itinerary
      hotelCost = 0; // Will be calculated in final itinerary
    }

    // 3. ATTRACTION LOGIC - USE ATTRACTION MANAGER FOR UNIQUE SELECTION
    List<Attraction> dayAttractions = _attractionManager.getAttractionsForDay(
      state,
      dayAllocation,
      request,
    );

    double attractionCost = dayAttractions.fold(0, (sum, attraction) {
      double price = attraction.pricing.isNotEmpty ? attraction.pricing.first.price : 0;
      return sum + (price * request.numberOfPax);
    });

    // 4. MEAL COSTS
    double mealCost = _calculateOptimalMealCost(request.tripType, request.numberOfPax);

    // Adjust for longer stays
    if (dayAllocation.totalDaysInState > 1) {
      if (dayAllocation.dayInState == 1) {
        mealCost *= 1.1; // Welcome day
      } else if (dayAllocation.dayInState == dayAllocation.totalDaysInState) {
        mealCost *= 1.1; // Farewell day
      } else {
        mealCost *= 0.9; // Regular day
      }
    }

    double totalDayCost = transportCost + hotelCost + attractionCost + mealCost;

    return IdealDay(
      date: date,
      state: state,
      hotel: selectedHotel,
      attractions: dayAttractions,
      transports: dayTransports,
      transportCost: transportCost,
      hotelCost: hotelCost,
      attractionCost: attractionCost,
      mealCost: mealCost,
      totalCost: totalDayCost,
      dayAllocation: dayAllocation,
    );
  }

  // Build final itinerary ensuring hotel consistency
  Future<GeneratedItinerary> _buildFinalItinerary(IdealItinerary idealItinerary, TripRequest request) async {
    print('\n=== BUILDING FINAL ITINERARY WITH UNIQUE ATTRACTIONS ===');

    List<ItineraryDay> finalDays = [];

    // Track hotels by state for consistency
    Map<String, Hotel?> hotelsByState = {};

    // First pass: establish hotels for each state
    for (IdealDay idealDay in idealItinerary.days) {
      if (idealDay.dayAllocation!.isFirstDayInState && idealDay.hotel != null) {
        hotelsByState[idealDay.state] = idealDay.hotel;
        print('Established hotel for ${idealDay.state}: ${idealDay.hotel!.name}');
      }
    }

    // Second pass: build final days with consistent hotels
    for (int i = 0; i < idealItinerary.days.length; i++) {
      IdealDay idealDay = idealItinerary.days[i];

      // Use consistent hotel for this state
      Hotel? dayHotel = hotelsByState[idealDay.state];

      // Calculate hotel cost for this day
      double dayHotelCost = 0;
      if (dayHotel != null) {
        dayHotelCost = _getHotelPrice(dayHotel, request.numberOfPax);
      }

      // Generate schedule for this day
      List<ScheduledActivity> schedule = _generateConsecutiveDaySchedule(
        idealDay.date,
        dayHotel,
        idealDay.attractions,
        idealDay.transports,
        request.flexibility,
        i == 0, // isFirstDay of trip
        i == idealItinerary.days.length - 1, // isLastDay of trip
        idealDay.dayAllocation!.isFirstDayInState,
        idealDay.dayAllocation!.isLastDayInState,
        idealDay.mealCost,
        request.origin,
        idealDay.state,
      );

      // Recalculate total cost with consistent hotel
      double finalDayCost = idealDay.transportCost + dayHotelCost + idealDay.attractionCost + idealDay.mealCost;

      ItineraryDay finalDay = ItineraryDay(
        date: idealDay.date,
        state: idealDay.state,
        hotel: dayHotel,
        attractions: idealDay.attractions,
        transports: idealDay.transports,
        totalCost: finalDayCost,
        totalActivityTime: Duration(hours: idealDay.attractions.length * 2),
        restTime: _calculateRestTime(request.flexibility, Duration(hours: idealDay.attractions.length * 2)),
        schedule: schedule,
      );

      finalDays.add(finalDay);

      print('Final Day ${i + 1}: ${idealDay.state} - ${idealDay.attractions.map((a) => a.name).join(', ')}');
    }

    double finalTotalCost = finalDays.fold(0, (sum, day) => sum + day.totalCost);

    return GeneratedItinerary(
      days: finalDays,
      totalCost: finalTotalCost,
      originalRequest: request,
      generatedAt: DateTime.now(),
    );
  }

  // Generate schedule that handles consecutive days properly
  List<ScheduledActivity> _generateConsecutiveDaySchedule(
      DateTime date,
      Hotel? hotel,
      List<Attraction> attractions,
      List<Transport> transports,
      FlexibilityLevel flexibility,
      bool isFirstDayOfTrip,
      bool isLastDayOfTrip,
      bool isFirstDayInState,
      bool isLastDayInState,
      double mealBudget,
      String origin,
      String destination,
      ) {
    List<ScheduledActivity> schedule = [];
    DateTime currentTime = DateTime(date.year, date.month, date.day, 8, 0);

    print('\n=== GENERATING SCHEDULE ===');
    print('Date: ${date.day}/${date.month}/${date.year}');
    print('First day of trip: $isFirstDayOfTrip');
    print('First day in $destination: $isFirstDayInState');
    print('Last day in $destination: $isLastDayInState');
    print('Last day of trip: $isLastDayOfTrip');

    // TRANSPORT (only on travel days)
    if (transports.isNotEmpty) {
      for (Transport transport in transports) {
        Duration travelTime = transport.type.toLowerCase() == 'flight'
            ? Duration(hours: 2)
            : Duration(hours: 3);

        String travelTitle = isFirstDayOfTrip
            ? 'Travel from $origin to $destination'
            : 'Travel to $destination';

        String travelDescription = isFirstDayOfTrip
            ? 'Journey from $origin to $destination via ${transport.name}'
            : 'Inter-state travel via ${transport.name}';

        schedule.add(ScheduledActivity(
          startTime: currentTime,
          endTime: currentTime.add(travelTime),
          activityType: 'transport',
          title: travelTitle,
          description: travelDescription,
          location: isFirstDayOfTrip ? 'From $origin to $destination' : transport.route,
          cost: transport.price,
        ));
        currentTime = currentTime.add(travelTime).add(Duration(minutes: 30));
        print('✅ Travel scheduled: $travelTime duration');
      }
    }

    // HOTEL CHECK-IN (only on first day in state)
    if (hotel != null && isFirstDayInState) {
      DateTime checkInTime = DateTime(date.year, date.month, date.day, 15, 0);

      // If arriving late due to travel, allow immediate check-in
      if (currentTime.isAfter(checkInTime) || isFirstDayOfTrip) {
        checkInTime = currentTime;
      }

      schedule.add(ScheduledActivity(
        startTime: checkInTime,
        endTime: checkInTime.add(Duration(minutes: 30)),
        activityType: 'checkin',
        title: 'Hotel Check-in',
        description: 'Check into ${hotel.name}',
        location: hotel.address,
      ));
      currentTime = checkInTime.add(Duration(minutes: 30));
      print('✅ Check-in scheduled at ${hotel.name}');
    }

    // MEALS AND ATTRACTIONS
    if (attractions.isNotEmpty) {
      // Breakfast/Brunch (if early enough)
      if (currentTime.hour <= 11) {
        String mealTitle = isFirstDayOfTrip
            ? 'Welcome Breakfast in $destination'
            : isFirstDayInState
            ? 'Arrival Brunch'
            : 'Breakfast';

        schedule.add(ScheduledActivity(
          startTime: currentTime,
          endTime: currentTime.add(Duration(hours: 1)),
          activityType: 'meal',
          title: mealTitle,
          description: 'Local breakfast experience',
          location: 'Local restaurant',
          cost: mealBudget * 0.25,
        ));
        currentTime = currentTime.add(Duration(hours: 1));
        print('✅ Breakfast scheduled');
      }

      // Morning attractions
      int morningAttractions = (attractions.length / 2).ceil();
      for (int i = 0; i < morningAttractions; i++) {
        Attraction attraction = attractions[i];
        Duration visitTime = _getAttractionVisitTime(flexibility);

        schedule.add(ScheduledActivity(
          startTime: currentTime,
          endTime: currentTime.add(visitTime),
          activityType: 'attraction',
          title: attraction.name,
          description: attraction.description,
          location: attraction.address,
          cost: attraction.pricing.isNotEmpty ? attraction.pricing.first.price : 0,
        ));
        currentTime = currentTime.add(visitTime).add(Duration(minutes: 30));
        print('✅ Morning attraction: ${attraction.name}');
      }

      // Lunch
      if (currentTime.hour >= 12 && currentTime.hour <= 15) {
        schedule.add(ScheduledActivity(
          startTime: currentTime,
          endTime: currentTime.add(Duration(hours: 1, minutes: 30)),
          activityType: 'meal',
          title: 'Lunch',
          description: 'Local cuisine experience',
          location: 'Local restaurant',
          cost: mealBudget * 0.35,
        ));
        currentTime = currentTime.add(Duration(hours: 1, minutes: 30));
        print('✅ Lunch scheduled');
      }

      // Afternoon rest (for multi-day stays or flexible schedule)
      if (!isFirstDayInState && !isLastDayInState && flexibility == FlexibilityLevel.flexible) {
        schedule.add(ScheduledActivity(
          startTime: currentTime,
          endTime: currentTime.add(Duration(hours: 1)),
          activityType: 'rest',
          title: 'Afternoon Rest',
          description: 'Relaxation time at hotel',
          location: hotel?.name ?? 'Hotel',
        ));
        currentTime = currentTime.add(Duration(hours: 1));
        print('✅ Afternoon rest (consecutive day benefit)');
      }

      // Afternoon attractions
      for (int i = morningAttractions; i < attractions.length; i++) {
        Attraction attraction = attractions[i];
        Duration visitTime = _getAttractionVisitTime(flexibility);

        // Don't schedule too late
        if (currentTime.add(visitTime).hour > 18) break;

        schedule.add(ScheduledActivity(
          startTime: currentTime,
          endTime: currentTime.add(visitTime),
          activityType: 'attraction',
          title: attraction.name,
          description: attraction.description,
          location: attraction.address,
          cost: attraction.pricing.isNotEmpty ? attraction.pricing.first.price : 0,
        ));
        currentTime = currentTime.add(visitTime).add(Duration(minutes: 30));
        print('✅ Afternoon attraction: ${attraction.name}');
      }

      // Dinner
      if (currentTime.hour < 19) {
        currentTime = DateTime(date.year, date.month, date.day, 19, 0);
      }

      String dinnerTitle = 'Dinner';
      String dinnerDescription = 'Local dinner experience';

      if (isFirstDayOfTrip) {
        dinnerTitle = 'Welcome Dinner in $destination';
        dinnerDescription = 'Welcome dinner featuring local specialties';
      } else if (isLastDayInState) {
        dinnerTitle = 'Farewell Dinner in $destination';
        dinnerDescription = 'Farewell dinner with local highlights';
      } else if (isLastDayOfTrip) {
        dinnerTitle = 'Final Dinner';
        dinnerDescription = 'Memorable final dinner of the trip';
      }

      schedule.add(ScheduledActivity(
        startTime: currentTime,
        endTime: currentTime.add(Duration(hours: 2)),
        activityType: 'meal',
        title: dinnerTitle,
        description: dinnerDescription,
        location: 'Local restaurant',
        cost: mealBudget * 0.4,
      ));
      print('✅ Dinner scheduled: $dinnerTitle');
    }

    // HOTEL CHECK-OUT (only on last day in state)
    if (hotel != null && isLastDayInState) {
      DateTime checkOutTime = DateTime(date.year, date.month, date.day, 11, 0);

      // Only add check-out if not already in schedule
      bool hasCheckOut = schedule.any((activity) => activity.activityType == 'checkout');
      if (!hasCheckOut) {
        schedule.add(ScheduledActivity(
          startTime: checkOutTime,
          endTime: checkOutTime.add(Duration(minutes: 30)),
          activityType: 'checkout',
          title: 'Hotel Check-out',
          description: 'Check out from ${hotel.name}',
          location: hotel.address,
        ));
        print('✅ Check-out scheduled from ${hotel.name}');
      }
    }

    schedule.sort((a, b) => a.startTime.compareTo(b.startTime));
    print('Total activities scheduled: ${schedule.length}');

    return schedule;
  }

  Duration _getAttractionVisitTime(FlexibilityLevel flexibility) {
    switch (flexibility) {
      case FlexibilityLevel.full:
        return Duration(hours: 1, minutes: 30);
      case FlexibilityLevel.flexible:
        return Duration(hours: 3);
      case FlexibilityLevel.normal:
      default:
        return Duration(hours: 2, minutes: 30);
    }
  }

  // Helper methods
  List<String> _optimizeStateOrder(Set<String> selectedStates, String origin) {
    List<String> states = selectedStates.toList();

    Map<String, List<String>> regions = {
      'North': ['Kedah', 'Penang', 'Perlis'],
      'Central': ['Kuala Lumpur', 'Selangor', 'Putrajaya'],
      'South': ['Johor', 'Malacca', 'Negeri Sembilan'],
      'East Coast': ['Kelantan', 'Terengganu', 'Pahang'],
      'East Malaysia': ['Sabah', 'Sarawak', 'Labuan'],
    };

    String originRegion = '';
    for (String region in regions.keys) {
      if (regions[region]!.contains(origin)) {
        originRegion = region;
        break;
      }
    }

    states.sort((a, b) {
      bool aInOriginRegion = regions[originRegion]?.contains(a) ?? false;
      bool bInOriginRegion = regions[originRegion]?.contains(b) ?? false;

      if (aInOriginRegion && !bInOriginRegion) return -1;
      if (!aInOriginRegion && bInOriginRegion) return 1;

      return 0;
    });

    return states;
  }

  Transport _selectBestQualityTransport(List<Transport> transports) {
    transports.sort((a, b) {
      if (a.type.toLowerCase() == 'flight' && b.type.toLowerCase() != 'flight') return -1;
      if (a.type.toLowerCase() != 'flight' && b.type.toLowerCase() == 'flight') return 1;

      if (a.name.toLowerCase().contains('express') && !b.name.toLowerCase().contains('express')) return -1;
      if (!a.name.toLowerCase().contains('express') && b.name.toLowerCase().contains('express')) return 1;

      return a.price.compareTo(b.price);
    });

    return transports.first;
  }

  Hotel? _selectBestQualityHotel(List<Hotel> hotels, String state, int numberOfPax) {
    List<Hotel> stateHotels = hotels.where((hotel) {
      String hotelState = _extractStateFromHotel(hotel);
      return hotelState.toLowerCase() == state.toLowerCase() ||
          hotel.city.toLowerCase().contains(state.toLowerCase()) ||
          hotel.address.toLowerCase().contains(state.toLowerCase());
    }).toList();

    if (stateHotels.isEmpty) return null;

    stateHotels.sort((a, b) {
      int ratingComparison = b.rating.compareTo(a.rating);
      if (ratingComparison != 0) return ratingComparison;

      double priceA = _getHotelPrice(a, numberOfPax);
      double priceB = _getHotelPrice(b, numberOfPax);
      return priceA.compareTo(priceB);
    });

    return stateHotels.first;
  }

  double _calculateOptimalMealCost(TripType tripType, int numberOfPax) {
    double baseCostPerPerson = 60.0;

    switch (tripType) {
      case TripType.adventure:
        baseCostPerPerson = 50.0;
        break;
      case TripType.chill:
        baseCostPerPerson = 80.0;
        break;
      case TripType.mix:
        baseCostPerPerson = 60.0;
        break;
    }

    return baseCostPerPerson * numberOfPax;
  }

  String _extractStateFromHotel(Hotel hotel) {
    String address = hotel.address.toLowerCase();
    String city = hotel.city.toLowerCase();

    Map<String, String> stateKeywords = {
      'kuala lumpur': 'Kuala Lumpur',
      'kl': 'Kuala Lumpur',
      'johor': 'Johor',
      'kedah': 'Kedah',
      'kelantan': 'Kelantan',
      'labuan': 'Labuan',
      'malacca': 'Malacca',
      'melaka': 'Malacca',
      'negeri sembilan': 'Negeri Sembilan',
      'pahang': 'Pahang',
      'penang': 'Penang',
      'perak': 'Perak',
      'perlis': 'Perlis',
      'putrajaya': 'Putrajaya',
      'sabah': 'Sabah',
      'sarawak': 'Sarawak',
      'selangor': 'Selangor',
      'terengganu': 'Terengganu',
    };

    for (String keyword in stateKeywords.keys) {
      if (address.contains(keyword) || city.contains(keyword)) {
        return stateKeywords[keyword]!;
      }
    }

    return hotel.city;
  }

  double _getHotelPrice(Hotel hotel, int numberOfPax) {
    if (hotel.roomTypes == null || hotel.roomTypes!.isEmpty) {
      return hotel.price;
    }

    var suitableRooms = hotel.roomTypes!.where((room) {
      String roomName = room['name'].toLowerCase();
      if (numberOfPax >= 4) return roomName.contains('family') || roomName.contains('penthouse') || roomName.contains('suite');
      if (numberOfPax == 3) return !roomName.contains('single');
      if (numberOfPax == 2) return !roomName.contains('single');
      return true;
    }).toList();

    if (suitableRooms.isEmpty) {
      suitableRooms = hotel.roomTypes!;
    }

    return suitableRooms.map((room) => room['price'] as double).reduce((a, b) => a < b ? a : b);
  }

  Duration _calculateRestTime(FlexibilityLevel flexibility, Duration activityTime) {
    switch (flexibility) {
      case FlexibilityLevel.full:
        return Duration(hours: 1);
      case FlexibilityLevel.flexible:
        return Duration(hours: 4);
      case FlexibilityLevel.normal:
      default:
        return Duration(hours: 2);
    }
  }

  // Placeholder methods for optimization and alternatives
  Future<GeneratedItinerary> _generateOptimizedItinerary(IdealItinerary idealItinerary, TripRequest request) async {
    return await _buildFinalItinerary(idealItinerary, request);
  }

  Future<GeneratedItinerary> _generateAlternativeItinerary(IdealItinerary idealItinerary, TripRequest request) async {
    return await _buildFinalItinerary(idealItinerary, request);
  }
}

// SUPPORTING DATA CLASSES

class IdealItinerary {
  final List<IdealDay> days;
  final double totalCost;
  final TripRequest originalRequest;

  IdealItinerary({
    required this.days,
    required this.totalCost,
    required this.originalRequest,
  });
}

class IdealDay {
  final DateTime date;
  final String state;
  final Hotel? hotel;
  final List<Attraction> attractions;
  final List<Transport> transports;
  final double transportCost;
  final double hotelCost;
  final double attractionCost;
  final double mealCost;
  final double totalCost;
  final DayStateAllocation? dayAllocation;

  IdealDay({
    required this.date,
    required this.state,
    this.hotel,
    required this.attractions,
    required this.transports,
    required this.transportCost,
    required this.hotelCost,
    required this.attractionCost,
    required this.mealCost,
    required this.totalCost,
    this.dayAllocation,
  });
}

// UPDATE YOUR MAIN ITINERARY GENERATOR TO USE THE NEW SYSTEM
class ItineraryGenerator {
  final RequirementBasedItineraryGenerator _requirementGenerator = RequirementBasedItineraryGenerator();

  Future<GeneratedItinerary?> generateItinerary(TripRequest request) async {
    return await _requirementGenerator.generateItinerary(request);
  }

  // Optional: Keep some legacy methods for compatibility if needed
  Future<GeneratedItinerary?> modifyItinerary(
      GeneratedItinerary currentItinerary,
      int dayIndex,
      {Hotel? newHotel, List<Attraction>? newAttractions}
      ) async {
    // This would need to be implemented with the new system
    // For now, return null to indicate modification not supported
    print('Itinerary modification not yet implemented in new system');
    return null;
  }
}

class SmartStateAllocation {
  static List<DayStateAllocation> allocateStatesAcrossDays(
      List<String> optimizedStates,
      int totalDays,
      String origin
      ) {
    print('\n=== SMART STATE ALLOCATION ===');
    print('States: ${optimizedStates.join(', ')}');
    print('Total days: $totalDays');

    List<DayStateAllocation> allocation = [];

    if (totalDays <= optimizedStates.length) {
      // Simple case: one day per state or fewer days than states
      for (int i = 0; i < totalDays; i++) {
        allocation.add(DayStateAllocation(
          dayIndex: i,
          state: optimizedStates[i],
          dayInState: 1,
          totalDaysInState: 1,
          isFirstDayInState: true,
          isLastDayInState: true,
        ));
      }
    } else {
      // Complex case: more days than states - need to distribute smartly
      allocation = _distributeConsecutiveDays(optimizedStates, totalDays);
    }

    print('\n--- STATE ALLOCATION RESULT ---');
    for (var day in allocation) {
      print('Day ${day.dayIndex + 1}: ${day.state} (Day ${day.dayInState}/${day.totalDaysInState})');
    }

    return allocation;
  }

  static List<DayStateAllocation> _distributeConsecutiveDays(
      List<String> states,
      int totalDays
      ) {
    List<DayStateAllocation> allocation = [];

    // Calculate how many days each state should get
    int baseDays = totalDays ~/ states.length; // Base days per state
    int extraDays = totalDays % states.length; // Extra days to distribute

    print('Base days per state: $baseDays, Extra days to distribute: $extraDays');

    // Determine days per state
    List<int> daysPerState = [];
    for (int i = 0; i < states.length; i++) {
      int stateDays = baseDays;
      if (i < extraDays) {
        stateDays += 1; // Distribute extra days to first few states
      }
      daysPerState.add(stateDays);
    }

    print('Days per state: $daysPerState');

    // Create allocation
    int currentDay = 0;
    for (int stateIndex = 0; stateIndex < states.length; stateIndex++) {
      String state = states[stateIndex];
      int totalDaysInThisState = daysPerState[stateIndex];

      for (int dayInState = 1; dayInState <= totalDaysInThisState; dayInState++) {
        allocation.add(DayStateAllocation(
          dayIndex: currentDay,
          state: state,
          dayInState: dayInState,
          totalDaysInState: totalDaysInThisState,
          isFirstDayInState: dayInState == 1,
          isLastDayInState: dayInState == totalDaysInThisState,
        ));
        currentDay++;
      }
    }

    return allocation;
  }
}

class DayStateAllocation {
  final int dayIndex;
  final String state;
  final int dayInState; // Which day in this state (1, 2, 3...)
  final int totalDaysInState; // Total days staying in this state
  final bool isFirstDayInState;
  final bool isLastDayInState;

  DayStateAllocation({
    required this.dayIndex,
    required this.state,
    required this.dayInState,
    required this.totalDaysInState,
    required this.isFirstDayInState,
    required this.isLastDayInState,
  });
}

class AttractionDistributionManager {
  Map<String, List<Attraction>> usedAttractionsByState = {};
  Map<String, List<Attraction>> availableAttractionsByState = {};

  void initializeState(String state, List<Attraction> allAttractions) {
    usedAttractionsByState[state] = [];
    availableAttractionsByState[state] = List.from(allAttractions);
    print('Initialized $state with ${allAttractions.length} attractions');
  }

  List<Attraction> getAttractionsForDay(
      String state,
      DayStateAllocation dayAllocation,
      TripRequest request,
      ) {
    print('\n=== SELECTING ATTRACTIONS FOR $state DAY ${dayAllocation.dayInState}/${dayAllocation.totalDaysInState} ===');

    List<Attraction> available = availableAttractionsByState[state] ?? [];
    List<Attraction> used = usedAttractionsByState[state] ?? [];

    print('Available attractions: ${available.length}');
    print('Already used: ${used.map((a) => a.name).join(', ')}');

    if (available.isEmpty) {
      print('❌ No more attractions available for $state');
      return [];
    }

    int attractionsNeeded = _getOptimalAttractionCount(request.flexibility, request.tripType);

    // Strategy based on day number in state
    List<Attraction> selectedForDay = _selectByDayStrategy(
      available,
      dayAllocation,
      attractionsNeeded,
      request.tripType,
    );

    // Mark selected attractions as used
    for (Attraction attraction in selectedForDay) {
      availableAttractionsByState[state]!.remove(attraction);
      usedAttractionsByState[state]!.add(attraction);
    }

    print('Selected for day ${dayAllocation.dayInState}: ${selectedForDay.map((a) => a.name).join(', ')}');
    print('Remaining available: ${availableAttractionsByState[state]!.length}');

    return selectedForDay;
  }

  List<Attraction> _selectByDayStrategy(
      List<Attraction> available,
      DayStateAllocation dayAllocation,
      int count,
      TripType tripType,
      ) {
    // Categorize available attractions by type
    Map<String, List<Attraction>> byType = {};
    for (Attraction attraction in available) {
      for (String type in attraction.type) {
        String normalizedType = type.toLowerCase();
        if (!byType.containsKey(normalizedType)) {
          byType[normalizedType] = [];
        }
        byType[normalizedType]!.add(attraction);
      }
    }

    List<Attraction> selected = [];
    List<String> priorityTypes = [];

    // Different strategy for each day in state
    if (dayAllocation.dayInState == 1) {
      // First day: Iconic/must-see attractions
      priorityTypes = ['heritage', 'culture', 'landmark', 'shopping', 'theme park'];
      print('Day 1 strategy: Iconic attractions');
    } else if (dayAllocation.isLastDayInState) {
      // Last day: Relaxing/shopping activities
      priorityTypes = ['shopping', 'spa', 'beach', 'garden', 'culture'];
      print('Last day strategy: Relaxing activities');
    } else {
      // Middle days: Adventure/nature activities
      priorityTypes = ['adventure', 'nature', 'sports', 'water sports', 'theme park'];
      print('Middle day strategy: Adventure/nature');
    }

    // First, try to get attractions from priority types
    for (String type in priorityTypes) {
      if (byType.containsKey(type) && selected.length < count) {
        List<Attraction> typeAttractions = List.from(byType[type]!);

        // Sort by price for variety (mix of free and paid)
        typeAttractions.sort((a, b) {
          double priceA = a.pricing.isNotEmpty ? a.pricing.first.price : 0;
          double priceB = b.pricing.isNotEmpty ? b.pricing.first.price : 0;
          return priceA.compareTo(priceB);
        });

        // Take one from this type
        if (typeAttractions.isNotEmpty) {
          selected.add(typeAttractions.first);
          print('Selected from $type: ${typeAttractions.first.name}');
        }
      }
    }

    // If we still need more attractions, fill with any remaining
    while (selected.length < count && selected.length < available.length) {
      for (Attraction attraction in available) {
        if (!selected.contains(attraction) && selected.length < count) {
          selected.add(attraction);
          print('Filled remaining slot: ${attraction.name}');
        }
      }
      break; // Prevent infinite loop
    }

    return selected;
  }

  int _getOptimalAttractionCount(FlexibilityLevel flexibility, TripType tripType) {
    int base = 2; // Reduced base to ensure we don't run out

    switch (flexibility) {
      case FlexibilityLevel.full:
        base = 3;
        break;
      case FlexibilityLevel.flexible:
        base = 2;
        break;
      case FlexibilityLevel.normal:
        base = 2;
        break;
    }

    if (tripType == TripType.adventure) {
      base += 1;
    }

    return base;
  }
}