import 'package:flutter/material.dart';
import 'package:localquest/Module_Booking_Management/Bookingallinone.dart' hide Attraction hide Transport;
import '../Model/transport.dart';
import '../Model/attraction_model.dart';
import '../services/itinerary_service.dart';
import '../services/itinerary_storage_service.dart';
import '../widgets/state_attraction_viewer.dart';
import 'package:intl/intl.dart';

class ViewItineraryPage extends StatefulWidget {
  const ViewItineraryPage({Key? key}) : super(key: key);

  @override
  _ViewItineraryPageState createState() => _ViewItineraryPageState();
}

class _ViewItineraryPageState extends State<ViewItineraryPage> {
  List<SavedItinerary> savedItineraries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedItineraries();
  }

  Future<void> _loadSavedItineraries() async {
    setState(() {
      isLoading = true;
    });

    try {
      final itineraries = await ItineraryStorageService.getAllSavedItineraries();
      setState(() {
        savedItineraries = itineraries;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Error loading saved itineraries');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deleteItinerary(SavedItinerary itinerary) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Itinerary'),
        content: Text('Are you sure you want to delete "${itinerary.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ItineraryStorageService.deleteItinerary(itinerary.id);
      if (success) {
        _showSuccessSnackBar('Itinerary deleted successfully');
        _loadSavedItineraries();
      } else {
        _showErrorSnackBar('Failed to delete itinerary');
      }
    }
  }

  Future<void> _renameItinerary(SavedItinerary itinerary) async {
    final controller = TextEditingController(text: itinerary.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename Itinerary'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Itinerary Name',
            border: OutlineInputBorder(),
          ),
          maxLength: 50,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != itinerary.name) {
      final exists = await ItineraryStorageService.doesNameExist(newName);
      if (exists) {
        _showErrorSnackBar('An itinerary with this name already exists');
        return;
      }

      final success = await ItineraryStorageService.updateItineraryName(itinerary.id, newName);
      if (success) {
        _showSuccessSnackBar('Itinerary renamed successfully');
        _loadSavedItineraries();
      } else {
        _showErrorSnackBar('Failed to rename itinerary');
      }
    }
  }

  void _navigateToItineraryDetails(SavedItinerary savedItinerary) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SavedItineraryDetailPage(savedItinerary: savedItinerary),
      ),
    ).then((_) {
      // Refresh the list when returning from detail page
      _loadSavedItineraries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Saved Itineraries",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Color(0xFF0816A7),
        actions: [
          IconButton(
            onPressed: _loadSavedItineraries,
            icon: Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : savedItineraries.isEmpty
          ? _buildEmptyState(screenWidth, screenHeight)
          : ListView.builder(
        padding: EdgeInsets.all(screenWidth * 0.04),
        itemCount: savedItineraries.length,
        itemBuilder: (context, index) {
          return _buildItineraryCard(savedItineraries[index], screenWidth, screenHeight);
        },
      ),
    );
  }

  Widget _buildEmptyState(double screenWidth, double screenHeight) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: screenWidth * 0.2,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            'No Saved Itineraries',
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'Create and save itineraries to view them here',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.03),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Bookingallinone(), // Replace with your page
                ),
              );
            },
            icon: Icon(Icons.add),
            label: Text('Create New Itinerary'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.015,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryCard(SavedItinerary savedItinerary, double screenWidth, double screenHeight) {
    final itinerary = savedItinerary.itinerary;

    return Card(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => _navigateToItineraryDetails(savedItinerary),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          savedItinerary.name,
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          "Saved on ${DateFormat('dd/MM/yyyy').format(savedItinerary.savedDate)}",
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey.shade400,
                        size: screenWidth * 0.04,
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'rename') {
                            _renameItinerary(savedItinerary);
                          } else if (value == 'delete') {
                            _deleteItinerary(savedItinerary);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'rename',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Rename'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.015),

              // Trip Summary Row
              Row(
                children: [
                  // Duration
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.025,
                      vertical: screenHeight * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today,
                            size: screenWidth * 0.035,
                            color: Colors.blue.shade700),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          "${itinerary.days.length} Days",
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: screenWidth * 0.02),

                  // Cost
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.025,
                      vertical: screenHeight * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: itinerary.isWithinBudget ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: itinerary.isWithinBudget ? Colors.green.shade200 : Colors.red.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_money,
                            size: screenWidth * 0.035,
                            color: itinerary.isWithinBudget ? Colors.green.shade700 : Colors.red.shade700),
                        Text(
                          "RM${itinerary.totalCost.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w600,
                            color: itinerary.isWithinBudget ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.015),

              // States
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: screenWidth * 0.04,
                      color: Colors.grey.shade600),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: Text(
                      itinerary.originalRequest.selectedStates.join(' • '),
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.01),

              // Origin
              Row(
                children: [
                  Icon(Icons.flight_takeoff,
                      size: screenWidth * 0.04,
                      color: Colors.grey.shade600),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    "From ${itinerary.originalRequest.origin}",
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.grey.shade600,
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
}

class SavedItineraryDetailPage extends StatefulWidget {
  final SavedItinerary savedItinerary;

  const SavedItineraryDetailPage({Key? key, required this.savedItinerary}) : super(key: key);

  @override
  _SavedItineraryDetailPageState createState() => _SavedItineraryDetailPageState();
}

class _SavedItineraryDetailPageState extends State<SavedItineraryDetailPage> {
  int selectedDayIndex = 0;
  bool showAttractionsViewer = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final itinerary = widget.savedItinerary.itinerary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.savedItinerary.name,
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Color(0xFF0816A7),
        actions: [
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
                      "${itinerary.days.length} Days Trip",
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    // Explore attractions button
                    if (!showAttractionsViewer)
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            showAttractionsViewer = true;
                          });
                        },
                        icon: Icon(Icons.explore, size: screenWidth * 0.04),
                        label: Text(
                          'Explore',
                          style: TextStyle(fontSize: screenWidth * 0.032),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
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
                SizedBox(height: screenHeight * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Cost: RM${itinerary.totalCost.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        color: itinerary.isWithinBudget ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      "Budget: RM${itinerary.originalRequest.maxBudget.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  "States: ${itinerary.originalRequest.selectedStates.join(', ')}",
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  "Saved on: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.savedItinerary.savedDate)}",
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey.shade600,
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
                    selectedStates: itinerary.originalRequest.selectedStates,
                    tripType: itinerary.originalRequest.tripType,
                    maxBudget: itinerary.originalRequest.maxBudget,
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
              itemCount: itinerary.days.length,
              itemBuilder: (context, index) {
                final day = itinerary.days[index];
                final isSelected = selectedDayIndex == index;

                String dayStateText;
                if (index == 0) {
                  dayStateText = "From ${itinerary.originalRequest.origin}";
                } else {
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
            child: _buildDayDetails(itinerary.days[selectedDayIndex], itinerary, screenWidth, screenHeight),
          ),
        ],
      ),
    );
  }

  Widget _buildDayDetails(ItineraryDay day, GeneratedItinerary itinerary, double screenWidth, double screenHeight) {
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
                  selectedDayIndex == 0
                      ? "${day.date.day}/${day.date.month}/${day.date.year} - Travel from ${itinerary.originalRequest.origin} to ${day.state}"
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
              color: Colors.white,
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
                color: Colors.white,
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
                color: Colors.white,
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
                    color: Colors.black
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
                    color: Colors.black
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