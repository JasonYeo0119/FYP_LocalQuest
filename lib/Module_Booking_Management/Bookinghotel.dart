import 'package:flutter/material.dart';
import 'package:localquest/Module_Booking_Management/Bookingallinone.dart';
import 'package:localquest/Module_Booking_Management/Bookingattractionmain.dart';
import 'package:localquest/Module_Booking_Management/Bookingtransportmain.dart';
import 'package:localquest/Module_Booking_Management/Searchresult.dart';
import '../Model/hotel.dart';
import '../services/mock_hotel_service.dart';
import '../widgets/hotel_card.dart';
import 'Hoteldetails.dart';

class Bookinghotelmain extends StatefulWidget {
  @override
  _BookinghotelmainState createState() => _BookinghotelmainState();
}

class _BookinghotelmainState extends State<Bookinghotelmain> {
  // Existing controllers
  TextEditingController _checkInController = TextEditingController();
  TextEditingController _checkOutController = TextEditingController();

  // New controller for location search
  TextEditingController _locationController = TextEditingController();

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int? selectedAdults;
  int? selectedChildren;

  // Loading state for search
  bool _isLoading = false;

  // Missing variables for search results
  bool _showResults = false;
  List<Hotel> _searchResults = [];
  String _errorMessage = '';

  // Navigation methods
  void Search(BuildContext ctx) {
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return Searchresult();
    }));
  }

  void Allinone(BuildContext ctx) {
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return Bookingallinone();
    }));
  }

  void Transport(BuildContext ctx) {
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return Bookingtransportmain();
    }));
  }

  void Attraction(BuildContext ctx) {
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return Bookingattractionmain();
    }));
  }

  Future<void> _searchHotels() async {
    // Validate form before searching
    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a destination")),
      );
      return;
    }

    if (_checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select check-in date")),
      );
      return;
    }

    if (_checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select check-out date")),
      );
      return;
    }

    if (selectedAdults == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select number of adults")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final hotels = await MockMalaysiaHotelService.searchHotels(
        destination: _locationController.text,
      );

      setState(() {
        _isLoading = false;
        _searchResults = hotels;
        _showResults = true;
      });

      // Navigate to search results page with the found hotels
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HotelSearchResultsScreen(
            hotels: hotels,
            destination: _locationController.text,
            checkInDate: _checkInDate!,
            checkOutDate: _checkOutDate!,
            adults: selectedAdults!,
            children: selectedChildren ?? 0,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to search hotels. Please try again.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to search hotels. Please try again.')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, bool isCheckIn) async {
    DateTime today = DateTime.now();
    DateTime initialDate = today;

    if (!isCheckIn && _checkInDate != null) {
      initialDate = _checkInDate!.add(Duration(days: 1));
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isCheckIn ? today : (_checkInDate ?? today).add(Duration(days: 1)),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = pickedDate;
          _checkInController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";

          if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutController.clear();
            _checkOutDate = null;
          }
        } else {
          if (_checkInDate != null && pickedDate.isBefore(_checkInDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Check-Out date must be after Check-In date.")),
            );
          } else {
            _checkOutDate = pickedDate;
            _checkOutController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
          }
        }
      });
    }
  }

  void _onDestinationTap(String destination) {
    _locationController.text = destination;
  }

  void _navigateToHotelDetails(Hotel hotel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelDetailsScreen(hotel: hotel),
      ),
    );
  }

  Widget _buildPopularDestinations(double screenWidth) {
    final destinations = MockMalaysiaHotelService.getPopularDestinations();

    return Container(
      margin: EdgeInsets.only(
          top: screenWidth * 0.01, // Responsive top margin
          left: screenWidth * 0.026,
          right: screenWidth * 0.026
      ),
      padding: EdgeInsets.all(screenWidth * 0.041),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepOrange, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Destinations in Malaysia',
            style: TextStyle(
              fontSize: screenWidth * 0.041,
              fontWeight: FontWeight.bold,
              color: Colors.black87
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: destinations.map((destination) {
              return ActionChip(
                label: Text(destination),
                onPressed: () => _onDestinationTap(destination),
                backgroundColor: Colors.deepOrange.withOpacity(0.1),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchForm(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.026,
        vertical: screenHeight * 0.025,
      ),
      padding: EdgeInsets.all(screenWidth * 0.026),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.deepOrange,
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: [
          // Location input
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
            child: TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Where do you want to go?',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
              textAlignVertical: TextAlignVertical.center,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),

          // Check-in and Check-out dates
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
                      hintText: 'Check In',
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
                  child: TextField(
                    controller: _checkOutController,
                    readOnly: true,
                    onTap: () => _selectDate(context, _checkOutController, false),
                    decoration: InputDecoration(
                      hintText: 'Check Out',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                    textAlignVertical: TextAlignVertical.center,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),

          // Adults and Children dropdowns
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
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.013),
                  alignment: Alignment.center,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedAdults,
                      dropdownColor: Colors.white,
                      isExpanded: true,
                      hint: Text(
                        'Number of Adult(s)',
                        style: TextStyle(fontSize: screenWidth * 0.036, color: Color(0xFFB1B1B1)),
                      ),
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedAdults = newValue!;
                        });
                      },
                      items: [
                        DropdownMenuItem<int>(
                          value: null,
                          child: Text(
                            'Number of Adult(s)',
                            style: TextStyle(fontSize: screenWidth * 0.036, color: Color(0xFFB1B1B1)),
                          ),
                        ),
                        ...List.generate(20, (index) => index + 1).map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(
                              value.toString(),
                              style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                            ),
                          );
                        }).toList(),
                      ],
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
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.013),
                  alignment: Alignment.center,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedChildren,
                      dropdownColor: Colors.white,
                      isExpanded: true,
                      hint: Text(
                        'Number of Child',
                        style: TextStyle(fontSize: screenWidth * 0.036, color: Color(0xFFB1B1B1)),
                      ),
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedChildren = newValue!;
                        });
                      },
                      items: [
                        DropdownMenuItem<int>(
                          value: null,
                          child: Text(
                            'Number of Child',
                            style: TextStyle(fontSize: screenWidth * 0.036, color: Color(0xFFB1B1B1)),
                          ),
                        ),
                        ...List.generate(11, (index) => index).map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(
                              value.toString(),
                              style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.025),

          // Search button
          Center(
            child: GestureDetector(
              onTap: _isLoading ? null : _searchHotels,
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
                    colors: [Color(0xFFFF4502), Color(0xFFFFFF00)],
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
            // Hotel button (active)
            Container(
              width: iconSize,
              height: iconSize,
              decoration: ShapeDecoration(
                gradient: LinearGradient(
                  begin: Alignment(1.00, 0.00),
                  end: Alignment(-1, 0),
                  colors: [Color(0xFFFF4502), Color(0xFFFFFF00)],
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

            // Transport button
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
        title: Text("All Rooms",
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
              colors: [Color(0xFFFF4502), Color(0xFFFFFF00)],
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
                  _buildPopularDestinations(screenWidth),
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

// Create the missing HotelSearchResultsScreen class
class HotelSearchResultsScreen extends StatelessWidget {
  final List<Hotel> hotels;
  final String destination;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int adults;
  final int children;

  const HotelSearchResultsScreen({
    Key? key,
    required this.hotels,
    required this.destination,
    required this.checkInDate,
    required this.checkOutDate,
    required this.adults,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hotels in $destination'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF4502), Color(0xFFFFFF00)],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$destination',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${checkInDate.day}/${checkInDate.month}/${checkInDate.year} - ${checkOutDate.day}/${checkOutDate.month}/${checkOutDate.year}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  '$adults Adults${children > 0 ? ', $children Children' : ''}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child: hotels.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hotel_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hotels found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: hotels.length,
              itemBuilder: (context, index) {
                return HotelCard(
                  hotel: hotels[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HotelDetailsScreen(hotel: hotels[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}