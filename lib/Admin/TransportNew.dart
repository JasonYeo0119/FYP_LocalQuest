import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localquest/Admin/Adminpage.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

class Transportnew extends StatefulWidget {
  @override
  TransportnewState createState() => TransportnewState();
}

class TransportnewState extends State<Transportnew> {
  final name = TextEditingController();
  final price = TextEditingController();
  final origin = TextEditingController();
  final destination = TextEditingController();

  final List<String> types = [
    "Bus", "Car", "Flight", "Ferry", "Train",
  ];
  String? selectedType;

  final List<String> days = [
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
  ];
  List<String> selectedDays = [];

  final List<String> timeSlots = [
    "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00",
    "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00"
  ];
  List<String> selectedTimeSlots = [];

  // Bus seat management
  Set<int> availableSeats = Set<int>.from(List.generate(33, (i) => i + 1));
  Set<int> selectedSeats = Set<int>();

  // Image management
  File? transportImage;
  String? imageUrl;
  bool isUploading = false;

  DatabaseReference? dbRef;

  @override
  void initState() {
    super.initState();
    try {
      dbRef = FirebaseDatabase.instance.ref().child('Transports');
      print("Database reference initialized successfully");
    } catch (e) {
      print("Error initializing database reference: $e");
    }
  }

  @override
  void dispose() {
    name.dispose();
    price.dispose();
    origin.dispose();
    destination.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        transportImage = File(pickedFile.path);
        isUploading = true;
      });

      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (transportImage == null) return;

    try {
      String fileName = 'transports/${DateTime.now().millisecondsSinceEpoch}_${name.text.isEmpty ? 'transport' : name.text.replaceAll(' ', '_')}.jpg';
      final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(transportImage!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        imageUrl = downloadUrl;
        isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image uploaded successfully")),
      );
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image: $e")),
      );
    }
  }

  void saveTransport() async {
    print("Save transport button pressed"); // Debug print

    // Check if database reference is initialized
    if (dbRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Database not initialized. Please check Firebase setup.")),
      );
      return;
    }

    if (isUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please wait for image to upload")),
      );
      return;
    }

    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select transport type")),
      );
      return;
    }

    // For non-bus types, only require basic fields
    if (selectedType != "Bus") {
      if (name.text.isEmpty || price.text.isEmpty || origin.text.isEmpty || destination.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill in all required fields")),
        );
        return;
      }
    } else {
      // For bus type, require name field and bus-specific data
      if (name.text.isEmpty || price.text.isEmpty || origin.text.isEmpty || destination.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill in all required fields")),
        );
        return;
      }

      if (selectedDays.isEmpty || selectedTimeSlots.isEmpty || selectedSeats.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please complete bus schedule and seat selection")),
        );
        return;
      }
    }

    try {
      Map<String, dynamic> transportData = {
        'name': name.text,
        'type': selectedType,
        'price': double.tryParse(price.text) ?? 0.0,
        'origin': origin.text,
        'destination': destination.text,
        'imageUrl': imageUrl ?? '',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      // Add bus-specific data
      if (selectedType == "Bus") {
        transportData['operatingDays'] = selectedDays;
        transportData['timeSlots'] = selectedTimeSlots;
        transportData['availableSeats'] = selectedSeats.toList();
        transportData['totalSeats'] = 33;
      }

      print("Saving data: $transportData"); // Debug print

      await dbRef!.push().set(transportData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Transport added successfully!")),
      );
      clearFields();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Adminpage()),
      );
    } catch (error) {
      print("Error saving transport: $error"); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add transport: $error")),
      );
    }
  }

  void clearFields() {
    name.clear();
    price.clear();
    origin.clear();
    destination.clear();
    selectedType = null;
    selectedDays = [];
    selectedTimeSlots = [];
    selectedSeats = Set<int>();
    availableSeats = Set<int>.from(List.generate(33, (i) => i + 1));
    transportImage = null;
    imageUrl = null;
    setState(() {});
  }

  Widget buildBusSeatMap() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Available Seats (${selectedSeats.length}/33)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Tap seats to toggle availability",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          SizedBox(height: 16),

          // Driver section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text("Driver", textAlign: TextAlign.center),
          ),
          SizedBox(height: 16),

          // Seat layout - 11 rows of seats
          Column(
            children: List.generate(11, (rowIndex) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Single seat on left
                    buildSeatButton(rowIndex * 3 + 1),
                    SizedBox(width: 20), // Aisle
                    // Double seats on right
                    buildSeatButton(rowIndex * 3 + 2),
                    buildSeatButton(rowIndex * 3 + 3),
                  ],
                ),
              );
            }),
          ),

          SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: 8),
              Text("Available", style: TextStyle(fontSize: 12)),
              SizedBox(width: 16),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: 8),
              Text("Not Available", style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSeatButton(int seatNumber) {
    if (seatNumber > 33) return SizedBox.shrink();

    bool isSelected = selectedSeats.contains(seatNumber);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedSeats.remove(seatNumber);
          } else {
            selectedSeats.add(seatNumber);
          }
        });
      },
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey[300],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Center(
          child: Text(
            seatNumber.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create New Transport"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Transport Type Selection
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Transport Type",
                  border: OutlineInputBorder(),
                ),
                value: selectedType,
                items: types.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedType = newValue;
                    // Reset bus-specific selections when type changes
                    if (selectedType != "Bus") {
                      selectedDays = [];
                      selectedTimeSlots = [];
                      selectedSeats = Set<int>();
                    }
                  });
                },
              ),
              SizedBox(height: 16),

              // Name field - required for all transport types
              buildTextField(
                  selectedType == "Bus" ? "Bus Name" : "Transport Name",
                  name
              ),

              buildTextField("Price (MYR)", price, isNumber: true),
              buildTextField("Departure Location", origin),
              buildTextField("Destination", destination),

              // Bus-specific fields
              if (selectedType == "Bus") ...[
                SizedBox(height: 16),

                // Days Selection
                MultiSelectDialogField(
                  items: days.map((day) => MultiSelectItem<String>(day, day)).toList(),
                  title: Text("Select Operating Days"),
                  buttonText: Text("Operating Days"),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onConfirm: (values) {
                    setState(() {
                      selectedDays = values.cast<String>();
                    });
                  },
                ),
                SizedBox(height: 16),

                // Time Slots Selection
                MultiSelectDialogField(
                  items: timeSlots.map((time) => MultiSelectItem<String>(time, time)).toList(),
                  title: Text("Select Time Slots"),
                  buttonText: Text("Time Slots (8AM - 10PM)"),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onConfirm: (values) {
                    setState(() {
                      selectedTimeSlots = values.cast<String>();
                    });
                  },
                ),
                SizedBox(height: 16),

                // Bus Seat Map
                buildBusSeatMap(),
                SizedBox(height: 16),
              ],

              // Image Upload Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Transport Image",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text("Add Image"),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Image Preview
              if (transportImage != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isUploading
                      ? Center(child: CircularProgressIndicator())
                      : Image.file(transportImage!, fit: BoxFit.cover),
                )
              else
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text("No image selected"),
                  ),
                ),

              SizedBox(height: 20),

              // Confirm Button
              GestureDetector(
                onTap: saveTransport,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Confirm",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}