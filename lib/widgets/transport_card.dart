import 'package:flutter/material.dart';
import '../Model/transport.dart';
import '../services/transport_service.dart';
import '../Module_Financial/Payment.dart'; // Import the new payment page

// Replace your current TransportCard class with this enhanced version:

class TransportCard extends StatefulWidget {
  final Map<String, dynamic> transport;
  final DateTime? departDate;
  final DateTime? returnDate;
  final int? numberOfDays;
  final int? ferryNumberOfPax;
  final String? ferryTicketType;

  const TransportCard({
    Key? key,
    required this.transport,
    this.departDate,
    this.returnDate,
    this.numberOfDays,
    this.ferryNumberOfPax,
    this.ferryTicketType,
  }) : super(key: key);

  @override
  _TransportCardState createState() => _TransportCardState();
}

class _TransportCardState extends State<TransportCard> {
  String? selectedTime;
  List<int> selectedSeats = [];
  final int maxSeats = 5;

  @override
  Widget build(BuildContext context) {
    // Extract data safely from the map
    List<String> timeSlots = [];
    if (widget.transport['timeSlots'] is List) {
      timeSlots = List<String>.from(widget.transport['timeSlots']);
      timeSlots.sort();
    }

    List<int> availableSeats = [];
    if (widget.transport['availableSeats'] is List) {
      availableSeats = List<int>.from(widget.transport['availableSeats']);
    }

    double basePrice = (widget.transport['price'] ?? 0.0).toDouble();
    double totalPrice;

    // Calculate total price based on transport type
    if (widget.transport['type']?.toString().toLowerCase() == 'car' && widget.numberOfDays != null) {
      totalPrice = basePrice * widget.numberOfDays!;
    } else if (widget.transport['type']?.toString().toLowerCase() == 'ferry' && widget.ferryNumberOfPax != null) {
      // Add ferry passenger calculation
      totalPrice = basePrice * widget.ferryNumberOfPax!;
    } else {
      totalPrice = basePrice * (selectedSeats.isNotEmpty ? selectedSeats.length : 1);
    }

    // Get availability status for cars
    bool isCarAvailable = widget.transport['additionalInfo']?['isAvailable'] ?? true;
    String availabilityStatus = widget.transport['additionalInfo']?['availabilityStatus'] ?? 'Available';

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transport Image with Availability Overlay for Cars
          if (widget.transport['imageUrl'] != null &&
              widget.transport['imageUrl'].toString().isNotEmpty)
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    widget.transport['imageUrl'].toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(Icons.image_not_supported, size: 50),
                        ),
                      );
                    },
                  ),
                ),
                // Availability Status Overlay for Cars
                if (widget.transport['type']?.toString().toLowerCase() == 'car')
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCarAvailable ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCarAvailable ? Icons.check_circle : Icons.cancel,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            availabilityStatus,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transport Name and Type
                Row(
                  children: [
                    Icon(_getTransportIcon(widget.transport['type']?.toString()),
                        size: 24, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.transport['name']?.toString() ?? 'Unnamed Transport',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Route or Location Information
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.transport['type']?.toString().toLowerCase() == 'car'
                            ? (widget.transport['location']?.toString() ?? widget.transport['origin']?.toString() ?? 'Unknown Location')
                            : '${widget.transport['origin']?.toString() ?? 'Unknown'} → ${widget.transport['destination']?.toString() ?? 'Unknown'}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),

                // Car Availability Status (Alternative placement if no image)
                if (widget.transport['type']?.toString().toLowerCase() == 'car' &&
                    (widget.transport['imageUrl'] == null || widget.transport['imageUrl'].toString().isEmpty)) ...[
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCarAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCarAvailable ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCarAvailable ? Icons.check_circle : Icons.cancel,
                          color: isCarAvailable ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          availabilityStatus,
                          style: TextStyle(
                            color: isCarAvailable ? Colors.green[800] : Colors.red[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Spacer(),
                        if (widget.transport['searchDates'] != null) ...[
                          Text(
                            'For ${widget.transport['searchDates']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 8),

                // Price information
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      widget.transport['type']?.toString().toLowerCase() == 'car'
                          ? 'MYR ${basePrice.toStringAsFixed(2)} per day'
                          : 'MYR ${basePrice.toStringAsFixed(2)} per seat',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                // Car-specific information
                if (widget.transport['type']?.toString().toLowerCase() == 'car') ...[
                  SizedBox(height: 8),
                  if (widget.transport['plateNumber'] != null)
                    _buildCarInfoRow('Plate Number:', widget.transport['plateNumber'].toString()),
                  if (widget.transport['color'] != null)
                    _buildCarInfoRow('Color:', widget.transport['color'].toString()),
                  if (widget.transport['maxPassengers'] != null)
                    _buildCarInfoRow('Max Passengers:', '${widget.transport['maxPassengers']} persons'),
                  if (widget.transport['driverIncluded'] != null)
                    _buildCarInfoRow('Driver:', widget.transport['driverIncluded'] == true ? 'Included' : 'Self-drive'),
                ],

                SizedBox(height: 12),
                Divider(),
                SizedBox(height: 8),

                // Available Times (Clickable) - Only for non-car transports
                if (timeSlots.isNotEmpty && widget.transport['type']?.toString().toLowerCase() != 'car') ...[
                  Text(
                    'Available Times:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: timeSlots.map((time) => GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTime = selectedTime == time ? null : time;
                          // Reset seat selection when time changes
                          if (selectedTime != time) {
                            selectedSeats.clear();
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selectedTime == time
                              ? Colors.deepPurple
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selectedTime == time
                                ? Colors.deepPurple
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: selectedTime == time
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    )).toList(),
                  ),
                  SizedBox(height: 12),
                ],

                // Seat Selection (only show if time is selected and not a car)
                if (selectedTime != null && availableSeats.isNotEmpty && widget.transport['type']?.toString().toLowerCase() != 'car') ...[
                  Text(
                    'Select Seats (Max 5):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
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
                          'Available Seats: ${availableSeats.length}/${widget.transport['totalSeats'] ?? 33}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        Column(
                          children: [
                            // Driver section indicator
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.drive_eta, size: 20, color: Colors.grey[600]),
                                  SizedBox(width: 8),
                                  Text(
                                    'Driver',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Seat layout
                            ...List.generate((availableSeats.length / 3).ceil(), (rowIndex) {
                              int startSeat = rowIndex * 3;
                              List<int> rowSeats = availableSeats
                                  .skip(startSeat)
                                  .take(3)
                                  .toList();

                              if (rowSeats.isEmpty) return SizedBox.shrink();

                              return Container(
                                margin: EdgeInsets.only(bottom: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Left side - Single seat
                                    if (rowSeats.length > 0)
                                      _buildSeatWidget(rowSeats[0])
                                    else
                                      SizedBox(width: 50),

                                    // Aisle space
                                    SizedBox(width: 20),

                                    // Right side - Double seats
                                    if (rowSeats.length > 1)
                                      _buildSeatWidget(rowSeats[1])
                                    else
                                      SizedBox(width: 50),
                                    SizedBox(width: 8),
                                    if (rowSeats.length > 2)
                                      _buildSeatWidget(rowSeats[2])
                                    else
                                      SizedBox(width: 50),
                                  ],
                                ),
                              );
                            }).toList(),

                            // Row labels
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  child: Text(
                                    'A',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Container(
                                  width: 50,
                                  child: Text(
                                    'B',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  width: 50,
                                  child: Text(
                                    'C',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (selectedSeats.length == maxSeats) ...[
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Maximum 5 seats selected',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                ],

                // Selected seats summary
                if (selectedSeats.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.deepPurple[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Seats:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Seats: ${selectedSeats.join(', ')}',
                          style: TextStyle(color: Colors.deepPurple[700]),
                        ),
                        Text(
                          'Quantity: ${selectedSeats.length}',
                          style: TextStyle(color: Colors.deepPurple[700]),
                        ),
                        Text(
                          'Total Price: MYR ${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],

                // Car rental summary
                if (widget.transport['type']?.toString().toLowerCase() == 'car' && widget.numberOfDays != null) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.deepPurple[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rental Summary:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Duration: ${widget.numberOfDays} day${widget.numberOfDays! > 1 ? 's' : ''}',
                          style: TextStyle(color: Colors.deepPurple[700]),
                        ),
                        Text(
                          'Price per day: MYR ${basePrice.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.deepPurple[700]),
                        ),
                        Text(
                          'Total Price: MYR ${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],

                // Ferry summary
                if (widget.transport['type']?.toString().toLowerCase() == 'ferry' && widget.ferryNumberOfPax != null) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.deepPurple[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ferry Booking Summary:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Passengers: ${widget.ferryNumberOfPax}',
                          style: TextStyle(color: Colors.deepPurple[700]),
                        ),
                        Text(
                          'Price per passenger: MYR ${(widget.transport['price'] ?? 0.0).toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.deepPurple[700]),
                        ),
                        Text(
                          'Total Price: MYR ${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],

                // Description
                if (widget.transport['description'] != null &&
                    widget.transport['description'].toString().isNotEmpty) ...[
                  Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.transport['description'].toString(),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16),
                ],

                // Book Now Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canBookNow()
                        ? () {
                      _navigateToPayment(context);
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canBookNow()
                          ? Colors.deepPurple
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _getBookButtonText(),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // Not Available Message for Cars
                if (widget.transport['type']?.toString().toLowerCase() == 'car' && !isCarAvailable) ...[
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[300]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This car is not available for your selected dates.',
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Try selecting different dates to check availability.',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  bool _canBookNow() {
    // For cars, check availability status
    if (widget.transport['type']?.toString().toLowerCase() == 'car') {
      bool isCarAvailable = widget.transport['isAvailable'] ?? true;
      return isCarAvailable; // Only allow booking if car is available
    }

    List<String> timeSlots = [];
    if (widget.transport['timeSlots'] is List) {
      timeSlots = List<String>.from(widget.transport['timeSlots']);
    }

    List<int> availableSeats = [];
    if (widget.transport['availableSeats'] is List) {
      availableSeats = List<int>.from(widget.transport['availableSeats']);
    }

    // If transport has time slots, user must select time
    if (timeSlots.isNotEmpty && selectedTime == null) {
      return false;
    }

    // If transport has available seats, user must select at least one seat
    if (availableSeats.isNotEmpty && selectedSeats.isEmpty) {
      return false;
    }

    return true;
  }

  String _getBookButtonText() {
    // For cars, check availability
    if (widget.transport['type']?.toString().toLowerCase() == 'car') {
      bool isCarAvailable = widget.transport['isAvailable'] ?? true;
      if (!isCarAvailable) {
        return 'Not Available';
      }
      double totalPrice = (widget.transport['price'] ?? 0.0).toDouble() * (widget.numberOfDays ?? 1);
      return 'Book Now - MYR ${totalPrice.toStringAsFixed(2)}';
    }

    List<String> timeSlots = [];
    if (widget.transport['timeSlots'] is List) {
      timeSlots = List<String>.from(widget.transport['timeSlots']);
    }

    List<int> availableSeats = [];
    if (widget.transport['availableSeats'] is List) {
      availableSeats = List<int>.from(widget.transport['availableSeats']);
    }

    // For ferries
    if (widget.transport['type']?.toString().toLowerCase() == 'ferry' && widget.ferryNumberOfPax != null) {
      double totalPrice = (widget.transport['price'] ?? 0.0).toDouble() * widget.ferryNumberOfPax!;
      return 'Book Now - MYR ${totalPrice.toStringAsFixed(2)}';
    }

    if (timeSlots.isNotEmpty && selectedTime == null) {
      return 'Select Time First';
    }

    if (availableSeats.isNotEmpty && selectedSeats.isEmpty) {
      return 'Select Seats to Book';
    }

    if (selectedSeats.isNotEmpty) {
      double totalPrice = (widget.transport['price'] ?? 0.0).toDouble() * selectedSeats.length;
      return 'Book Now - MYR ${totalPrice.toStringAsFixed(2)}';
    }

    return 'Book Now';
  }

  IconData _getTransportIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'bus':
        return Icons.directions_bus;
      case 'train':
        return Icons.train;
      case 'flight':
        return Icons.flight;
      case 'car':
        return Icons.directions_car;
      default:
        return Icons.directions_transit;
    }
  }

  void _navigateToPayment(BuildContext context) {
    // For cars, check availability one more time before navigation
    if (widget.transport['type']?.toString().toLowerCase() == 'car') {
      bool isCarAvailable = widget.transport['isAvailable'] ?? true;
      if (!isCarAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This car is not available for your selected dates.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    double totalPrice;

    // Calculate total price based on transport type
    if (widget.transport['type']?.toString().toLowerCase() == 'car' && widget.numberOfDays != null) {
      totalPrice = (widget.transport['price'] ?? 0.0).toDouble() * widget.numberOfDays!;
    } else if (widget.transport['type']?.toString().toLowerCase() == 'ferry' && widget.ferryNumberOfPax != null) {
      double basePrice = (widget.transport['price'] ?? 0.0).toDouble();
      totalPrice = basePrice * widget.ferryNumberOfPax!;

    } else {
      totalPrice = (widget.transport['price'] ?? 0.0).toDouble() * (selectedSeats.isNotEmpty ? selectedSeats.length : 1);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPaymentPage(
          transport: widget.transport,
          selectedTime: selectedTime,
          selectedSeats: selectedSeats,
          totalPrice: totalPrice,
          departDate: widget.departDate,
          returnDate: widget.returnDate,
          numberOfDays: widget.numberOfDays,
          ferryNumberOfPax: widget.ferryNumberOfPax,
          ferryTicketType: widget.ferryTicketType,
        ),
      ),
    );
  }

  Widget _buildSeatWidget(int seatNumber) {
    bool isSelected = selectedSeats.contains(seatNumber);
    bool canSelect = selectedSeats.length < maxSeats || isSelected;

    return GestureDetector(
      onTap: canSelect ? () {
        setState(() {
          if (isSelected) {
            selectedSeats.remove(seatNumber);
          } else {
            if (selectedSeats.length < maxSeats) {
              selectedSeats.add(seatNumber);
            }
          }
        });
      } : null,
      child: Container(
        width: 50,
        height: 45,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.deepPurple
              : canSelect
              ? Colors.white
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Colors.deepPurple
                : Colors.grey[400]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_seat,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : canSelect
                  ? Colors.grey[600]
                  : Colors.grey[400],
            ),
            Text(
              seatNumber.toString(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : canSelect
                    ? Colors.black
                    : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}