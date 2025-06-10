import 'package:flutter/material.dart';
import '../Model/transport.dart';
import '../Model/attraction_model.dart';
import '../services/itinerary_service.dart';
import '../services/itinerary_storage_service.dart';
import '../widgets/state_attraction_viewer.dart';
import 'Viewitinerary.dart';

class ItineraryDisplayPage extends StatefulWidget {
  final GeneratedItinerary itinerary;
  const ItineraryDisplayPage({Key? key, required this.itinerary}) : super(key: key);

  @override
  _ItineraryDisplayPageState createState() => _ItineraryDisplayPageState();
}

class _ItineraryDisplayPageState extends State<ItineraryDisplayPage> {
  int selectedDayIndex = 0;
  bool showAttractionsViewer = false;
  bool isSaving = false;

  Future<void> _saveItinerary() async {
    // Show dialog to get custom name
    final customName = await _showSaveDialog();
    if (customName == null || customName.trim().isEmpty) return;

    setState(() {
      isSaving = true;
    });

    try {
      // Check if name already exists
      final exists = await ItineraryStorageService.doesNameExist(customName.trim());
      if (exists) {
        _showErrorSnackBar('An itinerary with this name already exists');
        setState(() {
          isSaving = false;
        });
        return;
      }

      final success = await ItineraryStorageService.saveItinerary(widget.itinerary, customName.trim());

      setState(() {
        isSaving = false;
      });

      if (success) {
        _showSuccessSnackBar('Itinerary saved successfully!');
      } else {
        _showErrorSnackBar('Failed to save itinerary');
      }
    } catch (e) {
      setState(() {
        isSaving = false;
      });
      _showErrorSnackBar('Error saving itinerary: $e');
    }
  }

  Future<String?> _showSaveDialog() async {
    final controller = TextEditingController();

    // Generate default name based on states and date
    final states = widget.itinerary.originalRequest.selectedStates.join('-');
    final date = DateTime.now();
    final defaultName = '$states Trip ${date.day}/${date.month}/${date.year}';
    controller.text = defaultName;

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Save Itinerary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Give your itinerary a memorable name:',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Itinerary Name',
                border: OutlineInputBorder(),
                hintText: 'e.g., Summer Holiday 2024',
              ),
              maxLength: 50,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View Saved',
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ViewItineraryPage()),
            );
          },
        ),
      ),
    );
  }

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
        actions: [
          // Save button
          if (isSaving)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              onPressed: _saveItinerary,
              icon: Icon(Icons.bookmark_add, color: Colors.white),
              tooltip: 'Save Itinerary',
            ),

          // View saved itineraries button
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ViewItineraryPage()),
              );
            },
            icon: Icon(Icons.bookmark, color: Colors.white),
            tooltip: 'View Saved Itineraries',
          ),

          // Attractions browser button
          IconButton(
            onPressed: () {
              setState(() {
                showAttractionsViewer = !showAttractionsViewer;
              });
            },
            icon: Icon(
              showAttractionsViewer ? Icons.close : Icons.explore,
              color: Colors.white,
            ),
            tooltip: showAttractionsViewer ? 'Close Attractions' : 'Browse All Attractions',
          ),
        ],
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${widget.itinerary.days.length} Days Trip",
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    // Save and explore buttons row
                    Row(
                      children: [
                        // Save button (secondary)
                        ElevatedButton.icon(
                          onPressed: isSaving ? null : _saveItinerary,
                          icon: isSaving
                              ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : Icon(Icons.bookmark_add, size: screenWidth * 0.035),
                          label: Text(
                            isSaving ? 'Saving...' : 'Save',
                            style: TextStyle(fontSize: screenWidth * 0.032),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03,
                              vertical: screenHeight * 0.008,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),

                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              showAttractionsViewer = !showAttractionsViewer;  // Toggle instead of just setting to true
                            });
                          },
                          icon: Icon(
                              showAttractionsViewer ? Icons.close : Icons.explore,  // Dynamic icon
                              size: screenWidth * 0.04
                          ),
                          label: Text(
                            showAttractionsViewer ? 'Close' : 'Explore',  // Dynamic label
                            style: TextStyle(fontSize: screenWidth * 0.032),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: showAttractionsViewer ? Colors.red : Colors.blue,  // Dynamic color
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03,
                              vertical: screenHeight * 0.008,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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

          // Attractions Viewer (when toggled)
          if (showAttractionsViewer) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.blue.shade200),
                ),
              ),
              child: Column(
                children: [
                  // Header for attractions section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.015,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.explore,
                          color: Colors.blue.shade700,
                          size: screenWidth * 0.05,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          'Explore All Attractions',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // The attractions viewer widget
                  StateAttractionsViewer(
                    selectedStates: widget.itinerary.originalRequest.selectedStates,
                    tripType: widget.itinerary.originalRequest.tripType,
                    maxBudget: widget.itinerary.originalRequest.maxBudget,
                  ),
                ],
              ),
            ),
          ],

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

                // Determine what to display for the day state
                String dayStateText;
                if (index == 0) {
                  // First day shows travel from origin
                  dayStateText = "From ${widget.itinerary.originalRequest.origin}";
                } else {
                  // Other days show the destination state
                  dayStateText = day.state;
                }

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
                          dayStateText,
                          style: TextStyle(
                            fontSize: screenWidth * 0.025,
                            color: isSelected ? Colors.white : Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                // Updated header text to show origin for first day
                Text(
                  selectedDayIndex == 0
                      ? "${day.date.day}/${day.date.month}/${day.date.year} - Travel from ${widget.itinerary.originalRequest.origin} to ${day.state}"
                      : "${day.date.day}/${day.date.month}/${day.date.year} - ${day.state}",
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Attractions Visited",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
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

  // Method to show attractions for a single state
  void _showSingleStateAttractions(String state) {
    showDialog(
      context: context,
      builder: (context) => StateAttractionsDialog(
        state: state,
        attractions: [], // Will be loaded by the dialog
        tripType: widget.itinerary.originalRequest.tripType,
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