import 'package:flutter/material.dart';
import 'package:localquest/Module_Booking_Management/Bookingallinone.dart' hide Transport;
import 'package:localquest/Module_Booking_Management/Bookingattractionmain.dart' hide Transport;
import 'package:localquest/Module_Booking_Management/Bookinghotel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Transportsearchresultscreen.dart';
import '../services/transport_service.dart';
import '../Model/transport.dart';

@override
void Allinone(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Bookingallinone();
  }));
}

@override
void Stay(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Bookinghotelmain();
  }));
}

@override
void Attraction(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Bookingattractionmain();
  }));
}

class Bookingtransportmain extends StatefulWidget {
  @override
  _BookingtransportmainState createState() => _BookingtransportmainState();
}

class _BookingtransportmainState extends State<Bookingtransportmain> with SingleTickerProviderStateMixin {
  TextEditingController _checkInController = TextEditingController();
  TextEditingController _checkOutController = TextEditingController();
  TextEditingController originController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  // Car rental specific controllers
  TextEditingController _bookingDateController = TextEditingController();
  TextEditingController _numberOfDaysController = TextEditingController();
  TextEditingController _carLocationController = TextEditingController();

  // Ferry specific controllers
  TextEditingController _ferryDateController = TextEditingController();
  TextEditingController _ferryOriginController = TextEditingController();
  TextEditingController _ferryDestinationController = TextEditingController();

  TextEditingController _flightDepartController = TextEditingController();
  TextEditingController _flightReturnController = TextEditingController();
  TextEditingController _flightOriginController = TextEditingController();
  TextEditingController _flightDestinationController = TextEditingController();

  DateTime? _flightDepartDate;
  DateTime? _flightReturnDate;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  DateTime? _bookingDate;
  DateTime? _ferryDate;
  String? _selectedTransport;

  // Ferry specific variables
  String _selectedTicketType = 'pedestrian';
  int _numberOfPax = 1;
  List<String> _ferryOrigins = ["Butterworth", "George Town"];
  List<String> _ferryDestinations = ["Butterworth", "George Town"];
  List<String> _flightLocations = [
    'Kuala Lumpur International Airport(KUL)', 'Johor Bahru Senai International Airport (JHB)', 'Penang International Airport (PEN)', 'Kota Kinabalu International Airport (BKI)',
    'Sadakan Airport (SDK)', 'Tawau Airport (TWU)', 'Sibu Airport (SBW)', 'Kuching International Airport (KCH)'
  ];


  // Tab controller for transport types
  late TabController _tabController;
  int _selectedTabIndex = 0; // Default to Car (index 0)

  // Add variables for search functionality
  bool _isLoading = false;
  bool _showResults = false;
  List<Map<String, dynamic>> _searchResults = [];
  String _errorMessage = '';

  // Firebase database reference
  final databaseRef = FirebaseDatabase.instance.ref().child('Transports');

  final List<String> transportTypes = ['Car', 'Bus', 'Flight', 'Ferry']; // Changed Train to Ferry

  final List<String> locations = [
    "Johor, Larkin Sentral, Johor Bahru", "Johor, Terminal Bas Kluang, Kluang", "Johor, Terminal Bas Segamat, Segamat", "Johor, Terminal Bas Batu Pahat, Batu Pahat", "Johor, Terminal Bas Muar Bentayan, Muar",
    "Malacca, Melaka Sentral", "Malacca, Terminal Bas Jasin",
    "Negeri Sembilan, Terminal One Bus Station, Seremban", "Negeri Sembilan, Terminal Bas Tampin",
    "Kuala Lumpur, Terminal Bersepadu Selatan (TBS)", "Kuala Lumpur, Pudu Sentral (Puduraya)", "Kuala Lumpur, Hentian Duta", "Kuala Lumpur, Terminal Shah Alam (Seksyen 17)", "Kuala Lumpur, Terminal KL Sentral", "Selangor, Terminal Klang Sentral, Klang",
    "Pahang, Terminal Kuantan Sentral, Kuantan",
    "Perak, Amanjaya Bus Terminal, Ipoh", "Perak, Terminal Bas Taiping, Taiping", "Perak, Terminal Bas Kampar", "Perak, Terminal Bas Lumut",
    "Terengganu, Kuala Terengganu Bus Terminal",
    "Kelantan, Kota Bahru Bus Terminal",
    "Penang, Sungai Nibong", "Penang, Penang Sentral",
    "Kedah, Alor Setar Bus Terminal", "Kedah, Terminal Bas Kulim", "Kedah, Terminal Bas Sungai Petani",
    "Perlis, Kangar Bus Terminal", "Perlis, Terminal Bas Kuala Perlis",
    "Sabah, Inanam Bus Terminal, Kota Kinabalu", "Sabah, Terminal Bas Sadakan", "Sabah, Terminal Bas Tawau",
    "Sarawak, Kuching Sentral", "Sarawak, Miri Bus Terminal", "Sarawak, Sibu Bus Terminal", "Sarawak, Bintulu Bus Terminal"
  ];

