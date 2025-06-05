import 'package:flutter/material.dart';
import 'package:localquest/Homepage.dart';
import 'package:localquest/Module_Booking_Management/Location.dart';
import 'package:localquest/Module_User_Account/Favourite.dart';
import 'package:localquest/Module_User_Account/Profile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

@override
void SavedIcon(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Favourite();
  }));
}

@override
void MytripsIcon(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return History();
  }));
}

@override
void AttractionsIcon(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Location();
  }));
}

@override
void ProfileIcon(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Profile();
  }));
}

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _filteredBookings = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBookings();
    _searchController.addListener(_filterBookings);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
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
          List<Map<String, dynamic>> loadedBookings = [];

          bookingsData.forEach((key, value) {
            Map<String, dynamic> booking = Map<String, dynamic>.from(value);
            booking['key'] = key;
            loadedBookings.add(booking);
          });

          // Sort bookings by booking date (newest first)
          loadedBookings.sort((a, b) {
            DateTime dateA = DateTime.parse(a['bookingDate'] ?? DateTime.now().toIso8601String());
            DateTime dateB = DateTime.parse(b['bookingDate'] ?? DateTime.now().toIso8601String());
            return dateB.compareTo(dateA);
          });

          setState(() {
            _bookings = loadedBookings;
            _filteredBookings = loadedBookings;
            _isLoading = false;
          });
        } else {
          setState(() {
            _bookings = [];
            _filteredBookings = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading bookings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterBookings() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBookings = _bookings.where((booking) {
        String transportName = booking['transport']['name']?.toString().toLowerCase() ?? '';
        String status = booking['status']?.toString().toLowerCase() ?? '';
        return transportName.contains(query) || status.contains(query);
      }).toList();
    });
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('hh:mm a').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
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
    return Scaffold(
      appBar: AppBar(
        title: Text("My Trips"),
        backgroundColor: Color(0xFF0816A7),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search bar
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search bookings...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    prefixIcon: Icon(Icons.search, size: 20),
                  ),
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
              SizedBox(height: 20),

              // Loading indicator or bookings list
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF0816A7),
                  ),
                )
              else if (_filteredBookings.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        _bookings.isEmpty ? "No bookings yet" : "No bookings found",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_bookings.isEmpty)
                        Text(
                          "Your completed bookings will appear here",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = _filteredBookings[index];
                    return _buildBookingCard(booking);
                  },
                ),
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
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Favourite()));
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite, color: Colors.white),
                  Text("Saved", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => History()));
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag, color: Color(0xFF0816A7)),
                  Text("My Trips", style: TextStyle(color: Color(0xFF0816A7))),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Homepage()));
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home, color: Colors.white),
                  Text("Home", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Location()));
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.park, color: Colors.white),
                  Text("Attractions", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, color: Colors.white),
                  Text("Profile", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with transport name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking['transport']['name'] ?? 'Transport',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0816A7),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking['status'] ?? 'pending').withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(booking['status'] ?? 'pending'),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    (booking['status'] ?? 'pending').toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(booking['status'] ?? 'pending'),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Booking details
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Booked: ${_formatDate(booking['bookingDate'])} at ${_formatTime(booking['bookingDate'])}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 8),

            if (booking['departDate'] != null) ...[
              Row(
                children: [
                  Icon(Icons.flight_takeoff, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Departure: ${_formatDate(booking['departDate'])}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],

            if (booking['returnDate'] != null) ...[
              Row(
                children: [
                  Icon(Icons.flight_land, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Return: ${_formatDate(booking['returnDate'])}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],

            if (booking['selectedTime'] != null) ...[
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Time: ${booking['selectedTime']}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],

            if (booking['selectedSeats'] != null && booking['selectedSeats'].isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.event_seat, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Seats: ${booking['selectedSeats'].join(', ')}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],

            if (booking['numberOfDays'] != null) ...[
              Row(
                children: [
                  Icon(Icons.date_range, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Duration: ${booking['numberOfDays']} days',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],

            // Payment info and total
            Row(
              children: [
                Icon(Icons.payment, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Payment: ${booking['paymentMethod'] ?? 'N/A'}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                if (booking['cardLastFour'] != null) ...[
                  Text(
                    ' ending in ${booking['cardLastFour']}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ],
            ),
            SizedBox(height: 12),

            // Total price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking ID: ${booking['bookingId'] ?? 'N/A'}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'RM ${booking['totalPrice']?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0816A7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}