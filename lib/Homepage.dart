import 'package:localquest/Module_Booking_Management/Bookingallinone.dart';
import 'package:localquest/Module_Booking_Management/Bookingattractionmain.dart';
import 'package:localquest/Module_Booking_Management/Bookinghotel.dart';
import 'package:localquest/Module_Booking_Management/Bookingtransportmain.dart';
import 'package:localquest/Module_Booking_Management/History.dart';
import 'package:localquest/Module_Booking_Management/Location.dart';
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

  DateTime _getRelevantDate(Map<String, dynamic> booking) {
    try {
      if (booking['returnDate'] != null) {
        return DateTime.parse(booking['returnDate']);
      } else if (booking['departDate'] != null) {
        return DateTime.parse(booking['departDate']);
      } else {
        return DateTime.parse(booking['bookingDate'] ?? DateTime.now().toIso8601String());
      }
    } catch (e) {
      return DateTime.now();
    }
  }

  bool _isUpcoming(Map<String, dynamic> booking) {
    DateTime relevantDate = _getRelevantDate(booking);
    String status = booking['status']?.toString().toLowerCase() ?? 'pending';

    return relevantDate.isAfter(DateTime.now()) ||
        (status != 'completed' && status != 'cancelled' &&
            relevantDate.isAfter(DateTime.now().subtract(Duration(days: 1))));
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
                height: screenHeight * 0.43,
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildServiceCard(
                      'Stay',
                      Icons.hotel_outlined,
                      [Color(0xFFFF4502), Color(0xFFFFFF00)],
                      Colors.black54,
                          () => _navigateToStay(),
                    ),
                    _buildServiceCard(
                      'Transport',
                      Icons.directions_train_outlined,
                      [Color(0xFF7107F3), Color(0xFFFF02FA)],
                      Colors.black54,
                          () => _navigateToTransport(),
                    ),
                    _buildServiceCard(
                      'Attractions',
                      Icons.park_outlined,
                      [Color(0xFF0C1FF7), Color(0xFF02BFFF)],
                      Colors.black54,
                          () => _navigateToAttraction(),
                    ),
                    _buildServiceCard(
                      'Generate\nItinerary',
                      Icons.dashboard_outlined,
                      [Color(0xFF02ED64), Color(0xFFFFFA02)],
                      Colors.black54,
                          () => _navigateToAllinone(),
                    ),
                  ],
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
        height: 100,
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
      return Container(
        width: double.infinity,
        height: 100,
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
              Icon(Icons.schedule, color: Colors.grey[400], size: 32),
              SizedBox(height: 8),
              Text(
                'No upcoming trips',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final trip = _nextUpcomingTrip!;
    final transportName = trip['transport']?['name'] ?? 'Transport';
    final departDate = _formatDate(trip['departDate']);
    final departTime = trip['selectedTime'] ?? _formatTime(trip['departDate']);
    final seats = trip['selectedSeats']?.isNotEmpty == true ? trip['selectedSeats'].join(', ') : 'N/A';
    final status = trip['status'] ?? 'pending';

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    transportName,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getStatusColor(status)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '$departDate - $departTime - Seat $seats',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'View Details',
              style: TextStyle(
                color: Color(0xFF0181F9),
                fontSize: 12,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
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
}