  final List<String> carlocations = [
    "Johor, Johor Bahru", "Johor, Batu Pahat", "Johor, Muar", "Johor, Pontian", "Johor, Desaru",
    "Malacca, Malacca Town",
    "Negeri Sembilan, Seremban",
    "Kuala Lumpur, Bukit Jalil", "Kuala Lumpur, Bukit Bintang", "Kuala Lumpur, Bandar Sunway", "Kuala Lumpur, Cheras",
    "Selangor, Klang Valley", "Selangor, Subang Jaya", "Selangor, Petaling Jaya",
    "Pahang, Kuantan",
    "Perak, Ipoh", "Perak, Kampar", "Perak, Taiping",
    "Kelantan, Kota Bahru",
    "Terengganu, Kuala Terengganu",
    "Penang, Bayan Lepas", "Penang, Georgetown", "Penang, Gelugor", "Penang, George Town", "Penang, Butterworth",
    "Kedah, Sungai Petani", "Kedah, Alor Setar", "Kedah, Kulim", "Kedah, Changlun",
    "Perlis, Kuala Perlis",
    "Sabah, Kota Kinabalu", "Sabah, Tawau", "Sabah, Sadakan",
    "Sarawak, Kuching"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: transportTypes.length, vsync: this, initialIndex: _selectedTabIndex);
    _selectedTransport = transportTypes[_selectedTabIndex]; // Set initial transport type
    _loadFerryLocations(); // Load ferry locations from Firebase

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
          _selectedTransport = transportTypes[_selectedTabIndex];
          // Clear form when switching tabs
          _clearForm();
        });
      }
    });
  }

  // Load ferry locations from Firebase
  Future<void> _loadFerryLocations() async {
    try {
      final snapshot = await databaseRef.orderByChild('type').equalTo('Ferry').get();
      if (snapshot.exists) {
        Set<String> origins = {};
        Set<String> destinations = {};

        Map<dynamic, dynamic> ferries = snapshot.value as Map<dynamic, dynamic>;
        ferries.forEach((key, value) {
          if (value['origin'] != null) origins.add(value['origin']);
          if (value['destination'] != null) destinations.add(value['destination']);
        });

        setState(() {
          _ferryOrigins = origins.toList()..sort();
          _ferryDestinations = destinations.toList()..sort();
        });
      }
    } catch (e) {
      print('Error loading ferry locations: $e');
    }
  }

  void _clearForm() {
    _checkInController.clear();
    _checkOutController.clear();
    originController.clear();
    destinationController.clear();
    _bookingDateController.clear();
    _numberOfDaysController.clear();
    _carLocationController.clear();
    _ferryDateController.clear();
    _ferryOriginController.clear();
    _ferryDestinationController.clear();

    _checkInDate = null;
    _checkOutDate = null;
    _bookingDate = null;
    _ferryDate = null;
    _selectedTicketType = 'pedestrian';
    _numberOfPax = 1;

    _flightDepartController.clear();
    _flightReturnController.clear();
    _flightOriginController.clear();
    _flightDestinationController.clear();
    _flightDepartDate = null;
    _flightReturnDate = null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // In your Bookingtransportmain.dart file, update the _searchTransports method:

  Future<void> _searchTransports() async {
    // Validate form based on transport type
    if (_selectedTransport == 'Car') {
      if (_carLocationController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select car location")),
        );
        return;
      }

      if (_bookingDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select booking date")),
        );
        return;
      }

      if (_numberOfDaysController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter number of days")),
        );
        return;
      }
    } else if (_selectedTransport == 'Ferry') {
      // Ferry validation
      if (_ferryOriginController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select origin")),
        );
        return;
      }

      if (_ferryDestinationController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select destination")),
        );
        return;
      }

      if (_ferryDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select travel date")),
        );
        return;
      }
    } else if (_selectedTransport == 'Flight') {
      // Flight validation
      if (_flightOriginController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select departure location")),
        );
        return;
      }

      if (_flightDestinationController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select arrival location")),
        );
        return;
      }

      if (_flightOriginController.text == _flightDestinationController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Departure and arrival locations cannot be the same")),
        );
        return;
      }

      if (_flightDepartDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select departure date")),
        );
        return;
      }
    } else {
      if (originController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter origin location")),
        );
        return;
      }

      if (destinationController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter destination location")),
        );
        return;
      }

      if (_checkInDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select departure date")),
        );
        return;
      }
    }

    // Extract airport codes for flight search
    String origin = '';
    String destination = '';

    if (_selectedTransport == 'Flight') {
      // Extract airport codes from the selected locations
      origin = _extractAirportCode(_flightOriginController.text);
      destination = _extractAirportCode(_flightDestinationController.text);
    } else if (_selectedTransport == 'Car') {
      origin = _carLocationController.text;
      destination = _carLocationController.text;
    } else if (_selectedTransport == 'Ferry') {
      origin = _ferryOriginController.text;
      destination = _ferryDestinationController.text;
    } else {
      origin = originController.text;
      destination = destinationController.text;
    }

    // Navigate to search results page - let it handle the data fetching
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransportSearchResultsScreen(
          transports: [], // Empty list - results screen will fetch data
          origin: origin,
          destination: destination,
          departDate: _selectedTransport == 'Car' ? _bookingDate! :
          _selectedTransport == 'Ferry' ? _ferryDate! :
          _selectedTransport == 'Flight' ? _flightDepartDate! : _checkInDate!,
          returnDate: _selectedTransport == 'Car' || _selectedTransport == 'Ferry' ? null :
          _selectedTransport == 'Flight' ? _flightReturnDate : _checkOutDate,
          transportType: _selectedTransport,
          // Pass car-specific parameters
          carLocation: _selectedTransport == 'Car' ? _carLocationController.text : null,
          numberOfDays: _selectedTransport == 'Car' ? int.tryParse(_numberOfDaysController.text) : null,
          // Pass ferry-specific parameters
          ferryTicketType: _selectedTransport == 'Ferry' ? _selectedTicketType : null,
          ferryNumberOfPax: _selectedTransport == 'Ferry' ? _numberOfPax : null,
        ),
      ),
    );
  }

