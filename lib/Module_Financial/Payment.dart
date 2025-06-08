import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localquest/Module_Financial/Paymentloading.dart';
import 'package:localquest/Model/attraction_model.dart';
import '../Model/hotel.dart';

// Passenger model for flight bookings
class Passenger {
  String surname;
  String givenName;
  String idNumber;
  String nationality;
  String idType;
  String? checkedBaggageWeight;
  String? selectedMeal;

  Passenger({
    this.surname = '',
    this.givenName = '',
    this.idNumber = '',
    required this.nationality,
    this.idType = 'Malaysian',
    this.checkedBaggageWeight,
    this.selectedMeal,
  });
}

class BookingPaymentPage extends StatefulWidget {
  // Transport booking parameters
  final Map<String, dynamic>? transport;
  final String? selectedTime;
  final List<int>? selectedSeats;
  final DateTime? departDate;
  final DateTime? returnDate;
  final int? numberOfDays;

  // Attraction booking parameters
  final Attraction? attraction;
  final List<Map<String, dynamic>>? selectedTickets;
  final DateTime? visitDate;

  // Hotel booking parameters
  final Hotel? hotel;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int? numberOfGuests;
  final int? numberOfRooms;
  final int? numberOfNights;

  //Ferry
  final String? ferryTicketType;
  final int? ferryNumberOfPax;

  // room type parameters - now supports multiple room types
  final List<Map<String, dynamic>>? selectedRoomTypes;

  // Common
  final double totalPrice;

  const BookingPaymentPage({
    Key? key,
    // Transport parameters
    this.transport,
    this.selectedTime,
    this.selectedSeats,
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
    // room type parameters
    this.selectedRoomTypes,
    // Ferry
    this.ferryTicketType,
    this.ferryNumberOfPax,
    // Common
    required this.totalPrice,
  }) : super(key: key);

  @override
  _BookingPaymentPageState createState() => _BookingPaymentPageState();
}

