import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localquest/Module_Financial/Paymentloading.dart';

class BookingPaymentPage extends StatefulWidget {
  final Map<String, dynamic> transport;
  final String? selectedTime;
  final List<int> selectedSeats;
  final double totalPrice;
  final DateTime? departDate;
  final DateTime? returnDate;
  final int? numberOfDays;

  const BookingPaymentPage({
    Key? key,
    required this.transport,
    this.selectedTime,
    required this.selectedSeats,
    required this.totalPrice,
    this.departDate,
    this.returnDate,
    this.numberOfDays,
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
        title: Text('Booking Summary & Payment'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7107F3), Color(0xFFFF02FA)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Summary Card
            _buildBookingSummaryCard(),
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

  Widget _buildBookingSummaryCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Color(0xFF7107F3), size: 24),
                SizedBox(width: 8),
                Text(
                  'Booking Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7107F3),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 12),

            // Transport Details
            _buildSummaryRow('Transport Name:', widget.transport['name']?.toString() ?? 'Unknown'),
            _buildSummaryRow('Transport Type:', widget.transport['type']?.toString() ?? 'Unknown'),

            if (widget.transport['type']?.toString().toLowerCase() == 'car') ...[
              _buildSummaryRow('Location:', widget.transport['location']?.toString() ?? widget.transport['origin']?.toString() ?? 'Unknown'),
              if (widget.numberOfDays != null)
                _buildSummaryRow('Duration:', '${widget.numberOfDays} day${widget.numberOfDays! > 1 ? 's' : ''}'),
            ] else ...[
              _buildSummaryRow('Route:', '${widget.transport['origin']?.toString() ?? 'Unknown'} → ${widget.transport['destination']?.toString() ?? 'Unknown'}'),
            ],

            // Date Information
            if (widget.departDate != null)
              _buildSummaryRow(
                widget.transport['type']?.toString().toLowerCase() == 'car' ? 'Booking Date:' : 'Departure Date:',
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
            if (widget.selectedSeats.isNotEmpty) ...[
              _buildSummaryRow('Selected Seats:', widget.selectedSeats.join(', ')),
              _buildSummaryRow('Number of Seats:', '${widget.selectedSeats.length}'),
            ],

            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 12),

            // Price Breakdown
            if (widget.selectedSeats.isNotEmpty) ...[
              _buildSummaryRow(
                'Base Price per Seat:',
                'MYR ${(widget.transport['price'] ?? 0.0).toStringAsFixed(2)}',
                isSubtotal: true,
              ),
              _buildSummaryRow(
                'Quantity:',
                '${widget.selectedSeats.length} seat${widget.selectedSeats.length > 1 ? 's' : ''}',
                isSubtotal: true,
              ),
            ] else if (widget.numberOfDays != null) ...[
              _buildSummaryRow(
                'Price per Day:',
                'MYR ${(widget.transport['price'] ?? 0.0).toStringAsFixed(2)}',
                isSubtotal: true,
              ),
              _buildSummaryRow(
                'Duration:',
                '${widget.numberOfDays} day${widget.numberOfDays! > 1 ? 's' : ''}',
                isSubtotal: true,
              ),
            ],

            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF7107F3).withOpacity(0.1),
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
                      color: Color(0xFF7107F3),
                    ),
                  ),
                  Text(
                    'MYR ${widget.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7107F3),
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

  Widget _buildContactInformationCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contact_mail, color: Color(0xFF7107F3), size: 24),
                SizedBox(width: 8),
                Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7107F3),
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
                  Icon(Icons.credit_card, color: Color(0xFF7107F3), size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Card Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7107F3),
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
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF7107F3),
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
          transport: widget.transport,
          selectedTime: widget.selectedTime,
          selectedSeats: widget.selectedSeats,
          totalPrice: widget.totalPrice,
          departDate: widget.departDate,
          returnDate: widget.returnDate,
          numberOfDays: widget.numberOfDays,
        ),
        ),
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