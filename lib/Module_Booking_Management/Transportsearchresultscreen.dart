import 'package:flutter/material.dart';
import '../Model/transport.dart';
import '../widgets/transport_card.dart';
import '../services/transport_service.dart';

class TransportSearchResultsScreen extends StatefulWidget {
  final List<Transport> transports; // May be empty - we'll fetch data here
  final String origin;
  final String destination;
  final DateTime departDate;
  final DateTime? returnDate;
  final String? transportType;
  // Car-specific parameters
  final String? carLocation;
  final int? numberOfDays;

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
  }) : super(key: key);

  @override
  _TransportSearchResultsScreenState createState() => _TransportSearchResultsScreenState();
}

class _TransportSearchResultsScreenState extends State<TransportSearchResultsScreen> {
  List<Transport> _searchResults = [];
  bool _isLoading = true;
  String _errorMessage = '';

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
      List<Transport> results;

      if (widget.transportType == 'Car') {
        results = await _fetchCarInformation();
      } else {
        results = await TransportService.searchTransports(
          origin: widget.origin,
          destination: widget.destination,
          type: widget.transportType,
        );
      }

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load transport data. Please try again.';
        _isLoading = false;
      });
      print('Error fetching transport data: $e');
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

      // Filter cars based on availability and location
      List<Transport> availableCars = allCars.where((car) {
        print('Checking car: ${car.name}');

        // Check if car is not hidden
        if (car.isHidden) {
          print('Car ${car.name} is hidden');
          return false;
        }

        // For cars, check if the location matches
        // Cars use 'location' field instead of 'origin'
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
          return false;
        }

        // Check if car is available on the selected date (if operating days are specified)
        if (car.operatingDays.isNotEmpty) {
          String selectedDay = _getDayName(widget.departDate.weekday);
          bool isAvailableOnDay = car.operatingDays.contains(selectedDay);
          if (!isAvailableOnDay) {
            print('Car ${car.name} not available on $selectedDay');
            return false;
          }
        }

        print('Car ${car.name} is available');
        return true;
      }).toList();

      print('Filtered to ${availableCars.length} available cars');

      // If no cars found with location matching, try a broader search
      if (availableCars.isEmpty) {
        print('No cars found with exact location match, trying broader search...');

        availableCars = allCars.where((car) {
          if (car.isHidden) return false;

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

          for (String searchPart in searchParts) {
            for (String carPart in carParts) {
              if (searchPart.trim().toLowerCase().contains(carPart.trim().toLowerCase()) ||
                  carPart.trim().toLowerCase().contains(searchPart.trim().toLowerCase())) {
                print('Found match: ${car.name} - $carLocationFromDB matches $searchLocation');
                return true;
              }
            }
          }

          return false;
        }).toList();

        print('Broader search found ${availableCars.length} cars');
      }

      // Sort cars by price (lowest first)
      availableCars.sort((a, b) => a.price.compareTo(b.price));

      return availableCars;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.transportType ?? 'Transport'} Results'),
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
                if (widget.transportType == 'Car') ...[
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
                : _searchResults.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.transportType == 'Car'
                        ? Icons.directions_car
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
                        : 'Try adjusting your search criteria',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _fetchTransportData,
              child: ListView.builder(
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

                  return TransportCard(transport: transportMap);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: !_isLoading && _searchResults.isNotEmpty
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