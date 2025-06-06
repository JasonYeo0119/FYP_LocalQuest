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

  // Check if this is an attraction booking
  bool get isAttractionBooking => widget.attraction != null;

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
          'bookingType': isAttractionBooking ? 'attraction' : 'transport',
        };

        // Add booking-specific data
        if (isAttractionBooking) {
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
        String collectionName = isAttractionBooking ? 'attraction_bookings' : 'transport_bookings';
        await _database.child(collectionName).child(bookingId).set(bookingData);

        print('${isAttractionBooking ? 'Attraction' : 'Transport'} booking saved successfully with ID: $bookingId');
      } else {
        print('No user logged in');
      }
    } catch (e) {
      print('Error saving booking: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    // Dynamic colors based on booking type
    Color primaryColor = isAttractionBooking ? Color(0xFF0C1FF7) : Color(0xFF0816A7);
    IconData cardIcon = isAttractionBooking ? Icons.confirmation_number : Icons.credit_card;

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
              isAttractionBooking
                  ? "Processing your attraction booking..."
                  : "Processing your transport booking...",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 5),

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
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedDots() {
    Color primaryColor = isAttractionBooking ? Color(0xFF0C1FF7) : Color(0xFF0816A7);

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