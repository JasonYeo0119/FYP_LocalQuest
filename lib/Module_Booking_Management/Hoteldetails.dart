// Updated HotelDetailsScreen to accept pre-filled data
import 'package:flutter/material.dart';
import '../Model/hotel.dart';
import '../Module_Financial/Payment.dart';

class HotelDetailsScreen extends StatefulWidget {
  final Hotel hotel;

  // Optional parameters that can be passed from search
  final DateTime? prefilledCheckInDate;
  final DateTime? prefilledCheckOutDate;
  final int? prefilledNumberOfGuests;
  final int? prefilledNumberOfChildren;

  HotelDetailsScreen({
    required this.hotel,
    // Optional pre-filled data from search
    this.prefilledCheckInDate,
    this.prefilledCheckOutDate,
    this.prefilledNumberOfGuests,
    this.prefilledNumberOfChildren,
  });

  @override
  _HotelDetailsScreenState createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _numberOfGuests = 1;
  int _numberOfRooms = 1;
  int _numberOfNights = 1;

  @override
  void initState() {
    super.initState();

    // Initialize with pre-filled data if provided
    _checkInDate = widget.prefilledCheckInDate;
    _checkOutDate = widget.prefilledCheckOutDate;

    // Calculate total guests (adults + children) and rooms
    if (widget.prefilledNumberOfGuests != null) {
      int totalGuests = widget.prefilledNumberOfGuests!;
      if (widget.prefilledNumberOfChildren != null) {
        totalGuests += widget.prefilledNumberOfChildren!;
      }
      _numberOfGuests = totalGuests;

      // Estimate number of rooms needed (assuming 2 guests per room)
      _numberOfRooms = (totalGuests / 2).ceil().clamp(1, 10);
    }

    // Calculate nights if both dates are provided
    if (_checkInDate != null && _checkOutDate != null) {
      _calculateNumberOfNights();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hotel.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF4502), Color(0xFFFFFF00)],
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.hotel.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: Icon(Icons.hotel, size: 64, color: Colors.grey[600]),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.hotel.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.white, size: 18),
                            SizedBox(width: 4),
                            Text(
                              widget.hotel.rating.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.hotel.address,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Show pre-filled info banner if data was passed
                  if (widget.prefilledCheckInDate != null || widget.prefilledCheckOutDate != null)
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your search details have been applied! You can modify them below if needed.',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 20),

                  // Booking Details Section
                  _buildBookingDetailsCard(),
                  SizedBox(height: 20),

                  Text(
                    'Amenities',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.hotel.amenities.map((amenity) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Text(
                          amenity,
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 30),

                  // Price Summary
                  _buildPriceSummaryCard(),
                  SizedBox(height: 20),

                  // Book Now Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canProceedToPayment() ? _proceedToPayment : null,
                      child: Text(
                        'Book Now',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canProceedToPayment() ? Colors.green[600] : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

  Widget _buildBookingDetailsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange[600],
              ),
            ),
            SizedBox(height: 16),

            // Check-in Date
            ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.orange[600]),
              title: Text('Check-in Date'),
              subtitle: Text(_checkInDate != null
                  ? '${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year}'
                  : 'Select check-in date'),
              onTap: () => _selectCheckInDate(context),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),

            // Check-out Date
            ListTile(
              leading: Icon(Icons.calendar_today_outlined, color: Colors.orange[600]),
              title: Text('Check-out Date'),
              subtitle: Text(_checkOutDate != null
                  ? '${_checkOutDate!.day}/${_checkOutDate!.month}/${_checkOutDate!.year}'
                  : 'Select check-out date'),
              onTap: () => _selectCheckOutDate(context),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),

            // Number of Guests
            ListTile(
              leading: Icon(Icons.people, color: Colors.orange[600]),
              title: Text('Number of Guests'),
              subtitle: Text('$_numberOfGuests guest${_numberOfGuests > 1 ? 's' : ''}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _numberOfGuests > 1 ? () {
                      setState(() {
                        _numberOfGuests--;
                      });
                    } : null,
                    icon: Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_numberOfGuests'),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _numberOfGuests++;
                      });
                    },
                    icon: Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ),

            // Number of Rooms
            ListTile(
              leading: Icon(Icons.hotel, color: Colors.orange[600]),
              title: Text('Number of Rooms'),
              subtitle: Text('$_numberOfRooms room${_numberOfRooms > 1 ? 's' : ''}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _numberOfRooms > 1 ? () {
                      setState(() {
                        _numberOfRooms--;
                      });
                    } : null,
                    icon: Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_numberOfRooms'),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _numberOfRooms++;
                      });
                    },
                    icon: Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ),

            if (_checkInDate != null && _checkOutDate != null)
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Duration:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '$_numberOfNights night${_numberOfNights > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummaryCard() {
    double totalPrice = _calculateTotalPrice();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF4502), Color(0xFFFFFF00)],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          if (_checkInDate != null && _checkOutDate != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price per night:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'MYR ${widget.hotel.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_numberOfNights night${_numberOfNights > 1 ? 's' : ''} × $_numberOfRooms room${_numberOfRooms > 1 ? 's' : ''}:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'MYR ${(widget.hotel.price * _numberOfNights * _numberOfRooms).toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Divider(color: Colors.white, thickness: 1),
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
                'MYR ${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectCheckInDate(BuildContext context) async {
    DateTime today = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? today,
      firstDate: today,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _checkInDate = pickedDate;

        // If check-out date is before or same as check-in, reset it
        if (_checkOutDate != null && _checkOutDate!.isBefore(pickedDate.add(Duration(days: 1)))) {
          _checkOutDate = null;
        }

        _calculateNumberOfNights();
      });
    }
  }

  Future<void> _selectCheckOutDate(BuildContext context) async {
    if (_checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select check-in date first')),
      );
      return;
    }

    DateTime minDate = _checkInDate!.add(Duration(days: 1));
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _checkOutDate ?? minDate,
      firstDate: minDate,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _checkOutDate = pickedDate;
        _calculateNumberOfNights();
      });
    }
  }

  void _calculateNumberOfNights() {
    if (_checkInDate != null && _checkOutDate != null) {
      _numberOfNights = _checkOutDate!.difference(_checkInDate!).inDays;
    }
  }

  double _calculateTotalPrice() {
    if (_checkInDate != null && _checkOutDate != null) {
      return widget.hotel.price * _numberOfNights * _numberOfRooms;
    }
    return widget.hotel.price;
  }

  bool _canProceedToPayment() {
    return _checkInDate != null && _checkOutDate != null && _numberOfNights > 0;
  }

  void _proceedToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPaymentPage(
          // Hotel booking parameters
          hotel: widget.hotel,
          checkInDate: _checkInDate!,
          checkOutDate: _checkOutDate!,
          numberOfGuests: _numberOfGuests,
          numberOfRooms: _numberOfRooms,
          numberOfNights: _numberOfNights,
          totalPrice: _calculateTotalPrice(),
        ),
      ),
    );
  }
}