import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:localquest/Admin/Adminpage.dart';

class Hotelnew extends StatefulWidget {
  @override
  HotelnewState createState() => HotelnewState();
}

class HotelnewState extends State<Hotelnew> {

  final name = TextEditingController();
  final address = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final description = TextEditingController();
  final type = TextEditingController();
  final price = TextEditingController();
  final pax = TextEditingController();
  final room = TextEditingController();
  final amenties = TextEditingController();
  final image = TextEditingController();

  final List<String> states = [
    "Johor",
    "Kedah",
    "Kelantan",
    "Kuala Lumpur",
    "Labuan",
    "Malacca",
    "Negeri Sembilan",
    "Pahang",
    "Penang",
    "Perak",
    "Perlis",
    "Putrajaya",
    "Sabah",
    "Sarawak",
    "Selangor",
    "Terengganu",
  ];
  String? selectedState;

  final List<String> types = [
    "Luxury Hotel", "Mid-range Hotel", "Budget Hotel", "Apartment", "Villa", "Suites"
  ];
  String? selectedType;

  final List<String> rooms = [
    "Single Room", "Double Room", "Triple Room", "Quad room",
    "Family Room (6 pax)", "Apartment", "Suites", "Villa", "Other"
  ];
  String? selectedRoom;

  final List<String> _amenties = [
    "Gym", "Wifi", "Pool", "Air-Conditioner", "Heater", "Kitchen Equipments",
    "Private Bathroom", "Bathtub", "Breakfast", "Washer", "Dryer", "Free Parking",
    "TV", "Lift", "Non-smoking Room", "Jacuzzi", "View"
  ];
  List<String> selectedamenties = [];



  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    name.dispose();
    address.dispose();
    city.dispose();
    state.dispose();
    description.dispose();
    type.dispose();
    price.dispose();
    room.dispose();
    pax.dispose();
    amenties.dispose();
    image.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create New Hotel"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildTextField("Name", name),
              buildTextField("Address", address),
              buildTextField("City", city),
              DropdownButtonFormField<String>(  //State Selection
                decoration: InputDecoration(
                  labelText: "State",
                  border: OutlineInputBorder(),
                ),
                value: selectedState,
                items: states.map((String state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  selectedState = newValue;
                },
              ),
              buildTextField("Description", description, maxLines: 5),

              DropdownButtonFormField<String>(  //Type Selection
                decoration: InputDecoration(
                  labelText: "Type",
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
                  selectedType = newValue;
                },
              ),

              buildTextField("Price (MYR)", price, isNumber: true),

              DropdownButtonFormField<String>(  //Room Selection
                decoration: InputDecoration(
                  labelText: "Room",
                  border: OutlineInputBorder(),
                ),
                value: selectedRoom,
                items: rooms.map((String room) {
                  return DropdownMenuItem<String>(
                    value: room,
                    child: Text(room),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  selectedRoom = newValue;
                },
              ),

              buildTextField("Number of Pax", pax, isNumber: true),

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