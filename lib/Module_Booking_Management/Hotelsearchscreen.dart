import 'package:flutter/material.dart';
import '../Model/hotel.dart';
import '../widgets/hotel_card.dart';
import 'Hoteldetails.dart';

class HotelSearchResultsScreen extends StatelessWidget {
  final List<Hotel> hotels;
  final String destination;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int adults;
  final int children;

  HotelSearchResultsScreen({
    required this.hotels,
    required this.destination,
    required this.checkInDate,
    required this.checkOutDate,
    required this.adults,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
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
      ),
      body: Column(
        children: [
          _buildSearchSummary(),
          _buildHotelList(context),
        ],
      ),
    );
  }

  Widget _buildSearchSummary() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.deepOrange, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  destination,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey[600], size: 16),
              SizedBox(width: 8),
              Text(
                '${checkInDate.day}/${checkInDate.month}/${checkInDate.year} - ${checkOutDate.day}/${checkOutDate.month}/${checkOutDate.year}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(width: 16),
              Icon(Icons.people, color: Colors.grey[600], size: 16),
              SizedBox(width: 4),
              Text(
                '$adults Adult${adults > 1 ? 's' : ''}${children > 0 ? ', $children Child${children > 1 ? 'ren' : ''}' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '${hotels.length} hotel${hotels.length != 1 ? 's' : ''} found',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.deepOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelList(BuildContext context) {
    if (hotels.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hotel_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No hotels found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try adjusting your search criteria',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: hotels.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: HotelCard(
              hotel: hotels[index],
              onTap: () => _navigateToHotelDetails(context, hotels[index]),
            ),
          );
        },
      ),
    );
  }

  void _navigateToHotelDetails(BuildContext context, Hotel hotel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelDetailsScreen(hotel: hotel),
      ),
    );
  }
}