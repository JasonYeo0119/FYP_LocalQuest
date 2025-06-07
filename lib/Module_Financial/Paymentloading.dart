import 'dart:async';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localquest/Module_Financial/Paymentstatus_F.dart';
import 'package:localquest/Module_Financial/Paymentstatus_S.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:localquest/Model/attraction_model.dart';
import '../Model/hotel.dart';

class Paymentloading extends StatefulWidget {
  final String cardNumber;
  final String expiry;
  final String cvv;
  final double totalPrice;

  // Transport booking parameters (optional)
  final Map<String, dynamic>? transport;
  final String? selectedTime;
  final List<int> selectedSeats;
  final DateTime? departDate;
  final DateTime? returnDate;
  final int? numberOfDays;

  // Attraction booking parameters (optional)
  final Attraction? attraction;
  final List<Map<String, dynamic>>? selectedTickets;
  final DateTime? visitDate;

  // Hotel booking parameters (optional)
  final Hotel? hotel;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int? numberOfGuests;
  final int? numberOfRooms;
  final int? numberOfNights;

  // Updated room type parameters - now supports multiple room types
  final List<Map<String, dynamic>>? selectedRoomTypes;

  const Paymentloading({
    Key? key,
    required this.cardNumber,
    required this.expiry,
    required this.cvv,
    required this.totalPrice,
    // Transport parameters
    this.transport,
    this.selectedTime,
    this.selectedSeats = const [],
    this.departDate,
    this.returnDate,
    this.numberOfDays,
    // Attraction parameters
    this.attraction,
    this.selectedTickets,
    this.visitDate,
    // Hotel parameters
    this.hotel,
    this.checkInDate,
    this.checkOutDate,
    this.numberOfGuests,
    this.numberOfRooms,
    this.numberOfNights,
    // Updated room type parameters
    this.selectedRoomTypes,
  }) : super(key: key);

  @override
  _PaymentloadingState createState() => _PaymentloadingState();
}

