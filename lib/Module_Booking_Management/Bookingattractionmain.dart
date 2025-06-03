import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localquest/Module_Booking_Management/Bookingallinone.dart';
import 'package:localquest/Module_Booking_Management/Bookinghotel.dart';
import 'package:localquest/Module_Booking_Management/Bookingtransportmain.dart';
import 'package:localquest/Module_Booking_Management/Location.dart';
import 'package:localquest/Module_Booking_Management/Searchresult.dart';

@override
void Search(BuildContext ctx, String query) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Searchresult(initialQuery: query);
  }));
}

@override
void Allinone(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Bookingallinone();
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
void Attractionlist(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Location();
  }));
}

@override
void Attraction(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Bookingattractionmain();
  }));
}

class Bookingattractionmain extends StatefulWidget {
  @override
  _BookingattractionmainState createState() => _BookingattractionmainState();
}

class _BookingattractionmainState extends State<Bookingattractionmain> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()), // Default to today
    );
  }

  @override
  void dispose() {
    _dateController.dispose(); // Dispose controller to free memory
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now, // Only allow today or future dates
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate); // Update UI
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Attractions"),
        backgroundColor: Colors.transparent, // Make AppBar background transparent
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0C1FF7), Color(0xFF02BFFF)],
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
                      height: 193,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.blue, // Border color
                            width: 2, // Border thickness
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 25,
                    top: 43,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: 359,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Where do you want to go?',
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
                  Positioned(
                    left: 25,
                    top: 109,
                    child: Material(
                      color: Colors.transparent, // Ensures no unwanted background
                      child: Container(
                        width: 180,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5), // Optional rounded corners
                          border: Border.all(color: Colors.black, width: 1),
                        ),// Optional border
                        padding: EdgeInsets.symmetric(horizontal: 8), // Padding for text input
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _dateController,
                          readOnly: true,
                          onTap: () => _selectDate(context), // Opens date picker on tap
                          decoration: InputDecoration(
                            hintText: 'Today',
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
                  Positioned(
                    left: 129,
                    top: 160,
                    child: GestureDetector(
                      onTap: () {
                        Search(context, _searchController.text);
                      },
                      child: Container(
                        width: 151,
                        height: 32,
                        decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(1.00, 0.00),
                            end: Alignment(-1, 0),
                            colors: [Color(0xFF0C1FF7), Color(0xFF02BFFF)],
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
                    top: 166,
                    child: GestureDetector(
                      onTap: () {
                        Search(context, _searchController.text);
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
                  Positioned(
                    left: 29,
                    top: 82,
                    child: GestureDetector(
                      onTap: () {
                        Attractionlist(context);
                      },
                      child: Text(
                        'Click here to view the attractions list',
                        style: TextStyle(
                          color: Color(0xFF1A24F1),
                          fontSize: 11,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
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
                          gradient: LinearGradient(
                            begin: Alignment(1.00, 0.00),
                            end: Alignment(-1, 0),
                            colors: [Color(0xFF0C1FF7), Color(0xFF02BFFF)],
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
                  Positioned(  //Attraction icon
                    left: 221,
                    top: 683,
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