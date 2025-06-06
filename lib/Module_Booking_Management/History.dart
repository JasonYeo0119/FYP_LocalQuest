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

class _HistoryState extends State<History> with SingleTickerProviderStateMixin {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _allBookings = [];
  List<Map<String, dynamic>> _upcomingBookings = [];
  List<Map<String, dynamic>> _completedBookings = [];
  List<Map<String, dynamic>> _filteredUpcoming = [];
  List<Map<String, dynamic>> _filteredCompleted = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
    _searchController.addListener(_filterBookings);
  }

  @override
  void dispose() {
    _tabController.dispose();
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

          // Update booking statuses and separate upcoming and completed bookings
          List<Map<String, dynamic>> upcoming = [];
          List<Map<String, dynamic>> completed = [];

          for (var booking in loadedBookings) {
            // Update status based on trip date
            await _updateBookingStatus(booking, user.uid);

            if (_isUpcoming(booking)) {
              upcoming.add(booking);
            } else {
              completed.add(booking);
            }
          }

          // Sort upcoming bookings by departure date (closest first)
          upcoming.sort((a, b) {
            DateTime dateA = _getRelevantDate(a);
            DateTime dateB = _getRelevantDate(b);
            return dateA.compareTo(dateB);
          });

          // Sort completed bookings by departure date (most recent first)
          completed.sort((a, b) {
            DateTime dateA = _getRelevantDate(a);
            DateTime dateB = _getRelevantDate(b);
            return dateB.compareTo(dateA);
          });

          setState(() {
            _allBookings = loadedBookings;
            _upcomingBookings = upcoming;
            _completedBookings = completed;
            _filteredUpcoming = upcoming;
            _filteredCompleted = completed;
            _isLoading = false;
          });
        } else {
          setState(() {
            _allBookings = [];
            _upcomingBookings = [];
            _completedBookings = [];
            _filteredUpcoming = [];
            _filteredCompleted = [];
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

  Future<void> _updateBookingStatus(Map<String, dynamic> booking, String userId) async {
    try {
      DateTime relevantDate = _getRelevantDate(booking);
      String currentStatus = booking['status']?.toString().toLowerCase() ?? 'pending';

      // Only update if the trip has passed and status is not already completed or cancelled
      if (relevantDate.isBefore(DateTime.now()) &&
          currentStatus != 'completed' &&
          currentStatus != 'cancelled') {

        // Update the booking status to completed
        booking['status'] = 'completed';

        // Update in Firebase database
        await _database
            .child('users')
            .child(userId)
            .child('bookings')
            .child(booking['key'])
            .child('status')
            .set('completed');

        print('Updated booking ${booking['bookingId']} status to completed');
      }
    } catch (e) {
      print('Error updating booking status: $e');
    }
  }

  DateTime _getRelevantDate(Map<String, dynamic> booking) {
    // Priority: returnDate > departDate > bookingDate
    // Use return date first as it's when the trip actually ends
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

    // A booking is upcoming if:
    // 1. The relevant date is in the future, OR
    // 2. The status is confirmed/pending and the date hasn't passed by more than 1 day
    return relevantDate.isAfter(DateTime.now()) ||
        (status != 'completed' && status != 'cancelled' &&
            relevantDate.isAfter(DateTime.now().subtract(Duration(days: 1))));
  }

  void _filterBookings() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUpcoming = _upcomingBookings.where((booking) {
        String transportName = booking['transport']['name']?.toString().toLowerCase() ?? '';
        String bookingId = booking['bookingId']?.toString().toLowerCase() ?? '';
        return transportName.contains(query) || bookingId.contains(query);
      }).toList();

      _filteredCompleted = _completedBookings.where((booking) {
        String transportName = booking['transport']['name']?.toString().toLowerCase() ?? '';
        String bookingId = booking['bookingId']?.toString().toLowerCase() ?? '';
        return transportName.contains(query) || bookingId.contains(query);
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

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(List<Map<String, dynamic>> bookings) {
    if (bookings.isEmpty) {
      return _buildEmptyState(
        _tabController.index == 0 ? "No upcoming trips" : "No completed trips",
        _tabController.index == 0
            ? "Your upcoming bookings will appear here"
            : "Your completed bookings will appear here",
        _tabController.index == 0 ? Icons.schedule : Icons.history,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Trips",
          style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),),
        backgroundColor: Color(0xFF0816A7),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 20),
                  SizedBox(width: 8),
                  Text('Upcoming (${_upcomingBookings.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 20),
                  SizedBox(width: 8),
                  Text('Completed (${_completedBookings.length})'),
                ],
              ),
            ),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: EdgeInsets.all(16),
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
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                prefixIcon: Icon(Icons.search, size: 20),
              ),
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),

          // Tab content
          Expanded(
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0816A7),
              ),
            )
                : TabBarView(
              controller: _tabController,
              children: [
                // Upcoming bookings
                _buildBookingsList(_filteredUpcoming),
                // Completed bookings
                _buildBookingsList(_filteredCompleted),
              ],
            ),
          ),
        ],
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