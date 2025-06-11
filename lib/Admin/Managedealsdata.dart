import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:localquest/Admin/Adminpage.dart';
import 'package:localquest/Admin/DealsNew.dart';
import 'package:localquest/Admin/DealsEdit.dart';

class Managedealsdata extends StatefulWidget {
  @override
  ManagedealsdataState createState() => ManagedealsdataState();
}

class ManagedealsdataState extends State<Managedealsdata> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> deals = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchDeals();
  }

  Future<void> fetchDeals() async {
    try {
      setState(() {
        isLoading = true;
      });

      DatabaseEvent event = await _database.child('deals').once();
      DataSnapshot snapshot = event.snapshot;

      List<Map<String, dynamic>> dealsList = [];

      if (snapshot.exists) {
        Map<dynamic, dynamic> dealsData = snapshot.value as Map<dynamic, dynamic>;

        for (var entry in dealsData.entries) {
          String dealId = entry.key.toString();
          var dealData = entry.value;

          if (dealData is Map) {
            Map<String, dynamic> deal = {};
            dealData.forEach((key, value) {
              deal[key.toString()] = value;
            });
            deal['dealId'] = dealId;

            // Check if deal should be expired and update if necessary
            await _checkAndUpdateExpiredStatus(dealId, deal);

            dealsList.add(deal);
          }
        }
      }

      // Sort deals by creation date (newest first)
      dealsList.sort((a, b) {
        String dateA = a['createdAt']?.toString() ?? '';
        String dateB = b['createdAt']?.toString() ?? '';
        return dateB.compareTo(dateA);
      });

      setState(() {
        deals = dealsList;
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

  Future<void> _checkAndUpdateExpiredStatus(String dealId, Map<String, dynamic> deal) async {
    try {
      String? endDate = deal['endDate']?.toString();
      String? endTime = deal['endTime']?.toString();
      String? currentStatus = deal['status']?.toString().toLowerCase();

      // Skip if already expired or if no end date
      if (currentStatus == 'expired' || endDate == null || endDate.isEmpty) {
        return;
      }

      DateTime now = DateTime.now();
      DateTime? expiryDateTime = _parseExpiryDateTime(endDate, endTime);

      if (expiryDateTime != null && now.isAfter(expiryDateTime)) {
        // Update status to expired in Firebase
        await _database.child('deals').child(dealId).update({
          'status': 'expired',
          'expiredAt': now.toIso8601String(),
        });

        // Update local deal object
        deal['status'] = 'expired';
        deal['expiredAt'] = now.toIso8601String();

        print('Deal "$dealId" automatically set to expired');
      }
    } catch (e) {
      print('Error checking expiry for deal $dealId: $e');
    }
  }

  DateTime? _parseExpiryDateTime(String endDate, String? endTime) {
    try {
      DateTime date = DateTime.parse(endDate);

      if (endTime != null && endTime.isNotEmpty) {
        // Parse time if provided (assuming format like "HH:mm" or "HH:mm:ss")
        List<String> timeParts = endTime.split(':');
        if (timeParts.length >= 2) {
          int hour = int.parse(timeParts[0]);
          int minute = int.parse(timeParts[1]);
          int second = timeParts.length > 2 ? int.parse(timeParts[2]) : 59; // Default to end of minute

          return DateTime(date.year, date.month, date.day, hour, minute, second);
        }
      }

      // If no time specified, assume end of day (23:59:59)
      return DateTime(date.year, date.month, date.day, 23, 59, 59);
    } catch (e) {
      print('Error parsing expiry date/time: $e');
      return null;
    }
  }

  Future<void> _deleteDeal(String dealId, String dealName) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Deal'),
        content: Text('Are you sure you want to delete "$dealName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _database.child('deals').child(dealId).remove();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deal deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        fetchDeals(); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting deal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get filteredDeals {
    if (searchQuery.isEmpty) {
      return deals;
    }
    return deals.where((deal) {
      String name = deal['name']?.toString().toLowerCase() ?? '';
      String description = deal['description']?.toString().toLowerCase() ?? '';
      String query = searchQuery.toLowerCase();
      return name.contains(query) || description.contains(query);
    }).toList();
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'expired':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _addNewDeal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Dealsnew()),
    );

    if (result == true) {
      fetchDeals(); // Refresh the deals list
    }
  }

  void _editDeal(Map<String, dynamic> deal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DealsEdit(deal: deal),
      ),
    );

    if (result == true) {
      fetchDeals(); // Refresh the deals list
    }
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Adminpage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Deals Data",
          style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.home_filled),
            onPressed: _goHome,
            tooltip: 'Home',
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNewDeal,
            tooltip: 'Add New Deal',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar and summary
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.black,
            child: Column(
              children: [
                // Search bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search deals...',
                    prefixIcon: Icon(Icons.search, color: Colors.blue.shade600),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          searchQuery = '';
                        });
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                SizedBox(height: 12),

                // Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSummaryCard('Total Deals', deals.length.toString(), Icons.local_offer, Colors.blue),
                    _buildSummaryCard(
                        'Active',
                        deals.where((d) => d['status'] == 'active').length.toString(),
                        Icons.check_circle,
                        Colors.green
                    ),
                    _buildSummaryCard(
                        'Expired',
                        deals.where((d) => d['status'] == 'expired').length.toString(),
                        Icons.schedule,
                        Colors.orange
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Deals list
          Expanded(
            child: isLoading
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading deals...'),
                ],
              ),
            )
                : filteredDeals.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    searchQuery.isEmpty ? 'No deals found' : 'No deals match your search',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addNewDeal,
                    icon: Icon(Icons.add),
                    label: Text('Create First Deal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: fetchDeals,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: filteredDeals.length,
                itemBuilder: (context, index) {
                  final deal = filteredDeals[index];
                  return DealCard(
                    deal: deal,
                    onEdit: () => _editDeal(deal),
                    onDelete: () => _deleteDeal(deal['dealId'], deal['name'] ?? 'Unknown'),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addNewDeal,
        backgroundColor: Colors.blue.shade700,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Add New Deal',
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DealCard extends StatelessWidget {
  final Map<String, dynamic> deal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DealCard({
    Key? key,
    required this.deal,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'expired':
        return Colors.orange;
      default:
        return Colors.grey;
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

  String formatDateTime(String? dateStr, String? timeStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateStr);
      String formattedDate = '${date.day}/${date.month}/${date.year}';

      if (timeStr != null && timeStr.isNotEmpty) {
        return '$formattedDate at $timeStr';
      }
      return formattedDate;
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    deal['name'] ?? 'Unnamed Deal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusColor(deal['status']),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '${deal['status'] ?? 'UNKNOWN'}'.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Description
            if (deal['description'] != null && deal['description'].toString().isNotEmpty) ...[
              Text(
                deal['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
            ],

            // Date range with time
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.date_range, size: 16, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'Start: ${formatDateTime(deal['startDate'], deal['startTime'])}',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.event, size: 16, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'End: ${formatDateTime(deal['endDate'], deal['endTime'])}',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Show expired timestamp if deal is expired
            if (deal['status']?.toString().toLowerCase() == 'expired' && deal['expiredAt'] != null) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: Colors.orange.shade700),
                    SizedBox(width: 6),
                    Text(
                      'Expired: ${formatDate(deal['expiredAt'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit, size: 16),
                  label: Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue.shade700,
                  ),
                ),
                SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete, size: 16),
                  label: Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}