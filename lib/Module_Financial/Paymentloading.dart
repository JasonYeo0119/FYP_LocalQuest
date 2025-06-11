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
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

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

  // Method to generate QR Code data
  String _generateQRData(String bookingId) {
    Map<String, dynamic> qrData = {
      'bookingId': bookingId,
      'bookingType': _getBookingType(),
      'totalPrice': widget.totalPrice,
      'bookingDate': DateTime.now().toIso8601String(),
      'userId': _auth.currentUser?.uid,
    };

    // Add specific booking details based on type
    if (isHotelBooking) {
      qrData.addAll({
        'hotelName': widget.hotel!.name,
        'checkInDate': widget.checkInDate?.toIso8601String(),
        'checkOutDate': widget.checkOutDate?.toIso8601String(),
        'numberOfRooms': widget.numberOfRooms,
        'numberOfNights': widget.numberOfNights,
      });
    } else if (isAttractionBooking) {
      qrData.addAll({
        'attractionName': widget.attraction!.name,
        'visitDate': widget.visitDate?.toIso8601String(),
        'city': widget.attraction!.city,
      });
    } else if (isFlightBooking) {
      qrData.addAll({
        'airline': widget.transport!['airline'],
        'flightNumber': widget.transport!['flightNumber'],
        'route': '${widget.transport!['origin']} → ${widget.transport!['destination']}',
        'departDate': widget.departDate?.toIso8601String(),
        'numberOfPassengers': widget.passengerData?.length ?? 0,
      });
    } else if (isFerryBooking) {
      qrData.addAll({
        'route': '${widget.transport!['origin']} → ${widget.transport!['destination']}',
        'departDate': widget.departDate?.toIso8601String(),
        'numberOfPassengers': widget.ferryNumberOfPax,
        'ticketType': widget.ferryTicketType,
      });
    }

    return jsonEncode(qrData);
  }

  // Generate QR Code and save it
  Future<String?> _generateAndSaveQRCode(String bookingId) async {
    try {
      // Generate QR data string
      String qrData = _generateQRData(bookingId);

      User? user = _auth.currentUser;
      if (user != null) {
        String userId = user.uid;

        // Generate QR code image as base64
        final qrValidationResult = QrValidator.validate(
          data: qrData,
          version: QrVersions.auto,
          errorCorrectionLevel: QrErrorCorrectLevel.M,
        );

        if (qrValidationResult.status == QrValidationStatus.valid) {
          final qrCode = qrValidationResult.qrCode!;
          final painter = QrPainter.withQr(
            qr: qrCode,
            color: const Color(0xFF000000),
            emptyColor: const Color(0xFFFFFFFF),
            gapless: true,
          );

          // Convert QR code to image and then to bytes
          final picData = await painter.toImageData(300);
          final byteData = picData!.buffer.asUint8List();

          // Encode bytes to base64
          String base64Image = base64Encode(byteData);

          Map<String, dynamic> qrCodeData = {
            'bookingId': bookingId,
            'qrData': qrData,
            'qrCodeImage': base64Image,
            'createdAt': DateTime.now().toIso8601String(),
            'userId': userId,
            'bookingType': _getBookingType(),
            'status': 'active',
          };

          // Save to /qr_codes
          await _database.child('qr_codes').child(bookingId).set(qrCodeData);

          // Save reference under user's bookings
          await _database.child('users').child(userId).child('bookings').child(bookingId).child('qrCode').set({
            'qrData': qrData,
            'qrCodeImage': base64Image,
            'createdAt': DateTime.now().toIso8601String(),
            'status': 'active',
          });

          print('QR Code image (base64) saved for booking: $bookingId');
          return qrData;
        } else {
          print('Invalid QR data');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Error generating QR code: $e');
      return null;
    }
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
        String bookingId = _generateBookingId();

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

        // Define transportData at the beginning for availability updates
        Map<String, dynamic> transportData = Map<String, dynamic>.from(widget.transport ?? {});

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
              'passengerData': widget.passengerData,
              'leadPassengerData': widget.leadPassengerData,
              'numberOfPassengers': widget.passengerData?.length ?? 0,
              'additionalCosts': widget.additionalCosts,
              'basePriceBeforeAddons': widget.totalPrice - widget.additionalCosts,
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
              'route': '${transportData['origin']} → ${transportData['destination']}',
              'basePricePerPassenger': transportData['price'] ?? 0.0,
              'totalCalculatedPrice': widget.totalPrice,
            });

            bookingData['bookingType'] = 'ferry';
            bookingData['transportType'] = 'ferry';
          }
        }

        // === NEW: Update availability before saving booking ===

        // Check if it's a bus booking and update seat availability
        if (widget.transport != null &&
            widget.transport!['type']?.toString().toLowerCase() == 'bus' &&
            widget.selectedSeats.isNotEmpty &&
            widget.selectedTime != null &&
            widget.departDate != null) {

          await _updateBusSeatsAvailability(
            transportData['id'] ?? transportData['name'], // Bus ID or name
            widget.selectedTime!,
            widget.departDate!,
            widget.selectedSeats,
          );
        }

        // Check if it's a car booking and update car availability
        if (widget.transport != null &&
            widget.transport!['type']?.toString().toLowerCase() == 'car' &&
            widget.departDate != null) {

          String carId = transportData['id'] ?? transportData['plateNumber'];
          print('=== BOOKING CAR: $carId ===');
          print('Depart Date: ${widget.departDate}');
          print('Return Date: ${widget.returnDate}');

          await _updateCarAvailability(
            carId,
            widget.departDate!,
            widget.returnDate,
          );

          // Debug: Check what was actually saved
          await _debugCarAvailability(carId);
        }

        // Save booking data to Firebase
        await _database.child('users').child(userId).child('bookings').child(bookingId).set(bookingData);
        await _database.child('bookings').child(bookingId).set(bookingData);
        String collectionName = _getCollectionName();
        await _database.child(collectionName).child(bookingId).set(bookingData);

        print('${_getBookingType()} booking saved successfully with ID: $bookingId');

        // Generate and save QR code after booking is saved
        String? qrDataString = await _generateAndSaveQRCode(bookingId);
        if (qrDataString != null) {
          // Update booking with QR code reference
          await _database.child('users').child(userId).child('bookings').child(bookingId).update({
            'hasQRCode': true,
            'qrCodeGenerated': true,
          });

          await _database.child('bookings').child(bookingId).update({
            'hasQRCode': true,
            'qrCodeGenerated': true,
          });

          print('QR Code generated and saved successfully for booking: $bookingId');
        }
      } else {
        print('No user logged in');
      }
    } catch (e) {
      print('Error saving booking: $e');
      rethrow; // Re-throw the error so the calling method can handle it
    }
  }

  Future<void> _updateBusSeatsAvailability(
      String busId,
      String selectedTime,
      DateTime departDate,
      List<int> selectedSeats,
      ) async {
    try {
      String dateKey = "${departDate.year}-${departDate.month.toString().padLeft(2, '0')}-${departDate.day.toString().padLeft(2, '0')}";

      // Reference to the bus document
      DatabaseReference busRef = _database.child('buses').child(busId);

      // Use transaction to ensure atomic updates
      await busRef.child('timeSlots').child(selectedTime).child('bookedSeats').child(dateKey).runTransaction((Object? bookedSeatsData) {
        List<int> currentBookedSeats = [];

        if (bookedSeatsData != null) {
          // Parse existing booked seats
          if (bookedSeatsData is List) {
            currentBookedSeats = bookedSeatsData.cast<int>();
          } else if (bookedSeatsData is Map) {
            // Handle case where it might be stored as a map
            currentBookedSeats = bookedSeatsData.values.cast<int>().toList();
          }
        }

        // Add the newly booked seats
        currentBookedSeats.addAll(selectedSeats);

        // Remove duplicates and sort
        currentBookedSeats = currentBookedSeats.toSet().toList()..sort();

        return Transaction.success(currentBookedSeats);
      });

      // Also update the available seats count
      await busRef.child('timeSlots').child(selectedTime).child('availableSeats').child(dateKey).runTransaction((Object? availableSeatsData) {
        int currentAvailableSeats = availableSeatsData as int? ?? 33; // Default total seats
        int newAvailableSeats = currentAvailableSeats - selectedSeats.length;

        // Ensure it doesn't go below 0
        newAvailableSeats = newAvailableSeats < 0 ? 0 : newAvailableSeats;

        return Transaction.success(newAvailableSeats);
      });

      print('Bus seats updated successfully for bus: $busId, time: $selectedTime, date: $dateKey');
      print('Booked seats: $selectedSeats');

    } catch (e) {
      print('Error updating bus seats availability: $e');
      throw e;
    }
  }

  Future<void> _updateCarAvailability(
      String carId,
      DateTime departDate,
      DateTime? returnDate,
      ) async {
    try {
      // Reference to the car document
      DatabaseReference carRef = _database.child('cars').child(carId);

      // Calculate all dates the car will be unavailable
      List<String> unavailableDates = [];

      // Normalize dates to remove time component (use only date part)
      DateTime startDate = DateTime(departDate.year, departDate.month, departDate.day);

      // FIXED: Calculate end date properly based on numberOfDays if returnDate is null
      DateTime endDate;
      if (returnDate != null) {
        endDate = DateTime(returnDate.year, returnDate.month, returnDate.day);
      } else if (widget.numberOfDays != null) {
        // If booking for N days starting on departDate, end date is (departDate + N-1 days)
        // Example: 2 days starting June 17 = June 17 + June 18 (so endDate = June 18)
        endDate = startDate.add(Duration(days: widget.numberOfDays! - 1));
      } else {
        endDate = startDate; // Single day booking
      }

      print('=== CAR AVAILABILITY UPDATE ===');
      print('Start Date: $startDate');
      print('End Date: $endDate');
      print('Number of days: ${widget.numberOfDays}');
      print('Return Date provided: $returnDate');

      // For car rentals, include all dates from start to end (inclusive)
      DateTime currentDate = startDate;

      // FIXED: Use proper inclusive range
      while (currentDate.isBefore(endDate.add(Duration(days: 1)))) {
        String dateKey = "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";
        unavailableDates.add(dateKey);
        currentDate = currentDate.add(Duration(days: 1));
      }

      print('Dates to block: $unavailableDates');

      // Update car availability for each date
      for (String dateKey in unavailableDates) {
        await carRef.child('unavailableDates').child(dateKey).set({
          'isBlocked': true,
          'bookedAt': DateTime.now().toIso8601String(),
          'bookingType': 'rental',
          'numberOfDays': widget.numberOfDays,
          'bookingStartDate': startDate.toIso8601String(),
          'bookingEndDate': endDate.toIso8601String(),
        });
        print('✅ Blocked date: $dateKey');
      }

      // Update the car's booking status with CORRECT dates
      await carRef.update({
        'isCurrentlyBooked': true,
        'currentBookingStart': startDate.toIso8601String(),
        'currentBookingEnd': endDate.toIso8601String(),
        'lastBookedAt': DateTime.now().toIso8601String(),
        'totalBlockedDates': unavailableDates.length,
        'bookingDuration': widget.numberOfDays ?? 1,
      });

      print('Car availability updated successfully for car: $carId');
      print('Blocked dates: $unavailableDates');
      print('Booking period: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
      print('=============================');

    } catch (e) {
      print('Error updating car availability: $e');
      throw e;
    }
  }

  Future<void> _debugCarAvailability(String carId) async {
    try {
      DatabaseReference carRef = _database.child('cars').child(carId);
      DataSnapshot snapshot = await carRef.child('unavailableDates').get();

      print('=== DEBUG: Car Availability for $carId ===');
      if (snapshot.exists) {
        Map<String, dynamic> unavailableDates = Map<String, dynamic>.from(snapshot.value as Map);
        unavailableDates.forEach((date, data) {
          print('Date: $date -> $data');
        });
      } else {
        print('No unavailable dates found');
      }

      // Also check booking status
      DataSnapshot statusSnapshot = await carRef.get();
      if (statusSnapshot.exists) {
        Map<String, dynamic> carData = Map<String, dynamic>.from(statusSnapshot.value as Map);
        print('Car booking status: ${carData['isCurrentlyBooked']}');
        print('Current booking start: ${carData['currentBookingStart']}');
        print('Current booking end: ${carData['currentBookingEnd']}');
        print('Booking duration: ${carData['bookingDuration']}');
        print('Total blocked dates: ${carData['totalBlockedDates']}');
      }
      print('=====================================');
    } catch (e) {
      print('Error debugging car availability: $e');
    }
  }

// Helper method to check if transport is bus or car
  bool get isBusBooking => widget.transport?['type']?.toString().toLowerCase() == 'bus';
  bool get isCarBooking => widget.transport?['type']?.toString().toLowerCase() == 'car';

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
    try {
      // First validate availability before processing payment
      bool isSeatAvailable = await _validateSeatAvailability();
      bool isCarAvailable = await _validateCarAvailability();

      if (!isSeatAvailable) {
        // Show error dialog for seat unavailability
        _showAvailabilityError('Selected seats are no longer available. Please select different seats.');
        return;
      }

      if (!isCarAvailable) {
        // Show error dialog for car unavailability
        _showAvailabilityError('This vehicle is no longer available for the selected dates. Please choose different dates.');
        return;
      }

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
    } catch (e) {
      print('Error during payment verification: $e');

      // Rollback any availability updates if there was an error
      await _rollbackAvailabilityUpdates('FAILED_BOOKING');

      // Navigate to payment failed page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PaymentFailed()),
      );
    }
  }

  void _showAvailabilityError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Booking Unavailable'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
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

  Future<bool> _validateSeatAvailability() async {
    if (!isBusBooking || widget.selectedSeats.isEmpty) return true;

    try {
      String busId = widget.transport!['id'] ?? widget.transport!['name'];
      String dateKey = "${widget.departDate!.year}-${widget.departDate!.month.toString().padLeft(2, '0')}-${widget.departDate!.day.toString().padLeft(2, '0')}";

      DatabaseReference busRef = _database.child('buses').child(busId);
      DataSnapshot snapshot = await busRef.child('timeSlots').child(widget.selectedTime!).child('bookedSeats').child(dateKey).get();

      if (snapshot.exists) {
        List<int> bookedSeats = [];
        if (snapshot.value is List) {
          bookedSeats = (snapshot.value as List).cast<int>();
        } else if (snapshot.value is Map) {
          bookedSeats = (snapshot.value as Map).values.cast<int>().toList();
        }

        // Check if any selected seats are already booked
        for (int seatNumber in widget.selectedSeats) {
          if (bookedSeats.contains(seatNumber)) {
            return false; // Seat already booked
          }
        }
      }

      return true; // All seats are available
    } catch (e) {
      print('Error validating seat availability: $e');
      return false; // Err on the side of caution
    }
  }

  Future<bool> _validateCarAvailability() async {
    if (!isCarBooking) return true;

    try {
      String carId = widget.transport!['id'] ?? widget.transport!['plateNumber'];
      DatabaseReference carRef = _database.child('cars').child(carId);

      // Normalize dates to remove time component - SAME LOGIC AS BOOKING
      DateTime startDate = DateTime(widget.departDate!.year, widget.departDate!.month, widget.departDate!.day);

      // Calculate end date properly based on numberOfDays (same as booking logic)
      DateTime endDate;
      if (widget.returnDate != null) {
        endDate = DateTime(widget.returnDate!.year, widget.returnDate!.month, widget.returnDate!.day);
      } else if (widget.numberOfDays != null) {
        // If booking for N days starting on departDate, end date is (departDate + N-1 days)
        endDate = startDate.add(Duration(days: widget.numberOfDays! - 1));
      } else {
        endDate = startDate; // Single day booking
      }

      // Check each date in the booking period (inclusive of both start and end)
      DateTime currentDate = startDate;

      while (currentDate.isBefore(endDate.add(Duration(days: 1)))) {
        String dateKey = "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

        DataSnapshot snapshot = await carRef.child('unavailableDates').child(dateKey).get();
        if (snapshot.exists) {
          // Check if the date is blocked
          if (snapshot.value is bool && snapshot.value == true) {
            print('❌ Car validation failed - blocked on $dateKey (old structure)');
            return false; // Car is not available for this date (old structure)
          } else if (snapshot.value is Map) {
            Map<String, dynamic> dateData = Map<String, dynamic>.from(snapshot.value as Map);
            if (dateData['isBlocked'] == true) {
              print('❌ Car validation failed - blocked on $dateKey (new structure)');
              return false; // Car is not available for this date (new structure)
            }
          }
        }

        currentDate = currentDate.add(Duration(days: 1));
      }

      print('✅ Car validation passed - available for all requested dates');
      return true; // Car is available for all requested dates
    } catch (e) {
      print('❌ Error validating car availability: $e');
      return false; // Err on the side of caution
    }
  }

  Future<void> _rollbackAvailabilityUpdates(String bookingId) async {
    try {
      if (isBusBooking && widget.selectedSeats.isNotEmpty) {
        await _rollbackBusSeats();
      }

      if (isCarBooking) {
        await _rollbackCarAvailability();
      }

      print('Availability updates rolled back for failed booking: $bookingId');
    } catch (e) {
      print('Error rolling back availability updates: $e');
    }
  }


  Future<void> _rollbackBusSeats() async {
    try {
      String busId = widget.transport!['id'] ?? widget.transport!['name'];
      String dateKey = "${widget.departDate!.year}-${widget.departDate!.month.toString().padLeft(2, '0')}-${widget.departDate!.day.toString().padLeft(2, '0')}";

      DatabaseReference busRef = _database.child('buses').child(busId);

      // Remove the booked seats
      await busRef.child('timeSlots').child(widget.selectedTime!).child('bookedSeats').child(dateKey).runTransaction((Object? bookedSeatsData) {
        List<int> currentBookedSeats = [];

        if (bookedSeatsData != null) {
          if (bookedSeatsData is List) {
            currentBookedSeats = bookedSeatsData.cast<int>();
          } else if (bookedSeatsData is Map) {
            currentBookedSeats = bookedSeatsData.values.cast<int>().toList();
          }
        }

        // Remove the seats that were just booked
        for (int seat in widget.selectedSeats) {
          currentBookedSeats.remove(seat);
        }

        return Transaction.success(currentBookedSeats);
      });

      // Restore available seats count
      await busRef.child('timeSlots').child(widget.selectedTime!).child('availableSeats').child(dateKey).runTransaction((Object? availableSeatsData) {
        int currentAvailableSeats = availableSeatsData as int? ?? 0;
        int restoredSeats = currentAvailableSeats + widget.selectedSeats.length;

        return Transaction.success(restoredSeats);
      });

    } catch (e) {
      print('Error rolling back bus seats: $e');
    }
  }

  Future<void> _rollbackCarAvailability() async {
    try {
      String carId = widget.transport!['id'] ?? widget.transport!['plateNumber'];
      DatabaseReference carRef = _database.child('cars').child(carId);

      // Normalize dates to remove time component - SAME LOGIC AS BOOKING
      DateTime startDate = DateTime(widget.departDate!.year, widget.departDate!.month, widget.departDate!.day);

      // Calculate end date properly based on numberOfDays (same as booking logic)
      DateTime endDate;
      if (widget.returnDate != null) {
        endDate = DateTime(widget.returnDate!.year, widget.returnDate!.month, widget.returnDate!.day);
      } else if (widget.numberOfDays != null) {
        // If booking for N days starting on departDate, end date is (departDate + N-1 days)
        endDate = startDate.add(Duration(days: widget.numberOfDays! - 1));
      } else {
        endDate = startDate; // Single day booking
      }

      // Calculate dates to restore (same logic as blocking)
      List<String> datesToRestore = [];
      DateTime currentDate = startDate;

      while (currentDate.isBefore(endDate.add(Duration(days: 1)))) {
        String dateKey = "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";
        datesToRestore.add(dateKey);
        currentDate = currentDate.add(Duration(days: 1));
      }

      print('🔄 Rolling back car availability for dates: $datesToRestore');

      // Remove unavailable dates
      for (String dateKey in datesToRestore) {
        await carRef.child('unavailableDates').child(dateKey).remove();
      }

      // Reset booking status
      await carRef.update({
        'isCurrentlyBooked': false,
        'currentBookingStart': null,
        'currentBookingEnd': null,
        'totalBlockedDates': null,
        'bookingDuration': null,
      });

      print('✅ Rolled back car availability for dates: $datesToRestore');

    } catch (e) {
      print('❌ Error rolling back car availability: $e');
    }
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

            // // Show room type information for hotel bookings
            // if (isHotelBooking && widget.selectedRoomTypes != null && widget.selectedRoomTypes!.isNotEmpty) ...[
            //   SizedBox(height: 15),
            //   Container(
            //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            //     margin: EdgeInsets.symmetric(horizontal: 20),
            //     decoration: BoxDecoration(
            //       color: Colors.orange.withOpacity(0.1),
            //       borderRadius: BorderRadius.circular(20),
            //       border: Border.all(color: Colors.orange.withOpacity(0.3)),
            //     ),
            //     child: Column(
            //       children: [
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             Icon(Icons.hotel_class, color: Colors.orange[700], size: 16),
            //             SizedBox(width: 6),
            //             Text(
            //               "Selected Rooms:",
            //               style: GoogleFonts.poppins(
            //                 fontSize: 12,
            //                 fontWeight: FontWeight.w600,
            //                 color: Colors.orange[800],
            //               ),
            //             ),
            //           ],
            //         ),
            //         SizedBox(height: 6),
            //         Text(
            //           _getRoomTypeSummary(),
            //           textAlign: TextAlign.center,
            //           style: GoogleFonts.poppins(
            //             fontSize: 11,
            //             fontWeight: FontWeight.w500,
            //             color: Colors.orange[700],
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ],

            // if (isFlightBooking && widget.transport != null) ...[
            //   SizedBox(height: 15),
            //   Container(
            //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            //     margin: EdgeInsets.symmetric(horizontal: 20),
            //     decoration: BoxDecoration(
            //       color: Colors.purple.withOpacity(0.1),
            //       borderRadius: BorderRadius.circular(20),
            //       border: Border.all(color: Colors.purple.withOpacity(0.3)),
            //     ),
            //     child: Column(
            //       children: [
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             Icon(Icons.flight, color: Colors.purple[700], size: 16),
            //             SizedBox(width: 6),
            //             Text(
            //               "Flight Details:",
            //               style: GoogleFonts.poppins(
            //                 fontSize: 12,
            //                 fontWeight: FontWeight.w600,
            //                 color: Colors.purple[800],
            //               ),
            //             ),
            //           ],
            //         ),
            //         SizedBox(height: 6),
            //         Text(
            //           "${widget.transport!['airline']} ${widget.transport!['flightNumber']}",
            //           textAlign: TextAlign.center,
            //           style: GoogleFonts.poppins(
            //             fontSize: 11,
            //             fontWeight: FontWeight.w600,
            //             color: Colors.purple[700],
            //           ),
            //         ),
            //         Text(
            //           "${widget.transport!['origin']} → ${widget.transport!['destination']}",
            //           textAlign: TextAlign.center,
            //           style: GoogleFonts.poppins(
            //             fontSize: 10,
            //             fontWeight: FontWeight.w500,
            //             color: Colors.purple[600],
            //           ),
            //         ),
            //         if (widget.transport!['selectedClass'] != null)
            //           Text(
            //             "${widget.transport!['selectedClass']} Class",
            //             textAlign: TextAlign.center,
            //             style: GoogleFonts.poppins(
            //               fontSize: 10,
            //               fontWeight: FontWeight.w500,
            //               color: Colors.purple[600],
            //             ),
            //           ),
            //         // Updated passenger info
            //         if (widget.passengerData != null) ...[
            //           Text(
            //             "${widget.passengerData!.length} Passenger${widget.passengerData!.length > 1 ? 's' : ''}",
            //             textAlign: TextAlign.center,
            //             style: GoogleFonts.poppins(
            //               fontSize: 10,
            //               fontWeight: FontWeight.w500,
            //               color: Colors.purple[600],
            //             ),
            //           ),
            //           Text(
            //             _getPassengerSummary(),
            //             textAlign: TextAlign.center,
            //             style: GoogleFonts.poppins(
            //               fontSize: 9,
            //               fontWeight: FontWeight.w400,
            //               color: Colors.purple[500],
            //             ),
            //           ),
            //         ],
            //       ],
            //     ),
            //   ),
            // ],

            // SizedBox(height: 10),

            // if (isFlightBooking && widget.additionalCosts > 0) ...[
            //   SizedBox(height: 10),
            //   Container(
            //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //     margin: EdgeInsets.symmetric(horizontal: 20),
            //     decoration: BoxDecoration(
            //       color: Colors.green.withOpacity(0.1),
            //       borderRadius: BorderRadius.circular(15),
            //       border: Border.all(color: Colors.green.withOpacity(0.3)),
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Icon(Icons.add_circle_outline, color: Colors.green[700], size: 14),
            //         SizedBox(width: 6),
            //         Text(
            //           "Add-ons: MYR ${widget.additionalCosts.toStringAsFixed(0)}",
            //           style: GoogleFonts.poppins(
            //             fontSize: 11,
            //             fontWeight: FontWeight.w500,
            //             color: Colors.green[700],
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ],

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

            // // Show number of rooms and nights for hotel bookings
            // if (isHotelBooking && widget.numberOfRooms != null && widget.numberOfNights != null) ...[
            //   SizedBox(height: 10),
            //   Container(
            //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //     decoration: BoxDecoration(
            //       color: Colors.grey.withOpacity(0.1),
            //       borderRadius: BorderRadius.circular(15),
            //       border: Border.all(color: Colors.grey.withOpacity(0.3)),
            //     ),
            //     child: Text(
            //       "${widget.numberOfRooms} room${widget.numberOfRooms! > 1 ? 's' : ''} × ${widget.numberOfNights} night${widget.numberOfNights! > 1 ? 's' : ''}",
            //       style: GoogleFonts.poppins(
            //         fontSize: 12,
            //         fontWeight: FontWeight.w500,
            //         color: Colors.grey[700],
            //       ),
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }

  Color _getPrimaryColor() {
    if (isHotelBooking) return Color(0xFFFF4502);
    if (isAttractionBooking) return Color(0xFF0C1FF7);
    return Color(0xFF7107F3);
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