class _PaymentloadingState extends State<Paymentloading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isProcessing = true;

  // Firebase references
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Define the valid card details here
  static const String VALID_CARD_NUMBER = "4848100061531890";
  static const String VALID_CARD_DATE = "1226";
  static const String VALID_CARD_CVV = "550";

  // Check booking types
  bool get isAttractionBooking => widget.attraction != null;
  bool get isHotelBooking => widget.hotel != null;
  bool get isTransportBooking => widget.transport != null;

  // Method to generate random booking ID
  String _generateBookingId() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    int length = 8 + random.nextInt(2); // Random length between 8-9 characters

    return String.fromCharCodes(Iterable.generate(
        length,
            (_) => chars.codeUnitAt(random.nextInt(chars.length))
    ));
  }

  @override
  void initState() {
    super.initState();

    // Setup animation for loading indicator
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Timer to navigate after 6 seconds
    Timer(Duration(seconds: 6), () {
      setState(() {
        _isProcessing = false;
      });

      // Verify card number and navigate accordingly
      _verifyCardNumberAndNavigate();
    });
  }

  Future<void> _saveBookingToFirebase() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String userId = user.uid;
        String bookingId = _generateBookingId(); // Use custom booking ID generator

        Map<String, dynamic> bookingData = {
          'bookingId': bookingId,
          'userId': userId,
          'totalPrice': widget.totalPrice,
          'bookingDate': DateTime.now().toIso8601String(),
          'status': 'confirmed',
          'paymentMethod': 'Credit Card',
          'cardLastFour': widget.cardNumber.substring(widget.cardNumber.length - 4),
          'bookingType': _getBookingType(),
        };

        // Add booking-specific data
        if (isHotelBooking) {
          // Hotel booking data with multiple room types information
          Map<String, dynamic> hotelData = {
            'name': widget.hotel!.name,
            'address': widget.hotel!.address,
            'rating': widget.hotel!.rating,
            'pricePerNight': widget.hotel!.price,
            'imageUrl': widget.hotel!.imageUrl,
            'amenities': widget.hotel!.amenities,
          };

          bookingData.addAll({
            'hotel': hotelData,
            'checkInDate': widget.checkInDate?.toIso8601String(),
            'checkOutDate': widget.checkOutDate?.toIso8601String(),
            'numberOfGuests': widget.numberOfGuests,
            'numberOfRooms': widget.numberOfRooms,
            'numberOfNights': widget.numberOfNights,
          });

          // Add multiple room types information
          if (widget.selectedRoomTypes != null && widget.selectedRoomTypes!.isNotEmpty) {
            // Save the complete room type details
            bookingData['selectedRoomTypes'] = widget.selectedRoomTypes;

            // Create a summary of room types for easy querying
            List<String> roomTypeSummary = [];
            double totalRoomTypePrice = 0.0;

            for (var roomTypeData in widget.selectedRoomTypes!) {
              String roomType = roomTypeData['roomType'] ?? 'Unknown Room';
              int quantity = roomTypeData['quantity'] ?? 1;
              double pricePerNight = roomTypeData['pricePerNight'] ?? 0.0;
              double totalPrice = roomTypeData['totalPrice'] ?? 0.0;

              roomTypeSummary.add('${quantity}x $roomType');
              totalRoomTypePrice += totalPrice;
            }

            // Add summary fields for easier querying and display
            bookingData['roomTypeSummary'] = roomTypeSummary.join(', ');
            bookingData['totalRoomTypesPrice'] = totalRoomTypePrice;
            bookingData['numberOfRoomTypes'] = widget.selectedRoomTypes!.length;

            // Add individual room type names for filtering
            List<String> roomTypeNames = widget.selectedRoomTypes!
                .map((room) => room['roomType'].toString())
                .toList();
            bookingData['roomTypeNames'] = roomTypeNames;
          }

        } else if (isAttractionBooking) {
          // Attraction booking data
          bookingData.addAll({
            'attraction': {
              'id': widget.attraction!.id,
              'name': widget.attraction!.name,
              'city': widget.attraction!.city,
              'state': widget.attraction!.state,
              'address': widget.attraction!.address,
            },
            'selectedTickets': widget.selectedTickets,
            'visitDate': widget.visitDate?.toIso8601String(),
          });
        } else {
          // Transport booking data
          bookingData.addAll({
            'transport': widget.transport,
            'selectedTime': widget.selectedTime,
            'selectedSeats': widget.selectedSeats,
            'departDate': widget.departDate?.toIso8601String(),
            'returnDate': widget.returnDate?.toIso8601String(),
            'numberOfDays': widget.numberOfDays,
          });
        }

        // Save to user's bookings using the custom booking ID as key
        await _database.child('users').child(userId).child('bookings').child(bookingId).set(bookingData);

        // Save to general bookings collection using the custom booking ID as key
        await _database.child('bookings').child(bookingId).set(bookingData);

        // Save to specific collection based on booking type
        String collectionName = _getCollectionName();
        await _database.child(collectionName).child(bookingId).set(bookingData);

        print('${_getBookingType()} booking saved successfully with ID: $bookingId');

        // Print room type information for hotel bookings
        if (isHotelBooking && widget.selectedRoomTypes != null) {
          print('Selected Room Types:');
          for (var roomTypeData in widget.selectedRoomTypes!) {
            print('  - ${roomTypeData['quantity']}x ${roomTypeData['roomType']} @ MYR ${roomTypeData['pricePerNight']}/night');
            print('    Total: MYR ${roomTypeData['totalPrice']}');
          }
          print('Total for all rooms: MYR ${widget.totalPrice}');
        }

      } else {
        print('No user logged in');
      }
    } catch (e) {
      print('Error saving booking: $e');
    }
  }

  String _getBookingType() {
    if (isHotelBooking) return 'hotel';
    if (isAttractionBooking) return 'attraction';
    return 'transport';
  }

  String _getCollectionName() {
    if (isHotelBooking) return 'hotel_bookings';
    if (isAttractionBooking) return 'attraction_bookings';
    return 'transport_bookings';
  }

  void _verifyCardNumberAndNavigate() async {
    // Remove any spaces or formatting from the card details for comparison
    String cleanCardNumber = widget.cardNumber.replaceAll(' ', '').replaceAll('-', '');
    String cleanExpiry = widget.expiry.replaceAll(' ', '').replaceAll('-', '').replaceAll('/', '');
    String cleanCvv = widget.cvv.replaceAll(' ', '').replaceAll('-', '');

    // Check if all card details match the valid ones
    bool isValidCard = cleanCardNumber == VALID_CARD_NUMBER;
    bool isValidDate = cleanExpiry == VALID_CARD_DATE;
    bool isValidCvv = cleanCvv == VALID_CARD_CVV;

    if (isValidCard && isValidDate && isValidCvv) {
      // Save booking to Firebase before navigating to success
      await _saveBookingToFirebase();

      // Navigate to your existing Payment Success page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PaymentSuccess()),
      );
    } else {
      // Navigate to your existing Payment Failed page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PaymentFailed()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Get room type summary for display
  String _getRoomTypeSummary() {
    if (widget.selectedRoomTypes == null || widget.selectedRoomTypes!.isEmpty) {
      return '';
    }

    List<String> roomSummary = [];
    for (var roomTypeData in widget.selectedRoomTypes!) {
      String roomType = roomTypeData['roomType'] ?? 'Unknown Room';
      int quantity = roomTypeData['quantity'] ?? 1;
      roomSummary.add('${quantity}x $roomType');
    }

    return roomSummary.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic colors based on booking type
    Color primaryColor = _getPrimaryColor();
    IconData cardIcon = _getCardIcon();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Remove back button as this is a processing screen
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Card animation that rotates slightly
            RotationTransition(
              turns: _animation,
              child: Container(
                height: 80,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    cardIcon,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),

            // Loading spinner
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              strokeWidth: 3,
            ),
            SizedBox(height: 30),

            // Processing text
            Text(
              "Processing Payment",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 15),

            // Description with booking type context
            Text(
              _getProcessingDescription(),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),

            // Show room type information for hotel bookings
            if (isHotelBooking && widget.selectedRoomTypes != null && widget.selectedRoomTypes!.isNotEmpty) ...[
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hotel_class, color: Colors.orange[700], size: 16),
                        SizedBox(width: 6),
                        Text(
                          "Selected Rooms:",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      _getRoomTypeSummary(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 10),

            Text(
              "Please do not close this page",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),

            // Animated dots to indicate processing
            SizedBox(height: 10),
            _buildAnimatedDots(),

            // Show total amount
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getGradientColors(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                "Total: MYR ${widget.totalPrice.toStringAsFixed(2)}",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            // Show number of rooms and nights for hotel bookings
            if (isHotelBooking && widget.numberOfRooms != null && widget.numberOfNights != null) ...[
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Text(
                  "${widget.numberOfRooms} room${widget.numberOfRooms! > 1 ? 's' : ''} × ${widget.numberOfNights} night${widget.numberOfNights! > 1 ? 's' : ''}",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getPrimaryColor() {
    if (isHotelBooking) return Color(0xFFFF4502);
    if (isAttractionBooking) return Color(0xFF0C1FF7);
    return Color(0xFF0816A7);
  }

  List<Color> _getGradientColors() {
    if (isHotelBooking) return [Color(0xFFFF4502), Color(0xFFFFFF00)];
    if (isAttractionBooking) return [Color(0xFF0C1FF7), Color(0xFF02BFFF)];
    return [Color(0xFF7107F3), Color(0xFFFF02FA)];
  }

  IconData _getCardIcon() {
    if (isHotelBooking) return Icons.hotel;
    if (isAttractionBooking) return Icons.confirmation_number;
    return Icons.credit_card;
  }

  String _getProcessingDescription() {
    if (isHotelBooking) {
      if (widget.selectedRoomTypes != null && widget.selectedRoomTypes!.isNotEmpty) {
        int totalRooms = widget.selectedRoomTypes!
            .map((room) => room['quantity'] as int? ?? 1)
            .fold(0, (sum, quantity) => sum + quantity);

        if (totalRooms > 1) {
          return "Processing your ${totalRooms} rooms booking...";
        } else {
          String roomType = widget.selectedRoomTypes!.first['roomType'] ?? 'room';
          return "Processing your ${roomType.toLowerCase()} booking...";
        }
      }
      return "Processing your hotel booking...";
    }
    if (isAttractionBooking) return "Processing your attraction booking...";
    return "Processing your transport booking...";
  }

  Widget _buildAnimatedDots() {
    Color primaryColor = _getPrimaryColor();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: Interval(
              index * 0.3,
              0.3 + index * 0.3,
              curve: Curves.easeInOut,
            ),
          ),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}