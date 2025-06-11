import '../Model/bug.dart';
import '../services/bug.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class BugReport extends StatefulWidget {
  @override
  _BugReportState createState() => _BugReportState();
}

class _BugReportState extends State<BugReport> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _expectedController = TextEditingController();
  final _actualController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedPriority = 'Low';
  String _selectedCategory = 'General';
  bool _isSubmitting = false;

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Critical'];
  final List<String> _categories = [
    'General',
    'UI/UX',
    'Performance',
    'Crash',
    'Feature Request',
    'Security',
    'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _expectedController.dispose();
    _actualController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _generateId() {
    final random = Random();
    final timestamp = DateTime
        .now()
        .millisecondsSinceEpoch;
    final randomNum = random.nextInt(1000);
    return 'BUG_${timestamp}_$randomNum';
  }

  void _submitBugReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Create bug report model
        final bugReport = BugReportModel(
          id: _generateId(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          expectedResult: _expectedController.text.trim(),
          actualResult: _actualController.text.trim(),
          priority: _selectedPriority,
          category: _selectedCategory,
          email: _emailController.text
              .trim()
              .isEmpty ? null : _emailController.text.trim(),
          submittedAt: DateTime.now(),
        );
        Navigator.pop(context);

        // Save bug report
        await BugReportService.instance.submitBugReport(bugReport);

        setState(() {
          _isSubmitting = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Bug report submitted successfully!\nReport ID: ${bugReport
                          .id}'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );

        // Clear form
        _formKey.currentState!.reset();
        _titleController.clear();
        _descriptionController.clear();
        _expectedController.clear();
        _actualController.clear();
        _emailController.clear();
        setState(() {
          _selectedPriority = 'Low';
          _selectedCategory = 'General';
        });
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting bug report: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          dropdownColor: Colors.white,
          style: TextStyle(color: Colors.black),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(color: Colors.black),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? hintText,
    bool required = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            children: [
              if (required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: required
              ? (value) {
            if (value == null || value
                .trim()
                .isEmpty) {
              return 'This field is required';
            }
            return null;
          }
              : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Report a Bug",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF0816A7),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bug_report,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Help us improve!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Report bugs or suggest improvements',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Main Form Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Title
                      _buildTextField(
                          label: 'Bug Title',
                          controller: _titleController,
                          hintText: 'Brief description of the issue',
                      ),
                      SizedBox(height: 20),
                      _buildDropdown(
                        label: 'Priority',
                        value: _selectedPriority,
                        items: _priorities,
                        onChanged: (value) {
                          setState(() {
                            _selectedPriority = value!;
                          });
                        },
                      ),
                      SizedBox(height: 20),

                      _buildDropdown(
                        label: 'Category',
                        value: _selectedCategory,
                        items: _categories,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                      SizedBox(height: 20),

                      // Description
                      _buildTextField(
                        label: 'Description',
                        controller: _descriptionController,
                        maxLines: 4,
                        hintText: 'Describe the bug in detail...',
                      ),
                      SizedBox(height: 20),

                      _buildTextField(
                        label: 'Expected Result',
                        controller: _expectedController,
                        maxLines: 3,
                        hintText: 'What should happen?',
                      ),
                      SizedBox(height: 20),

                      // Actual Result
                      _buildTextField(
                        label: 'Actual Result',
                        controller: _actualController,
                        maxLines: 3,
                        hintText: 'What actually happened?',
                      ),
                      SizedBox(height: 20),

                      // Email (Optional)
                      _buildTextField(
                        label: 'Email',
                        controller: _emailController,
                        hintText: 'your.email@example.com (optional)',
                        required: false,
                      ),

                      SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitBugReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0816A7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: _isSubmitting
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Submitting...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                              : Text(
                            'Submit Bug Report',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Footer Note
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.blue[600],
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your feedback helps us improve the app. Thank you for taking the time to report this issue!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}