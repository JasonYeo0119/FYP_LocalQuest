import 'package:flutter/material.dart';
import '../Model/transport.dart';
import '../Model/flight.dart';
import '../widgets/transport_card.dart';
import '../widgets/flight_card.dart'; // You'll need to create this
import '../services/transport_service.dart';
import '../services/mock_flight_service.dart';
import 'package:firebase_database/firebase_database.dart'; // Add this import

class TransportSearchResultsScreen extends StatefulWidget {
  final List<Transport> transports; // May be empty - we'll fetch data here
  final String origin;
  final String destination;
  final DateTime departDate;
  final DateTime? returnDate;
  final String? transportType;
  final String? carLocation;
  final int? numberOfDays;
  final String? ferryTicketType;
  final int? ferryNumberOfPax;

  const TransportSearchResultsScreen({
    Key? key,
    required this.transports,
    required this.origin,
    required this.destination,
    required this.departDate,
    this.returnDate,
    this.transportType,
    this.carLocation,
    this.numberOfDays,
    this.ferryNumberOfPax,
    this.ferryTicketType,
  }) : super(key: key);

  @override
  _TransportSearchResultsScreenState createState() => _TransportSearchResultsScreenState();
}

class _TransportSearchResultsScreenState extends State<TransportSearchResultsScreen> {
  List<Transport> _searchResults = [];
  List<Flight> _flightResults = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Add Firebase database reference
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _fetchTransportData();
  }

  Future<void> _fetchTransportData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (widget.transportType == 'Flight') {
        await _fetchFlightInformation();
      } else if (widget.transportType == 'Car') {
        List<Transport> results = await _fetchCarInformation();
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      } else {
        List<Transport> results = await TransportService.searchTransports(
          origin: widget.origin,
          destination: widget.destination,
          type: widget.transportType,
        );
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load transport data. Please try again.';
        _isLoading = false;
      });
      print('Error fetching transport data: $e');
    }
  }

  Future<void> _fetchFlightInformation() async {
    try {
      print('Fetching flight information...');
      print('Origin: ${widget.origin}');
      print('Destination: ${widget.destination}');
      print('Depart Date: ${widget.departDate}');
      print('Return Date: ${widget.returnDate}');

      // Search flights using the mock service
      // The origin and destination should already be airport codes (e.g., "KUL", "PEN")
      List<Flight> availableFlights = await MockMalaysiaFlightService.searchFlights(
        from: widget.origin,
        to: widget.destination,
      );

      print('Found ${availableFlights.length} flights');

      // Filter flights based on operating days if needed
      List<Flight> filteredFlights = availableFlights.where((flight) {
        String selectedDay = _getDayName(widget.departDate.weekday);
        return flight.schedule.days.contains(selectedDay);
      }).toList();

      print('Filtered to ${filteredFlights.length} flights available on selected day');

      setState(() {
        _flightResults = filteredFlights;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching flight information: $e');
      setState(() {
        _errorMessage = 'Failed to load flight information. Please try again.';
        _isLoading = false;
      });
    }
  }

  // NEW: Check if a car is available for the requested dates
  Future<bool> _isCarAvailable(String carId, DateTime startDate, int? numberOfDays) async {
    try {
      // Normalize dates to remove time component
      DateTime normalizedStartDate = DateTime(startDate.year, startDate.month, startDate.day);

      // Calculate end date based on numberOfDays
      DateTime normalizedEndDate;
      if (numberOfDays != null && numberOfDays > 1) {
        // For N days starting on startDate, end date is (startDate + N-1 days)
        // Example: 2 days starting June 17 = June 17 + June 18
        normalizedEndDate = normalizedStartDate.add(Duration(days: numberOfDays - 1));
      } else {
        normalizedEndDate = normalizedStartDate; // Single day
      }

      // Calculate all dates in the booking period
      List<String> requestedDates = [];
      DateTime currentDate = normalizedStartDate;

      while (currentDate.isBefore(normalizedEndDate.add(Duration(days: 1)))) {
        String dateKey = "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";
        requestedDates.add(dateKey);
        currentDate = currentDate.add(Duration(days: 1));
      }

      print('🔍 Checking availability for car: $carId');
      print('📅 Requested dates: $requestedDates');
      print('📊 Booking period: ${normalizedStartDate.toIso8601String()} to ${normalizedEndDate.toIso8601String()}');

      // Check Firebase for unavailable dates
      DatabaseReference carRef = _database.child('cars').child(carId);
      DataSnapshot snapshot = await carRef.child('unavailableDates').get();

      if (snapshot.exists) {
        Map<String, dynamic> unavailableDates = Map<String, dynamic>.from(snapshot.value as Map);
        print('🚫 Unavailable dates in Firebase: ${unavailableDates.keys.toList()}');

        // Check if any requested date is blocked
        for (String requestedDate in requestedDates) {
          if (unavailableDates.containsKey(requestedDate)) {
            var dateData = unavailableDates[requestedDate];

            // Check both old structure (boolean) and new structure (object with isBlocked)
            bool isBlocked = false;
            if (dateData is bool && dateData == true) {
              isBlocked = true;
            } else if (dateData is Map && dateData['isBlocked'] == true) {
              isBlocked = true;
            }

            if (isBlocked) {
              print('❌ Car $carId is NOT available - blocked on $requestedDate');
              return false;
            }
          }
        }
      } else {
        print('✅ No unavailable dates found for car $carId');
      }

      print('✅ Car $carId is AVAILABLE for all requested dates');
      return true;
    } catch (e) {
      print('❌ Error checking car availability for $carId: $e');
      // In case of error, assume car is not available to be safe
      return false;
    }
  }

  Future<List<Transport>> _fetchCarInformation() async {
    try {
      print('Fetching car information...');
      print('Location: ${widget.carLocation}');
      print('Booking Date: ${widget.departDate}');
      print('Number of Days: ${widget.numberOfDays}');

      // Get all cars from the database
      List<Transport> allCars = await TransportService.getTransportsByType('Car');
      print('Found ${allCars.length} cars in database');

      // Filter cars based on location and operating days, but KEEP booked cars with status
      List<Transport> filteredCars = [];

      for (Transport car in allCars) {
        print('Checking car: ${car.name}');

        // Check if car is not hidden
        if (car.isHidden) {
          print('Car ${car.name} is hidden');
          continue;
        }

        // For cars, check if the location matches
        String carLocationFromDB = '';

        // Try to get location from additionalInfo first, then from origin
        if (car.additionalInfo != null && car.additionalInfo!['location'] != null) {
          carLocationFromDB = car.additionalInfo!['location'].toString();
        } else if (car.origin.isNotEmpty) {
          carLocationFromDB = car.origin;
        }

        print('Car location from DB: $carLocationFromDB');
        print('Search location: ${widget.carLocation}');

        String searchLocation = widget.carLocation ?? widget.origin;
        bool locationMatch = carLocationFromDB.toLowerCase().contains(searchLocation.toLowerCase()) ||
            searchLocation.toLowerCase().contains(carLocationFromDB.toLowerCase());

        if (!locationMatch) {
          print('Car ${car.name} location does not match');
          continue;
        }

        // Check if car is available on the selected day (if operating days are specified)
        if (car.operatingDays.isNotEmpty) {
          String selectedDay = _getDayName(widget.departDate.weekday);
          bool isAvailableOnDay = car.operatingDays.contains(selectedDay);
          if (!isAvailableOnDay) {
            print('Car ${car.name} not available on $selectedDay');
            continue;
          }
        }

        // NEW: Check availability but don't filter out - add status instead
        String carId = car.additionalInfo?['plateNumber']?.toString() ?? car.name ?? 'unknown';

        print('🚗 Checking availability for car: ${car.name}');
        print('🔑 Using plate number as ID: $carId');
        print('📅 Search dates: ${widget.departDate} for ${widget.numberOfDays} days');

        bool isAvailable = await _isCarAvailable(carId, widget.departDate, widget.numberOfDays);

        // DEBUG: Call this to see what's in Firebase for this car
        // await _debugFirebaseCarData(carId);

        // Create a modified transport object with availability status
        Transport carWithStatus = Transport(
          id: car.id,
          name: car.name,
          type: car.type,
          origin: car.origin,
          destination: car.destination,
          price: car.price,
          imageUrl: car.imageUrl,
          description: car.description,
          timeSlots: car.timeSlots,
          availableSeats: car.availableSeats,
          totalSeats: car.totalSeats,
          operatingDays: car.operatingDays,
          isHidden: car.isHidden,
          // Add availability status to additionalInfo
          additionalInfo: {
            ...car.additionalInfo ?? {},
            'isAvailable': isAvailable,
            'availabilityStatus': isAvailable ? 'Available' : 'Not Available',
            'searchDates': '${widget.departDate.day}/${widget.departDate.month}/${widget.departDate.year}',
            'searchDuration': '${widget.numberOfDays} day${widget.numberOfDays! > 1 ? 's' : ''}',
          },
        );

        print(isAvailable ? '✅ Car ${car.name} is AVAILABLE' : '❌ Car ${car.name} is NOT AVAILABLE');
        filteredCars.add(carWithStatus);
      }

      print('Filtered to ${filteredCars.length} cars (available and unavailable)');

      // If no cars found with exact location matching, try a broader search
      if (filteredCars.isEmpty) {
        print('No cars found with exact location match, trying broader search...');

        for (Transport car in allCars) {
          if (car.isHidden) continue;

          // Try to match any part of the location
          String searchLocation = widget.carLocation ?? widget.origin;
          String carLocationFromDB = '';

          if (car.additionalInfo != null && car.additionalInfo!['location'] != null) {
            carLocationFromDB = car.additionalInfo!['location'].toString();
          } else if (car.origin.isNotEmpty) {
            carLocationFromDB = car.origin;
          }

          // Extract state/city from both locations for comparison
          List<String> searchParts = searchLocation.split(',');
          List<String> carParts = carLocationFromDB.split(',');

          bool foundMatch = false;
          for (String searchPart in searchParts) {
            for (String carPart in carParts) {
              if (searchPart.trim().toLowerCase().contains(carPart.trim().toLowerCase()) ||
                  carPart.trim().toLowerCase().contains(searchPart.trim().toLowerCase())) {

                String carId = car.additionalInfo?['plateNumber']?.toString() ?? car.name ?? 'unknown';

                bool isAvailable = await _isCarAvailable(carId, widget.departDate, widget.numberOfDays);

                // DEBUG: Call this to see what's in Firebase for this car
                // await _debugFirebaseCarData(carId);

                // Create a modified transport object with availability status
                Transport carWithStatus = Transport(
                  id: car.id,
                  name: car.name,
                  type: car.type,
                  origin: car.origin,
                  destination: car.destination,
                  price: car.price,
                  imageUrl: car.imageUrl,
                  description: car.description,
                  timeSlots: car.timeSlots,
                  availableSeats: car.availableSeats,
                  totalSeats: car.totalSeats,
                  operatingDays: car.operatingDays,
                  isHidden: car.isHidden,
                  // Add availability status to additionalInfo
                  additionalInfo: {
                    ...car.additionalInfo ?? {},
                    'isAvailable': isAvailable,
                    'availabilityStatus': isAvailable ? 'Available' : 'Not Available',
                    'searchDates': '${widget.departDate.day}/${widget.departDate.month}/${widget.departDate.year}',
                    'searchDuration': '${widget.numberOfDays} day${widget.numberOfDays! > 1 ? 's' : ''}',
                  },
                );

                print('Found match: ${car.name} - $carLocationFromDB matches $searchLocation (${isAvailable ? 'Available' : 'Not Available'})');
                filteredCars.add(carWithStatus);
                foundMatch = true;
                break;
              }
            }
            if (foundMatch) break;
          }
        }

        print('Broader search found ${filteredCars.length} cars');
      }

      // Sort cars by availability first (available cars first), then by price
      filteredCars.sort((a, b) {
        bool aAvailable = a.additionalInfo?['isAvailable'] ?? true;
        bool bAvailable = b.additionalInfo?['isAvailable'] ?? true;

        // Available cars first
        if (aAvailable && !bAvailable) return -1;
        if (!aAvailable && bAvailable) return 1;

        // If same availability, sort by price
        return a.price.compareTo(b.price);
      });

      return filteredCars;
    } catch (e) {
      print('Error fetching car information: $e');
      throw Exception('Failed to fetch car information: $e');
    }
  }

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

  String _getAirportDisplayName(String code) {
    final airportInfo = MockMalaysiaFlightService.getAirportInfo(code);
    if (airportInfo.isNotEmpty) {
      return '${airportInfo['city']} (${code})';
    }
    return code;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.transportType ?? 'Transport'} Results',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7107F3), Color(0xFFFF02FA)],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.transportType == 'Flight') ...[
                  Text(
                    '${_getAirportDisplayName(widget.origin)} → ${_getAirportDisplayName(widget.destination)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text(
                    'Depart date: ${widget.departDate.day}/${widget.departDate.month}/${widget.departDate.year}',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  if (widget.returnDate != null)
                    Text(
                      'Return date: ${widget.returnDate!.day}/${widget.returnDate!.month}/${widget.returnDate!.year}',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                ] else if (widget.transportType == 'Car') ...[
                  Text(
                    'Car Rental - ${widget.carLocation ?? widget.origin}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text(
                    'Booking date: ${widget.departDate.day}/${widget.departDate.month}/${widget.departDate.year}',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  if (widget.numberOfDays != null)
                    Text(
                      'Duration: ${widget.numberOfDays} day${widget.numberOfDays! > 1 ? 's' : ''}',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  // Add availability info
                  SizedBox(height: 4),
                  Text(
                    'Showing all cars with availability status',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                  ),
                ] else ...[
                  Text(
                    '${widget.origin} → ${widget.destination}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text(
                    'Depart date: ${widget.departDate.day}/${widget.departDate.month}/${widget.departDate.year}',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  if (widget.returnDate != null)
                    Text(
                      'Return date: ${widget.returnDate!.day}/${widget.returnDate!.month}/${widget.returnDate!.year}',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7107F3)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading ${widget.transportType?.toLowerCase() ?? 'transport'} options...',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
                : _errorMessage.isNotEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    style: TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchTransportData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7107F3),
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Retry'),
                  ),
                ],
              ),
            )
                : (widget.transportType == 'Flight' ? _flightResults.isEmpty : _searchResults.isEmpty)
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.transportType == 'Car'
                        ? Icons.directions_car
                        : widget.transportType == 'Flight'
                        ? Icons.flight
                        : Icons.directions_transit,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No ${widget.transportType?.toLowerCase() ?? 'transport options'} found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.transportType == 'Car'
                        ? 'Try selecting a different location or date'
                        : widget.transportType == 'Flight'
                        ? 'No flights available for the selected route and date'
                        : 'Try adjusting your search criteria',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _fetchTransportData,
              child: widget.transportType == 'Flight'
                  ? ListView.builder(
                itemCount: _flightResults.length,
                itemBuilder: (context, index) {
                  final flight = _flightResults[index];
                  return FlightCard(
                    flight: flight,
                    departDate: widget.departDate,
                    returnDate: widget.returnDate,
                  );
                },
              )
                  : ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final transport = _searchResults[index];
                  // Convert Transport object to Map<String, dynamic>
                  final transportMap = transport.toMap();

                  // Add car-specific data to the map
                  if (widget.transportType == 'Car') {
                    transportMap['numberOfDays'] = widget.numberOfDays;
                    transportMap['bookingDate'] = widget.departDate.toIso8601String();

                    // Add car-specific fields from additionalInfo if they exist
                    if (transport.additionalInfo != null) {
                      transportMap['plateNumber'] = transport.additionalInfo!['plateNumber'];
                      transportMap['location'] = transport.additionalInfo!['location'];
                      transportMap['color'] = transport.additionalInfo!['color'];
                      transportMap['driverIncluded'] = transport.additionalInfo!['driverIncluded'];
                      transportMap['maxPassengers'] = transport.additionalInfo!['maxPassengers'];
                      transportMap['priceType'] = transport.additionalInfo!['priceType'];
                    }

                    // Override origin/destination for cars to show location
                    if (transportMap['location'] != null) {
                      transportMap['origin'] = transportMap['location'];
                      transportMap['destination'] = transportMap['location'];
                    }
                  }

                  return TransportCard(
                    transport: transportMap,
                    departDate: widget.departDate,
                    returnDate: widget.returnDate,
                    numberOfDays: widget.numberOfDays,
                    ferryNumberOfPax: widget.ferryNumberOfPax,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: !_isLoading &&
          (widget.transportType == 'Flight' ? _flightResults.isNotEmpty : _searchResults.isNotEmpty)
          ? FloatingActionButton(
        onPressed: _fetchTransportData,
        backgroundColor: Color(0xFF7107F3),
        child: Icon(Icons.refresh, color: Colors.white),
        tooltip: 'Refresh Results',
      )
          : null,
    );
  }
}