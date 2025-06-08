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
  final Map<String, dynamic>? transport;
  final String? selectedTime;
  final List<int> selectedSeats;
  final DateTime? departDate;
  final DateTime? returnDate;
  final int? numberOfDays;
  final Attraction? attraction;
  final List<Map<String, dynamic>>? selectedTickets;
  final DateTime? visitDate;
  final Hotel? hotel;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int? numberOfGuests;
  final int? numberOfRooms;
  final int? numberOfNights;
  final List<Map<String, dynamic>>? selectedRoomTypes;
  final List<Map<String, dynamic>>? passengerData;
  final Map<String, dynamic>? leadPassengerData;
  final double additionalCosts;
  final String? ferryTicketType;
  final int? ferryNumberOfPax;

  const Paymentloading({
    Key? key,
    required this.cardNumber,
    required this.expiry,
    required this.cvv,
    required this.totalPrice,
    this.transport,
    this.selectedTime,
    this.selectedSeats = const [],
    this.departDate,
    this.returnDate,
    this.numberOfDays,
    this.attraction,
    this.selectedTickets,
    this.visitDate,
    this.hotel,
    this.checkInDate,
    this.checkOutDate,
    this.numberOfGuests,
    this.numberOfRooms,
    this.numberOfNights,
    this.selectedRoomTypes,
    this.passengerData,
    this.leadPassengerData,
    this.additionalCosts = 0.0,
    this.ferryTicketType,
    this.ferryNumberOfPax,
  }) : super(key: key);

  @override
  _PaymentloadingState createState() => _PaymentloadingState();
}

