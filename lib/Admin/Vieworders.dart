import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Vieworders extends StatefulWidget {
  @override
  ViewordersState createState() => ViewordersState();
}

class ViewordersState extends State<Vieworders> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> allBookings = [];
  bool isLoading = true;
  String selectedFilter = 'All';
  List<String> filterOptions = ['All', 'flight', 'transport', 'car', 'bus'];

  @override
  void initState() {
    super.initState();
    fetchAllBookings();
  }

  Future<void> fetchAllBookings() async {
    try {
      setState(() {
        isLoading = true;
      });

      Map<String, Map<String, dynamic>> usersLookup = {};

      // Get user data from Users collection (capital U)
      try {
        DatabaseEvent usersEvent = await _database.child('Users').once();
        DataSnapshot usersSnapshot = usersEvent.snapshot;

        if (usersSnapshot.exists) {
          // Safe casting with proper type conversion
          final usersData = usersSnapshot.value;
          if (usersData is Map) {
            Map<String, dynamic> convertedUsersData = Map<String, dynamic>.from(usersData);

            // Create lookup map for users
            convertedUsersData.forEach((userId, userData) {
              if (userData is Map) {
                String userIdStr = userId.toString();
                Map<String, dynamic> userDataMap = Map<String, dynamic>.from(userData);
                usersLookup[userIdStr] = {
                  'name': userDataMap['name']?.toString() ?? 'No name',
                  'email': userDataMap['email']?.toString() ?? 'No email',
                  'phone': userDataMap['phone']?.toString() ?? 'No phone',
                  'emailVerified': userDataMap['emailVerified'] ?? false,
                  'uid': userDataMap['uid']?.toString() ?? userIdStr,
                };
              }
            });
          }
        }
      } catch (e) {
        print('Error fetching Users collection: $e');
      }

      // Now get all bookings from users collection (lowercase u)
      DatabaseEvent usersBookingsEvent = await _database.child('users').once();
      DataSnapshot usersBookingsSnapshot = usersBookingsEvent.snapshot;

      List<Map<String, dynamic>> bookingsData = [];

      if (usersBookingsSnapshot.exists) {
        final usersBookingsData = usersBookingsSnapshot.value;
        if (usersBookingsData is Map) {
          Map<String, dynamic> convertedUsersBookingsData = Map<String, dynamic>.from(usersBookingsData);

          // Loop through each user in the users collection
          for (String userId in convertedUsersBookingsData.keys) {
            final userData = convertedUsersBookingsData[userId];
            if (userData is Map) {
              Map<String, dynamic> userDataMap = Map<String, dynamic>.from(userData);

              // Check if user has bookings
              if (userDataMap['bookings'] != null) {
                final userBookings = userDataMap['bookings'];
                if (userBookings is Map) {
                  Map<String, dynamic> userBookingsMap = Map<String, dynamic>.from(userBookings);

                  // Loop through each booking
                  for (String bookingId in userBookingsMap.keys) {
                    final bookingData = userBookingsMap[bookingId];
                    if (bookingData is Map) {
                      // Convert to proper format
                      Map<String, dynamic> formattedBooking = Map<String, dynamic>.from(bookingData);

                      // Add user info to booking data
                      formattedBooking['userId'] = userId;
                      formattedBooking['bookingDocId'] = bookingId;

                      // Look up user details from Users collection
                      if (usersLookup.containsKey(userId)) {
                        formattedBooking['userName'] = usersLookup[userId]!['name'];
                        formattedBooking['userEmail'] = usersLookup[userId]!['email'];
                        formattedBooking['userPhone'] = usersLookup[userId]!['phone'];
                        formattedBooking['emailVerified'] = usersLookup[userId]!['emailVerified'];
                      } else {
                        // Try to find by uid field or transport userId
                        String? matchedUserId;

                        // Check if any user's uid matches our userId
                        for (String key in usersLookup.keys) {
                          if (usersLookup[key]!['uid'] == userId) {
                            matchedUserId = key;
                            break;
                          }
                        }

                        // If still not found, try transport userId
                        if (matchedUserId == null && formattedBooking['transport'] != null) {
                          final transport = formattedBooking['transport'];
                          if (transport is Map) {
                            Map<String, dynamic> transportMap = Map<String, dynamic>.from(transport);
                            String transportUserId = transportMap['userId']?.toString() ?? '';
                            if (usersLookup.containsKey(transportUserId)) {
                              matchedUserId = transportUserId;
                            } else {
                              // Check if transport userId matches any uid field
                              for (String key in usersLookup.keys) {
                                if (usersLookup[key]!['uid'] == transportUserId) {
                                  matchedUserId = key;
                                  break;
                                }
                              }
                            }
                          }
                        }

                        if (matchedUserId != null) {
                          formattedBooking['userName'] = usersLookup[matchedUserId]!['name'];
                          formattedBooking['userEmail'] = usersLookup[matchedUserId]!['email'];
                          formattedBooking['userPhone'] = usersLookup[matchedUserId]!['phone'];
                          formattedBooking['emailVerified'] = usersLookup[matchedUserId]!['emailVerified'];
                        } else {
                          formattedBooking['userName'] = 'User data not found';
                          formattedBooking['userEmail'] = 'Email not found';
                          formattedBooking['userPhone'] = 'Phone not found';
                          formattedBooking['emailVerified'] = false;
                        }
                      }

                      bookingsData.add(formattedBooking);
                    }
                  }
                }
              }
            }
          }
        }
      }

      // Sort bookings by booking date (most recent first)
      bookingsData.sort((a, b) {
        String dateA = a['bookingDate']?.toString() ?? '';
        String dateB = b['bookingDate']?.toString() ?? '';
        return dateB.compareTo(dateA);
      });

      setState(() {
        allBookings = bookingsData;
        isLoading = false;
      });

    } catch (e) {
      print('Error fetching bookings: $e');
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bookings: $e')),
      );
    }
  }

  List<Map<String, dynamic>> getFilteredBookings() {
    if (selectedFilter == 'All') {
      return allBookings;
    }

    return allBookings.where((booking) {
      String bookingType = booking['bookingType']?.toString().toLowerCase() ?? '';
      String transportType = '';

      // Safe access to transport type
      final transport = booking['transport'];
      if (transport is Map) {
        transportType = transport['type']?.toString().toLowerCase() ?? '';
      }

      if (selectedFilter.toLowerCase() == 'transport') {
        return bookingType == 'transport';
      } else if (selectedFilter.toLowerCase() == 'car') {
        return bookingType == 'transport' && transportType == 'car';
      } else if (selectedFilter.toLowerCase() == 'bus') {
        return bookingType == 'transport' && transportType == 'bus';
      } else if (selectedFilter.toLowerCase() == 'flight') {
        return bookingType == 'flight';
      }

      return bookingType == selectedFilter.toLowerCase();
    }).toList();
  }

  Map<String, int> getBookingStats() {
    Map<String, int> stats = {
      'total': allBookings.length,
      'flight': 0,
      'transport': 0,
      'car': 0,
      'bus': 0,
      'confirmed': 0,
      'pending': 0,
      'cancelled': 0,
    };

    for (var booking in allBookings) {
      String bookingType = booking['bookingType']?.toString().toLowerCase() ?? '';
      String transportType = '';

      // Safe access to transport type
      final transport = booking['transport'];
      if (transport is Map) {
        transportType = transport['type']?.toString().toLowerCase() ?? '';
      }

      String status = booking['status']?.toString().toLowerCase() ?? '';

      if (bookingType == 'flight') {
        stats['flight'] = stats['flight']! + 1;
      } else if (bookingType == 'transport') {
        stats['transport'] = stats['transport']! + 1;
        if (transportType == 'car') {
          stats['car'] = stats['car']! + 1;
        } else if (transportType == 'bus') {
          stats['bus'] = stats['bus']! + 1;
        }
      }

      if (status == 'confirmed') {
        stats['confirmed'] = stats['confirmed']! + 1;
      } else if (status == 'pending') {
        stats['pending'] = stats['pending']! + 1;
      } else if (status == 'cancelled') {
        stats['cancelled'] = stats['cancelled']! + 1;
      }
    }

    return stats;
  }

  String formatDate(dynamic date) {
    if (date == null) return 'N/A';

    String dateStr = date.toString();
    if (dateStr.isEmpty) return 'N/A';

    try {
      if (dateStr.contains('T')) {
        DateTime parsedDate = DateTime.parse(dateStr);
        return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year} ${parsedDate.hour}:${parsedDate.minute.toString().padLeft(2, '0')}';
      } else if (dateStr.contains('-')) {
        DateTime parsedDate = DateTime.parse(dateStr);
        return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredBookings = getFilteredBookings();
    Map<String, int> stats = getBookingStats();

    return Scaffold(
      appBar: AppBar(
        title: Text("All Orders"),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchAllBookings,
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading bookings...'),
          ],
        ),
      )
          : allBookings.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No bookings found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: fetchAllBookings,
              child: Text('Retry'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Filter dropdown
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: selectedFilter,
                  items: filterOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFilter = newValue!;
                    });
                  },
                ),
                Spacer(),
                Text('Showing: ${filteredBookings.length} bookings'),
              ],
            ),
          ),
          // Bookings list
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchAllBookings,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: filteredBookings.length,
                itemBuilder: (context, index) {
                  final booking = filteredBookings[index];
                  return EnhancedBookingCard(booking: booking);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class EnhancedBookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const EnhancedBookingCard({Key? key, required this.booking}) : super(key: key);

  String formatDate(dynamic date) {
    if (date == null) return 'N/A';

    String dateStr = date.toString();
    if (dateStr.isEmpty) return 'N/A';

    try {
      if (dateStr.contains('T')) {
        DateTime parsedDate = DateTime.parse(dateStr);
        return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year} ${parsedDate.hour}:${parsedDate.minute.toString().padLeft(2, '0')}';
      } else if (dateStr.contains('-')) {
        DateTime parsedDate = DateTime.parse(dateStr);
        return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData getBookingTypeIcon(String? bookingType, Map<String, dynamic>? transport) {
    String type = bookingType?.toLowerCase() ?? '';
    if (type == 'flight') {
      return Icons.flight;
    } else if (type == 'transport') {
      String transportType = transport?['type']?.toString().toLowerCase() ?? '';
      if (transportType == 'car') {
        return Icons.directions_car;
      } else if (transportType == 'bus') {
        return Icons.directions_bus;
      }
      return Icons.directions;
    }
    return Icons.book;
  }

  Color getBookingTypeColor(String? bookingType, Map<String, dynamic>? transport) {
    String type = bookingType?.toLowerCase() ?? '';
    if (type == 'flight') {
      return Color(0xFF7107F3);
    } else if (type == 'transport') {
      return Colors.green.shade700;
    }
    return Colors.grey.shade700;
  }

  @override
  Widget build(BuildContext context) {
    String bookingType = booking['bookingType']?.toString() ?? 'Unknown';
    Map<String, dynamic>? transport;

    // Safe conversion of transport data
    final transportData = booking['transport'];
    if (transportData is Map) {
      transport = Map<String, dynamic>.from(transportData);
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with booking type, ID and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        getBookingTypeIcon(bookingType, transport),
                        color: getBookingTypeColor(bookingType, transport),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${bookingType.toUpperCase()}${transport != null ? ' - ${transport['type'] ?? ''}' : ''}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: getBookingTypeColor(bookingType, transport),
                              ),
                            ),
                            Text(
                              'ID: ${booking['bookingId'] ?? booking['bookingDocId'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusColor(booking['status']),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '${booking['status'] ?? 'UNKNOWN'}'.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Customer information
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.person, color: Colors.white, size: 16),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Customer Information',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      if (booking['emailVerified'] == true) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'VERIFIED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 8),
                  _buildCustomerDetailRow('Name', booking['userName'] ?? 'No name', Icons.person_outline),
                  _buildCustomerDetailRow('Email', booking['userEmail'] ?? 'No email', Icons.email_outlined),
                  _buildCustomerDetailRow('Phone', booking['userPhone'] ?? 'No phone', Icons.phone_outlined),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Service-specific details
            if (bookingType.toLowerCase() == 'flight') ...[
              _buildFlightDetails(),
            ] else if (bookingType.toLowerCase() == 'transport') ...[
              _buildTransportDetails(transport),
            ],

            SizedBox(height: 12),

            // Booking details
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildDetailRow('Booking Date', formatDate(booking['bookingDate']), Icons.calendar_today),
                  _buildDetailRow('Departure Date', formatDate(booking['departDate']), Icons.flight_takeoff),
                  if (booking['numberOfDays'] != null)
                    _buildDetailRow('Duration', '${booking['numberOfDays']} days', Icons.schedule),
                  _buildDetailRow('Payment Method', booking['paymentMethod'] ?? 'N/A', Icons.payment),
                  _buildDetailRow('Total Price', 'MYR ${booking['totalPrice'] ?? 'N/A'}', Icons.attach_money),
                  if (booking['cardLastFour'] != null)
                    _buildDetailRow('Card Last 4', '**** ${booking['cardLastFour']}', Icons.credit_card),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightDetails() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flight, color: Colors.purple.shade700, size: 16),
              SizedBox(width: 8),
              Text(
                'Flight Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (booking['airline'] != null)
            Text('Airline: ${booking['airline']}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
          if (booking['flightNumber'] != null)
            Text('Flight: ${booking['flightNumber']}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
          if (booking['route'] != null)
            Text('Route: ${booking['route']}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
          if (booking['selectedClass'] != null)
            Text('Class: ${booking['selectedClass']}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
          if (booking['numberOfPassengers'] != null)
            Text('Passengers: ${booking['numberOfPassengers']}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
        ],
      ),
    );
  }

  Widget _buildTransportDetails(Map<String, dynamic>? transport) {
    if (transport == null) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                  transport['type']?.toString().toLowerCase() == 'car'
                      ? Icons.directions_car
                      : Icons.directions_bus,
                  color: Colors.green.shade700,
                  size: 16
              ),
              SizedBox(width: 8),
              Text(
                'Transport Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (transport['type'] != null)
            Text('Type: ${transport['type']}', style: TextStyle(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
          if (transport['name'] != null)
            Text('Vehicle: ${transport['name']}', style: TextStyle(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
          if (transport['plateNumber'] != null)
            Text('Plate: ${transport['plateNumber']}', style: TextStyle(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
          if (transport['type']?.toString().toLowerCase() == 'car' && transport['location'] != null)
            Text('Location: ${transport['location']}', style: TextStyle(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
          if (transport['type']?.toString().toLowerCase() == 'bus') ...[
            if (transport['origin'] != null && transport['destination'] != null)
              Text('Route: ${transport['origin']} → ${transport['destination']}', style: TextStyle(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
          ],
          if (transport['maxPassengers'] != null)
            Text('Max Passengers: ${transport['maxPassengers']}', style: TextStyle(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
          if (transport['price'] != null)
            Text('Price per ${transport['priceType'] ?? 'unit'}: MYR ${transport['price']}', style: TextStyle(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.blue.shade600),
          SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}