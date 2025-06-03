import 'package:flutter/material.dart';
import 'package:localquest/Module_Booking_Management/Bookingattractionmain.dart';
import 'package:localquest/Module_Booking_Management/Bookinghotel.dart';
import 'package:localquest/Module_Booking_Management/Bookingtransportmain.dart';
import 'package:localquest/Module_Booking_Management/Searchresult.dart';

@override
void Search(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Searchresult();
  }));
}

@override
void Stay(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Bookinghotelmain();
  }));
}

@override
void Transport(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Bookingtransportmain();
  }));
}

@override
void Attraction(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Bookingattractionmain();
  }));
}

@override
void Allinone(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Bookingallinone();
  }));
}

class Bookingallinone extends StatefulWidget {
  @override
  _BookingallinoneState createState() => _BookingallinoneState();
}

class _BookingallinoneState extends State<Bookingallinone> {
  TextEditingController _checkInController = TextEditingController();
  TextEditingController _checkOutController = TextEditingController();

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  String? selectedActivity; // Default selection
  String? selectedFlex;
  Set<String> selectedStates = {};
  final List<Map<String, dynamic>> states = [
    {"name": "Johor", "image": "lib/Image/johor.png", "left": 39.0, "top": 97.0},
    {"name": "Kedah", "image": "lib/Image/kedah.png", "left": 125.0, "top": 97.0},
    {"name": "Kelantan", "image": "lib/Image/kelantan.png", "left": 211.0, "top": 97.0},
    {"name": "Kuala Lumpur", "image": "lib/Image/kl.png", "left": 297.0, "top": 97.0, "fontSize": 11.0},
    {"name": "Labuan", "image": "lib/Image/labuan.png", "left": 39.0, "top": 150.0},
    {"name": "Malacca", "image": "lib/Image/malacca.png", "left": 125.0, "top": 150.0},
    {"name": "Negeri Sembilan", "image": "lib/Image/n9.png", "left": 211.0, "top": 150.0, "fontSize": 11.0, "isMultiline": true},
    {"name": "Pahang", "image": "lib/Image/pahang.png", "left": 297.0, "top": 150.0},
    {"name": "Penang", "image": "lib/Image/penang.png", "left": 39.0, "top": 203.0},
    {"name": "Perak", "image": "lib/Image/perak.png", "left": 125.0, "top": 203.0},
    {"name": "Perlis", "image": "lib/Image/perlis.png", "left": 211.0, "top": 203.0},
    {"name": "Putrajaya", "image": "lib/Image/putrajaya.png", "left": 297.0, "top": 203.0},
    {"name": "Sabah", "image": "lib/Image/sabah.png", "left": 39.0, "top": 256.0},
    {"name": "Sarawak", "image": "lib/Image/sarawak.png", "left": 125.0, "top": 256.0},
    {"name": "Selangor", "image": "lib/Image/selangor.png", "left": 211.0, "top": 256.0},
    {"name": "Terengganu", "image": "lib/Image/terengganu.png", "left": 297.0, "top": 256.0},
  ];

