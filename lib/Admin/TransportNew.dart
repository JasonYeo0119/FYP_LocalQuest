import 'package:flutter/material.dart';
import 'package:localquest/Admin/Adminpage.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class Transportnew extends StatefulWidget {
  @override
  TransportnewState createState() => TransportnewState();
}

class TransportnewState extends State<Transportnew> {

  final name = TextEditingController();
  final type = TextEditingController();
  final price = TextEditingController();
  final time = TextEditingController();
  final date = TextEditingController();
  final seat = TextEditingController();
  final amenties = TextEditingController();
  final origin = TextEditingController();
  final destination = TextEditingController();
  final image = TextEditingController();

  final List<String> types = [
    "Bus", "Car", "Flight", "Ferry", "Train",
  ];
  String? selectedtype;

  final List<String> dates = [
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
  ];
  List<String> selecteddate = [];

  final List<String> _amenties = [
    "Wifi", "CCTV", "Emergency Exit", "Safety Belt", "Reclining Seat", "Air-Conditioner", "USB Port", "TV"
  ];
  List <String> selectedamenties = [];

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    name.dispose();
    type.dispose();
    price.dispose();
    time.dispose();
    date.dispose();
    seat.dispose();
    amenties.dispose();
    origin.dispose();
    destination.dispose();
    image.dispose();
    super.dispose();
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
              buildTextField("Name", name),

              DropdownButtonFormField<String>(  //Room Selection
                decoration: InputDecoration(
                  labelText: "Type",
                  border: OutlineInputBorder(),
                ),
                value: selectedtype,
                items: types.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  selectedtype = newValue;
                },
              ),

              buildTextField("Price", price),
              buildTextField("Time", time),

              MultiSelectDialogField(  //Amenties
                items: dates.map((date) => MultiSelectItem<String>(date, date)).toList(),
                title: Text(
                  "Date",
                  style: TextStyle(color: Colors.white60), // White title text
                ),
                buttonText: Text(
                  "Date",
                  style: TextStyle(color: Colors.white60), // White button text
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white38, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                dialogWidth: 300,
                dialogHeight: 400,
                backgroundColor: Colors.blueGrey[900], // Dark background for the dialog
                itemsTextStyle: TextStyle(color: Colors.white), // White text for items
                selectedItemsTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // White text for selected items
                selectedColor: Colors.blue, // Highlight color for selected items
                checkColor: Colors.white, // White checkbox tick color
                confirmText: Text(
                  "OK",
                  style: TextStyle(color: Colors.white), // White "OK" button text
                ),
                cancelText: Text(
                  "CANCEL",
                  style: TextStyle(color: Colors.white), // White "CANCEL" button text
                ),
                onConfirm: (values) {
                  selecteddate = values.cast<String>();
                },
              ),

              buildTextField("Seat", seat, isNumber: true),
              MultiSelectDialogField(  //Amenties
                items: _amenties.map((amenties) => MultiSelectItem<String>(amenties, amenties)).toList(),
                title: Text(
                  "Amenties",
                  style: TextStyle(color: Colors.white60), // White title text
                ),
                buttonText: Text(
                  "Amenties",
                  style: TextStyle(color: Colors.white60), // White button text
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white38, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                dialogWidth: 300,
                dialogHeight: 400,
                backgroundColor: Colors.blueGrey[900], // Dark background for the dialog
                itemsTextStyle: TextStyle(color: Colors.white), // White text for items
                selectedItemsTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // White text for selected items
                selectedColor: Colors.blue, // Highlight color for selected items
                checkColor: Colors.white, // White checkbox tick color
                confirmText: Text(
                  "OK",
                  style: TextStyle(color: Colors.white), // White "OK" button text
                ),
                cancelText: Text(
                  "CANCEL",
                  style: TextStyle(color: Colors.white), // White "CANCEL" button text
                ),
                onConfirm: (values) {
                  selectedamenties = values.cast<String>();
                },
              ),
              buildTextField("Origin", origin),
              buildTextField("Destination", destination),
              buildTextField("Insert Image", image),
              SizedBox(height: 20),

              Positioned(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Adminpage()),
                    );
                  },
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
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Reusable TextField builder
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