import 'package:flutter/material.dart';
import '../Model/bug.dart';
import '../services/bug.dart';

class ViewBugReports extends StatefulWidget {
  @override
  _ViewBugReportsState createState() => _ViewBugReportsState();
}

class _ViewBugReportsState extends State<ViewBugReports> {
  List<BugReportModel> bugReports = [];
  List<BugReportModel> filteredReports = [];
  String selectedFilter = 'All';
  bool isLoading = true;

  final List<String> filterOptions = ['All', 'Open', 'In Progress', 'Resolved', 'Closed'];
  final List<String> priorityFilters = ['All', 'Critical', 'High', 'Medium', 'Low'];
  String selectedPriorityFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadBugReports();
  }

  Future<void> _loadBugReports() async {
    try {
      final reports = await BugReportService.instance.getAllBugReports();
      setState(() {
        bugReports = reports;
        filteredReports = reports;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bug reports: $e')),
      );
    }
  }

  void _filterReports() {
    setState(() {
      filteredReports = bugReports.where((report) {
        bool statusMatch = selectedFilter == 'All' || report.status == selectedFilter;
        bool priorityMatch = selectedPriorityFilter == 'All' || report.priority == selectedPriorityFilter;
        return statusMatch && priorityMatch;
      }).toList();
    });
  }

  Future<void> _updateReportStatus(BugReportModel report, String newStatus) async {
    try {
      await BugReportService.instance.updateBugReportStatus(report.id, newStatus);
      await _loadBugReports();
      _filterReports();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bug report status updated to $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  Future<void> _deleteReport(BugReportModel report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Bug Report'),
        content: Text('Are you sure you want to delete this bug report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await BugReportService.instance.deleteBugReport(report.id);
        await _loadBugReports();
        _filterReports();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bug report deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting report: $e')),
        );
      }
    }
  }

  void _showReportDetails(BugReportModel report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Priority', report.priority, report.priorityColor),
              _buildDetailRow('Category', report.category),
              _buildDetailRow('Status', report.status),
              if (report.email != null) _buildDetailRow('Email', report.email!),
              _buildDetailRow('Submitted', _formatDate(report.submittedAt)),
              SizedBox(height: 16),
              Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(report.description),
              SizedBox(height: 12),
              Text('Expected Result:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(report.expectedResult),
              SizedBox(height: 12),
              Text('Actual Result:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(report.actualResult),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? color]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bug Reports',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF0816A7),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadBugReports,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Filter Section
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedFilter,
                        decoration: InputDecoration(
                          labelText: 'Filter by Status',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: filterOptions.map((filter) {
                          return DropdownMenuItem(
                            value: filter,
                            child: Text(filter),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedFilter = value!;
                          });
                          _filterReports();
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedPriorityFilter,
                        decoration: InputDecoration(
                          labelText: 'Filter by Priority',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: priorityFilters.map((filter) {
                          return DropdownMenuItem(
                            value: filter,
                            child: Text(filter),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPriorityFilter = value!;
                          });
                          _filterReports();
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Total Reports: ${filteredReports.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Reports List
          Expanded(
            child: filteredReports.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bug_report_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No bug reports found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Reports will appear here when users submit them',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredReports.length,
              itemBuilder: (context, index) {
                final report = filteredReports[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: report.priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        report.categoryIcon,
                        color: report.priorityColor,
                      ),
                    ),
                    title: Text(
                      report.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: report.priorityColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                report.priority,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                report.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Status: ${report.status}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Submitted: ${_formatDate(report.submittedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showReportDetails(report),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deleteReport(report);
                        } else {
                          _updateReportStatus(report, value);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'Open', child: Text('Mark as Open')),
                        PopupMenuItem(value: 'In Progress', child: Text('Mark as In Progress')),
                        PopupMenuItem(value: 'Resolved', child: Text('Mark as Resolved')),
                        PopupMenuItem(value: 'Closed', child: Text('Mark as Closed')),
                        PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}