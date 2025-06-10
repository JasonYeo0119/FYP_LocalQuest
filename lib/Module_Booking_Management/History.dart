import 'dart:convert';

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
  String _selectedFilter = 'All'; // Add this line
  List<String> _filterOptions = ['All', 'Accommodation', 'Transport', 'Attraction']; // Add this line
  List<Map<String, dynamic>> _allBookings = [];
  List<Map<String, dynamic>> _upcomingBookings = [];
  List<Map<String, dynamic>> _completedBookings = [];
  List<Map<String, dynamic>> _filteredUpcoming = [];
  List<Map<String, dynamic>> _filteredCompleted = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();
  bool _isFerryBooking(Map<String, dynamic> booking) {
    return booking['bookingType']?.toString().toLowerCase() == 'ferry' ||
        booking['transportType']?.toString().toLowerCase() == 'ferry';
  }

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
    // Check booking type and get appropriate date
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
        bool matchesSearch = _matchesSearch(booking, query);
        bool matchesFilter = _matchesFilter(booking);
        return matchesSearch && matchesFilter;
      }).toList();

      _filteredCompleted = _completedBookings.where((booking) {
        bool matchesSearch = _matchesSearch(booking, query);
        bool matchesFilter = _matchesFilter(booking);
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  bool _matchesSearch(Map<String, dynamic> booking, String query) {
    String bookingType = booking['bookingType']?.toString() ?? 'transport';
    String searchableName = '';
    String bookingId = booking['bookingId']?.toString().toLowerCase() ?? '';

    // Get room types for search
    List<String> roomTypes = _getAllRoomTypes(booking);
    String roomTypesString = roomTypes.join(' ').toLowerCase();

    // Ferry-specific search terms
    String ferryTicketType = booking['ferryTicketType']?.toString().toLowerCase() ?? '';
    String ferryPax = booking['ferryNumberOfPax']?.toString() ?? '';

    if (bookingType == 'hotel') {
      searchableName = booking['hotel']?['name']?.toString().toLowerCase() ?? '';
    } else if (bookingType == 'attraction') {
      searchableName = booking['attraction']?['name']?.toString().toLowerCase() ?? '';
    } else {
      searchableName = booking['transport']?['name']?.toString().toLowerCase() ?? '';
    }

    return searchableName.contains(query) ||
        bookingId.contains(query) ||
        bookingType.contains(query) ||
        roomTypesString.contains(query) ||
        ferryTicketType.contains(query) ||  // Add this line
        ferryPax.contains(query);           // Add this line
  }

  bool _matchesFilter(Map<String, dynamic> booking) {
    if (_selectedFilter == 'All') return true;

    String bookingType = booking['bookingType']?.toString() ?? 'transport';

    switch (_selectedFilter) {
      case 'Accommodation':
        return bookingType == 'hotel';
      case 'Transport':
        return bookingType == 'transport' ||
            bookingType == 'flight' ||
            bookingType == 'ferry' ||  // Add this line
            _isFerryBooking(booking);  // Add this line
      case 'Attraction':
        return bookingType == 'attraction';
      default:
        return true;
    }
  }

  // Helper method to get all room types from a booking for search purposes
  List<String> _getAllRoomTypes(Map<String, dynamic> booking) {
    List<String> roomTypes = [];

    // Check for new format (selectedRoomTypes array)
    if (booking['selectedRoomTypes'] != null && booking['selectedRoomTypes'] is List) {
      List<dynamic> selectedRoomTypes = booking['selectedRoomTypes'];
      for (var roomType in selectedRoomTypes) {
        if (roomType is Map && roomType['roomType'] != null) {
          roomTypes.add(roomType['roomType'].toString());
        }
      }
    }

    // Check for legacy format (single selectedRoomType)
    if (booking['selectedRoomType'] != null) {
      roomTypes.add(booking['selectedRoomType'].toString());
    }

    // Check hotel object for room type
    if (booking['hotel']?['selectedRoomType'] != null) {
      roomTypes.add(booking['hotel']['selectedRoomType'].toString());
    }

    return roomTypes;
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

  // Get QR code from Firebase
  Future<Map<String, dynamic>?> getQRCodeDataForBooking(String bookingId) async {
    try {
      DatabaseEvent event = await _database.child('qr_codes').child(bookingId).once();
      if (event.snapshot.exists) {
        Map<String, dynamic> qrData = Map<String, dynamic>.from(event.snapshot.value as Map);
        return qrData;
      }
      return null;
    } catch (e) {
      print('Error getting QR code data: $e');
      return null;
    }
  }

  // Display QR code from base64
  Widget displayQRCode(String base64String) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.memory(
        base64Decode(base64String),
        width: 200,
        height: 200,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget buildBookingDetails(Map<String, dynamic> bookingData) {
    // Format dates
    String formatDate(String dateString) {
      try {
        DateTime date = DateTime.parse(dateString);
        return DateFormat('MMM dd, yyyy').format(date);
      } catch (e) {
        return dateString;
      }
    }

    String formatDateTime(String dateString) {
      try {
        DateTime date = DateTime.parse(dateString);
        return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
      } catch (e) {
        return dateString;
      }
    }

    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0816A7),
            ),
          ),
          SizedBox(height: 12),

          // Booking ID
          _buildDetailRow(
            'Booking ID',
            bookingData['bookingId'] ?? 'N/A',
            isMonospace: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isMonospace = false, bool isPrice = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
                fontFamily: isMonospace ? 'monospace' : null,
                color: isPrice ? Color(0xFF0816A7) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQRCodeDialog(String bookingId, String bookingType) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF0816A7),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your QR Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Content
                Container(
                  padding: EdgeInsets.all(20),
                  child: FutureBuilder<Map<String, dynamic>?>(
                    future: getQRCodeDataForBooking(bookingId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF0816A7),
                            ),
                          ),
                        );
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return Container(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 48, color: Colors.red),
                                SizedBox(height: 16),
                                Text(
                                  'QR Code not available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        Map<String, dynamic> qrData = snapshot.data!;
                        String? qrCodeImage = qrData['qrCodeImage'];

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              // QR Code
                              if (qrCodeImage != null) ...[
                                displayQRCode(qrCodeImage),
                                SizedBox(height: 16),
                                Text(
                                  'Show this QR code to the staff\n\nor\n\nGive your Booking ID to the staff',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 10),
                              ],

                              // Booking Details
                              buildBookingDetails(qrData),

                              SizedBox(height: 20),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
        String bookingType = booking['bookingType']?.toString() ?? 'transport';

        // Handle different booking types
        if (bookingType == 'hotel') {
          return _buildHotelBookingCard(booking);
        } else if (bookingType == 'attraction') {
          return _buildAttractionBookingCard(booking);
        } else if (bookingType == 'flight') {
          return _buildFlightBookingCard(booking);
        } else if (bookingType == 'ferry' || _isFerryBooking(booking)) {
          return _buildFerryBookingCard(booking);
        } else {
          return _buildTransportBookingCard(booking);
        }
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
                  Text('Upcoming (${_filteredUpcoming.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 20),
                  SizedBox(width: 8),
                  Text('Completed (${_filteredCompleted.length})'),
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
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                String filter = _filterOptions[index];
                bool isSelected = _selectedFilter == filter;

                return Container(
                  margin: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Color(0xFF0816A7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                      _filterBookings();
                    },
                    selectedColor: Color(0xFF0816A7),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: Color(0xFF0816A7),
                      width: 1,
                    ),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8), // Add some spacing

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

  Widget _buildRoomTypesDisplay(Map<String, dynamic> booking) {
    // Check for new format (selectedRoomTypes array)
    if (booking['selectedRoomTypes'] != null && booking['selectedRoomTypes'] is List) {
      List<dynamic> selectedRoomTypes = booking['selectedRoomTypes'];

      if (selectedRoomTypes.isNotEmpty) {
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.hotel_class, color: Colors.orange[600], size: 18),
                  SizedBox(width: 8),
                  Text(
                    selectedRoomTypes.length > 1 ? 'Room Types' : 'Room Type',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ...selectedRoomTypes.map<Widget>((roomType) {
                if (roomType is Map) {
                  String roomTypeName = roomType['roomType']?.toString() ?? 'Unknown Room';
                  int quantity = roomType['quantity'] ?? 1;
                  double pricePerNight = roomType['pricePerNight']?.toDouble() ?? 0.0;
                  double totalPrice = roomType['totalPrice']?.toDouble() ?? 0.0;

                  return Container(
                    margin: EdgeInsets.only(bottom: 6),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${quantity}x $roomTypeName',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ),
                            if (pricePerNight > 0)
                              Text(
                                'MYR ${pricePerNight.toStringAsFixed(0)}/night',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        if (totalPrice > 0) ...[
                          SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total for this room type:',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'MYR ${totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              }).toList(),
            ],
          ),
        );
      }
    }

    // Fallback to legacy format (single selectedRoomType)
    String? selectedRoomType = booking['selectedRoomType']?.toString() ??
        booking['hotel']?['selectedRoomType']?.toString();

    if (selectedRoomType != null) {
      double pricePerNight = booking['roomTypePrice']?.toDouble() ??
          booking['hotel']?['roomTypePrice']?.toDouble() ??
          booking['hotel']?['pricePerNight']?.toDouble() ??
          0.0;

      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.hotel_class, color: Colors.orange[600], size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Room Type',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    selectedRoomType,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                ],
              ),
            ),
            if (pricePerNight > 0)
              Text(
                'MYR ${pricePerNight.toStringAsFixed(0)}/night',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }

  Widget _buildHotelBookingCard(Map<String, dynamic> booking) {
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
            // Header with hotel name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.hotel, size: 20, color: Color(0xFFFF4502)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking['hotel']?['name'] ?? 'Hotel',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF4502),
                          ),
                        ),
                      ),
                    ],
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
            // Room Type Information (Enhanced)
            _buildRoomTypesDisplay(booking),
            SizedBox(height: 12),

            // Hotel Details
            if (booking['hotel']?['address'] != null) ...[
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking['hotel']['address'],
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],

            // Rating
            if (booking['hotel']?['rating'] != null) ...[
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber[600]),
                  SizedBox(width: 8),
                  Text(
                    '${booking['hotel']['rating']} ⭐',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],

            // Booking Details
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

            // Check-in Date
            if (booking['checkInDate'] != null) ...[
              Row(
                children: [
                  Icon(Icons.login, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Check-in: ${_formatDate(booking['checkInDate'])}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],

            // Check-out Date
            if (booking['checkOutDate'] != null) ...[
              Row(
                children: [
                  Icon(Icons.logout, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Check-out: ${_formatDate(booking['checkOutDate'])}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],

            // Duration
            if (booking['numberOfNights'] != null) ...[
              Row(
                children: [
                  Icon(Icons.nights_stay, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Duration: ${booking['numberOfNights']} night${booking['numberOfNights'] > 1 ? 's' : ''}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],

            // Room and Guest Details
            Row(
              children: [
                Icon(Icons.door_front_door, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Rooms: ${booking['numberOfRooms'] ?? 1}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                SizedBox(width: 20),
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Guests: ${booking['numberOfGuests'] ?? 1}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Payment Info
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

            // Enhanced Price Breakdown for Multiple Room Types
            _buildPriceBreakdown(booking),

            // Total price and booking ID
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
                  'MYR ${booking['totalPrice']?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF4502),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            if (booking['bookingId'] != null) ...[
              SizedBox(height: 8),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _showQRCodeDialog(
                      booking['bookingId'],
                      booking['bookingType'] ?? 'unknown'
                  ),
                  icon: Icon(Icons.qr_code, size: 20),
                  label: Text('View QR Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0816A7),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

      Widget _buildFerryBookingCard(Map<String, dynamic> booking) {
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
                // Header with ferry name and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.directions_boat, size: 20, color: Color(0xFF0816A7)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              booking['transport']?['name'] ?? 'Ferry Service',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0816A7),
                              ),
                            ),
                          ),
                        ],
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

                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.directions_boat, color: Colors.blue[700], size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${booking['transport']?['origin'] ?? 'Unknown'} → ${booking['transport']?['destination'] ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                if (booking['ferryNumberOfPax'] != null) ...[
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        'Passengers: ${booking['ferryNumberOfPax']}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
                if (booking['ferryTicketType'] != null) ...[
                  Row(
                    children: [
                      Icon(Icons.confirmation_number, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        'Ticket Type: ${booking['ferryTicketType'].toString().toUpperCase()}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
                if (booking['basePricePerPassenger'] != null) ...[
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        'Price per Passenger: MYR ${booking['basePricePerPassenger'].toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
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
                      Icon(Icons.sailing, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        'Travel Date: ${_formatDate(booking['departDate'])}',
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
                        'Departure Time: ${booking['selectedTime']}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],

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

                // Price breakdown for ferry
                if (booking['ferryNumberOfPax'] != null && booking['ferryNumberOfPax'] > 1) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price Breakdown',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Price per passenger:',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                            Text(
                              'MYR ${booking['pricePerPassenger']?.toStringAsFixed(2) ?? (booking['totalPrice'] / booking['ferryNumberOfPax']).toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${booking['ferryNumberOfPax']} passenger${booking['ferryNumberOfPax'] > 1 ? 's' : ''}:',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                            Text(
                              'MYR ${booking['totalPrice']?.toStringAsFixed(2) ?? '0.00'}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                ],
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
                        'MYR ${booking['totalPrice']?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0816A7),
                        ),
                      ),
                    ]
                ),
                SizedBox(height: 12),

                if (booking['bookingId'] != null) ...[
                  SizedBox(height: 8),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _showQRCodeDialog(
                          booking['bookingId'],
                          booking['bookingType'] ?? 'unknown'
                      ),
                      icon: Icon(Icons.qr_code, size: 20),
                      label: Text('View QR Code'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0816A7),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ],
            ),
          ),
        );
      }

    Widget _buildPriceBreakdown(Map<String, dynamic> booking) {
    // Check if we have multiple room types with detailed pricing
    if (booking['selectedRoomTypes'] != null && booking['selectedRoomTypes'] is List) {
      List<dynamic> selectedRoomTypes = booking['selectedRoomTypes'];

      if (selectedRoomTypes.isNotEmpty && booking['numberOfNights'] != null) {
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price Breakdown',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
              SizedBox(height: 8),
              ...selectedRoomTypes.map<Widget>((roomType) {
                if (roomType is Map) {
                  String roomTypeName = roomType['roomType']?.toString() ?? 'Unknown Room';
                  int quantity = roomType['quantity'] ?? 1;
                  double pricePerNight = roomType['pricePerNight']?.toDouble() ?? 0.0;
                  double totalPrice = roomType['totalPrice']?.toDouble() ?? 0.0;

                  return Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '$roomTypeName × $quantity × ${booking['numberOfNights']} night${booking['numberOfNights'] > 1 ? 's' : ''}:',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Text(
                          'MYR ${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              }).toList(),
            ],
          ),
        );
      }
    }

    // Fallback to legacy price breakdown
    double pricePerNight = booking['roomTypePrice']?.toDouble() ??
        booking['hotel']?['roomTypePrice']?.toDouble() ??
        booking['hotel']?['pricePerNight']?.toDouble() ??
        0.0;

    if (pricePerNight > 0 && booking['numberOfNights'] != null) {
      String? selectedRoomType = booking['selectedRoomType']?.toString() ??
          booking['hotel']?['selectedRoomType']?.toString();

      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedRoomType != null ? '$selectedRoomType per night:' : 'Price per night:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'MYR ${pricePerNight.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${booking['numberOfNights']} night${booking['numberOfNights'] > 1 ? 's' : ''} × ${booking['numberOfRooms'] ?? 1} room${(booking['numberOfRooms'] ?? 1) > 1 ? 's' : ''}:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'MYR ${booking['totalPrice']?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return SizedBox(height: 12);
  }

  Widget _buildTransportBookingCard(Map<String, dynamic> booking) {
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
                  child: Row(
                    children: [
                      Icon(Icons.directions_bus, size: 20, color: Color(0xFF0816A7)),
                      SizedBox(width: 8),
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
                    ],
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
            SizedBox(height: 12),

            if (booking['bookingId'] != null) ...[
              SizedBox(height: 8),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _showQRCodeDialog(
                      booking['bookingId'],
                      booking['bookingType'] ?? 'unknown'
                  ),
                  icon: Icon(Icons.qr_code, size: 20),
                  label: Text('View QR Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0816A7),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttractionBookingCard(Map<String, dynamic> booking) {
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
            // Header with attraction name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.attractions, size: 20, color: Color(0xFF0C1FF7)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking['attraction']?['name'] ?? 'Attraction',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0C1FF7),
                          ),
                        ),
                      ),
                    ],
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
            // Location info
            if (booking['attraction']?['city'] != null || booking['attraction']?['state'] != null) ...[
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    '${booking['attraction']?['city'] ?? ''}, ${booking['attraction']?['state'] ?? ''}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],

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

            if (booking['visitDate'] != null) ...[
              Row(
                children: [
                  Icon(Icons.event, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Visit Date: ${_formatDate(booking['visitDate'])}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],

            // Selected tickets
            if (booking['selectedTickets'] != null && booking['selectedTickets'].isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.confirmation_number, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Tickets:',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 4),
              ...booking['selectedTickets'].map<Widget>((ticket) => Padding(
                padding: EdgeInsets.only(left: 24, bottom: 4),
                child: Text(
                  '• ${ticket['type']}: ${ticket['quantity']} ticket${ticket['quantity'] > 1 ? 's' : ''} (RM ${ticket['subtotal'].toStringAsFixed(2)})',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              )).toList(),
              SizedBox(height: 8),
            ],

            // Payment info
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
                    color: Color(0xFF0C1FF7),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            if (booking['bookingId'] != null) ...[
              SizedBox(height: 8),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _showQRCodeDialog(
                      booking['bookingId'],
                      booking['bookingType'] ?? 'unknown'
                  ),
                  icon: Icon(Icons.qr_code, size: 20),
                  label: Text('View QR Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0816A7),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
  Widget _buildFlightBookingCard(Map<String, dynamic> booking) {
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
            // Header with flight info and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.flight, size: 20, color: Color(0xFF7107F3)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${booking['airline'] ?? 'Unknown Airline'} ${booking['flightNumber'] ?? ''}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7107F3),
                          ),
                        ),
                      ),
                    ],
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
            // Flight route
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.flight_takeoff, color: Colors.purple[700], size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking['route'] ?? '${booking['transport']?['origin'] ?? 'Unknown'} → ${booking['transport']?['destination'] ?? 'Unknown'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

            // Flight details
            if (booking['aircraft'] != null) ...[
              Row(
                children: [
                  Icon(Icons.airplanemode_active, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Aircraft: ${booking['aircraft']}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],

            if (booking['selectedClass'] != null) ...[
              Row(
                children: [
                  Icon(Icons.airline_seat_recline_normal, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Class: ${booking['selectedClass']}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],

            if (booking['departureTime'] != null && booking['arrivalTime'] != null) ...[
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Flight Time: ${booking['departureTime']} - ${booking['arrivalTime']}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],

            if (booking['duration'] != null) ...[
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Duration: ${booking['duration']}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
            // Detailed Passenger Information
            if (booking['passengerData'] != null) ...[
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.blue[700]),
                        SizedBox(width: 8),
                        Text(
                          'Passenger Details',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    // Convert passenger data to proper format
                    ...(() {
                      var passengerData = booking['passengerData'];
                      List<Widget> passengerWidgets = [];

                      if (passengerData is List) {
                        // If it's already a List
                        for (int index = 0; index < passengerData.length; index++) {
                          var passenger = passengerData[index];
                          if (passenger is Map) {
                            passengerWidgets.add(_buildPassengerCard(index, Map<String, dynamic>.from(passenger)));
                          }
                        }
                      } else if (passengerData is Map) {
                        // If it's a Map (Firebase format), convert to List
                        var passengerMap = Map<String, dynamic>.from(passengerData);
                        var sortedKeys = passengerMap.keys.toList()..sort();

                        for (int i = 0; i < sortedKeys.length; i++) {
                          var key = sortedKeys[i];
                          var passenger = passengerMap[key];
                          if (passenger is Map) {
                            passengerWidgets.add(_buildPassengerCard(i, Map<String, dynamic>.from(passenger)));
                          }
                        }
                      }

                      return passengerWidgets;
                    })(),
                  ],
                ),
              ),
            ] else if (booking['numberOfPassengers'] != null) ...[
              // Fallback for bookings without detailed passenger data
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Passengers: ${booking['numberOfPassengers']}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],

            // Add-ons summary (keep as backup)
            if (booking['checkedBaggageCount'] != null && booking['checkedBaggageCount'] > 0) ...[
              Row(
                children: [
                  Icon(Icons.luggage, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Total Checked Baggage: ${booking['checkedBaggageCount']} (MYR ${booking['totalBaggageCost']?.toStringAsFixed(0) ?? '0'})',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],

            if (booking['mealCount'] != null && booking['mealCount'] > 0) ...[
              Row(
                children: [
                  Icon(Icons.restaurant, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Total Meals: ${booking['mealCount']} (MYR ${booking['totalMealCost']?.toStringAsFixed(0) ?? '0'})',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],

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

            // Payment info
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

            // Price breakdown for flights with add-ons
            if (booking['additionalCosts'] != null && booking['additionalCosts'] > 0) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price Breakdown',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Base Price:',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                        Text(
                          'MYR ${booking['basePriceBeforeAddons']?.toStringAsFixed(2) ?? '0.00'}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add-ons:',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                        Text(
                          'MYR ${booking['additionalCosts']?.toStringAsFixed(2) ?? '0.00'}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
            ],

            // Total price and booking ID
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
                  'MYR ${booking['totalPrice']?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7107F3),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            if (booking['bookingId'] != null) ...[
              SizedBox(height: 8),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _showQRCodeDialog(
                      booking['bookingId'],
                      booking['bookingType'] ?? 'unknown'
                  ),
                  icon: Icon(Icons.qr_code, size: 20),
                  label: Text('View QR Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0816A7),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
  Widget _buildPassengerCard(int index, Map<String, dynamic> passenger) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passenger ${index + 1}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Name: ${passenger['givenName'] ?? ''} ${passenger['surname'] ?? ''}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Checked baggage: ${passenger['checkedBaggageWeight'] != null ? passenger['checkedBaggageWeight'] : 'No'}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Meal: ${passenger['selectedMeal'] != null && passenger['selectedMeal'] != 'None' ? 'Yes' : 'No'}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}