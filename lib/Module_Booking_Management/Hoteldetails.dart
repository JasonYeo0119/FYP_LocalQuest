import 'package:flutter/material.dart';
import '../Model/hotel.dart';
import '../Module_Financial/Payment.dart';

class HotelDetailsScreen extends StatefulWidget {
  final Hotel hotel;
  final DateTime? prefilledCheckInDate;
  final DateTime? prefilledCheckOutDate;
  final int? prefilledNumberOfGuests;
  final int? prefilledNumberOfChildren;

  HotelDetailsScreen({
    required this.hotel,
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
  int _numberOfNights = 1;

  // Room selection state
  Map<String, int> _selectedRooms = {}; // roomTypeName -> quantity
  bool _showRoomSelectionError = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Initialize with pre-filled data if provided
    _checkInDate = widget.prefilledCheckInDate;
    _checkOutDate = widget.prefilledCheckOutDate;

    // Calculate total guests (adults + children)
    if (widget.prefilledNumberOfGuests != null) {
      int totalGuests = widget.prefilledNumberOfGuests!;
      if (widget.prefilledNumberOfChildren != null) {
        totalGuests += widget.prefilledNumberOfChildren!;
      }
      _numberOfGuests = totalGuests;
    }

    // Calculate nights if both dates are provided
    if (_checkInDate != null && _checkOutDate != null) {
      _calculateNumberOfNights();
    }

    // Initialize with no rooms selected initially
    _selectedRooms = {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.hotel.name,
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
            _buildHotelImage(),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHotelHeader(),
                  _buildPrefilledInfoBanner(),
                  SizedBox(height: 20),
                  _buildBookingDetailsCard(),
                  SizedBox(height: 20),
                  _buildAmenitiesSection(),
                  SizedBox(height: 20),
                  if (_selectedRooms.isNotEmpty) _buildPriceSummaryCard(),
                  SizedBox(height: 20),
                  _buildBookNowButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelImage() {
    return Image.network(
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
    );
  }

  Widget _buildHotelHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.hotel.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.hotel.address,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
    );
  }

  Widget _buildPrefilledInfoBanner() {
    if (widget.prefilledCheckInDate == null && widget.prefilledCheckOutDate == null) {
      return SizedBox.shrink();
    }

    return Container(
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
            _buildDateSelection(),
            _buildGuestSelection(),
            _buildNightsSummary(),
            Divider(thickness: 1, color: Colors.grey[300]),
            SizedBox(height: 16),
            _buildRoomSelectionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildGuestSelection() {
    return ListTile(
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
    );
  }

  Widget _buildNightsSummary() {
    if (_checkInDate == null || _checkOutDate == null) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: 20),
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
    );
  }

  Widget _buildRoomSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Rooms',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange[600],
              ),
            ),
            if (_selectedRooms.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedRooms.clear();
                    _showRoomSelectionError = false;
                  });
                },
                child: Text(
                  'Clear All',
                  style: TextStyle(color: Colors.red[600], fontSize: 12),
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Choose room types and quantities for your stay',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),

        // Show error message if no rooms selected when trying to book
        if (_showRoomSelectionError)
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[600], size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please select at least one room to continue',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        SizedBox(height: 12),

        if (widget.hotel.roomTypes == null || widget.hotel.roomTypes!.isEmpty)
          _buildNoRoomsAvailable()
        else
          _buildRoomTypesList(),
      ],
    );
  }

  Widget _buildNoRoomsAvailable() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[600], size: 24),
            SizedBox(height: 8),
            Text(
              'No room types available for this hotel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Please contact the hotel directly for booking',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomTypesList() {
    return Column(
      children: [
        // Selected rooms summary
        if (_selectedRooms.isNotEmpty) _buildSelectedRoomsSummary(),

        // Available room types
        ...widget.hotel.roomTypes!.map((roomType) {
          return _buildRoomTypeCard(roomType);
        }).toList(),
      ],
    );
  }

  Widget _buildSelectedRoomsSummary() {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Rooms:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
              fontSize: 12,
            ),
          ),
          SizedBox(height: 6),
          ..._selectedRooms.entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${entry.value}x ${entry.key}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Text(
                    'MYR ${(_getRoomPrice(entry.key) * entry.value).toStringAsFixed(0)}/night',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRoomTypeCard(Map<String, dynamic> roomType) {
    String roomTypeName = roomType['name'];
    int currentQuantity = _selectedRooms[roomTypeName] ?? 0;
    int maxQuantity = roomType['quantity'];
    double price = roomType['price'].toDouble();

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: currentQuantity > 0 ? Colors.orange[600]! : Colors.grey[300]!,
          width: currentQuantity > 0 ? 2 : 1,
        ),
        color: currentQuantity > 0 ? Colors.orange[50] : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  roomTypeName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: currentQuantity > 0 ? Colors.orange[800] : Colors.black87,
                  ),
                ),
              ),
              Text(
                'MYR ${price.toStringAsFixed(0)}/night',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            roomType['description'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.hotel_class, size: 12, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    '${maxQuantity} available',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              _buildQuantitySelector(roomTypeName, currentQuantity, maxQuantity),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(String roomTypeName, int currentQuantity, int maxQuantity) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: currentQuantity > 0 ? () {
            setState(() {
              if (currentQuantity == 1) {
                _selectedRooms.remove(roomTypeName);
              } else {
                _selectedRooms[roomTypeName] = currentQuantity - 1;
              }
              _showRoomSelectionError = false;
            });
          } : null,
          icon: Icon(
            Icons.remove_circle_outline,
            color: currentQuantity > 0 ? Colors.orange[600] : Colors.grey,
            size: 20,
          ),
        ),
        Container(
          width: 30,
          height: 25,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              '$currentQuantity',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: currentQuantity < maxQuantity ? () {
            setState(() {
              _selectedRooms[roomTypeName] = currentQuantity + 1;
              _showRoomSelectionError = false;
            });
          } : null,
          icon: Icon(
            Icons.add_circle_outline,
            color: currentQuantity < maxQuantity ? Colors.orange[600] : Colors.grey,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildPriceSummaryCard() {
    double totalPrice = _calculateTotalPrice();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color(0xFFFF4502),
      ),
      child: Column(
        children: [
          Text(
            'Booking Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          ..._selectedRooms.entries.map((entry) {
            String roomName = entry.key;
            int quantity = entry.value;
            double roomPrice = _getRoomPrice(roomName);
            double roomTotal = roomPrice * quantity * _numberOfNights;

            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${quantity}x $roomName',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        'MYR ${roomPrice.toStringAsFixed(0)}/night',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (_numberOfNights > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '  × $_numberOfNights night${_numberOfNights > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          'MYR ${roomTotal.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }).toList(),
          if (_checkInDate != null && _checkOutDate != null && _selectedRooms.isNotEmpty) ...[
            Divider(color: Colors.white, thickness: 1),
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
        ],
      ),
    );
  }

  Widget _buildBookNowButton() {
    bool canProceed = _canProceedToPayment();
    String buttonText = _getBookButtonText();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canProceed ? _proceedToPayment : _handleBookingAttempt,
        child: Text(
          buttonText,
          style: TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: canProceed ? Colors.green[600] : Colors.grey,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Helper methods
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

  double _getRoomPrice(String roomTypeName) {
    for (var roomType in widget.hotel.roomTypes!) {
      if (roomType['name'] == roomTypeName) {
        return roomType['price'].toDouble();
      }
    }
    return 0.0;
  }

  double _calculateTotalPrice() {
    if (_checkInDate == null || _checkOutDate == null || _selectedRooms.isEmpty) {
      return 0.0;
    }

    double total = 0.0;
    _selectedRooms.forEach((roomName, quantity) {
      double roomPrice = _getRoomPrice(roomName);
      total += roomPrice * quantity * _numberOfNights;
    });

    return total;
  }

  int _getTotalRooms() {
    return _selectedRooms.values.fold(0, (sum, quantity) => sum + quantity);
  }

  bool _canProceedToPayment() {
    return _checkInDate != null &&
        _checkOutDate != null &&
        _numberOfNights > 0 &&
        _selectedRooms.isNotEmpty;
  }

  String _getBookButtonText() {
    if (_checkInDate == null || _checkOutDate == null) {
      return 'Please select dates';
    }
    if (_selectedRooms.isEmpty) {
      return 'Please select rooms';
    }
    return 'Book Now - MYR ${_calculateTotalPrice().toStringAsFixed(2)}';
  }

  void _handleBookingAttempt() {
    if (_selectedRooms.isEmpty) {
      setState(() {
        _showRoomSelectionError = true;
      });
      // Scroll to room selection section
      return;
    }

    // Handle other validation cases
    if (_checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select check-in date')),
      );
      return;
    }

    if (_checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select check-out date')),
      );
      return;
    }
  }

  void _proceedToPayment() {
    // Create a list of selected room details for payment
    List<Map<String, dynamic>> selectedRoomDetails = [];
    _selectedRooms.forEach((roomName, quantity) {
      selectedRoomDetails.add({
        'roomType': roomName,
        'quantity': quantity,
        'pricePerNight': _getRoomPrice(roomName),
        'totalPrice': _getRoomPrice(roomName) * quantity * _numberOfNights,
      });
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPaymentPage(
          hotel: widget.hotel,
          checkInDate: _checkInDate!,
          checkOutDate: _checkOutDate!,
          numberOfGuests: _numberOfGuests,
          numberOfRooms: _getTotalRooms(),
          numberOfNights: _numberOfNights,
          totalPrice: _calculateTotalPrice(),
          selectedRoomTypes: selectedRoomDetails,
        ),
      ),
    );
  }
}