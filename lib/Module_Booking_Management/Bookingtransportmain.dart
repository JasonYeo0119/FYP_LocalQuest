import 'package:flutter/material.dart';
import 'package:localquest/Module_Booking_Management/Bookingallinone.dart';
import 'package:localquest/Module_Booking_Management/Bookingattractionmain.dart';
import 'package:localquest/Module_Booking_Management/Bookinghotel.dart';
import 'package:localquest/Module_Booking_Management/Searchresult.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Transportsearchresultscreen.dart';
import '../services/transport_service.dart';

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

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  String? _selectedTransport;

  // Tab controller for transport types
  late TabController _tabController;
  int _selectedTabIndex = 0; // Default to Bus (index 1)

  // Add variables for search functionality
  bool _isLoading = false;
  bool _showResults = false;
  List<Map<String, dynamic>> _searchResults = [];
  String _errorMessage = '';

  // Firebase database reference
  final databaseRef = FirebaseDatabase.instance.ref().child('Transports');

  final List<String> transportTypes = ['Car', 'Bus', 'Flight', 'Train'];

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

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
          _selectedTransport = transportTypes[_selectedTabIndex];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _searchTransports() async {
    // Validate form before searching
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

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Use the TransportService to search for transports
      final transports = await TransportService.searchTransports(
        origin: originController.text,
        destination: destinationController.text,
        type: _selectedTransport,
      );

      setState(() {
        _isLoading = false;
        _showResults = true;
      });

      // Navigate to search results page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransportSearchResultsScreen(
            transports: transports,
            origin: originController.text,
            destination: destinationController.text,
            departDate: _checkInDate!,
            returnDate: _checkOutDate,
            transportType: _selectedTransport,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to search transports. Please try again.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to search transports. Please try again.')),
      );
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

  void swapValues() {
    setState(() {
      String temp = originController.text;
      originController.text = destinationController.text;
      destinationController.text = temp;
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
      case 'Train':
        return Icons.train;
      default:
        return Icons.directions_transit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Transports"),
        backgroundColor: Colors.transparent,
        // Make AppBar background transparent
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
      body: SingleChildScrollView( // Prevents overflow issues
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 790,
              decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
              child: Stack(
                children: [
                  Positioned( //backgroundwhite
                    left: 10,
                    top: 10,
                    child: Container(
                      width: 389,
                      height: 213,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.deepPurple, // Border color
                            width: 2, // Border thickness
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
                  Positioned( //departdate
                    left: 25,
                    top: 73, // Moved down to accommodate tabs
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
                          // Prevent manual input
                          onTap: () =>
                              _selectDate(context, _checkInController, true),
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
                  Positioned( //returndate
                    left: 212,
                    top: 73, // Moved down to accommodate tabs
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
                          // Prevent manual input
                          onTap: () =>
                              _selectDate(context, _checkOutController, false),
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
                  Positioned( //originplace
                    left: 25,
                    top: 116, // Moved down to accommodate tabs
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
                  Positioned( //destination
                    left: 212,
                    top: 116, // Moved down to accommodate tabs
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
                  Positioned( //switchbutton
                    left: 183,
                    top: 114, // Moved down to accommodate tabs
                    child: GestureDetector(
                      onTap: swapValues, // Call swapValues() when tapped
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
                        child: Icon(Icons.swap_horiz,
                            color: Colors.white), // Add an icon
                      ),
                    ),
                  ),
                  // Display current transport type selection
                  Positioned(
                    left: 25,
                    top: 159, // Moved down to accommodate tabs
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  Positioned( //Searchbutton
                    left: 129,
                    top: 172, // Moved down to accommodate tabs
                    child: GestureDetector(
                      onTap: _isLoading ? null : _searchTransports,
                      // Updated to use new search function
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
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
                      top: 178, // Moved down to accommodate tabs
                      child: GestureDetector(
                        onTap: _searchTransports,
                        // Updated to use new search function
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
                  Positioned( //Hotelbutton
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
                  Positioned( //hotel icon
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
                            MaterialPageRoute(
                                builder: (context) => Bookinghotelmain()),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned( //Transportbutton
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
                  Positioned( //Transport icon
                    left: 133,
                    top: 687, // Sets the opacity to 30%
                    child: IconButton(
                      icon: Icon(
                          Icons.directions_train_outlined, color: Colors.black),
                      iconSize: 40,
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              Bookingtransportmain()),
                        );
                      },
                    ),
                  ),
                  Positioned( //Blueroundicon
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
                  Positioned( //Attraction icon
                    left: 221,
                    top: 683,
                    child: Opacity(
                      opacity: 0.3, // Sets the opacity to 30%
                      child: IconButton(
                        icon: Icon(Icons.park_outlined, color: Colors.black),
                        iconSize: 40,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Bookingattractionmain()),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned( //Greenroundbutton
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
                  Positioned( //Allinone icon
                    left: 309,
                    top: 686,
                    child: Opacity(
                      opacity: 0.3, // Sets the opacity to 30%
                      child: IconButton(
                        icon: Icon(
                            Icons.dashboard_outlined, color: Colors.black),
                        iconSize: 40,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Bookingallinone()),
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