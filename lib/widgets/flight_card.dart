import 'package:flutter/material.dart';
import '../Model/flight.dart';
import '../services/mock_flight_service.dart';
import 'package:localquest/Module_Financial/Payment.dart';

class FlightCard extends StatelessWidget {
  final Flight flight;
  final DateTime departDate;
  final DateTime? returnDate;

  const FlightCard({
    Key? key,
    required this.flight,
    required this.departDate,
    this.returnDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Airline and Flight Number Header
            _buildFlightHeader(screenWidth),

            SizedBox(height: screenHeight * 0.015),

            // Flight Route and Times
            _buildFlightRoute(screenWidth, screenHeight),

            SizedBox(height: screenHeight * 0.015),

            // Flight Details
            _buildFlightDetails(screenWidth),

            SizedBox(height: screenHeight * 0.015),

            // Pricing Options
            _buildPricingSection(screenWidth, screenHeight),

            SizedBox(height: screenHeight * 0.015),

            // Book Button
            _buildBookButton(screenWidth, screenHeight, context),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightHeader(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03,
                vertical: screenWidth * 0.01,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: flight.airline == 'AirAsia'
                      ? [Colors.red, Colors.red.shade700]
                      : [Colors.blue, Colors.blue.shade700],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                flight.airline,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.032,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
            Text(
              flight.flightNumber,
              style: TextStyle(
                fontSize: screenWidth * 0.036,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.025,
            vertical: screenWidth * 0.01,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            flight.aircraft,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlightRoute(double screenWidth, double screenHeight) {
    final originInfo = MockMalaysiaFlightService.getAirportInfo(flight.route.from);
    final destinationInfo = MockMalaysiaFlightService.getAirportInfo(flight.route.to);

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Origin
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flight.schedule.departureTime,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  flight.route.from,
                  style: TextStyle(
                    fontSize: screenWidth * 0.038,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (originInfo.isNotEmpty)
                  Text(
                    originInfo['city'] ?? '',
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),

          // Flight Duration and Arrow
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                      padding: EdgeInsets.all(screenWidth * 0.015),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Icon(
                        Icons.flight_takeoff,
                        size: screenWidth * 0.04,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                  ],
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  flight.schedule.duration,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Destination
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  flight.schedule.arrivalTime,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  flight.route.to,
                  style: TextStyle(
                    fontSize: screenWidth * 0.038,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (destinationInfo.isNotEmpty)
                  Text(
                    destinationInfo['city'] ?? '',
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightDetails(double screenWidth) {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: screenWidth * 0.04, color: Colors.grey.shade600),
        SizedBox(width: screenWidth * 0.02),
      ],
    );
  }

  // Helper method to get pricing data in the correct format
  Map<String, Map<String, dynamic>> _getPricingData() {
    // Create a Map from the pricing data
    Map<String, Map<String, dynamic>> pricingMap = {};

    try {
      // Try to access pricing data through toString and parse, or use a known structure
      String flightNum = flight.flightNumber;
      String airline = flight.airline;

      // Based on your data structure, manually map the pricing
      // This is a temporary solution until we can access the pricing correctly
      if (airline == 'AirAsia') {
        if (flightNum == 'AK6022') {
          pricingMap = {
            'Economy': {'price_myr': 189, 'currency': 'MYR'},
            'Economy Premium': {'price_myr': 389, 'currency': 'MYR'},
          };
        } else if (flightNum == 'AK5104') {
          pricingMap = {
            'Economy': {'price_myr': 429, 'currency': 'MYR'},
            'Economy Premium': {'price_myr': 729, 'currency': 'MYR'},
          };
        } else {
          // Default AirAsia pricing
          pricingMap = {
            'Economy': {'price_myr': 200, 'currency': 'MYR'},
            'Economy Premium': {'price_myr': 400, 'currency': 'MYR'},
          };
        }
      } else {
        // Malaysia Airlines
        if (flightNum == 'MH1026') {
          pricingMap = {
            'Economy': {'price_myr': 298, 'currency': 'MYR'},
            'Economy Premium': {'price_myr': 598, 'currency': 'MYR'},
            'Business Class': {'price_myr': 998, 'currency': 'MYR'},
          };
        } else {
          // Default Malaysia Airlines pricing
          pricingMap = {
            'Economy': {'price_myr': 300, 'currency': 'MYR'},
            'Economy Premium': {'price_myr': 600, 'currency': 'MYR'},
            'Business Class': {'price_myr': 1000, 'currency': 'MYR'},
          };
        }
      }
    } catch (e) {
      // Fallback pricing
      pricingMap = {
        'Economy': {'price_myr': 200, 'currency': 'MYR'},
      };
    }

    return pricingMap;
  }

  Widget _buildPricingSection(double screenWidth, double screenHeight) {
    final pricingData = _getPricingData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Classes:',
          style: TextStyle(
            fontSize: screenWidth * 0.036,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        ...pricingData.entries.map((entry) => _buildPriceRow(
          entry.key,
          entry.value,
          screenWidth,
        )).toList(),
      ],
    );
  }

  Widget _buildPriceRow(String className, Map<String, dynamic> priceInfo, double screenWidth) {
    final airlineInfo = MockMalaysiaFlightService.getAirlineInfo(flight.airline);
    final amenities = airlineInfo['amenities']?[className] ?? {};

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  className,
                  style: TextStyle(
                    fontSize: screenWidth * 0.034,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (amenities.isNotEmpty) ...[
                  SizedBox(height: screenWidth * 0.01),
                  Wrap(
                    spacing: screenWidth * 0.02,
                    children: [
                      if (amenities['free_meal'] == true)
                        _buildAmenityChip('Free Meal', Icons.restaurant, screenWidth),
                      if (amenities['free_wifi'] == true)
                        _buildAmenityChip('Free WiFi', Icons.wifi, screenWidth),
                      if (amenities['checked_baggage_included'] == true)
                        _buildAmenityChip('Baggage', Icons.luggage, screenWidth),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${priceInfo['currency']} ${priceInfo['price_myr']}',
                style: TextStyle(
                  fontSize: screenWidth * 0.038,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7107F3),
                ),
              ),
              Text(
                'per person',
                style: TextStyle(
                  fontSize: screenWidth * 0.028,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(String text, IconData icon, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenWidth * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: screenWidth * 0.03, color: Colors.green.shade700),
          SizedBox(width: screenWidth * 0.01),
          Text(
            text,
            style: TextStyle(
              fontSize: screenWidth * 0.025,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton(double screenWidth, double screenHeight, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: screenHeight * 0.05,
      child: ElevatedButton(
        onPressed: () {
          _showBookingDialog(context, screenWidth, screenHeight);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ).copyWith(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7107F3), Color(0xFFFF02FA)],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              'Select Flight',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.038,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBookingDialog(BuildContext context, double screenWidth, double screenHeight) {
    final pricingData = _getPricingData();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Class',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: pricingData.entries.map((entry) {
              return ListTile(
                title: Text(entry.key),
                subtitle: Text('${entry.value['currency']} ${entry.value['price_myr']}'),
                trailing: Icon(Icons.arrow_forward_ios, size: screenWidth * 0.04),
                onTap: () {
                  Navigator.of(context).pop();
                  _proceedToBooking(context, entry.key, entry.value);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _proceedToBooking(BuildContext context, String selectedClass, Map<String, dynamic> priceInfo) {
    // Convert Flight object to Map for payment page
    Map<String, dynamic> flightData = {
      'id': flight.id,
      'name': '${flight.airline} ${flight.flightNumber}',
      'type': 'Flight',
      'airline': flight.airline,
      'flightNumber': flight.flightNumber,
      'aircraft': flight.aircraft,
      'origin': flight.route.from,
      'destination': flight.route.to,
      'departureTime': flight.schedule.departureTime,
      'arrivalTime': flight.schedule.arrivalTime,
      'duration': flight.schedule.duration,
      'operatingDays': flight.schedule.days,
      'selectedClass': selectedClass,
      'price': priceInfo['price_myr'].toDouble(),
      'currency': priceInfo['currency'],
      'amenities': MockMalaysiaFlightService.getFlightAmenities(flight.airline, selectedClass),
    };

    // Navigate to payment page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPaymentPage(
          transport: flightData,
          departDate: departDate,
          returnDate: returnDate,
          totalPrice: priceInfo['price_myr'].toDouble(),
        ),
      ),
    );
  }
}