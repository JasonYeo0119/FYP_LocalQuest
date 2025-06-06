import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localquest/Module_Booking_Management/Bookingallinone.dart';
import 'package:localquest/Module_Booking_Management/Bookinghotel.dart';
import 'package:localquest/Module_Booking_Management/Bookingtransportmain.dart';
import 'package:localquest/Module_Booking_Management/Location.dart';
import 'Attractionsearchresult.dart';

@override
void Search(BuildContext ctx, String query) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return AttractionSearchResults(initialQuery: query);
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
  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchForm(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.026,
        vertical: screenHeight * 0.025,
      ),
      padding: EdgeInsets.all(screenWidth * 0.026),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.blue,
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search input field
          Container(
            width: double.infinity,
            height: screenHeight * 0.045,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.black, width: 1),
            ),
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
            alignment: Alignment.center,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Where do you want to go?',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
              textAlignVertical: TextAlignVertical.center,
              // Added onSubmitted to allow search on Enter key
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  Search(context, value.trim());
                }
              },
            ),
          ),

          SizedBox(height: screenHeight * 0.01),

          // Attractions list link
          GestureDetector(
            onTap: () {
              Attractionlist(context);
            },
            child: Text(
              'Click here to view the attractions list',
              style: TextStyle(
                color: Color(0xFF1A24F1),
                fontSize: screenWidth * 0.035,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.underline,
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          // Search button
          Center(
            child: GestureDetector(
              onTap: () {
                // Modified to handle empty search query
                String searchQuery = _searchController.text.trim();
                if (searchQuery.isEmpty) {
                  // If search is empty, show all attractions
                  Search(context, '');
                } else {
                  Search(context, searchQuery);
                }
              },
              child: Container(
                width: screenWidth * 0.39,
                height: screenHeight * 0.04,
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
                child: Center(
                  child: Text(
                    'Search',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.036,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(double screenWidth, double screenHeight) {
    double iconSize = screenWidth * 0.18;
    double iconButtonSize = screenWidth * 0.103;

    return Positioned(
      left: 0,
      right: 0,
      bottom: screenHeight * 0.02,
      child: Container(
        height: screenHeight * 0.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Hotel button
            Container(
              width: iconSize,
              height: iconSize,
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
              child: Opacity(
                opacity: 0.3,
                child: IconButton(
                  icon: Icon(Icons.hotel_outlined, color: Colors.black),
                  iconSize: iconButtonSize,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Bookinghotelmain()),
                    );
                  },
                ),
              ),
            ),

            // Transport button
            Container(
              width: iconSize,
              height: iconSize,
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
              child: Opacity(
                opacity: 0.3,
                child: IconButton(
                  icon: Icon(Icons.directions_train_outlined, color: Colors.black),
                  iconSize: iconButtonSize,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Bookingtransportmain()),
                    );
                  },
                ),
              ),
            ),

            // Attraction button (active)
            Container(
              width: iconSize,
              height: iconSize,
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
              child: IconButton(
                icon: Icon(Icons.park_outlined, color: Colors.black),
                iconSize: iconButtonSize,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Bookingattractionmain()),
                  );
                },
              ),
            ),

            // All in one button
            Container(
              width: iconSize,
              height: iconSize,
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
              child: Opacity(
                opacity: 0.3,
                child: IconButton(
                  icon: Icon(Icons.dashboard_outlined, color: Colors.black),
                  iconSize: iconButtonSize,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("All Attractions",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
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
      body: Container(
        width: double.infinity,
        height: screenHeight,
        decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildSearchForm(screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.15), // Space for bottom navigation
                ],
              ),
            ),
            _buildBottomNavigation(screenWidth, screenHeight),
          ],
        ),
      ),
    );
  }
}