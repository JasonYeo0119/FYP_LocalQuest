import 'package:flutter/material.dart';
import 'package:localquest/Module_Booking_Management/Bookingallinone.dart';
import 'package:localquest/Module_Booking_Management/Bookingattractionmain.dart';
import 'package:localquest/Module_Booking_Management/Bookingtransportmain.dart';
import 'package:localquest/Module_Booking_Management/Searchresult.dart';

@override
void Search(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Searchresult();
  }));
}

@override
void Allinone(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Bookingallinone();
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

class Bookinghotelmain extends StatefulWidget {
  @override
  _BookinghotelmainState createState() => _BookinghotelmainState();
}


class _BookinghotelmainState extends State<Bookinghotelmain> {
  TextEditingController _checkInController = TextEditingController();
  TextEditingController _checkOutController = TextEditingController();

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int? selectedAdults; // Initially null for hint text
  int? selectedChildren; // Initially null for hint text

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
        title: Text("All Rooms"),
        backgroundColor: Colors.transparent, // Make AppBar background transparent
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF4502), Color(0xFFFFFF00)],
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
                  Positioned(  //Whitebackground
                    left: 10,
                    top: 20,
                    child: Container(
                      width: 389,
                      height: 220,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.deepOrange, // Border color
                            width: 2, // Border thickness
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(   //Locationname
                    left: 25,
                    top: 43,
                    child: Material(
                      color: Colors.transparent, // Ensures no unwanted background
                      child: Container(
                        width: 359,
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
                            hintText: 'Where do you want to go?',
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
                    top: 89,
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
                    left: 212,
                    top: 89,
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
                  Positioned(  //Numofadult
                    left: 25,
                    top: 134,
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
                        padding: EdgeInsets.symmetric(horizontal: 1),
                        alignment: Alignment.center,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedAdults,
                            dropdownColor: Colors.white,
                            hint: Text(
                              'Number of Adult(s)',
                              style: TextStyle(fontSize: 14, color: Color(0xFFB1B1B1)),
                            ),
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedAdults = newValue!;
                              });
                            },
                            items: [
                              // Hint item (not selectable)
                              DropdownMenuItem<int>(
                                value: null,
                                child: Text(
                                  'Number of Adult(s)',
                                  style: TextStyle(fontSize: 14, color: Color(0xFFB1B1B1)),
                                ),
                              ),
                              // Actual options (1-20)
                              ...List.generate(20, (index) => index + 1).map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(
                                    value.toString(),
                                    style: TextStyle(fontSize: 14, color: Colors.black),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Numofchildren
                    left: 212,
                    top: 134,
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
                        padding: EdgeInsets.symmetric(horizontal: 1),
                        alignment: Alignment.center,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedChildren,
                            dropdownColor: Colors.white,
                            hint: Text(
                              'Number of Adult(s)',
                              style: TextStyle(fontSize: 14, color: Color(0xFFB1B1B1)),
                            ),
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedChildren = newValue!;
                              });
                            },
                            items: [
                              // Hint item (not selectable)
                              DropdownMenuItem<int>(
                                value: null,
                                child: Text(
                                  'Number of Children',
                                  style: TextStyle(fontSize: 14, color: Color(0xFFB1B1B1)),
                                ),
                              ),
                              // Actual options (1-20)
                              ...List.generate(10, (index) => index + 1).map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(
                                    value.toString(),
                                    style: TextStyle(fontSize: 14, color: Colors.black),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Searchbutton
                    left: 129,
                    top: 187,
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
                            colors: [Color(0xFFFF4502), Color(0xFFFFFF00)],
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
                    left: 180,
                    top: 193,
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
                  Positioned(  //Orangeroundbutton
                    left: 38,
                    top: 678,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(1.00, 0.00),
                          end: Alignment(-1, 0),
                          colors: [Color(0xFFFF4502), Color(0xFFFFFF00)],
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
                  Positioned(  //hotel icon
                    left: 45,
                    top: 684,
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
                  Positioned(  //Purpleroundbutton
                    left: 126,
                    top: 678,
                    child: GestureDetector(
                      onTap: () {
                        Transport(context);
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
                  Positioned(  //Allinone icon
                    left: 309,
                    top: 686,
                    child: Opacity(
                      opacity: 0.3, // Sets the opacity to 30%
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