// Add this helper method to extract airport codes
  String _extractAirportCode(String location) {
    // Extract airport code from location string
    // Example: "Kuala Lumpur International Airport(KUL)" -> "KUL"
    final RegExp regExp = RegExp(r'\(([A-Z]+)\)');
    final match = regExp.firstMatch(location);
    return match?.group(1) ?? location;
  }

  Future<List<Transport>> _fetchCarInformation() async {
    try {
      print('Fetching car information...');
      print('Location: ${_carLocationController.text}');
      print('Booking Date: ${_bookingDate?.toString()}');
      print('Number of Days: ${_numberOfDaysController.text}');

      // Get all cars from the selected location
      List<Transport> allCars = await TransportService.searchTransports(
        origin: _carLocationController.text,
        type: 'Car',
      );

      print('Found ${allCars.length} cars in database');

      // Filter cars based on availability and location
      List<Transport> availableCars = allCars.where((car) {
        // Check if car is not hidden
        if (car.isHidden) {
          print('Car ${car.name} is hidden');
          return false;
        }

        // Check if car origin matches selected location
        bool locationMatch = car.origin.toLowerCase().contains(_carLocationController.text.toLowerCase());
        if (!locationMatch) {
          print('Car ${car.name} location does not match: ${car.origin}');
          return false;
        }

        // Check if car is available on the selected date (if operating days are specified)
        if (car.operatingDays.isNotEmpty && _bookingDate != null) {
          String selectedDay = _getDayName(_bookingDate!.weekday);
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

  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, bool isCheckIn) async {
    DateTime today = DateTime.now();
    DateTime initialDate = today;

    if (!isCheckIn && _checkInDate != null) {
      // Check-Out must be after Check-In
      initialDate = _checkInDate!.add(Duration(days: 1));
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isCheckIn ? today : (_checkInDate ?? today).add(
          Duration(days: 1)),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = pickedDate;
          _checkInController.text =
          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";

          // Reset Check-Out if it's now before Check-In
          if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutController.clear();
            _checkOutDate = null;
          }
        } else {
          if (_checkInDate != null && pickedDate.isBefore(_checkInDate!)) {
            // Show error if Check-Out is earlier than Check-In
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Return date must be after depart date.")),
            );
          } else {
            _checkOutDate = pickedDate;
            _checkOutController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
          }
        }
      });
    }
  }

  Future<void> _selectBookingDate(BuildContext context) async {
    DateTime today = DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _bookingDate = pickedDate;
        _bookingDateController.text =
        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  Future<void> _selectFerryDate(BuildContext context) async {
    DateTime today = DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _ferryDate = pickedDate;
        _ferryDateController.text =
        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  Widget _buildTouristRecommendations(double screenWidth, double screenHeight) {
    final recommendations = [
      {
        'title': 'KL-Penang Express Bus',
        'subtitle': 'Comfortable 4-5 hour journey',
        'price': 'RM 40.00 - 60.00',
        'icon': Icons.directions_bus,
        'popular': true,
      },
      {
        'title': 'AirAsia Domestic',
        'subtitle': 'Quick inter-state flights',
        'price': 'RM 159.00',
        'icon': Icons.flight,
        'popular': false,
      },
      {
        'title': 'Penang Ferry',
        'subtitle': 'Iconic Butterworth-Georgetown',
        'price': 'RM 2.00',
        'icon': Icons.directions_boat,
        'popular': true,
      },
      {
        'title': 'Car Rental',
        'subtitle': 'Explore Cameron Highlands',
        'price': 'RM 80-160/day',
        'icon': Icons.directions_car,
        'popular': false,
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.026),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.013),
            child: Row(
              children: [
                Icon(Icons.star, color: Color(0xFF7107F3), size: screenWidth * 0.051),
                SizedBox(width: screenWidth * 0.013),
                Text(
                  'Popular for Tourists',
                  style: TextStyle(
                    fontSize: screenWidth * 0.041,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.013),
          Container(
            height: screenHeight * 0.16,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.013),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final rec = recommendations[index];
                return Container(
                  width: screenWidth * 0.42,
                  margin: EdgeInsets.only(right: screenWidth * 0.026),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.026),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(screenWidth * 0.015),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF7107F3), Color(0xFFFF02FA)],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    rec['icon'] as IconData,
                                    color: Colors.white,
                                    size: screenWidth * 0.041,
                                  ),
                                ),
                                Spacer(),
                                if (rec['popular'] as bool)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.013,
                                      vertical: screenWidth * 0.005,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFF02FA).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'HOT',
                                      style: TextStyle(
                                        color: Color(0xFFFF02FA),
                                        fontSize: screenWidth * 0.025,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              rec['title'] as String,
                              style: TextStyle(
                                fontSize: screenWidth * 0.033,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Text(
                              rec['subtitle'] as String,
                              style: TextStyle(
                                fontSize: screenWidth * 0.028,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Spacer(),
                            Text(
                              'From ${rec['price']}',
                              style: TextStyle(
                                fontSize: screenWidth * 0.031,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7107F3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTips(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.026,
        vertical: screenHeight * 0.013,
      ),
      padding: EdgeInsets.all(screenWidth * 0.026),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7107F3).withOpacity(0.1), Color(0xFFFF02FA).withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF7107F3).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Color(0xFF7107F3)),
          SizedBox(width: screenWidth * 0.026),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tourist Tip',
                  style: TextStyle(
                    fontSize: screenWidth * 0.033,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7107F3),
                  ),
                ),
                Text(
                  'Get Touch \'n Go card for seamless travel across Malaysia',
                  style: TextStyle(
                    fontSize: screenWidth * 0.028,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void swapValues() {
    setState(() {
      String temp = originController.text;
      originController.text = destinationController.text;
      destinationController.text = temp;
    });
  }

  void swapFerryValues() {
    setState(() {
      String temp = _ferryOriginController.text;
      _ferryOriginController.text = _ferryDestinationController.text;
      _ferryDestinationController.text = temp;
    });
  }

  // Get icon for transport type
  IconData _getTransportIcon(String transportType) {
    switch (transportType) {
      case 'Car':
        return Icons.directions_car;
      case 'Bus':
        return Icons.directions_bus;
      case 'Flight':
        return Icons.flight;
      case 'Ferry':
        return Icons.directions_boat;
      default:
        return Icons.directions_transit;
    }
  }

  Widget _buildTransportTabs(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.87,
      height: screenHeight * 0.057,
      child: TabBar(
        controller: _tabController,
        tabs: transportTypes.map((type) => Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getTransportIcon(type), size: screenWidth * 0.041),
              SizedBox(width: screenWidth * 0.01),
              Text(type, style: TextStyle(fontSize: screenWidth * 0.031)),
            ],
          ),
        )).toList(),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7107F3), Color(0xFFFF02FA)],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
      ),
    );
  }

  Future<void> _selectFlightDepartDate(BuildContext context) async {
    DateTime today = DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _flightDepartDate = pickedDate;
        _flightDepartController.text =
        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";

        // Reset return date if it's now before depart date
        if (_flightReturnDate != null && _flightReturnDate!.isBefore(_flightDepartDate!)) {
          _flightReturnController.clear();
          _flightReturnDate = null;
        }
      });
    }
  }

  // Future<void> _selectFlightReturnDate(BuildContext context) async {
  //   DateTime initialDate = _flightDepartDate?.add(Duration(days: 1)) ?? DateTime.now();
  //
  //   DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: initialDate,
  //     firstDate: _flightDepartDate ?? DateTime.now(),
  //     lastDate: DateTime(2100),
  //   );
  //
  //   if (pickedDate != null) {
  //     if (_flightDepartDate != null && pickedDate.isBefore(_flightDepartDate!)) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Return date must be after depart date.")),
  //       );
  //     } else {
  //       setState(() {
  //         _flightReturnDate = pickedDate;
  //         _flightReturnController.text =
  //         "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
  //       });
  //     }
  //   }
  // }

  void swapFlightValues() {
    setState(() {
      String temp = _flightOriginController.text;
      _flightOriginController.text = _flightDestinationController.text;
      _flightDestinationController.text = temp;
    });
  }

  Widget _buildFlightForm(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: screenHeight * 0.045,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
                alignment: Alignment.center,
                child: TextField(
                  controller: _flightDepartController,
                  readOnly: true,
                  onTap: () => _selectFlightDepartDate(context),
                  decoration: InputDecoration(
                    hintText: 'Depart date',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
            ),
            // SizedBox(width: screenWidth * 0.026),
            // Expanded(
            //   child: Container(
            //     height: screenHeight * 0.045,
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(5),
            //       border: Border.all(color: Colors.black, width: 1),
            //     ),
            //     padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
            //     alignment: Alignment.center,
            //     child: TextField(
            //       controller: _flightReturnController,
            //       readOnly: true,
            //       onTap: () => _selectFlightReturnDate(context),
            //       decoration: InputDecoration(
            //         hintText: 'Return date (Optional)',
            //         border: InputBorder.none,
            //         isDense: true,
            //         contentPadding: EdgeInsets.zero,
            //       ),
            //       style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
            //       textAlignVertical: TextAlignVertical.center,
            //     ),
            //   ),
            // ),
          ],
        ),
        SizedBox(height: screenHeight * 0.015),
        Row(
          children: [
            Expanded(
              child: Container(
                height: screenHeight * 0.045,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
                alignment: Alignment.center,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _flightOriginController.text.isEmpty ? null : _flightOriginController.text,
                    hint: Text('Depart from', style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.grey)),
                    isExpanded: true,
                    style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                    dropdownColor: Colors.white,
                    items: _flightLocations.map((String location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _flightOriginController.text = newValue ?? '';
                      });
                    },
                  ),
                ),
              ),
            ),
            Container(
              width: screenWidth * 0.103,
              height: screenWidth * 0.103,
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.013),
              decoration: ShapeDecoration(
                gradient: LinearGradient(
                  begin: Alignment(1.00, 0.00),
                  end: Alignment(-1, 0),
                  colors: [Color(0xFF7107F3), Color(0xFFFF02FA)],
                ),
                shape: OvalBorder(side: BorderSide(width: 1)),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.swap_horiz, color: Colors.white),
                iconSize: screenWidth * 0.051,
                onPressed: swapFlightValues,
              ),
            ),
            Expanded(
              child: Container(
                height: screenHeight * 0.045,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
                alignment: Alignment.center,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _flightDestinationController.text.isEmpty ? null : _flightDestinationController.text,
                    hint: Text('Arrive at', style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.grey)),
                    isExpanded: true,
                    style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                    dropdownColor: Colors.white,
                    items: _flightLocations.map((String location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _flightDestinationController.text = newValue ?? '';
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCarForm(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: screenHeight * 0.045,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
                alignment: Alignment.center,
                child: TextField(
                  controller: _bookingDateController,
                  readOnly: true,
                  onTap: () => _selectBookingDate(context),
                  decoration: InputDecoration(
                    hintText: 'Booking date',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.026),
            Expanded(
              child: Container(
                height: screenHeight * 0.045,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
                alignment: Alignment.centerLeft,
                child: DropdownButton<int>(
                  dropdownColor: Colors.white,
                  value: _numberOfDaysController.text.isNotEmpty
                      ? int.tryParse(_numberOfDaysController.text)
                      : null,
                  hint: Text(
                    'Number of days',
                    style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.grey[400]),
                  ),
                  items: List.generate(10, (index) => index + 1)
                      .map((int value) => DropdownMenuItem<int>(
                    value: value,
                    child: Text(
                      value.toString(),
                      style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                    ),
                  ))
                      .toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _numberOfDaysController.text = newValue?.toString() ?? '';
                    });
                  },
                  underline: Container(), // Removes the default underline
                  isDense: true,
                  style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.015),
        Container(
          width: double.infinity,
          height: screenHeight * 0.045,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.black, width: 1),
          ),
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
          alignment: Alignment.center,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _carLocationController.text.isEmpty ? null : _carLocationController.text,
              hint: Text('Select car location', style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.grey)),
              isExpanded: true,
              style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
              dropdownColor: Colors.white,
              items: carlocations.map((String location) {
                return DropdownMenuItem<String>(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _carLocationController.text = newValue ?? '';
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFerryForm(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: screenHeight * 0.045,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
                alignment: Alignment.center,
                child: TextField(
                  controller: _ferryDateController,
                  readOnly: true,
                  onTap: () => _selectFerryDate(context),
                  decoration: InputDecoration(
                    hintText: 'Travel date',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.026),
            Expanded(
              child: Container(
                height: screenHeight * 0.045,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
                alignment: Alignment.center,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _numberOfPax,
                    hint: Text('Number of pax', style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.grey)),
                    isExpanded: true,
                    style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                    dropdownColor: Colors.white,
                    items: List.generate(10, (index) => index + 1).map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value pax'),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        _numberOfPax = newValue ?? 1;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.015),
        Row(
          children: [
            Expanded(
              child: Container(
                height: screenHeight * 0.045,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
                alignment: Alignment.center,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _ferryOriginController.text.isEmpty ? null : _ferryOriginController.text,
                    hint: Text('Origin', style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.grey)),
                    isExpanded: true,
                    style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                    dropdownColor: Colors.white,
                    items: _ferryOrigins.map((String location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _ferryOriginController.text = newValue ?? '';
                      });
                    },
                  ),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.026),
            Expanded(
              child: Container(
                height: screenHeight * 0.045,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
                alignment: Alignment.center,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _ferryDestinationController.text.isEmpty ? null : _ferryDestinationController.text,
                    hint: Text('Destination', style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.grey)),
                    isExpanded: true,
                    style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                    dropdownColor: Colors.white,
                    items: _ferryDestinations.map((String location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _ferryDestinationController.text = newValue ?? '';
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.015),
        Container(
          width: double.infinity,
          height: screenHeight * 0.045,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.black, width: 1),
          ),
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
          alignment: Alignment.center,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTicketType,
              hint: Text('Ticket type', style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.grey)),
              isExpanded: true,
              style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
              dropdownColor: Colors.white,
              items: [
                DropdownMenuItem(
                  value: 'pedestrian',
                  child: Text('Pedestrian'),
                ),
                DropdownMenuItem(
                  value: 'vehicle',
                  child: Text('Vehicle'),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTicketType = newValue ?? 'pedestrian';
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherTransportForm(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: screenHeight * 0.045,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
                alignment: Alignment.center,
                child: TextField(
                  controller: _checkInController,
                  readOnly: true,
                  onTap: () => _selectDate(context, _checkInController, true),
                  decoration: InputDecoration(
                    hintText: 'Depart date',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.026),
            // Expanded(
            //   child: Container(
            //     height: screenHeight * 0.045,
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(5),
            //       border: Border.all(color: Colors.black, width: 1),
            //     ),
            //     padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
            //     alignment: Alignment.center,
            //     child: TextField(
            //       controller: _checkOutController,
            //       readOnly: true,
            //       onTap: () => _selectDate(context, _checkOutController, false),
            //       decoration: InputDecoration(
            //         hintText: 'Return date (Optional)',
            //         border: InputBorder.none,
            //         isDense: true,
            //         contentPadding: EdgeInsets.zero,
            //       ),
            //       style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
            //       textAlignVertical: TextAlignVertical.center,
            //     ),
            //   ),
            // ),
          ],
        ),
        SizedBox(height: screenHeight * 0.015),
        Row(
          children: [
            Expanded(
              child: Container(
                height: screenHeight * 0.045,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
                alignment: Alignment.center,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: originController.text.isEmpty ? null : originController.text,
                    hint: Text('Origin', style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.grey)),
                    isExpanded: true,
                    style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                    dropdownColor: Colors.white,
                    items: locations.map((String location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        originController.text = newValue ?? '';
                      });
                    },
                  ),
                ),
              ),
            ),
            Container(
              width: screenWidth * 0.103,
              height: screenWidth * 0.103,
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.013),
              decoration: ShapeDecoration(
                gradient: LinearGradient(
                  begin: Alignment(1.00, 0.00),
                  end: Alignment(-1, 0),
                  colors: [Color(0xFF7107F3), Color(0xFFFF02FA)],
                ),
                shape: OvalBorder(side: BorderSide(width: 1)),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.swap_horiz, color: Colors.white),
                iconSize: screenWidth * 0.051,
                onPressed: swapValues,
              ),
            ),
            Expanded(
              child: Container(
                height: screenHeight * 0.045,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
                alignment: Alignment.center,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: destinationController.text.isEmpty ? null : destinationController.text,
                    hint: Text('Destination', style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.grey)),
                    isExpanded: true,
                    style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                    dropdownColor: Colors.white,
                    items: locations.map((String location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        destinationController.text = newValue ?? '';
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchForm(double screenWidth, double screenHeight) {
    bool isCarSelected = _selectedTransport == 'Car';
    bool isFerrySelected = _selectedTransport == 'Ferry';

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.026,
        vertical: screenHeight * 0.013,
      ),
      padding: EdgeInsets.all(screenWidth * 0.026),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.deepPurple,
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildTransportTabs(screenWidth, screenHeight),
          SizedBox(height: screenHeight * 0.02),
          if (isCarSelected)
            _buildCarForm(screenWidth, screenHeight)
          else if (isFerrySelected)
            _buildFerryForm(screenWidth, screenHeight)
          else if (_selectedTransport == 'Flight')
              _buildFlightForm(screenWidth, screenHeight)
            else
              _buildOtherTransportForm(screenWidth, screenHeight),
          SizedBox(height: screenHeight * 0.025),
          Center(
            child: GestureDetector(
              onTap: _isLoading ? null : _searchTransports,
              child: Container(
                width: screenWidth * 0.39,
                height: screenHeight * 0.04,
                decoration: ShapeDecoration(
                  gradient: _isLoading
                      ? LinearGradient(
                    colors: [Colors.grey, Colors.grey.shade300],
                  )
                      : LinearGradient(
                    begin: Alignment(1.00, 0.00),
                    end: Alignment(-1, 0),
                    colors: [Color(0xFF7107F3), Color(0xFFFF02FA)],
                  ),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Center(
                  child: _isLoading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    'Search',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.036,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(double screenWidth, double screenHeight) {
    double iconSize = screenWidth * 0.18;
    double iconButtonSize = screenWidth * 0.103;

    return Positioned(
      left: 0,
      right: 0,
      bottom: screenHeight * 0.02,
      child: Container(
        height: screenHeight * 0.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Hotel button
            Container(
              width: iconSize,
              height: iconSize,
              decoration: ShapeDecoration(
                color: Color(0xFFF5F5F5),
                shape: OvalBorder(side: BorderSide(width: 1)),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Opacity(
                opacity: 0.3,
                child: IconButton(
                  icon: Icon(Icons.hotel_outlined, color: Colors.black),
                  iconSize: iconButtonSize,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Bookinghotelmain()),
                    );
                  },
                ),
              ),
            ),

            // Transport button (active)
            Container(
              width: iconSize,
              height: iconSize,
              decoration: ShapeDecoration(
                gradient: LinearGradient(
                  begin: Alignment(1.00, 0.00),
                  end: Alignment(-1, 0),
                  colors: [Color(0xFF7107F3), Color(0xFFFF02FA)],
                ),
                shape: OvalBorder(side: BorderSide(width: 1)),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.directions_train_outlined, color: Colors.black),
                iconSize: iconButtonSize,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Bookingtransportmain()),
                  );
                },
              ),
            ),

            // Attraction button
            Container(
              width: iconSize,
              height: iconSize,
              decoration: ShapeDecoration(
                color: Color(0xFFF5F5F5),
                shape: OvalBorder(side: BorderSide(width: 1)),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Opacity(
                opacity: 0.3,
                child: IconButton(
                  icon: Icon(Icons.park_outlined, color: Colors.black),
                  iconSize: iconButtonSize,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Bookingattractionmain()),
                    );
                  },
                ),
              ),
            ),

            // All in one button
            Container(
              width: iconSize,
              height: iconSize,
              decoration: ShapeDecoration(
                color: Color(0xFFF5F5F5),
                shape: OvalBorder(side: BorderSide(width: 1)),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Opacity(
                opacity: 0.3,
                child: IconButton(
                  icon: Icon(Icons.dashboard_outlined, color: Colors.black),
                  iconSize: iconButtonSize,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Bookingallinone()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("All Transports",
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
      body: Container(
        width: double.infinity,
        height: screenHeight,
        decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildSearchForm(screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.02),
                  _buildTouristRecommendations(screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.013),
                  _buildQuickTips(screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.15), // Space for bottom navigation
                ],
              ),
            ),
            _buildBottomNavigation(screenWidth, screenHeight),
          ],
        ),
      ),
    );
  }
}