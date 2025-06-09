import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/bug.dart';

class BugReportService {
  static const String _bugReportsKey = 'bug_reports';
  static BugReportService? _instance;

  BugReportService._internal();

  static BugReportService get instance {
    _instance ??= BugReportService._internal();
    return _instance!;
  }

  // Submit a new bug report
  Future<void> submitBugReport(BugReportModel bugReport) async {
    final prefs = await SharedPreferences.getInstance();
    final existingReports = await getAllBugReports();

    existingReports.add(bugReport);

    final jsonList = existingReports.map((report) => report.toJson()).toList();
    await prefs.setString(_bugReportsKey, jsonEncode(jsonList));
  }

  // Get all bug reports
  Future<List<BugReportModel>> getAllBugReports() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_bugReportsKey);

    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => BugReportModel.fromJson(json)).toList();
  }

  // Update bug report status
  Future<void> updateBugReportStatus(String id, String status) async {
    final reports = await getAllBugReports();
    final reportIndex = reports.indexWhere((report) => report.id == id);

    if (reportIndex != -1) {
      final updatedReport = BugReportModel(
        id: reports[reportIndex].id,
        title: reports[reportIndex].title,
        description: reports[reportIndex].description,
        expectedResult: reports[reportIndex].expectedResult,
        actualResult: reports[reportIndex].actualResult,
        priority: reports[reportIndex].priority,
        category: reports[reportIndex].category,
        email: reports[reportIndex].email,
        submittedAt: reports[reportIndex].submittedAt,
        status: status,
      );

      reports[reportIndex] = updatedReport;

      final prefs = await SharedPreferences.getInstance();
      final jsonList = reports.map((report) => report.toJson()).toList();
      await prefs.setString(_bugReportsKey, jsonEncode(jsonList));
    }
  }

  // Delete a bug report
  Future<void> deleteBugReport(String id) async {
    final reports = await getAllBugReports();
    reports.removeWhere((report) => report.id == id);

    final prefs = await SharedPreferences.getInstance();
    final jsonList = reports.map((report) => report.toJson()).toList();
    await prefs.setString(_bugReportsKey, jsonEncode(jsonList));
  }

  // Get bug reports by status
  Future<List<BugReportModel>> getBugReportsByStatus(String status) async {
    final allReports = await getAllBugReports();
    return allReports.where((report) => report.status == status).toList();
  }

  // Get bug reports by priority
  Future<List<BugReportModel>> getBugReportsByPriority(String priority) async {
    final allReports = await getAllBugReports();
    return allReports.where((report) => report.priority == priority).toList();
  }
}