import 'package:flutter/material.dart';
import 'package:localquest/Module_Booking_Management/Bookingallinone.dart' hide Transport;
import 'package:localquest/Module_Booking_Management/Bookingattractionmain.dart' hide Transport;
import 'package:localquest/Module_Booking_Management/Bookinghotel.dart';
import 'package:localquest/Module_Booking_Management/Searchresult.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Transportsearchresultscreen.dart';
import '../services/transport_service.dart';
import '../Model/transport.dart';

@override
void Search(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Searchresult();
  }));
}

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
    } else {
      // Validation for other transport types (Bus, Flight)
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

    // Navigate to search results page - let it handle the data fetching
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransportSearchResultsScreen(
          transports: [], // Empty list - results screen will fetch data
          origin: _selectedTransport == 'Car' ? _carLocationController.text :
          _selectedTransport == 'Ferry' ? _ferryOriginController.text : originController.text,
          destination: _selectedTransport == 'Car' ? _carLocationController.text :
          _selectedTransport == 'Ferry' ? _ferryDestinationController.text : destinationController.text,
          departDate: _selectedTransport == 'Car' ? _bookingDate! :
          _selectedTransport == 'Ferry' ? _ferryDate! : _checkInDate!,
          returnDate: _selectedTransport == 'Car' || _selectedTransport == 'Ferry' ? null : _checkOutDate,
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

  @override
  Widget build(BuildContext context) {
    bool isCarSelected = _selectedTransport == 'Car';
    bool isFerrySelected = _selectedTransport == 'Ferry';

    return Scaffold(
      appBar: AppBar(
        title: Text("All Transports"),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 790,
              decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
              child: Stack(
                children: [
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      width: 389,
                      height: isFerrySelected ? 280 : 213,
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
                    ),
                  ),
                  // Transport Type Tabs
                  Positioned(
                    left: 25,
                    top: 17,
                    child: Container(
                      width: 340,
                      height: 45,
                      child: TabBar(
                        controller: _tabController,
                        tabs: transportTypes.map((type) => Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_getTransportIcon(type), size: 16),
                              SizedBox(width: 4),
                              Text(type, style: TextStyle(fontSize: 12)),
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
                        labelPadding: EdgeInsets.symmetric(horizontal: 4),
                      ),
                    ),
                  ),

                  // Conditional form fields based on transport type
                  if (isCarSelected) ...[
                    // Car rental form
                    Positioned(
                      left: 25,
                      top: 73,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 170,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8),
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
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            textAlignVertical: TextAlignVertical.center,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 212,
                      top: 73,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 170,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          alignment: Alignment.center,
                          child: TextField(
                            controller: _numberOfDaysController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Number of days',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            textAlignVertical: TextAlignVertical.center,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 25,
                      top: 116,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 357,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          alignment: Alignment.center,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _carLocationController.text.isEmpty ? null : _carLocationController.text,
                              hint: Text('Select car location', style: TextStyle(fontSize: 14, color: Colors.grey)),
                              isExpanded: true,
                              style: TextStyle(fontSize: 14, color: Colors.black),
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
                      ),
                    ),

                  ] else if (isFerrySelected) ...[
                    // Ferry form
                    Positioned(
                      left: 25,
                      top: 73,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 170,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8),
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
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            textAlignVertical: TextAlignVertical.center,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 212,
                      top: 73,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 170,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          alignment: Alignment.center,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _numberOfPax,
                              hint: Text('Number of pax', style: TextStyle(fontSize: 14, color: Colors.grey)),
                              isExpanded: true,
                              style: TextStyle(fontSize: 14, color: Colors.black),
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
                    ),
                    Positioned(
                      left: 25,
                      top: 116,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 170,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          alignment: Alignment.center,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _ferryOriginController.text.isEmpty ? null : _ferryOriginController.text,
                              hint: Text('Origin', style: TextStyle(fontSize: 14, color: Colors.grey)),
                              isExpanded: true,
                              style: TextStyle(fontSize: 14, color: Colors.black),
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
                    ),
                    Positioned(
                      left: 212,
                      top: 116,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 170,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          alignment: Alignment.center,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _ferryDestinationController.text.isEmpty ? null : _ferryDestinationController.text,
                              hint: Text('Destination', style: TextStyle(fontSize: 14, color: Colors.grey)),
                              isExpanded: true,
                              style: TextStyle(fontSize:14, color: Colors.black),
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
                    ),
                    Positioned(
                      left: 25,
                      top: 159,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 357,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          alignment: Alignment.center,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedTicketType,
                              hint: Text('Ticket type', style: TextStyle(fontSize: 14, color: Colors.grey)),
                              isExpanded: true,
                              style: TextStyle(fontSize: 14, color: Colors.black),
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
                      ),
                    ),
                  ] else ...[
                    // Other transport forms (Bus, Flight)
                    Positioned(
                      left: 25,
                      top: 73,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 170,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8),
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
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            textAlignVertical: TextAlignVertical.center,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 212,
                      top: 73,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 170,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          alignment: Alignment.center,
                          child: TextField(
                            controller: _checkOutController,
                            readOnly: true,
                            onTap: () => _selectDate(context, _checkOutController, false),
                            decoration: InputDecoration(
                              hintText: 'Return date (Optional)',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            textAlignVertical: TextAlignVertical.center,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 25,
                      top: 116,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 170,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          alignment: Alignment.center,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: originController.text.isEmpty ? null : originController.text,
                              hint: Text('Origin', style: TextStyle(fontSize: 14, color: Colors.grey)),
                              isExpanded: true,
                              style: TextStyle(fontSize: 14, color: Colors.black),
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
                    ),
                    Positioned(
                      left: 212,
                      top: 116,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 170,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: destinationController.text.isEmpty ? null : destinationController.text,
                              hint: Text('Destination', style: TextStyle(fontSize: 14, color: Colors.grey)),
                              isExpanded: true,
                              style: TextStyle(fontSize: 14, color: Colors.black),
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
                    ),
                    Positioned(
                      left: 183,
                      top: 114,
                      child: GestureDetector(
                        onTap: swapValues,
                        child: Container(
                          width: 40,
                          height: 40,
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
                          child: Icon(Icons.swap_horiz, color: Colors.white),
                        ),
                      ),
                    ),
                  ],

                  Positioned(
                    left: 129,
                    top: isFerrySelected ? 239 : 172,
                    child: GestureDetector(
                      onTap: _isLoading ? null : _searchTransports,
                      child: Container(
                        width: 151,
                        height: 32,
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
                        child: _isLoading
                            ? Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        )
                            : null,
                      ),
                    ),
                  ),
                  if (!_isLoading)
                    Positioned(
                      left: 181,
                      top: isFerrySelected ? 245 : 178,
                      child: GestureDetector(
                        onTap: _searchTransports,
                        child: Text(
                          'Search',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 38,
                    top: 678,
                    child: GestureDetector(
                      onTap: () {
                        Stay(context);
                      },
                      child: Container(
                        width: 70,
                        height: 70,
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
                      ),
                    ),
                  ),
                  Positioned(
                    left: 45,
                    top: 684,
                    child: Opacity(
                      opacity: 0.3,
                      child: IconButton(
                        icon: Icon(Icons.hotel_outlined, color: Colors.black),
                        iconSize: 40,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Bookinghotelmain()),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 126,
                    top: 678,
                    child: Container(
                      width: 70,
                      height: 70,
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
                    ),
                  ),
                  Positioned(
                    left: 133,
                    top: 687,
                    child: IconButton(
                      icon: Icon(Icons.directions_train_outlined, color: Colors.black),
                      iconSize: 40,
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Bookingtransportmain()),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    left: 214,
                    top: 677,
                    child: GestureDetector(
                      onTap: () {
                        Attraction(context);
                      },
                      child: Container(
                        width: 70,
                        height: 70,
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
                      ),
                    ),
                  ),
                  Positioned(
                    left: 221,
                    top: 683,
                    child: Opacity(
                      opacity: 0.3,
                      child: IconButton(
                        icon: Icon(Icons.park_outlined, color: Colors.black),
                        iconSize: 40,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Bookingattractionmain()),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 302,
                    top: 678,
                    child: GestureDetector(
                      onTap: () {
                        Allinone(context);
                      },
                      child: Container(
                        width: 70,
                        height: 70,
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
                      ),
                    ),
                  ),
                  Positioned(
                    left: 309,
                    top: 686,
                    child: Opacity(
                      opacity: 0.3,
                      child: IconButton(
                        icon: Icon(Icons.dashboard_outlined, color: Colors.black),
                        iconSize: 40,
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
          ],
        ),
      ),
    );
  }
}