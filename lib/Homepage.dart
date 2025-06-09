import 'package:localquest/Module_Booking_Management/Bookingallinone.dart';
import 'package:localquest/Module_Booking_Management/Bookingattractionmain.dart';
import 'package:localquest/Module_Booking_Management/Bookinghotel.dart';
import 'package:localquest/Module_Booking_Management/Bookingtransportmain.dart';
import 'package:localquest/Module_Booking_Management/History.dart';
import 'package:localquest/Module_Booking_Management/Location.dart';
import 'package:localquest/Module_Booking_Management/Viewitinerary.dart';
import 'package:localquest/Module_Financial/Deals.dart';
import 'package:localquest/Module_Financial/Payment.dart';
import 'package:localquest/Module_User_Account/Favourite.dart';
import 'package:localquest/Module_User_Account/Profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _nextUpcomingTrip;
  bool _isLoadingTrip = true;
  final List<Map<String, dynamic>> items = [
      {
        "title": "Stay",
        "icon": Icons.hotel_outlined,
        "color": Colors.orange,
      },
      {
        "title": "Transport",
        "icon": Icons.train_outlined,
        "color": Colors.purple,
      },
      {
        "title": "Attractions",
        "icon": Icons.park_outlined,
        "color": Colors.blue,
      },
      {
        "title": "Generate Itinerary",
        "icon": Icons.dashboard_outlined,
        "color": Colors.green,
      }
  ];


  @override
  void initState() {
    super.initState();
    _loadNextUpcomingTrip();
  }

  Future<void> _loadNextUpcomingTrip() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DatabaseEvent event = await _database
            .child('users')
            .child(user.uid)
            .child('bookings')
            .once();

        if (event.snapshot.exists) {
          Map<dynamic, dynamic> bookingsData = event.snapshot.value as Map<dynamic, dynamic>;
          List<Map<String, dynamic>> upcomingBookings = [];

          bookingsData.forEach((key, value) {
            Map<String, dynamic> booking = Map<String, dynamic>.from(value);
            booking['key'] = key;

            if (_isUpcoming(booking)) {
              upcomingBookings.add(booking);
            }
          });

          // Sort by closest departure date
          upcomingBookings.sort((a, b) {
            DateTime dateA = _getRelevantDate(a);
            DateTime dateB = _getRelevantDate(b);
            return dateA.compareTo(dateB);
          });

          setState(() {
            _nextUpcomingTrip = upcomingBookings.isNotEmpty ? upcomingBookings.first : null;
            _isLoadingTrip = false;
          });
        } else {
          setState(() {
            _nextUpcomingTrip = null;
            _isLoadingTrip = false;
          });
        }
      }
    } catch (e) {
      print('Error loading upcoming trip: $e');
      setState(() {
        _nextUpcomingTrip = null;
        _isLoadingTrip = false;
      });
    }
  }

  // Updated to match History.dart logic
  DateTime _getRelevantDate(Map<String, dynamic> booking) {
    String bookingType = booking['bookingType']?.toString() ?? 'transport';

    try {
      if (bookingType == 'hotel') {
        // For hotels, use check-out date as the relevant date
        if (booking['checkOutDate'] != null) {
          return DateTime.parse(booking['checkOutDate']);
        } else if (booking['checkInDate'] != null) {
          return DateTime.parse(booking['checkInDate']);
        }
      } else if (bookingType == 'attraction') {
        // For attractions, use visitDate
        if (booking['visitDate'] != null) {
          return DateTime.parse(booking['visitDate']);
        }
      } else {
        // For transport, use returnDate > departDate > bookingDate
        if (booking['returnDate'] != null) {
          return DateTime.parse(booking['returnDate']);
        } else if (booking['departDate'] != null) {
          return DateTime.parse(booking['departDate']);
        }
      }

      // Fallback to booking date
      return DateTime.parse(booking['bookingDate'] ?? DateTime.now().toIso8601String());
    } catch (e) {
      return DateTime.now();
    }
  }

  // Updated to match History.dart logic
  bool _isUpcoming(Map<String, dynamic> booking) {
    DateTime relevantDate = _getRelevantDate(booking);
    String status = booking['status']?.toString().toLowerCase() ?? 'pending';

    // A booking is upcoming if:
    // 1. The relevant date is in the future, OR
    // 2. The status is confirmed/pending and the date hasn't passed by more than 1 day
    return relevantDate.isAfter(DateTime.now()) ||
        (status != 'completed' && status != 'cancelled' &&
            relevantDate.isAfter(DateTime.now().subtract(Duration(days: 1))));
  }

  // Helper method to check if it's a ferry booking
  bool _isFerryBooking(Map<String, dynamic> booking) {
    return booking['bookingType']?.toString().toLowerCase() == 'ferry' ||
        booking['transportType']?.toString().toLowerCase() == 'ferry';
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('d MMMM yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('HH:mm').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get appropriate icon based on booking type
  IconData _getBookingIcon(Map<String, dynamic> booking) {
    String bookingType = booking['bookingType']?.toString() ?? 'transport';

    if (bookingType == 'hotel') {
      return Icons.hotel;
    } else if (bookingType == 'attraction') {
      return Icons.attractions;
    } else if (bookingType == 'flight') {
      return Icons.flight;
    } else if (bookingType == 'ferry' || _isFerryBooking(booking)) {
      return Icons.directions_boat;
    } else {
      return Icons.directions_bus;
    }
  }

  // Get appropriate color based on booking type
  Color _getBookingColor(Map<String, dynamic> booking) {
    String bookingType = booking['bookingType']?.toString() ?? 'transport';

    if (bookingType == 'hotel') {
      return Color(0xFFFF4502);
    } else if (bookingType == 'attraction') {
      return Color(0xFF0C1FF7);
    } else if (bookingType == 'flight') {
      return Color(0xFF7107F3);
    } else if (bookingType == 'ferry' || _isFerryBooking(booking)) {
      return Color(0xFF0816A7);
    } else {
      return Color(0xFF0816A7);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "LocalQuest",
          style: GoogleFonts.irishGrover(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.w400
          ),
        ),
        backgroundColor: Color(0xFF0816A7),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Service Buttons Grid
              Container(
                height: screenHeight * 0.47,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.94,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // Navigate to different pages based on index
                          switch (index) {
                            case 0:
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Bookinghotelmain()));
                              break;
                            case 1:
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Bookingtransportmain()));
                              break;
                            case 2:
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Bookingattractionmain()));
                              break;
                            case 3:
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Bookingallinone()));
                              break;
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: item['color'].withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  item['icon'],
                                  size: 40,
                                  color: item['color'],
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                item['title'],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.irishGrover(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 12),

              // Upcoming Trip Section
              Text(
                'Upcoming Trip',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),

              _buildUpcomingTripCard(),

              SizedBox(height: 28),

              // Special Deals Tab
              GestureDetector(
                onTap: () => _navigateToDeals(),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Special Deals',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF0816A7),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 18),

              // Itinerary Tab
              GestureDetector(
                onTap: () => _navigateToViewItinerary(),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'View Itinerary',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF0816A7),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 18),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: Colors.black, width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.favorite, "Saved", Colors.white, () => _navigateToFavourite()),
            _buildBottomNavItem(Icons.shopping_bag, "My Trips", Colors.white, () => _navigateToHistory()),
            _buildBottomNavItem(Icons.home, "Home", Color(0xFF0816A7), () {}),
            _buildBottomNavItem(Icons.park, "Attractions", Colors.white, () => _navigateToLocation()),
            _buildBottomNavItem(Icons.person, "Profile", Colors.white, () => _navigateToProfile()),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(String title, IconData icon, List<Color> gradientColors, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 60,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.irishGrover(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTripCard() {
    if (_isLoadingTrip) {
      return Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF0816A7),
          ),
        ),
      );
    }

    if (_nextUpcomingTrip == null) {
      return GestureDetector(
        onTap: () => _navigateToAllinone(), // Navigate to make booking
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: Color(0xFF0816A7), size: 40),
                SizedBox(height: 8),
                Text(
                  'No upcoming trips',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tap to start planning your adventure!',
                  style: TextStyle(
                    color: Color(0xFF0816A7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final trip = _nextUpcomingTrip!;
    String bookingType = trip['bookingType']?.toString() ?? 'transport';

    return GestureDetector(
      onTap: () => _navigateToHistory(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getBookingIcon(trip),
                  color: _getBookingColor(trip),
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getBookingTitle(trip),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        _getBookingSubtitle(trip),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(trip['status'] ?? 'pending').withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getStatusColor(trip['status'] ?? 'pending')),
                  ),
                  child: Text(
                    (trip['status'] ?? 'pending').toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(trip['status'] ?? 'pending'),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              _getBookingDetails(trip),
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'View Details →',
                  style: TextStyle(
                    color: Color(0xFF0181F9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getBookingTitle(Map<String, dynamic> trip) {
    String bookingType = trip['bookingType']?.toString() ?? 'transport';

    if (bookingType == 'hotel') {
      return trip['hotel']?['name'] ?? 'Hotel Booking';
    } else if (bookingType == 'attraction') {
      return trip['attraction']?['name'] ?? 'Attraction Ticket';
    } else if (bookingType == 'flight') {
      return '${trip['airline'] ?? 'Flight'} ${trip['flightNumber'] ?? ''}';
    } else if (bookingType == 'ferry' || _isFerryBooking(trip)) {
      return trip['transport']?['name'] ?? 'Ferry Service';
    } else {
      return trip['transport']?['name'] ?? 'Transport Booking';
    }
  }

  String _getBookingSubtitle(Map<String, dynamic> trip) {
    String bookingType = trip['bookingType']?.toString() ?? 'transport';

    if (bookingType == 'hotel') {
      return trip['hotel']?['address'] ?? 'Hotel Stay';
    } else if (bookingType == 'attraction') {
      String city = trip['attraction']?['city'] ?? '';
      String state = trip['attraction']?['state'] ?? '';
      return city.isNotEmpty && state.isNotEmpty ? '$city, $state' : 'Attraction Visit';
    } else if (bookingType == 'flight') {
      return trip['route'] ?? '${trip['transport']?['origin'] ?? ''} → ${trip['transport']?['destination'] ?? ''}';
    } else if (bookingType == 'ferry' || _isFerryBooking(trip)) {
      return '${trip['transport']?['origin'] ?? ''} → ${trip['transport']?['destination'] ?? ''}';
    } else {
      return '${trip['transport']?['origin'] ?? ''} → ${trip['transport']?['destination'] ?? ''}';
    }
  }

  String _getBookingDetails(Map<String, dynamic> trip) {
    String bookingType = trip['bookingType']?.toString() ?? 'transport';

    if (bookingType == 'hotel') {
      String checkInDate = _formatDate(trip['checkInDate']);
      String checkOutDate = _formatDate(trip['checkOutDate']);
      int nights = trip['numberOfNights'] ?? 1;
      return 'Check-in: $checkInDate • Check-out: $checkOutDate • $nights night${nights > 1 ? 's' : ''}';
    } else if (bookingType == 'attraction') {
      String visitDate = _formatDate(trip['visitDate']);
      return 'Visit Date: $visitDate';
    } else if (bookingType == 'flight') {
      String departDate = _formatDate(trip['departDate']);
      String departureTime = trip['departureTime'] ?? '';
      String arrivalTime = trip['arrivalTime'] ?? '';
      String timeInfo = departureTime.isNotEmpty && arrivalTime.isNotEmpty
          ? ' • $departureTime - $arrivalTime'
          : '';
      return 'Departure: $departDate$timeInfo';
    } else if (bookingType == 'ferry' || _isFerryBooking(trip)) {
      String departDate = _formatDate(trip['departDate']);
      String selectedTime = trip['selectedTime'] ?? '';
      int passengers = trip['ferryNumberOfPax'] ?? 1;
      String timeInfo = selectedTime.isNotEmpty ? ' • $selectedTime' : '';
      return 'Travel Date: $departDate$timeInfo • $passengers passenger${passengers > 1 ? 's' : ''}';
    } else {
      String departDate = _formatDate(trip['departDate']);
      String selectedTime = trip['selectedTime'] ?? '';
      String seats = trip['selectedSeats']?.isNotEmpty == true ? trip['selectedSeats'].join(', ') : '';
      String timeInfo = selectedTime.isNotEmpty ? ' • $selectedTime' : '';
      String seatInfo = seats.isNotEmpty ? ' • Seat $seats' : '';
      return 'Departure: $departDate$timeInfo$seatInfo';
    }
  }

  Widget _buildBottomNavItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToStay() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Bookinghotelmain()));
  }

  void _navigateToTransport() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Bookingtransportmain()));
  }

  void _navigateToAttraction() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Bookingattractionmain()));
  }

  void _navigateToAllinone() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Bookingallinone()));
  }

  void _navigateToHistory() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => History()));
  }

  void _navigateToDeals() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Deals()));
  }

  void _navigateToFavourite() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Favourite()));
  }

  void _navigateToLocation() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Location()));
  }

  void _navigateToProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
  }

  void _navigateToViewItinerary() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewItineraryPage()));
  }
}