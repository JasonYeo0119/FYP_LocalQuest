import 'package:flutter/material.dart';
import '../Model/transport.dart';
import '../Model/attraction_model.dart';
import '../services/itinerary_service.dart';


class ItineraryDisplayPage extends StatefulWidget {
  final GeneratedItinerary itinerary;
  const ItineraryDisplayPage({Key? key, required this.itinerary}) : super(key: key);

  @override
  _ItineraryDisplayPageState createState() => _ItineraryDisplayPageState();
}

class _ItineraryDisplayPageState extends State<ItineraryDisplayPage> {
  int selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your Trip Itinerary",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF02ED64), Color(0xFFFFFA02)],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Trip summary
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.itinerary.days.length} Days Trip",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Cost: RM${widget.itinerary.totalCost.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        color: widget.itinerary.isWithinBudget ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      "Budget: RM${widget.itinerary.originalRequest.maxBudget.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  "States: ${widget.itinerary.originalRequest.selectedStates.join(', ')}",
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          // Day selector
          Container(
            height: screenHeight * 0.08,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              itemCount: widget.itinerary.days.length,
              itemBuilder: (context, index) {
                final day = widget.itinerary.days[index];
                final isSelected = selectedDayIndex == index;

                return GestureDetector(
                  onTap: () => setState(() => selectedDayIndex = index),
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.01,
                      vertical: screenHeight * 0.01,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Day ${index + 1}",
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          day.state,
                          style: TextStyle(
                            fontSize: screenWidth * 0.025,
                            color: isSelected ? Colors.white : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Day details
          Expanded(
            child: _buildDayDetails(widget.itinerary.days[selectedDayIndex], screenWidth, screenHeight),
          ),
        ],
      ),
    );
  }

  Widget _buildDayDetails(ItineraryDay day, double screenWidth, double screenHeight) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${day.date.day}/${day.date.month}/${day.date.year} - ${day.state}",
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                if (day.hotel != null) ...[
                  Text(
                    "Hotel: ${day.hotel!.name}",
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    day.hotel!.address,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                SizedBox(height: screenHeight * 0.01),
                Text(
                  "Day Cost: RM${day.totalCost.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          // Schedule
          Text(
            "Schedule",
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),

          ...day.schedule.map((activity) => _buildActivityCard(activity, screenWidth, screenHeight)),

          SizedBox(height: screenHeight * 0.02),

          // Attractions summary
          if (day.attractions.isNotEmpty) ...[
            Text(
              "Attractions Visited",
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            ...day.attractions.map((attraction) => _buildAttractionCard(attraction, screenWidth, screenHeight)),
          ],

          SizedBox(height: screenHeight * 0.02),

          // Transport summary
          if (day.transports.isNotEmpty) ...[
            Text(
              "Transportation",
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            ...day.transports.map((transport) => _buildTransportCard(transport, screenWidth, screenHeight)),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityCard(ScheduledActivity activity, double screenWidth, double screenHeight) {
    Color activityColor = _getActivityColor(activity.activityType);
    IconData activityIcon = _getActivityIcon(activity.activityType);

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: activityColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: screenWidth * 0.12,
            height: screenWidth * 0.12,
            decoration: BoxDecoration(
              color: activityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activityIcon,
              color: activityColor,
              size: screenWidth * 0.06,
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activity.timeRange,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                        color: activityColor,
                      ),
                    ),
                    if (activity.cost != null && activity.cost! > 0)
                      Text(
                        "RM${activity.cost!.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade600,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: screenWidth * 0.032,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (activity.location != null) ...[
                  SizedBox(height: screenHeight * 0.005),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: screenWidth * 0.035,
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Expanded(
                        child: Text(
                          activity.location!,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttractionCard(Attraction attraction, double screenWidth, double screenHeight) {
    double price = attraction.pricing.isNotEmpty ? attraction.pricing.first.price : 0;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.place, color: Colors.blue, size: screenWidth * 0.05),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attraction.name,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  attraction.address,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  "Types: ${attraction.type.join(', ')}",
                  style: TextStyle(
                    fontSize: screenWidth * 0.028,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          if (price > 0)
            Text(
              "RM${price.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: screenWidth * 0.032,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransportCard(Transport transport, double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(_getTransportIcon(transport.type), color: Colors.orange, size: screenWidth * 0.05),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transport.name,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  transport.route,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  transport.type,
                  style: TextStyle(
                    fontSize: screenWidth * 0.028,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            transport.formattedPrice,
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String activityType) {
    switch (activityType) {
      case 'transport':
        return Colors.orange;
      case 'attraction':
        return Colors.blue;
      case 'meal':
        return Colors.green;
      case 'rest':
        return Colors.purple;
      case 'checkin':
      case 'checkout':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String activityType) {
    switch (activityType) {
      case 'transport':
        return Icons.directions;
      case 'attraction':
        return Icons.place;
      case 'meal':
        return Icons.restaurant;
      case 'rest':
        return Icons.hotel;
      case 'checkin':
        return Icons.login;
      case 'checkout':
        return Icons.logout;
      default:
        return Icons.event;
    }
  }

  IconData _getTransportIcon(String transportType) {
    switch (transportType.toLowerCase()) {
      case 'flight':
        return Icons.flight;
      case 'bus':
        return Icons.directions_bus;
      case 'train':
        return Icons.train;
      case 'car':
        return Icons.directions_car;
      case 'ferry':
        return Icons.directions_boat;
      default:
        return Icons.directions;
    }
  }
}