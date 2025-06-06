import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localquest/Module_Financial/Paymentloading.dart';
import 'package:localquest/Model/attraction_model.dart';
import '../Model/hotel.dart';

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
    // Common
    required this.totalPrice,
  }) : super(key: key);

  @override
  _BookingPaymentPageState createState() => _BookingPaymentPageState();
}

class _BookingPaymentPageState extends State<BookingPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedPaymentMethod = 'credit_card';
  bool _isProcessing = false;

  // For attraction visit date (if not provided)
  DateTime? _selectedVisitDate;

  // Check booking type
  bool get isAttractionBooking => widget.attraction != null;
  bool get isHotelBooking => widget.hotel != null;
  bool get isTransportBooking => widget.transport != null;

  @override
  void initState() {
    super.initState();
    _selectedVisitDate = widget.visitDate;
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
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
            // Booking Summary Card
            _buildBookingSummaryCard(),
            SizedBox(height: 24),

            // Visit Date Selection (for attractions only)
            if (isAttractionBooking && widget.visitDate == null)
              _buildVisitDateCard(),
            if (isAttractionBooking && widget.visitDate == null)
              SizedBox(height: 24),

            // Contact Information
            _buildContactInformationCard(),
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
    return Icons.receipt_long;
  }

  Widget _buildBookingSummaryCard() {
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

            // Total Amount
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: _getGradientColors()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
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
                    'MYR ${widget.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
        _buildSummaryRow('Number of Rooms:', '${widget.numberOfRooms}'),
        _buildSummaryRow('Number of Guests:', '${widget.numberOfGuests}'),

        SizedBox(height: 16),

        // Price Breakdown
        Container(
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
                    'Price per night:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'MYR ${widget.hotel!.price.toStringAsFixed(2)}',
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
                    '${widget.numberOfNights} night${widget.numberOfNights! > 1 ? 's' : ''} × ${widget.numberOfRooms} room${widget.numberOfRooms! > 1 ? 's' : ''}:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'MYR ${widget.totalPrice.toStringAsFixed(2)}',
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
        ] else ...[
          _buildSummaryRow('Route:', '${widget.transport?['origin']?.toString() ?? 'Unknown'} → ${widget.transport?['destination']?.toString() ?? 'Unknown'}'),
        ],

        // Date Information
        if (widget.departDate != null)
          _buildSummaryRow(
            widget.transport?['type']?.toString().toLowerCase() == 'car' ? 'Booking Date:' : 'Departure Date:',
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
        ] else if (widget.numberOfDays != null) ...[
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
        ],
      ],
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
                        hintText: '12/25',
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
              'Pay Now - MYR ${widget.totalPrice.toStringAsFixed(2)}',
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

    // Validate contact information
    if (_emailController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all contact information'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate payment form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Navigate to payment loading screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Paymentloading(
          cardNumber: _cardNumberController.text,
          expiry: _expiryController.text,
          cvv: _cvvController.text,
          totalPrice: widget.totalPrice,
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