class _PaymentloadingState extends State<Paymentloading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isProcessing = true;
  bool get isFlightBooking => widget.transport?['type']?.toString().toLowerCase() == 'flight';

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
  bool get isFerryBooking => widget.transport?['type']?.toString().toLowerCase() == 'ferry';

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
          Map<String, dynamic> transportData = Map<String, dynamic>.from(
              widget.transport ?? {});
          // Transport booking data
          bookingData.addAll({
            'transport': widget.transport,
            'selectedTime': widget.selectedTime,
            'selectedSeats': widget.selectedSeats,
            'departDate': widget.departDate?.toIso8601String(),
            'returnDate': widget.returnDate?.toIso8601String(),
            'numberOfDays': widget.numberOfDays,
          });
          if (isFlightBooking) {
            bookingData.addAll({
              'flightNumber': transportData['flightNumber'],
              'airline': transportData['airline'],
              'aircraft': transportData['aircraft'],
              'selectedClass': transportData['selectedClass'],
              'departureTime': transportData['departureTime'],
              'arrivalTime': transportData['arrivalTime'],
              'duration': transportData['duration'],
              'route': '${transportData['origin']} → ${transportData['destination']}',
              'amenities': transportData['amenities'],
              // ADD PASSENGER DATA:
              'passengerData': widget.passengerData,
              'leadPassengerData': widget.leadPassengerData,
              'numberOfPassengers': widget.passengerData?.length ?? 0,
              'additionalCosts': widget.additionalCosts,
              'basePriceBeforeAddons': widget.totalPrice -
                  widget.additionalCosts,
            });
            // Calculate add-on summary for Firebase
            if (widget.passengerData != null) {
              int checkedBaggageCount = 0;
              int mealCount = 0;
              List<String> selectedMeals = [];
              List<String> baggageWeights = [];
              double totalBaggageCost = 0.0;

              for (var passenger in widget.passengerData!) {
                // Updated baggage logic
                if (passenger['checkedBaggageWeight'] != null) {
                  checkedBaggageCount++;
                  baggageWeights.add(passenger['checkedBaggageWeight']);

                  // Calculate baggage cost based on weight
                  switch (passenger['checkedBaggageWeight']) {
                    case '20kg':
                      totalBaggageCost += 77.0;
                      break;
                    case '25kg':
                      totalBaggageCost += 89.0;
                      break;
                    case '30kg':
                      totalBaggageCost += 109.0;
                      break;
                    case '40kg':
                      totalBaggageCost += 166.0;
                      break;
                    case '50kg':
                      totalBaggageCost += 217.0;
                      break;
                    case '60kg':
                      totalBaggageCost += 287.0;
                      break;
                  }
                }

                if (passenger['selectedMeal'] != null &&
                    passenger['selectedMeal'] != 'None') {
                  mealCount++;
                  selectedMeals.add(passenger['selectedMeal']);
                }
              }

              bookingData.addAll({
                'checkedBaggageCount': checkedBaggageCount,
                'baggageWeights': baggageWeights,
                'totalBaggageCost': totalBaggageCost,
                'mealCount': mealCount,
                'selectedMeals': selectedMeals,
                'totalMealCost': mealCount * 15.0, // Assuming meal price is 15
              });
            }
          } else if (isFerryBooking) {
            // Ferry-specific data
            bookingData.addAll({
              'ferryTicketType': widget.ferryTicketType,
              'ferryNumberOfPax': widget.ferryNumberOfPax,
              'numberOfPassengers': widget.ferryNumberOfPax,
              // Store passenger count explicitly
              'route': '${transportData['origin']} → ${transportData['destination']}',
              // Store base price from transport data for reference
              'basePricePerPassenger': transportData['price'] ?? 0.0,
              'totalCalculatedPrice': widget.totalPrice,
            });

            // Set booking type for ferry
            bookingData['bookingType'] = 'ferry';
            bookingData['transportType'] = 'ferry';
          }
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
    if (isFlightBooking) return 'flight';
    if (isFerryBooking) return 'ferry';
    return 'transport';
  }

  String _getCollectionName() {
    if (isHotelBooking) return 'hotel_bookings';
    if (isAttractionBooking) return 'attraction_bookings';
    if (isFlightBooking) return 'flight_bookings';
    if (isFerryBooking) return 'ferry_bookings';
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

  String _getPassengerSummary() {
    if (widget.passengerData == null || widget.passengerData!.isEmpty) {
      return '';
    }

    List<String> summary = [];
    int baggageCount = 0;
    int mealCount = 0;

    for (var passenger in widget.passengerData!) {
      if (passenger['checkedBaggageWeight'] != null) {
        baggageCount++;
      }
      if (passenger['selectedMeal'] != null && passenger['selectedMeal'] != 'None') {
        mealCount++;
      }
    }

    if (baggageCount > 0) {
      summary.add('$baggageCount Baggage');
    }
    if (mealCount > 0) {
      summary.add('$mealCount Meal');
    }

    return summary.isEmpty ? 'No Add-ons' : summary.join(', ');
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

            if (isFlightBooking && widget.transport != null) ...[
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.flight, color: Colors.purple[700], size: 16),
                        SizedBox(width: 6),
                        Text(
                          "Flight Details:",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      "${widget.transport!['airline']} ${widget.transport!['flightNumber']}",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple[700],
                      ),
                    ),
                    Text(
                      "${widget.transport!['origin']} → ${widget.transport!['destination']}",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.purple[600],
                      ),
                    ),
                    if (widget.transport!['selectedClass'] != null)
                      Text(
                        "${widget.transport!['selectedClass']} Class",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.purple[600],
                        ),
                      ),
                    // Updated passenger info
                    if (widget.passengerData != null) ...[
                      Text(
                        "${widget.passengerData!.length} Passenger${widget.passengerData!.length > 1 ? 's' : ''}",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.purple[600],
                        ),
                      ),
                      Text(
                        _getPassengerSummary(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          color: Colors.purple[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            SizedBox(height: 10),

            if (isFlightBooking && widget.additionalCosts > 0) ...[
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, color: Colors.green[700], size: 14),
                    SizedBox(width: 6),
                    Text(
                      "Add-ons: MYR ${widget.additionalCosts.toStringAsFixed(0)}",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],

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
    if (isFlightBooking) return Icons.flight;
    return Icons.credit_card;
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