class _BookingPaymentPageState extends State<BookingPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _passengerFormKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Lead passenger information for flights
  final TextEditingController _leadPassengerNameController = TextEditingController();
  final TextEditingController _leadPassengerPhoneController = TextEditingController();
  final TextEditingController _leadPassengerEmailController = TextEditingController();

  String _selectedPaymentMethod = 'credit_card';
  bool _isProcessing = false;

  // For attraction visit date (if not provided)
  DateTime? _selectedVisitDate;

  // Flight passenger information
  List<Passenger> _passengers = [Passenger(nationality: 'Malaysian')];
  final List<String> _mealOptions = ['None', 'Yes'];
  double _additionalCosts = 0.0;
  final double _checkedBaggagePrice = 25.0; // MYR per passenger
  final double _mealPrice = 15.0; // MYR per meal

  // Check booking type
  bool get isAttractionBooking => widget.attraction != null;
  bool get isHotelBooking => widget.hotel != null;
  bool get isTransportBooking => widget.transport != null;
  bool get isFlightBooking => widget.transport?['type']?.toString().toLowerCase() == 'flight';

  @override
  void initState() {
    super.initState();
    _selectedVisitDate = widget.visitDate;
    _calculateAdditionalCosts();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _leadPassengerNameController.dispose();
    _leadPassengerPhoneController.dispose();
    _leadPassengerEmailController.dispose();
    super.dispose();
  }

  void _calculateAdditionalCosts() {
    double costs = 0.0;
    for (Passenger passenger in _passengers) {
      // Calculate baggage cost based on weight
      if (passenger.checkedBaggageWeight != null) {
        switch (passenger.checkedBaggageWeight) {
          case '20kg': costs += 77.0; break;
          case '25kg': costs += 89.0; break;
          case '30kg': costs += 109.0; break;
          case '40kg': costs += 166.0; break;
          case '50kg': costs += 217.0; break;
          case '60kg': costs += 287.0; break;
        }
      }
      if (passenger.selectedMeal != null && passenger.selectedMeal != 'None') {
        costs += _mealPrice;
      }
    }
    setState(() {
      _additionalCosts = costs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getGradientColors(),
            ),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isFlightBooking) ...[
              _buildFlightPassengerCard(),
              SizedBox(height: 24),
            ],
            // Contact Information (for non-flight bookings)
            if (!isFlightBooking) ...[
              _buildContactInformationCard(),
              SizedBox(height: 24),
            ],
            // Booking Summary Card
            _buildBookingSummaryCard(),
            SizedBox(height: 24),

            // Visit Date Selection (for attractions only)
            if (isAttractionBooking && widget.visitDate == null)
              _buildVisitDateCard(),
            if (isAttractionBooking && widget.visitDate == null)
              SizedBox(height: 24),

            _buildPaymentDetailsCard(),

            SizedBox(height: 32),

            // Pay Now Button
            _buildPayNowButton(),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    if (isHotelBooking) return 'Hotel Booking Payment';
    if (isAttractionBooking) return 'Attraction Booking Payment';
    if (isFlightBooking) return 'Flight Booking Payment';
    return 'Transport Booking Payment';
  }

  List<Color> _getGradientColors() {
    if (isHotelBooking) return [Color(0xFFFF4502), Color(0xFFFFFF00)];
    if (isAttractionBooking) return [Color(0xFF0C1FF7), Color(0xFF02BFFF)];
    return [Color(0xFF7107F3), Color(0xFFFF02FA)];
  }

  Color _getPrimaryColor() {
    if (isHotelBooking) return Color(0xFFFF4502);
    if (isAttractionBooking) return Color(0xFF0C1FF7);
    return Color(0xFF7107F3);
  }

  IconData _getBookingIcon() {
    if (isHotelBooking) return Icons.hotel;
    if (isAttractionBooking) return Icons.confirmation_number;
    if (isFlightBooking) return Icons.flight;
    return Icons.receipt_long;
  }

  Widget _buildFlightPassengerCard() {
    Color primaryColor = _getPrimaryColor();

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _passengerFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.people, color: primaryColor, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Passenger Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Lead Passenger Section
              _buildLeadPassengerSection(),

              SizedBox(height: 24),

              // Passengers Section
              _buildPassengersSection(),

              // Additional Costs Summary
              if (_additionalCosts > 0) ...[
                SizedBox(height: 16),
                _buildAdditionalCostsSummary(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadPassengerSection() {
    Color primaryColor = _getPrimaryColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact of Lead Passenger',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        SizedBox(height: 12),

        TextFormField(
          controller: _leadPassengerNameController,
          decoration: InputDecoration(
            labelText: 'Full Name *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter lead passenger full name';
            }
            return null;
          },
        ),
        SizedBox(height: 12),

        TextFormField(
          controller: _leadPassengerEmailController,
          decoration: InputDecoration(
            labelText: 'Email Address *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter email address';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        SizedBox(height: 12),

        TextFormField(
          controller: _leadPassengerPhoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPassengersSection() {
    Color primaryColor = _getPrimaryColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Passengers (${_passengers.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _addPassenger,
          icon: Icon(Icons.add),
          label: Text('Add Passenger'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        ),

        ...List.generate(_passengers.length, (index) =>
            _buildPassengerCard(index)
        ),
      ],
    );
  }

  Widget _buildPassengerCard(int index) {
    Passenger passenger = _passengers[index];
    Color primaryColor = _getPrimaryColor();

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  index == 0 ? 'Passenger ${index + 1} (Lead)' : 'Passenger ${index + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                if (_passengers.length > 1)
                  IconButton(
                    onPressed: () => _removePassenger(index),
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
              ],
            ),
            SizedBox(height: 12),

            // ID Type Selection
            DropdownButtonFormField<String>(
              value: passenger.nationality,
              items: ['Malaysian', 'Non-Malaysian'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  passenger.nationality = newValue ?? 'Malaysian';
                });
              },
              decoration: InputDecoration(
                labelText: 'Nationality *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: passenger.surname,
                    decoration: InputDecoration(
                      labelText: 'Surname *',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      passenger.surname = value;
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: passenger.givenName,
                    decoration: InputDecoration(
                      labelText: 'Given Name *',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      passenger.givenName = value;
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            TextFormField(
              initialValue: passenger.idNumber,
              decoration: InputDecoration(
                labelText: passenger.nationality.toLowerCase() == 'malaysian'
                    ? 'Identity Card Number *'
                    : 'Passport Number *',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                passenger.idNumber = value;
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  String documentType = passenger.nationality.toLowerCase() == 'malaysian'
                      ? 'Identity Card'
                      : 'Passport';
                  return 'Please enter $documentType number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Add-ons Section
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add-ons',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: passenger.checkedBaggageWeight,
                    decoration: InputDecoration(
                      labelText: 'Checked Baggage',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      DropdownMenuItem(value: null, child: Text('No Checked Baggage')),
                      DropdownMenuItem(value: '20kg', child: Text('20kg (+MYR 77)')),
                      DropdownMenuItem(value: '25kg', child: Text('25kg (+MYR 89)')),
                      DropdownMenuItem(value: '30kg', child: Text('30kg (+MYR 109)')),
                      DropdownMenuItem(value: '40kg', child: Text('40kg (+MYR 166)')),
                      DropdownMenuItem(value: '50kg', child: Text('50kg (+MYR 217)')),
                      DropdownMenuItem(value: '60kg', child: Text('60kg (+MYR 287)')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        passenger.checkedBaggageWeight = value;
                        _calculateAdditionalCosts();
                      });
                    },
                  ),
                  SizedBox(height: 20),

                  // Meal Selection
                  DropdownButtonFormField<String>(
                    value: passenger.selectedMeal ?? 'None',
                    decoration: InputDecoration(
                      labelText: 'Meal Preference',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _mealOptions.map((meal) => DropdownMenuItem(
                      value: meal,
                      child: Text(meal == 'None'
                          ? 'No Meal'
                          : '$meal (+MYR ${_mealPrice.toStringAsFixed(0)})'
                      ),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        passenger.selectedMeal = value;
                        _calculateAdditionalCosts();
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalCostsSummary() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Costs Breakdown',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 8),

          // Baggage costs
          if (_passengers.any((p) => p.checkedBaggageWeight != null)) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Checked Baggage:'),
                Text('MYR ${_passengers.where((p) => p.checkedBaggageWeight != null).map((p) {
                  switch (p.checkedBaggageWeight) {
                    case '20kg': return 77.0;
                    case '25kg': return 89.0;
                    case '30kg': return 109.0;
                    case '40kg': return 166.0;
                    case '50kg': return 217.0;
                    case '60kg': return 287.0;
                    default: return 0.0;
                  }
                }).fold(0.0, (a, b) => a + b).toStringAsFixed(0)}'),
              ],
            ),
          ],

          // Meal costs
          if (_passengers.any((p) => p.selectedMeal != null && p.selectedMeal != 'None')) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Meals (${_passengers.where((p) => p.selectedMeal != null && p.selectedMeal != 'None').length} passengers):'),
                Text('MYR ${(_passengers.where((p) => p.selectedMeal != null && p.selectedMeal != 'None').length * _mealPrice).toStringAsFixed(0)}'),
              ],
            ),
          ],

          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Additional Costs:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'MYR ${_additionalCosts.toStringAsFixed(0)}',
                style: TextStyle(
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

  void _addPassenger() {
    setState(() {
      _passengers.add(Passenger(nationality: 'Malaysian'));
    });
  }

  void _removePassenger(int index) {
    if (_passengers.length > 1) {
      setState(() {
        _passengers.removeAt(index);
        _calculateAdditionalCosts();
      });
    }
  }

  Widget _buildBookingSummaryCard() {
    Color primaryColor = _getPrimaryColor();

    // Check if it's a ferry booking with multiple passengers
    bool isFerryBookingWithMultiplePax = isTransportBooking &&
        widget.transport?['type']?.toString().toLowerCase() == 'ferry' &&
        widget.ferryNumberOfPax != null &&
        widget.ferryNumberOfPax! > 1;

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getBookingIcon(), color: primaryColor, size: 24),
                SizedBox(width: 8),
                Text(
                  'Booking Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 12),

            // Content based on booking type
            if (isHotelBooking)
              _buildHotelSummary()
            else if (isAttractionBooking)
              _buildAttractionSummary()
            else
              _buildTransportSummary(),

            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 12),

            // Total Amount (updated for flights and ferries with breakdown)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: _getGradientColors()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Show breakdown for flights with additional costs
                  if (isFlightBooking && _additionalCosts > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Base Price (${_passengers.length} pax):',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'MYR ${(widget.totalPrice * _passengers.length).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add-ons:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'MYR ${_additionalCosts.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    SizedBox(height: 8),
                  ]
                  // Show breakdown for ferry bookings with multiple passengers
                  else if (isFerryBookingWithMultiplePax) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Price per Passenger:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'MYR ${(widget.totalPrice / widget.ferryNumberOfPax!).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Number of Passengers:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${widget.ferryNumberOfPax} pax',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    SizedBox(height: 8),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'MYR ${(isFlightBooking ? (widget.totalPrice * _passengers.length) + _additionalCosts : widget.totalPrice + _additionalCosts).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hotel Details
        _buildSummaryRow('Hotel Name:', widget.hotel!.name),
        _buildSummaryRow('Address:', widget.hotel!.address),
        _buildSummaryRow('Rating:', '${widget.hotel!.rating} ⭐'),

        SizedBox(height: 16),

        // Multiple Room Types Information
        if (widget.selectedRoomTypes != null && widget.selectedRoomTypes!.isNotEmpty) ...[
          Container(
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
                      'Selected Room Types',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ...widget.selectedRoomTypes!.map((roomTypeData) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
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
                                '${roomTypeData['quantity']}x ${roomTypeData['roomType']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Text(
                              'MYR ${roomTypeData['pricePerNight'].toStringAsFixed(0)}/night',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${widget.numberOfNights} night${widget.numberOfNights! > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'MYR ${roomTypeData['totalPrice'].toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],

        // Booking Details
        _buildSummaryRow(
          'Check-in Date:',
          '${widget.checkInDate!.day}/${widget.checkInDate!.month}/${widget.checkInDate!.year}',
        ),
        _buildSummaryRow(
          'Check-out Date:',
          '${widget.checkOutDate!.day}/${widget.checkOutDate!.month}/${widget.checkOutDate!.year}',
        ),
        _buildSummaryRow('Duration:', '${widget.numberOfNights} night${widget.numberOfNights! > 1 ? 's' : ''}'),
        _buildSummaryRow('Total Rooms:', '${widget.numberOfRooms}'),
        _buildSummaryRow('Number of Guests:', '${widget.numberOfGuests}'),

        SizedBox(height: 16),

        // Price Breakdown Summary
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              if (widget.selectedRoomTypes != null && widget.selectedRoomTypes!.isNotEmpty) ...[
                // Show room-wise breakdown
                ...widget.selectedRoomTypes!.map((roomTypeData) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${roomTypeData['quantity']}x ${roomTypeData['roomType']}:',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Text(
                          'MYR ${roomTypeData['totalPrice'].toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                Divider(thickness: 1, color: Colors.orange.withOpacity(0.3)),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Grand Total:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'MYR ${widget.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttractionSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Attraction Details
        _buildSummaryRow('Attraction:', widget.attraction!.name),
        _buildSummaryRow('Location:', '${widget.attraction!.city}, ${widget.attraction!.state}'),
        if (widget.attraction!.address.isNotEmpty)
          _buildSummaryRow('Address:', widget.attraction!.address),

        // Visit Date
        if (widget.visitDate != null)
          _buildSummaryRow(
              'Visit Date:',
              '${widget.visitDate!.day}/${widget.visitDate!.month}/${widget.visitDate!.year}'
          ),

        SizedBox(height: 16),
        Text(
          'Selected Tickets:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),

        // Ticket Breakdown
        if (widget.selectedTickets != null)
          ...widget.selectedTickets!.map((ticket) => Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ticket['type'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      'MYR ${ticket['price'].toStringAsFixed(2)} x ${ticket['quantity']}',
                      style: TextStyle(
                        fontSize: 14,
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
                      'Quantity: ${ticket['quantity']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'MYR ${ticket['subtotal'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )).toList(),
      ],
    );
  }

  Widget _buildTransportSummary() {
    // Check if it's a flight booking
    bool isFlightBooking = widget.transport?['type']?.toString().toLowerCase() == 'flight';

    if (isFlightBooking) {
      return _buildFlightSummary();
    }

    // Original transport summary for other transport types
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Transport Details
        _buildSummaryRow('Transport Name:', widget.transport?['name']?.toString() ?? 'Unknown'),
        _buildSummaryRow('Transport Type:', widget.transport?['type']?.toString() ?? 'Unknown'),

        if (widget.transport?['type']?.toString().toLowerCase() == 'car') ...[
          _buildSummaryRow('Location:', widget.transport?['location']?.toString() ?? widget.transport?['origin']?.toString() ?? 'Unknown'),
          if (widget.numberOfDays != null)
            _buildSummaryRow('Duration:', '${widget.numberOfDays} day${widget.numberOfDays! > 1 ? 's' : ''}'),
        ] else if (widget.transport?['type']?.toString().toLowerCase() == 'ferry') ...[
          _buildSummaryRow('Route:', '${widget.transport?['origin']?.toString() ?? 'Unknown'} → ${widget.transport?['destination']?.toString() ?? 'Unknown'}'),
          // Ferry-specific information
          if (widget.ferryNumberOfPax != null)
            _buildSummaryRow('Number of Passengers:', '${widget.ferryNumberOfPax}'),
          if (widget.ferryTicketType != null)
            _buildSummaryRow('Ticket Type:', widget.ferryTicketType!.toUpperCase()),
        ] else ...[
          _buildSummaryRow('Route:', '${widget.transport?['origin']?.toString() ?? 'Unknown'} → ${widget.transport?['destination']?.toString() ?? 'Unknown'}'),
        ],

        // Date Information
        if (widget.departDate != null)
          _buildSummaryRow(
            widget.transport?['type']?.toString().toLowerCase() == 'car'
                ? 'Booking Date:'
                : widget.transport?['type']?.toString().toLowerCase() == 'ferry'
                ? 'Travel Date:'
                : 'Departure Date:',
            '${widget.departDate!.day}/${widget.departDate!.month}/${widget.departDate!.year}',
          ),
        if (widget.returnDate != null)
          _buildSummaryRow(
            'Return Date:',
            '${widget.returnDate!.day}/${widget.returnDate!.month}/${widget.returnDate!.year}',
          ),

        // Time and Seats
        if (widget.selectedTime != null)
          _buildSummaryRow('Selected Time:', widget.selectedTime!),
        if (widget.selectedSeats != null && widget.selectedSeats!.isNotEmpty) ...[
          _buildSummaryRow('Selected Seats:', widget.selectedSeats!.join(', ')),
          _buildSummaryRow('Number of Seats:', '${widget.selectedSeats!.length}'),
        ],

        // Price Breakdown
        if (widget.selectedSeats != null && widget.selectedSeats!.isNotEmpty) ...[
          _buildSummaryRow(
            'Base Price per Seat:',
            'MYR ${(widget.transport?['price'] ?? 0.0).toStringAsFixed(2)}',
            isSubtotal: true,
          ),
          _buildSummaryRow(
            'Quantity:',
            '${widget.selectedSeats!.length} seat${widget.selectedSeats!.length > 1 ? 's' : ''}',
            isSubtotal: true,
          ),
        ] else if (widget.numberOfDays != null && widget.transport?['type']?.toString().toLowerCase() == 'car') ...[
          _buildSummaryRow(
            'Price per Day:',
            'MYR ${(widget.transport?['price'] ?? 0.0).toStringAsFixed(2)}',
            isSubtotal: true,
          ),
          _buildSummaryRow(
            'Duration:',
            '${widget.numberOfDays} day${widget.numberOfDays! > 1 ? 's' : ''}',
            isSubtotal: true,
          ),
        ] else if (widget.transport?['type']?.toString().toLowerCase() == 'ferry' && widget.ferryNumberOfPax != null) ...[
          _buildSummaryRow(
            'Price per Passenger:',
            'MYR ${(widget.transport?['price'] ?? 0.0).toStringAsFixed(2)}',
            isSubtotal: true,
          ),
          _buildSummaryRow(
            'Number of Passengers:',
            '${widget.ferryNumberOfPax} passenger${widget.ferryNumberOfPax! > 1 ? 's' : ''}',
            isSubtotal: true,
          ),
        ],
      ],
    );
  }

  Widget _buildFlightSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Flight Details
        _buildSummaryRow('Flight:', '${widget.transport?['airline']} ${widget.transport?['flightNumber']}'),
        _buildSummaryRow('Aircraft:', widget.transport?['aircraft']?.toString() ?? 'Unknown'),
        _buildSummaryRow('Route:', '${widget.transport?['origin']} → ${widget.transport?['destination']}'),

        // Flight Times
        _buildSummaryRow('Departure:', widget.transport?['departureTime']?.toString() ?? 'Unknown'),
        _buildSummaryRow('Arrival:', widget.transport?['arrivalTime']?.toString() ?? 'Unknown'),
        _buildSummaryRow('Duration:', widget.transport?['duration']?.toString() ?? 'Unknown'),

        // Class and Date Information
        if (widget.transport?['selectedClass'] != null)
          _buildSummaryRow('Class:', widget.transport!['selectedClass'].toString()),

        if (widget.departDate != null)
          _buildSummaryRow(
            'Flight Date:',
            '${widget.departDate!.day}/${widget.departDate!.month}/${widget.departDate!.year}',
          ),

        if (widget.returnDate != null)
          _buildSummaryRow(
            'Return Date:',
            '${widget.returnDate!.day}/${widget.returnDate!.month}/${widget.returnDate!.year}',
          ),

        // Passenger count
        _buildSummaryRow('Passengers:', '${_passengers.length}'),

        Text(
          "${_passengers.length} Passenger${_passengers.length > 1 ? 's' : ''}",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.purple[600],
            ),
          ),
        _buildSummaryRow('Price per Passenger:', 'MYR ${widget.totalPrice.toStringAsFixed(2)}'),
        _buildSummaryRow('Total Base Price:', 'MYR ${(widget.totalPrice * _passengers.length).toStringAsFixed(2)}'),

        // Amenities (if available)
        if (widget.transport?['amenities'] != null &&
            (widget.transport!['amenities'] as Map).isNotEmpty) ...[
          SizedBox(height: 12),
          Text(
            'Included Amenities:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.transport!['amenities']['free_meal'] == true)
                  _buildAmenityRow('Free Meal', Icons.restaurant),
                if (widget.transport!['amenities']['free_wifi'] == true)
                  _buildAmenityRow('Free WiFi', Icons.wifi),
                if (widget.transport!['amenities']['checked_baggage_included'] == true)
                  _buildAmenityRow('Checked Baggage Included', Icons.luggage),
                if (widget.transport!['amenities']['carry_on'] != null)
                  _buildAmenityRow(
                    'Carry-on: ${widget.transport!['amenities']['carry_on']['pieces']} piece(s), ${widget.transport!['amenities']['carry_on']['weight_kg']}kg',
                    Icons.work_outline,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAmenityRow(String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.green[600]),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitDateCard() {
    Color primaryColor = Color(0xFF0C1FF7);

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: primaryColor, size: 24),
                SizedBox(width: 8),
                Text(
                  'Visit Date',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            InkWell(
              onTap: () => _selectVisitDate(context),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedVisitDate != null
                          ? '${_selectedVisitDate!.day}/${_selectedVisitDate!.month}/${_selectedVisitDate!.year}'
                          : 'Select visit date *',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedVisitDate != null ? Colors.black87 : Colors.grey[600],
                      ),
                    ),
                    Icon(Icons.calendar_today, color: primaryColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectVisitDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedVisitDate = pickedDate;
      });
    }
  }

  Widget _buildContactInformationCard() {
    Color primaryColor = _getPrimaryColor();

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contact_mail, color: primaryColor, size: 24),
                SizedBox(width: 8),
                Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    Color primaryColor = _getPrimaryColor();

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.credit_card, color: primaryColor, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Card Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _cardHolderController,
                decoration: InputDecoration(
                  labelText: 'Cardholder Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cardholder name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                  hintText: '1234 5678 9012 3456',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberInputFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card number';
                  }
                  if (value.replaceAll(' ', '').length < 13) {
                    return 'Please enter a valid card number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: InputDecoration(
                        labelText: 'MM/YY *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                        hintText: '05/28',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryDateInputFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter expiry date';
                        }
                        if (value.length < 5) {
                          return 'Please enter valid expiry date';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.security),
                        hintText: '123',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter CVV';
                        }
                        if (value.length < 3) {
                          return 'Please enter valid CVV';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayNowButton() {
    Color primaryColor = _getPrimaryColor();
    double finalAmount = isFlightBooking
        ? (widget.totalPrice * _passengers.length) + _additionalCosts  // Updated calculation
        : widget.totalPrice + _additionalCosts;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: _isProcessing
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Processing Payment...', style: TextStyle(fontSize: 16)),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 20),
            SizedBox(width: 8),
            Text(
              'Pay Now - MYR ${finalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isSubtotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSubtotal ? 14 : 16,
              color: isSubtotal ? Colors.grey[600] : Colors.black,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isSubtotal ? 14 : 16,
                fontWeight: isSubtotal ? FontWeight.normal : FontWeight.w500,
                color: isSubtotal ? Colors.grey[600] : Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    // Additional validation for attraction bookings
    if (isAttractionBooking) {
      // Check if visit date is selected (if not provided)
      if (widget.visitDate == null && _selectedVisitDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a visit date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Validate passenger information for flight bookings
    if (isFlightBooking) {
      if (!_passengerFormKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in all passenger information'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate lead passenger contact information
      if (_leadPassengerNameController.text.trim().isEmpty ||
          _leadPassengerEmailController.text.trim().isEmpty ||
          _leadPassengerPhoneController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in lead passenger contact information'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate that all passengers have required information
      for (int i = 0; i < _passengers.length; i++) {
        Passenger passenger = _passengers[i];
        if (passenger.surname.trim().isEmpty ||
            passenger.givenName.trim().isEmpty ||
            passenger.idNumber.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please complete information for Passenger ${i + 1}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    } else {
      // Validate contact information for non-flight bookings
      if (_emailController.text.isEmpty || _phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in all contact information'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Validate payment form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Prepare passenger data for flight bookings
      List<Map<String, dynamic>>? passengerData;
      Map<String, dynamic>? leadPassengerData;

      if (isFlightBooking) {
        // Lead passenger data
        leadPassengerData = {
          'fullName': _leadPassengerNameController.text.trim(),
          'email': _leadPassengerEmailController.text.trim(),
          'phone': _leadPassengerPhoneController.text.trim(),
        };

        // Passenger data
        passengerData = _passengers.map((passenger) => {
          'surname': passenger.surname.trim(),
          'givenName': passenger.givenName.trim(),
          'idNumber': passenger.idNumber.trim(),
          'idType': passenger.idType,
          'checkedBaggageWeight': passenger.checkedBaggageWeight, // Updated field
          'selectedMeal': passenger.selectedMeal,
        }).toList();
      }

      double finalTotalPrice = isFlightBooking
          ? (widget.totalPrice * _passengers.length) + _additionalCosts
          : widget.totalPrice + _additionalCosts;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Paymentloading(
          cardNumber: _cardNumberController.text,
          expiry: _expiryController.text,
          cvv: _cvvController.text,
          totalPrice: widget.totalPrice + (isFlightBooking ? _additionalCosts : 0),
          // Transport parameters (will be null for other bookings)
          transport: widget.transport,
          selectedTime: widget.selectedTime,
          selectedSeats: widget.selectedSeats ?? [],
          departDate: widget.departDate,
          returnDate: widget.returnDate,
          numberOfDays: widget.numberOfDays,
          // Attraction parameters (will be null for other bookings)
          attraction: widget.attraction,
          selectedTickets: widget.selectedTickets,
          visitDate: widget.visitDate ?? _selectedVisitDate,
          // Hotel parameters (will be null for other bookings)
          hotel: widget.hotel,
          checkInDate: widget.checkInDate,
          checkOutDate: widget.checkOutDate,
          numberOfGuests: widget.numberOfGuests,
          numberOfRooms: widget.numberOfRooms,
          numberOfNights: widget.numberOfNights,
          // Updated room type parameters
          selectedRoomTypes: widget.selectedRoomTypes,
          // Flight-specific passenger data
          passengerData: passengerData,
          leadPassengerData: leadPassengerData,
          additionalCosts: isFlightBooking ? _additionalCosts : 0.0,
          ferryNumberOfPax: widget.ferryNumberOfPax,
          ferryTicketType: widget.ferryTicketType,
        )),
      );

    } catch (e) {
      // Handle any errors
      print('Navigation error: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }
}

class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String newText = newValue.text.replaceAll(' ', '');
    String formattedText = '';

    for (int i = 0; i < newText.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formattedText += ' ';
      }
      formattedText += newText[i];
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String newText = newValue.text;
    String formattedText = '';

    if (newText.length > 0) {
      formattedText = newText.substring(0, newText.length > 2 ? 2 : newText.length);
      if (newText.length > 2) {
        formattedText += '/' + newText.substring(2);
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}