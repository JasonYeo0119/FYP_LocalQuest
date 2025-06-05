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
          Map<dynamic, dynamic> usersData = usersSnapshot.value as Map<dynamic, dynamic>;

          // Create lookup map for users
          usersData.forEach((userId, userData) {
            if (userData is Map) {
              String userIdStr = userId.toString();
              usersLookup[userIdStr] = {
                'name': userData['name']?.toString() ?? 'No name',
                'email': userData['email']?.toString() ?? 'No email',
                'phone': userData['phone']?.toString() ?? 'No phone',
                'emailVerified': userData['emailVerified'] ?? false,
                'uid': userData['uid']?.toString() ?? userIdStr,
              };
            }
          });
        }
      } catch (e) {
        print('Error fetching Users collection: $e');
      }

      // Now get all bookings from users collection (lowercase u)
      DatabaseEvent usersBookingsEvent = await _database.child('users').once();
      DataSnapshot usersBookingsSnapshot = usersBookingsEvent.snapshot;

      List<Map<String, dynamic>> bookingsData = [];

      if (usersBookingsSnapshot.exists) {
        Map<dynamic, dynamic> usersBookingsData = usersBookingsSnapshot.value as Map<dynamic, dynamic>;

        // Loop through each user in the users collection
        for (String userId in usersBookingsData.keys) {
          Map<dynamic, dynamic> userData = usersBookingsData[userId] as Map<dynamic, dynamic>;

          // Check if user has bookings
          if (userData['bookings'] != null) {
            Map<dynamic, dynamic> userBookings = userData['bookings'] as Map<dynamic, dynamic>;

            // Loop through each booking
            for (String bookingId in userBookings.keys) {
              Map<dynamic, dynamic> bookingData = userBookings[bookingId] as Map<dynamic, dynamic>;

              // Convert to proper format
              Map<String, dynamic> formattedBooking = {};

              bookingData.forEach((key, value) {
                formattedBooking[key.toString()] = value;
              });

              // Add user info to booking data
              formattedBooking['userId'] = userId;
              formattedBooking['bookingDocId'] = bookingId;

              // Look up user details from Users collection
              // Try exact match first
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
                  String transportUserId = formattedBooking['transport']['userId']?.toString() ?? '';
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

  String formatDate(dynamic date) {
    if (date == null) return 'N/A';

    String dateStr = date.toString();
    if (dateStr.isEmpty) return 'N/A';

    try {
      // Handle different date formats that might come from Firebase
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
          // Summary header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Text(
              'Total Bookings: ${allBookings.length}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Bookings list
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchAllBookings,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: allBookings.length,
                itemBuilder: (context, index) {
                  final booking = allBookings[index];
                  return BookingCard(booking: booking);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingCard({Key? key, required this.booking}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with booking ID and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Booking ID: ${booking['bookingId'] ?? booking['bookingDocId'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
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

            // Customer information from Users collection
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
                  _buildCustomerDetailRow('User ID', booking['userId'] ?? 'No ID', Icons.fingerprint),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Booking details in a grid layout
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
                  _buildDetailRow('Duration', '${booking['numberOfDays'] ?? 'N/A'} days', Icons.schedule),
                  _buildDetailRow('Payment Method', booking['paymentMethod'] ?? 'N/A', Icons.payment),
                  _buildDetailRow('Total Price', '\$${booking['totalPrice'] ?? 'N/A'}', Icons.attach_money),
                  if (booking['cardLastFour'] != null)
                    _buildDetailRow('Card Last 4', '**** ${booking['cardLastFour']}', Icons.credit_card),
                ],
              ),
            ),

            // Transport information if available
            if (booking['transport'] != null) ...[
              SizedBox(height: 12),
              Container(
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
                        Icon(Icons.directions_car, color: Colors.green.shade700, size: 16),
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
                    if (booking['transport']['userId'] != null)
                      Text(
                        'Transport User ID: ${booking['transport']['userId']}',
                        style: TextStyle(fontSize: 13),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
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