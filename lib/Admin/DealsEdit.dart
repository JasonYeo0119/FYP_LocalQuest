import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DealsEdit extends StatefulWidget {
  final Map<String, dynamic> deal;

  const DealsEdit({Key? key, required this.deal}) : super(key: key);

  @override
  DealsEditState createState() => DealsEditState();
}

class DealsEditState extends State<DealsEdit> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  late TextEditingController name;
  late TextEditingController startdate;
  late TextEditingController enddate;
  late TextEditingController description;
  late TextEditingController image;
  late TextEditingController starttime;
  late TextEditingController endtime;

  String selectedStatus = 'active';
  bool isLoading = false;
  bool includeTime = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing deal data
    name = TextEditingController(text: widget.deal['name'] ?? '');
    startdate = TextEditingController(text: widget.deal['startDate'] ?? '');
    enddate = TextEditingController(text: widget.deal['endDate'] ?? '');
    description = TextEditingController(text: widget.deal['description'] ?? '');
    image = TextEditingController(text: widget.deal['image'] ?? '');
    starttime = TextEditingController(text: widget.deal['startTime'] ?? '');
    endtime = TextEditingController(text: widget.deal['endTime'] ?? '');

    selectedStatus = widget.deal['status'] ?? 'active';

    // Check if deal has time information
    includeTime = widget.deal['includeTime'] == true ||
        (widget.deal['startTime'] != null && widget.deal['startTime'].toString().isNotEmpty) ||
        (widget.deal['endTime'] != null && widget.deal['endTime'].toString().isNotEmpty);
  }

  @override
  void dispose() {
    name.dispose();
    startdate.dispose();
    enddate.dispose();
    description.dispose();
    image.dispose();
    starttime.dispose();
    endtime.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    // Parse existing date if available
    DateTime initialDate = DateTime.now();
    if (controller.text.isNotEmpty) {
      try {
        List<String> parts = controller.text.split('/');
        if (parts.length == 3) {
          initialDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        }
      } catch (e) {
        // If parsing fails, use current date
        initialDate = DateTime.now();
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    // Parse existing time if available
    TimeOfDay initialTime = TimeOfDay.now();
    if (controller.text.isNotEmpty) {
      try {
        List<String> parts = controller.text.split(':');
        if (parts.length >= 2) {
          initialTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      } catch (e) {
        // If parsing fails, use current time
        initialTime = TimeOfDay.now();
      }
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _updateDeal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String dealId = widget.deal['dealId'];

      // Create updated deal data
      Map<String, dynamic> updatedDealData = {
        'dealId': dealId,
        'name': name.text.trim(),
        'startDate': startdate.text.trim(),
        'endDate': enddate.text.trim(),
        'description': description.text.trim(),
        'image': image.text.trim(),
        'status': selectedStatus,
        'createdAt': widget.deal['createdAt'], // Keep original creation date
        'updatedAt': DateTime.now().toIso8601String(),
        'includeTime': includeTime,
        'startTime': includeTime ? starttime.text.trim() : '',
        'endTime': includeTime ? endtime.text.trim() : '',
      };

      // Update in Firebase
      await _database.child('deals').child(dealId).set(updatedDealData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deal updated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back after a short delay
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context, true); // Return true to indicate success
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating deal: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Deal"),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.edit, size: 48, color: Colors.orange.shade700),
                      SizedBox(height: 8),
                      Text(
                        'Edit Deal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      Text(
                        'Update the deal information below',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Form fields
                buildTextField(
                  "Deal Name",
                  name,
                  icon: Icons.title,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a deal name';
                    }
                    return null;
                  },
                ),

                buildDateField("Start Date", startdate, Icons.date_range),
                buildDateField("End Date", enddate, Icons.event),

                // Time toggle
                buildTimeToggle(),

                // Time fields (conditional)
                if (includeTime) ...[
                  buildTimeField("Start Time", starttime, Icons.access_time),
                  buildTimeField("End Time", endtime, Icons.access_time_filled),
                ],

                buildTextField(
                  "Description",
                  description,
                  maxLines: 4,
                  icon: Icons.description,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),

                buildTextField(
                  "Image URL",
                  image,
                  icon: Icons.image,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an image URL';
                    }
                    return null;
                  },
                ),

                // Status dropdown
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.settings, color: Colors.blue.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                      DropdownMenuItem(value: 'expired', child: Text('Expired')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                ),

                SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading ? null : () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _updateDeal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: isLoading
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text("Updating..."),
                          ],
                        )
                            : Text(
                          "Update Deal",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Deal info
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deal Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('ID: ${widget.deal['dealId']}', style: TextStyle(fontSize: 12)),
                      if (widget.deal['createdAt'] != null)
                        Text('Created: ${_formatDateTime(widget.deal['createdAt'])}', style: TextStyle(fontSize: 12)),
                      if (widget.deal['updatedAt'] != null)
                        Text('Last Updated: ${_formatDateTime(widget.deal['updatedAt'])}', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTimeToggle() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(Icons.schedule, color: Colors.blue.shade600),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Include Specific Times',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    'Add start and end times for your deal',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: includeTime,
              onChanged: (value) {
                setState(() {
                  includeTime = value;
                  if (!value) {
                    // Clear time fields when toggled off
                    starttime.clear();
                    endtime.clear();
                  }
                });
              },
              activeColor: Colors.blue.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTimeField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectTime(controller),
        validator: includeTime ? (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please select $label';
          }
          return null;
        } : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue.shade600),
          suffixIcon: Icon(Icons.access_time, color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  Widget buildTextField(
      String label,
      TextEditingController controller, {
        bool isNumber = false,
        int maxLines = 1,
        IconData? icon,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.blue.shade600) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget buildDateField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectDate(controller),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue.shade600),
          suffixIcon: Icon(Icons.calendar_today, color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }
}