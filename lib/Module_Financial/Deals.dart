import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Deals extends StatefulWidget {
  @override
  _DealsState createState() => _DealsState();
}

class _DealsState extends State<Deals> with SingleTickerProviderStateMixin {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> activeDeals = [];
  List<Map<String, dynamic>> expiredDeals = [];
  bool isLoading = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchDeals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchDeals() async {
    try {
      setState(() {
        isLoading = true;
      });

      DatabaseEvent event = await _database.child('deals').once();
      DataSnapshot snapshot = event.snapshot;

      List<Map<String, dynamic>> activeList = [];
      List<Map<String, dynamic>> expiredList = [];

      if (snapshot.exists) {
        Map<dynamic, dynamic> dealsData = snapshot.value as Map<dynamic, dynamic>;

        dealsData.forEach((dealId, dealData) {
          if (dealData is Map) {
            Map<String, dynamic> deal = {};
            dealData.forEach((key, value) {
              deal[key.toString()] = value;
            });
            deal['dealId'] = dealId.toString();

            // Check if deal is expired based on date/time
            bool isExpired = isDealExpired(deal['endDate'], deal['endTime']);

            // Categorize deals - show active, expired, but skip inactive
            if (deal['status'] == 'active' && !isExpired) {
              activeList.add(deal);
            } else if (deal['status'] == 'expired' || isExpired) {
              expiredList.add(deal);
            }
          }
        });
      }

      // Sort deals by creation date (newest first)
      activeList.sort((a, b) {
        String dateA = a['createdAt']?.toString() ?? '';
        String dateB = b['createdAt']?.toString() ?? '';
        return dateB.compareTo(dateA);
      });

      expiredList.sort((a, b) {
        String dateA = a['createdAt']?.toString() ?? '';
        String dateB = b['createdAt']?.toString() ?? '';
        return dateB.compareTo(dateA);
      });

      setState(() {
        activeDeals = activeList;
        expiredDeals = expiredList;
        isLoading = false;
      });

    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading deals: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';

    // If it's already in DD/MM/YYYY format, return as is
    if (dateStr.contains('/')) {
      return dateStr;
    }

    // Otherwise, try to parse and format
    try {
      DateTime date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    return timeStr; // Already in HH:MM format from the form
  }

  String formatDateTime(String? dateStr, String? timeStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';

    String formattedDate = formatDate(dateStr);
    String formattedTime = formatTime(timeStr);

    if (formattedTime.isNotEmpty) {
      return '$formattedDate at $formattedTime';
    }
    return formattedDate;
  }

  bool isDealExpired(String? endDateStr, String? endTimeStr) {
    if (endDateStr == null || endDateStr.isEmpty) return false;

    try {
      DateTime endDate;

      // Parse DD/MM/YYYY format
      if (endDateStr.contains('/')) {
        List<String> parts = endDateStr.split('/');
        if (parts.length == 3) {
          endDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        } else {
          return false;
        }
      } else {
        // Fallback to ISO format
        endDate = DateTime.parse(endDateStr);
      }

      // If time is specified, parse it
      if (endTimeStr != null && endTimeStr.isNotEmpty) {
        List<String> timeParts = endTimeStr.split(':');
        if (timeParts.length >= 2) {
          int hour = int.parse(timeParts[0]);
          int minute = int.parse(timeParts[1]);
          endDate = DateTime(endDate.year, endDate.month, endDate.day, hour, minute);
        }
      } else {
        // If no time specified, assume end of day
        endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      }

      return DateTime.now().isAfter(endDate);
    } catch (e) {
      return false;
    }
  }

  bool hasTimeInformation(Map<String, dynamic> deal) {
    String? startTime = deal['startTime']?.toString();
    String? endTime = deal['endTime']?.toString();
    return (startTime != null && startTime.isNotEmpty) ||
        (endTime != null && endTime.isNotEmpty);
  }

  Widget buildDealCard(Map<String, dynamic> deal, bool isExpiredTab) {
    bool isExpired = isDealExpired(deal['endDate'], deal['endTime']);
    bool hasTime = hasTimeInformation(deal);

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: isExpired ? 4 : 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deal Image
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isExpired ? [
                        Colors.grey.shade600,
                        Colors.grey.shade700,
                        Colors.grey.shade800,
                      ] : [
                        Color(0xFF0816A7),
                        Color(0xFF1E40AF),
                        Color(0xFF3B82F6),
                      ],
                    ),
                  ),
                  child: deal['image'] != null && deal['image'].toString().isNotEmpty
                      ? ColorFiltered(
                    colorFilter: isExpired
                        ? ColorFilter.mode(Colors.grey, BlendMode.saturation)
                        : ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                    child: Image.network(
                      deal['image'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isExpired ? [
                                Colors.grey.shade600,
                                Colors.grey.shade700,
                                Colors.grey.shade800,
                              ] : [
                                Color(0xFF0816A7),
                                Color(0xFF1E40AF),
                                Color(0xFF3B82F6),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.local_offer,
                              size: 60,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isExpired ? [
                                Colors.grey.shade600,
                                Colors.grey.shade700,
                                Colors.grey.shade800,
                              ] : [
                                Color(0xFF0816A7),
                                Color(0xFF1E40AF),
                                Color(0xFF3B82F6),
                              ],
                            ),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                      : Center(
                    child: Icon(
                      Icons.local_offer,
                      size: 60,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),

                // Status badges
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isExpired ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      isExpired ? 'EXPIRED' : 'ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Time indicator badge (if deal has specific times)
                if (hasTime)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isExpired ? Colors.grey.shade600 : Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'TIMED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Expired overlay
                if (isExpired)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'DEAL EXPIRED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Deal Content
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isExpired ? [
                    Colors.grey.shade600,
                    Colors.grey.shade700,
                  ] : [
                    Color(0xFF0816A7),
                    Color(0xFF0A1B8A),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Deal Title
                    Text(
                      deal['name'] ?? 'Special Offer',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        decoration: isExpired ? TextDecoration.lineThrough : TextDecoration.none,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12),

                    // Deal Description
                    Text(
                      deal['description'] ?? 'Amazing deal waiting for you!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(isExpired ? 0.7 : 0.9),
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 20),

                    // Date and Time Information
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(isExpired ? 0.05 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(isExpired ? 0.1 : 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Start Date and Time
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.play_arrow,
                                color: Colors.green.shade300,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Started",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      formatDateTime(deal['startDate'], deal['startTime']),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(isExpired ? 0.7 : 0.9),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16),

                          // Divider
                          Container(
                            height: 1,
                            color: Colors.white.withOpacity(isExpired ? 0.1 : 0.2),
                          ),

                          SizedBox(height: 16),

                          // End Date and Time
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.stop,
                                color: isExpired ? Colors.red.shade300 : Colors.orange.shade300,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isExpired ? "Expired" : "Ends",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      formatDateTime(deal['endDate'], deal['endTime']),
                                      style: TextStyle(
                                        color: isExpired
                                            ? Colors.red.shade200
                                            : Colors.white.withOpacity(0.9),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Additional time info if available
                          if (hasTime) ...[
                            SizedBox(height: 12),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (isExpired ? Colors.grey.shade600 : Colors.blue.shade600).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'This deal has specific timing',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState(String title, String subtitle, IconData icon, bool isExpiredTab) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: fetchDeals,
            icon: Icon(Icons.refresh),
            label: Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0816A7),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Special Deals", style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        ),
        backgroundColor: Color(0xFF0816A7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchDeals,
            tooltip: 'Refresh Deals',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer, size: 20),
                  SizedBox(width: 8),
                  Text('Active (${activeDeals.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 20),
                  SizedBox(width: 8),
                  Text('Expired (${expiredDeals.length})'),
                ],
              ),
            ),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0816A7)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading amazing deals...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          // Active Deals Tab
          activeDeals.isEmpty
              ? buildEmptyState(
            'No Active Deals',
            'All deals are currently inactive or expired.\nCheck back soon for exciting offers!',
            Icons.local_offer_outlined,
            false,
          )
              : RefreshIndicator(
            onRefresh: fetchDeals,
            color: Color(0xFF0816A7),
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: activeDeals.length,
              itemBuilder: (context, index) {
                return buildDealCard(activeDeals[index], false);
              },
            ),
          ),

          // Expired Deals Tab
          expiredDeals.isEmpty
              ? buildEmptyState(
            'No Expired Deals',
            'No deals have expired yet.\nExpired deals will appear here for reference.',
            Icons.schedule,
            true,
          )
              : RefreshIndicator(
            onRefresh: fetchDeals,
            color: Color(0xFF0816A7),
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: expiredDeals.length,
              itemBuilder: (context, index) {
                return buildDealCard(expiredDeals[index], true);
              },
            ),
          ),
        ],
      ),
    );
  }
}