  void toggleStateSelection(String stateName) {
    setState(() {
      if (selectedStates.contains(stateName)) {
        selectedStates.remove(stateName);
      } else {
        selectedStates.add(stateName);
      }
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, bool isCheckIn) async {
    DateTime today = DateTime.now();
    DateTime initialDate = today;

    if (!isCheckIn && _checkInDate != null) {
      // Check-Out must be after Check-In
      initialDate = _checkInDate!.add(Duration(days: 1));
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isCheckIn ? today : (_checkInDate ?? today).add(Duration(days: 1)),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = pickedDate;
          _checkInController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";

          // Reset Check-Out if it's now before Check-In
          if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutController.clear();
            _checkOutDate = null;
          }
        } else {
          if (_checkInDate != null && pickedDate.isBefore(_checkInDate!)) {
            // Show error if Check-Out is earlier than Check-In
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Check-Out date must be after Check-In date.")),
            );
          } else {
            _checkOutDate = pickedDate;
            _checkOutController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
          }
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All in One Bookings"),
        backgroundColor: Colors.transparent, // Make AppBar background transparent
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF02ED64), Color(0xFFFFFA02)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView( // Prevents overflow issues
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 790,
              decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
              child: Stack(
                children: [
                  Positioned(  //backgroundwhite
                    left: 10,
                    top: 20,
                    child: Container(
                      width: 389,
                      height: 570,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.green, // Border color
                            width: 2, // Border thickness
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 26,
                    top: 35,
                    child: Text(
                      "We'll create the perfect personalized trip just for you!",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 26,
                    top: 55,
                    child: Text(
                      "Select the state(s) you would like to visit",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  // State background container
                  Positioned(
                      left: 24,
                      top: 80,
                      child: Container(
                        width: 359,
                        height: 234,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1),
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      )
                  ),

                  // Generate all state tiles dynamically
                  ...states.map((state) {
                String stateName = state["name"];
                bool isSelected = selectedStates.contains(stateName);

                return Stack(
                  children: [
                    // State container with image
                    Positioned(
                      left: state["left"] - 3,
                      top: state["top"],
                      child: GestureDetector(
                        onTap: () => toggleStateSelection(stateName),
                        child: Container(
                          width: 75,
                          height: 40,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: isSelected ? Colors.blue : Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Opacity(
                                opacity: isSelected ? 1.0 : 0.3, // 100% when selected, 30% when not
                                child: Image.asset(
                                  state["image"],
                                  fit: BoxFit.fill,
                                  width: 75,
                                  height: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // State name text
                    Positioned(
                      left: state["name"] == "Negeri Sembilan" ? state["left"] + 11 :
                      (state["name"] == "Kuala Lumpur" ? state["left"] :
                      state["name"] == "Perak" ? state["left"] + 18 :
                      state["name"] == "Perlis" ? state["left"] + 18 :
                      state["name"] == "Terengganu" ? state["left"] + 2 :
                      state["left"] + (52 - stateName.length * 4) / 2),
                      top: state["name"] == "Negeri Sembilan" ? state["top"] + 4 : state["top"] + 12,
                      child: Text(
                        state["isMultiline"] == true ? '  Negeri\nSembilan' : stateName,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: state["fontSize"] ?? 12.0,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
                  }).toList(),
                  Positioned(  //Origin Location
                    left: 25,
                    top: 325,
                    child: Material(
                      color: Colors.transparent, // Ensures no unwanted background
                      child: Container(
                        width: 361,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5), // Optional rounded corners
                          border: Border.all(color: Colors.black, width: 1),
                        ),// Optional border
                        padding: EdgeInsets.symmetric(horizontal: 8), // Padding for text input
                        alignment: Alignment.center,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Where are you from?',
                            border: InputBorder.none, // Removes default TextField border
                            isDense: true, // Reduces TextField height to fit container
                            contentPadding: EdgeInsets.zero, // Aligns text properly
                          ),
                          style: TextStyle(fontSize: 14, color: Colors.black),
                          textAlignVertical: TextAlignVertical.center, // Ensures proper vertical alignment
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //datein
                    left: 25,
                    top: 375,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: 170,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _checkInController,
                          readOnly: true, // Prevent manual input
                          onTap: () => _selectDate(context, _checkInController, true),
                          decoration: InputDecoration(
                            hintText: 'Check In',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(fontSize: 14, color: Colors.black),
                          textAlignVertical: TextAlignVertical.center,
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //dateout
                    left: 217,
                    top: 375,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: 170,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _checkOutController,
                          readOnly: true, // Prevent manual input
                          onTap: () => _selectDate(context, _checkOutController, false),
                          decoration: InputDecoration(
                            hintText: 'Check Out',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(fontSize: 14, color: Colors.black),
                          textAlignVertical: TextAlignVertical.center,
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Numofpax
                    left: 25,
                    top: 425,
                    child: Material(
                      color: Colors.transparent, // Ensures no unwanted background
                      child: Container(
                        width: 170,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5), // Optional rounded corners
                          border: Border.all(color: Colors.black, width: 1),
                        ),// Optional border
                        padding: EdgeInsets.symmetric(horizontal: 8), // Padding for text input
                        alignment: Alignment.center,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Number of Pax',
                            border: InputBorder.none, // Removes default TextField border
                            isDense: true, // Reduces TextField height to fit container
                            contentPadding: EdgeInsets.zero, // Aligns text properly
                          ),
                          style: TextStyle(fontSize: 14, color: Colors.black),
                          textAlignVertical: TextAlignVertical.center, // Ensures proper vertical alignment
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //budget
                    left: 217,
                    top: 425,
                    child: Material(
                      color: Colors.transparent, // Ensures no unwanted background
                      child: Container(
                        width: 170,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5), // Optional rounded corners
                          border: Border.all(color: Colors.black, width: 1),
                        ),// Optional border
                        padding: EdgeInsets.symmetric(horizontal: 8), // Padding for text input
                        alignment: Alignment.center,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Maximum Budget',
                            border: InputBorder.none, // Removes default TextField border
                            isDense: true, // Reduces TextField height to fit container
                            contentPadding: EdgeInsets.zero, // Aligns text properly
                          ),
                          style: TextStyle(fontSize: 14, color: Colors.black),
                          textAlignVertical: TextAlignVertical.center, // Ensures proper vertical alignment
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Typeoftrip
                    left: 25,
                    top: 475,
                    child: Material(
                      color: Colors.transparent, // Ensures no unwanted background
                      child: Container(
                        width: 170,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5), // Optional rounded corners
                          border: Border.all(color: Colors.black, width: 1), // Optional border
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8), // Padding for dropdown
                        alignment: Alignment.center,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedActivity, // Holds the selected value
                            dropdownColor: Colors.white,
                            hint: Text(
                              'Type of Trip',
                              style: TextStyle(fontSize: 14, color: Color(0xFFB1B1B1)),
                            ),
                            isExpanded: true, // Ensure it fills the container
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedActivity = newValue!;
                              });
                            },
                            items: ['Adventure', 'Chill', 'Mix']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(fontSize: 14, color: Colors.black),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Flexibility
                    left: 217,
                    top: 475,
                    child: Material(
                      color: Colors.transparent, // Ensures no unwanted background
                      child: Container(
                        width: 170,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5), // Optional rounded corners
                          border: Border.all(color: Colors.black, width: 1), // Optional border
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8), // Padding for dropdown
                        alignment: Alignment.center,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedFlex, // Holds the selected value
                            dropdownColor: Colors.white,
                            hint: Text(
                              'Flexibility',
                              style: TextStyle(fontSize: 14, color: Color(0xFFB1B1B1)),
                            ),
                            isExpanded: true, // Ensure it fills the container
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedFlex = newValue!;
                              });
                            },
                            items: ['Flexible', 'Normal', 'Full']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(fontSize: 14, color: Colors.black),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Search Bar
                    left: 129,
                    top: 530,
                    child: GestureDetector(
                      onTap: () {
                        Search(context);
                      },
                      child: Container(
                        width: 151,
                        height: 32,
                        decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(1.00, 0.00),
                            end: Alignment(-1, 0),
                            colors: [Color(0xFF02ED64), Color(0xFFFFFA02)],
                          ),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          shadows: [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 182,
                    top: 536,
                    child: GestureDetector(
                      onTap: () {
                        Search(context);
                      },
                      child: Text(
                        'Search',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Hotelbutton
                    left: 38,
                    top: 678,
                    child: GestureDetector(
                      onTap: () {
                        Stay(context);
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: ShapeDecoration(
                          color: Color(0xFFF5F5F5),
                          shape: OvalBorder(side: BorderSide(width: 1)),
                          shadows: [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //hotel icon
                    left: 45,
                    top: 684,
                    child: Opacity(
                      opacity: 0.3,
                      child: IconButton(
                        icon: Icon(Icons.hotel_outlined, color: Colors.black),
                        iconSize: 40,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Bookinghotelmain()),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(  //Purpleroundbutton
                    left: 126,
                    top: 678,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: ShapeDecoration(
                        color: Color(0xFFF5F5F5),
                        shape: OvalBorder(side: BorderSide(width: 1)),
                        shadows: [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(  //Transport icon
                    left: 133,
                    top: 687,
                    child: Opacity(
                      opacity: 0.3, // Sets the opacity to 30%
                      child: IconButton(
                        icon: Icon(Icons.directions_train_outlined, color: Colors.black),
                        iconSize: 40,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Bookingtransportmain()),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(  //Blueroundicon
                    left: 214,
                    top: 677,
                    child: GestureDetector(
                      onTap: () {
                        Attraction(context);
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: ShapeDecoration(
                          color: Color(0xFFF5F5F5),
                          shape: OvalBorder(side: BorderSide(width: 1)),
                          shadows: [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Attraction icon
                    left: 221,
                    top: 683,
                    child: Opacity(
                      opacity: 0.3, // Sets the opacity to 30%
                      child: IconButton(
                        icon: Icon(Icons.park_outlined, color: Colors.black),
                        iconSize: 40,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Bookingattractionmain()),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(  //Greenroundbutton
                    left: 302,
                    top: 678,
                    child: GestureDetector(
                      onTap: () {
                        Allinone(context);
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(1.00, 0.00),
                            end: Alignment(-1, 0),
                            colors: [Color(0xFF02ED64), Color(0xFFFFFA02)],
                          ),
                          shape: OvalBorder(side: BorderSide(width: 1)),
                          shadows: [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Allinone icon
                    left: 309,
                    top: 686,
                    child: IconButton(
                      icon: Icon(Icons.dashboard_outlined, color: Colors.black),
                      iconSize: 40,
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Bookingallinone()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}