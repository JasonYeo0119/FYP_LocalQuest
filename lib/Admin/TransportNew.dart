import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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

  // Car-specific controllers
  final carPlateNumber = TextEditingController();

  // Ferry-specific controllers
  final ferryOriginController = TextEditingController();
  final ferryDestinationController = TextEditingController();
  final pedestrianPriceController = TextEditingController();
  final vehiclePriceController = TextEditingController();

  final List<String> types = [
    "Bus", "Car", "Flight", "Ferry", "Train",
  ];
  String? selectedType;

  // Departure and destination options
  final List<String> locations = [
    "Johor, Larkin Sentral, Johor Bahru", "Johor, Terminal Bas Kluang, Kluang", "Johor, Terminal Bas Segamat, Segamat", "Johor, Terminal Bas Batu Pahat, Batu Pahat", "Johor, Terminal Bas Muar Bentayan, Muar",
    "Malacca, Melaka Sentral", "Malacca, Terminal Bas Jasin",
    "Negeri Sembilan, Terminal One Bus Station, Seremban", "Negeri Sembilan, Terminal Bas Tampin",
    "Kuala Lumpur, Terminal Bersepadu Selatan (TBS)", "Kuala Lumpur, Pudu Sentral (Puduraya)", "Kuala Lumpur, Hentian Duta", "Kuala Lumpur, Terminal Shah Alam (Seksyen 17)", "Kuala Lumpur, Terminal KL Sentral", "Selangor, Terminal Klang Sentral, Klang",
    "Pahang, Terminal Kuantan Sentral, Kuantan",
    "Perak, Amanjaya Bus Terminal, Ipoh", "Perak, Terminal Bas Taiping, Taiping", "Perak, Terminal Bas Kampar", "Perak, Terminal Bas Lumut",
    "Terengganu, Kuala Terengganu Bus Terminal",
    "Kelantan, Kota Bahru Bus Terminal",
    "Penang, Sungai Nibong", "Penang, Penang Sentral",
    "Kedah, Alor Setar Bus Terminal", "Kedah, Terminal Bas Kulim", "Kedah, Terminal Bas Sungai Petani",
    "Perlis, Kangar Bus Terminal", "Perlis, Terminal Bas Kuala Perlis",
    "Sabah, Inanam Bus Terminal, Kota Kinabalu", "Sabah, Terminal Bas Sadakan", "Sabah, Terminal Bas Tawau",
    "Sarawak, Kuching Sentral", "Sarawak, Miri Bus Terminal", "Sarawak, Sibu Bus Terminal", "Sarawak, Bintulu Bus Terminal"
  ];

  final List<String> carlocations = [
    "Johor, Johor Bahru", "Johor, Batu Pahat", "Johor, Muar", "Johor, Pontian", "Johor, Desaru",
    "Malacca, Malacca Town",
    "Negeri Sembilan, Seremban",
    "Kuala Lumpur, Bukit Jalil", "Kuala Lumpur, Bukit Bintang", "Kuala Lumpur, Bandar Sunway", "Kuala Lumpur, Cheras",
    "Selangor, Klang Valley", "Selangor, Subang Jaya", "Selangor, Petaling Jaya",
    "Pahang, Kuantan",
    "Perak, Ipoh", "Perak, Kampar", "Perak, Taiping",
    "Kelantan, Kota Bahru",
    "Terengganu, Kuala Terengganu",
    "Penang, Bayan Lepas", "Penang, Georgetown", "Penang, Gelugor", "Penang, George Town", "Penang, Butterworth",
    "Kedah, Sungai Petani", "Kedah, Alor Setar", "Kedah, Kulim", "Kedah, Changlun",
    "Perlis, Kuala Perlis",
    "Sabah, Kota Kinabalu", "Sabah, Tawau", "Sabah, Sadakan",
    "Sarawak, Kuching"
  ];

  String? selectedOrigin;
  String? selectedDestination;

  // Car-specific fields
  String? selectedCarLocation;
  String? selectedCarColor;
  bool driverIncluded = false;
  int? selectedMaxPassengers;

  final List<String> carColors = [
    "White", "Black", "Silver", "Red", "Blue", "Gray", "Green", "Yellow", "Orange", "Brown"
  ];

  final List<int> passengerCounts = [2, 3, 4, 5, 6, 7];

  final List<String> days = [
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
  ];
  List<String> selectedDays = [];

  final List<String> timeSlots = [
    "08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
    "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30",
    "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30",
    "20:00", "20:30", "21:00", "21:30", "22:00"
  ];
  List<String> selectedTimeSlots = [];

  // Bus seat management
  Set<int> availableSeats = Set<int>.from(List.generate(33, (i) => i + 1));
  Set<int> selectedSeats = Set<int>();

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
  // void dispose() {
  //   name.dispose();
  //   price.dispose();
  //   carPlateNumber.dispose();
  //   ferryOriginController.dispose();
  //   ferryDestinationController.dispose();
  //   pedestrianPriceController.dispose();
  //   vehiclePriceController.dispose();
  //   super.dispose();
  // }

  void saveTransport() async {
    print("Save transport button pressed"); // Debug print

    // Check if database reference is initialized
    if (dbRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Database not initialized. Please check Firebase setup.")),
      );
      return;
    }

    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select transport type")),
      );
      return;
    }

    // Validation based on transport type
    if (selectedType == "Car") {
      if (name.text.isEmpty ||
          price.text.isEmpty ||
          carPlateNumber.text.isEmpty ||
          selectedCarLocation == null ||
          selectedCarColor == null ||
          selectedMaxPassengers == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill in all car details")),
        );
        return;
      }
    } else if (selectedType == "Bus") {
      if (name.text.isEmpty || price.text.isEmpty || selectedOrigin == null || selectedDestination == null) {
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
    } else if (selectedType == "Ferry") {
      if (name.text.isEmpty ||
          ferryOriginController.text.isEmpty ||
          ferryDestinationController.text.isEmpty ||
          pedestrianPriceController.text.isEmpty ||
          vehiclePriceController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill in all ferry details")),
        );
        return;
      }
    } else {
      // For other transport types (Flight, Train)
      if (name.text.isEmpty || price.text.isEmpty || selectedOrigin == null || selectedDestination == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill in all required fields")),
        );
        return;
      }
    }

    try {
      Map<String, dynamic> transportData = {
        'name': name.text,
        'type': selectedType,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      // Add type-specific data
      if (selectedType == "Car") {
        transportData['price'] = double.tryParse(price.text) ?? 0.0;
        transportData['plateNumber'] = carPlateNumber.text;
        transportData['location'] = selectedCarLocation;
        transportData['color'] = selectedCarColor;
        transportData['driverIncluded'] = driverIncluded;
        transportData['maxPassengers'] = selectedMaxPassengers;
        transportData['priceType'] = 'per_day';
      } else if (selectedType == "Bus") {
        transportData['price'] = double.tryParse(price.text) ?? 0.0;
        transportData['origin'] = selectedOrigin;
        transportData['destination'] = selectedDestination;
        transportData['operatingDays'] = selectedDays;
        transportData['timeSlots'] = selectedTimeSlots;
        transportData['availableSeats'] = selectedSeats.toList();
        transportData['totalSeats'] = 33;
      } else if (selectedType == "Ferry") {
        transportData['origin'] = ferryOriginController.text;
        transportData['destination'] = ferryDestinationController.text;
        transportData['pedestrianPrice'] = double.tryParse(pedestrianPriceController.text) ?? 0.0;
        transportData['vehiclePrice'] = double.tryParse(vehiclePriceController.text) ?? 0.0;
        transportData['priceType'] = 'dual_pricing';
      } else {
        // For other transport types (Flight, Train)
        transportData['price'] = double.tryParse(price.text) ?? 0.0;
        transportData['origin'] = selectedOrigin;
        transportData['destination'] = selectedDestination;
      }

      print("Saving data: $transportData"); // Debug print

      await dbRef!.push().set(transportData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Transport added successfully!")),
      );
      //clearFields();
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => Adminpage()),
      // );
    } catch (error) {
      print("Error saving transport: $error"); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add transport: $error")),
      );
    }
  }

  // void clearFields() {
  //   name.clear();
  //   price.clear();
  //   carPlateNumber.clear();
  //   ferryOriginController.clear();
  //   ferryDestinationController.clear();
  //   pedestrianPriceController.clear();
  //   vehiclePriceController.clear();
  //   selectedOrigin = null;
  //   selectedDestination = null;
  //   selectedType = null;
  //   selectedCarLocation = null;
  //   selectedCarColor = null;
  //   driverIncluded = false;
  //   selectedMaxPassengers = null;
  //   selectedDays = [];
  //   selectedTimeSlots = [];
  //   selectedSeats = Set<int>();
  //   availableSeats = Set<int>.from(List.generate(33, (i) => i + 1));
  //   setState(() {});
  // }

  Widget buildFerryDetailsSection() {
    return Column(
      children: [
        // Ferry Origin (Custom Input)
        buildTextField("Departure Port/Location", ferryOriginController),

        // Ferry Destination (Custom Input)
        buildTextField("Destination Port/Location", ferryDestinationController),

        // Row for Pedestrian and Vehicle Prices
        Row(
          children: [
            Expanded(
              child: buildTextField("Pedestrian Price (MYR)", pedestrianPriceController, isNumber: true),
            ),
            SizedBox(width: 16),
            Expanded(
              child: buildTextField("Vehicle Price (MYR)", vehiclePriceController, isNumber: true),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildCarDetailsSection() {
    return Column(
      children: [
        // Car Plate Number
        buildTextField("Car Plate Number", carPlateNumber),

        // Car Location Dropdown
        SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Car Location",
            border: OutlineInputBorder(),
          ),
          value: selectedCarLocation,
          items: carlocations.map((String location) {
            return DropdownMenuItem<String>(
              value: location,
              child: Text(location),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedCarLocation = newValue;
            });
          },
        ),

        // Car Color Dropdown
        SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Car Color",
            border: OutlineInputBorder(),
          ),
          value: selectedCarColor,
          items: carColors.map((String color) {
            return DropdownMenuItem<String>(
              value: color,
              child: Text(color),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedCarColor = newValue;
            });
          },
        ),

        // Maximum Passengers Dropdown
        SizedBox(height: 16),
        DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: "Maximum Number of Passengers",
            border: OutlineInputBorder(),
          ),
          value: selectedMaxPassengers,
          items: passengerCounts.map((int count) {
            return DropdownMenuItem<int>(
              value: count,
              child: Text("$count passengers"),
            );
          }).toList(),
          onChanged: (int? newValue) {
            setState(() {
              selectedMaxPassengers = newValue;
            });
          },
        ),

        // Driver Included Switch
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Driver Included",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Switch(
                value: driverIncluded,
                onChanged: (bool value) {
                  setState(() {
                    driverIncluded = value;
                  });
                },
                activeColor: Colors.blue,
              ),
            ],
          ),
        ),

        SizedBox(height: 8),
        Text(
          "Price: MYR ${price.text.isEmpty ? '0' : price.text} per day",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget buildOperatingDaysSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Operating Days",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (selectedDays.length == days.length) {
                      selectedDays.clear();
                    } else {
                      selectedDays = List.from(days);
                    }
                  });
                },
                child: Text(
                  selectedDays.length == days.length ? "Deselect All" : "Select All",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: days.map((day) {
              bool isSelected = selectedDays.contains(day);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedDays.remove(day);
                    } else {
                      selectedDays.add(day);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[600]!,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      if (isSelected) SizedBox(width: 6),
                      Text(
                        day,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildTimeSlotsSection() {
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
            "Time Slots (8AM - 10PM)",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Dark mode color
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Selected: ${selectedTimeSlots.length} slots",
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: timeSlots.map((timeSlot) {
              bool isSelected = selectedTimeSlots.contains(timeSlot);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedTimeSlots.remove(timeSlot);
                    } else {
                      selectedTimeSlots.add(timeSlot);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey[800],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[600]!,
                    ),
                  ),
                  child: Text(
                    timeSlot,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[300],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Tap seats to toggle availability",
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (selectedSeats.length == 33) {
                      selectedSeats.clear();
                    } else {
                      selectedSeats = Set<int>.from(List.generate(33, (i) => i + 1));
                    }
                  });
                },
                child: Text(
                  selectedSeats.length == 33 ? "Deselect All" : "Select All",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Driver section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "Driver",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
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
              Text("Available", style: TextStyle(fontSize: 12, color: Colors.white)),
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
              Text("Not Available", style: TextStyle(fontSize: 12, color: Colors.white)),
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
          color: isSelected ? Colors.green : Colors.grey[700],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Center(
          child: Text(
            seatNumber.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
                    // Reset type-specific selections when type changes
                    if (selectedType != "Bus") {
                      selectedDays = [];
                      selectedTimeSlots = [];
                      selectedSeats = Set<int>();
                    }
                    if (selectedType != "Car") {
                      carPlateNumber.clear();
                      selectedCarLocation = null;
                      selectedCarColor = null;
                      driverIncluded = false;
                      selectedMaxPassengers = null;
                    }
                    if (selectedType != "Ferry") {
                      ferryOriginController.clear();
                      ferryDestinationController.clear();
                      pedestrianPriceController.clear();
                      vehiclePriceController.clear();
                    }
                  });
                },
              ),
              SizedBox(height: 16),

              // Name field - required for all transport types
              buildTextField(
                  selectedType == "Bus" ? "Bus Name" :
                  selectedType == "Car" ? "Car Name" :
                  selectedType == "Ferry" ? "Ferry Name" : "Transport Name",
                  name
              ),

              // Price field - only for non-ferry types
              if (selectedType != "Ferry" && selectedType != null)
                buildTextField(
                    selectedType == "Car" ? "Price per Day (MYR)" : "Price (MYR)",
                    price,
                    isNumber: true
                ),

              // Car-specific fields
              if (selectedType == "Car") ...[
                SizedBox(height: 16),
                buildCarDetailsSection(),
              ],

              // Ferry-specific fields
              if (selectedType == "Ferry") ...[
                SizedBox(height: 16),
                buildFerryDetailsSection(),
              ],

              // Non-car and non-ferry transport fields (Bus, Flight, Train)
              if (selectedType != "Car" && selectedType != "Ferry" && selectedType != null) ...[
                // Origin Dropdown
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Departure Location",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedOrigin,
                  items: locations.map((String location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedOrigin = newValue;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Destination Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Destination",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedDestination,
                  items: locations.map((String location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDestination = newValue;
                    });
                  },
                ),
              ],

              // Bus-specific fields
              if (selectedType == "Bus") ...[
                SizedBox(height: 16),

                // Operating Days Section
                buildOperatingDaysSection(),
                SizedBox(height: 16),

                // Time Slots Section
                buildTimeSlotsSection(),
                SizedBox(height: 16),

                // Bus Seat Map
                buildBusSeatMap(),
                SizedBox(height: 16),
              ],

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