import 'dart:ui';

import 'package:flutter/material.dart';

class BugReportModel {
  final String id;
  final String title;
  final String description;
  final String expectedResult;
  final String actualResult;
  final String priority;
  final String category;
  final String? email;
  final DateTime submittedAt;
  final String status;

  BugReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.expectedResult,
    required this.actualResult,
    required this.priority,
    required this.category,
    this.email,
    required this.submittedAt,
    this.status = 'Open',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'expectedResult': expectedResult,
      'actualResult': actualResult,
      'priority': priority,
      'category': category,
      'email': email,
      'submittedAt': submittedAt.toIso8601String(),
      'status': status,
    };
  }

  factory BugReportModel.fromJson(Map<String, dynamic> json) {
    return BugReportModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      expectedResult: json['expectedResult'],
      actualResult: json['actualResult'],
      priority: json['priority'],
      category: json['category'],
      email: json['email'],
      submittedAt: DateTime.parse(json['submittedAt']),
      status: json['status'] ?? 'Open',
    );
  }

  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow[700]!;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'ui/ux':
        return Icons.design_services;
      case 'performance':
        return Icons.speed;
      case 'crash':
        return Icons.error;
      case 'feature request':
        return Icons.add_box;
      case 'security':
        return Icons.security;
      default:
        return Icons.bug_report;
    }
  }
}