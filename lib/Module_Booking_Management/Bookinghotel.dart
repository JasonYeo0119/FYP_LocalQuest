import 'package:flutter/material.dart';
import 'package:localquest/Module_Booking_Management/Bookingallinone.dart';
import 'package:localquest/Module_Booking_Management/Bookingattractionmain.dart';
import 'package:localquest/Module_Booking_Management/Bookingtransportmain.dart';
import 'package:localquest/Module_Booking_Management/Searchresult.dart';
// Add these imports for hotel search functionality
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

  Widget _buildPopularDestinations() {
    final destinations = MockMalaysiaHotelService.getPopularDestinations();

    return Container(
      margin: EdgeInsets.only(top: 250, left: 10, right: 10),
      padding: EdgeInsets.all(16),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Rooms"),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: _showResults ? 1200 : 790, // Adjust height based on results
              decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
              child: Stack(
                children: [
                  Positioned(
                    left: 10,
                    top: 20,
                    child: Container(
                      width: 389,
                      height: 220,
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
                    ),
                  ),
                  Positioned(
                    left: 25,
                    top: 43,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: 359,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _locationController, // Updated controller
                          decoration: InputDecoration(
                            hintText: 'Where do you want to go?',
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
                    top: 89,
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
                            hintText: 'Check In',
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
                    top: 89,
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
                            hintText: 'Check Out',
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
                    top: 134,
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
                        padding: EdgeInsets.symmetric(horizontal: 1),
                        alignment: Alignment.center,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedAdults,
                            dropdownColor: Colors.white,
                            hint: Text(
                              'Number of Adult(s)',
                              style: TextStyle(fontSize: 14, color: Color(0xFFB1B1B1)),
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
                                  style: TextStyle(fontSize: 14, color: Color(0xFFB1B1B1)),
                                ),
                              ),
                              ...List.generate(20, (index) => index + 1).map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(
                                    value.toString(),
                                    style: TextStyle(fontSize: 14, color: Colors.black),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 212,
                    top: 134,
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
                        padding: EdgeInsets.symmetric(horizontal: 1),
                        alignment: Alignment.center,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedChildren,
                            dropdownColor: Colors.white,
                            hint: Text(
                              'Number of Children', // Fixed hint text
                              style: TextStyle(fontSize: 14, color: Color(0xFFB1B1B1)),
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
                                  'Number of Children',
                                  style: TextStyle(fontSize: 14, color: Color(0xFFB1B1B1)),
                                ),
                              ),
                              ...List.generate(11, (index) => index).map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(
                                    value.toString(),
                                    style: TextStyle(fontSize: 14, color: Colors.black),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 129,
                    top: 187,
                    child: GestureDetector(
                      onTap: _isLoading ? null : _searchHotels, // Disable when loading
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
                      left: 180,
                      top: 193,
                      child: GestureDetector(
                        onTap: _searchHotels,
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
                  // Popular destinations section
                  Positioned(
                    left: 0,
                    top: 0,
                    right: 0,
                    child: _buildPopularDestinations(),
                  ),
                  Positioned(
                    left: 38,
                    top: 678,
                    child: Container(
                      width: 70,
                      height: 70,
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
                    ),
                  ),
                  Positioned(
                    left: 45,
                    top: 684,
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
                  Positioned(
                    left: 126,
                    top: 678,
                    child: GestureDetector(
                      onTap: () {
                        Transport(context);
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
                    left: 133,
                    top: 687,
                    child: Opacity(
                      opacity: 0.3,
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