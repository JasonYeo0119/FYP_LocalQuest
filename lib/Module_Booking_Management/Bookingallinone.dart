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
  TextEditingController _originController = TextEditingController();
  TextEditingController _paxController = TextEditingController();
  TextEditingController _budgetController = TextEditingController();

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  String? selectedActivity;
  String? selectedFlex;
  Set<String> selectedStates = {};

  final List<Map<String, dynamic>> states = [
    {"name": "Johor", "image": "lib/Image/johor.png"},
    {"name": "Kedah", "image": "lib/Image/kedah.png"},
    {"name": "Kelantan", "image": "lib/Image/kelantan.png"},
    {"name": "Kuala Lumpur", "image": "lib/Image/kl.png"},
    {"name": "Labuan", "image": "lib/Image/labuan.png"},
    {"name": "Malacca", "image": "lib/Image/malacca.png"},
    {"name": "Negeri Sembilan", "image": "lib/Image/n9.png"},
    {"name": "Pahang", "image": "lib/Image/pahang.png"},
    {"name": "Penang", "image": "lib/Image/penang.png"},
    {"name": "Perak", "image": "lib/Image/perak.png"},
    {"name": "Perlis", "image": "lib/Image/perlis.png"},
    {"name": "Putrajaya", "image": "lib/Image/putrajaya.png"},
    {"name": "Sabah", "image": "lib/Image/sabah.png"},
    {"name": "Sarawak", "image": "lib/Image/sarawak.png"},
    {"name": "Selangor", "image": "lib/Image/selangor.png"},
    {"name": "Terengganu", "image": "lib/Image/terengganu.png"},
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

          if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutController.clear();
            _checkOutDate = null;
          }
        } else {
          if (_checkInDate != null && pickedDate.isBefore(_checkInDate!)) {
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

  Widget _buildStateSelectionGrid(double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      height: screenHeight * 0.252,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1),
          borderRadius: BorderRadius.circular(9),
        ),
      ),
      padding: EdgeInsets.all(screenWidth * 0.013),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.8,
          crossAxisSpacing: screenWidth * 0.008,
          mainAxisSpacing: screenHeight * 0.008,
        ),
        itemCount: states.length,
        itemBuilder: (context, index) {
          final state = states[index];
          final stateName = state["name"];
          final isSelected = selectedStates.contains(stateName);

          return GestureDetector(
            onTap: () => toggleStateSelection(stateName),
            child: Container(
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
                    opacity: isSelected ? 1.0 : 0.3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Image.asset(
                        state["image"],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      stateName == "Negeri Sembilan" ? 'Negeri\nSembilan' : stateName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: stateName == "Kuala Lumpur" || stateName == "Negeri Sembilan"
                            ? screenWidth * 0.028
                            : screenWidth * 0.031,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.white,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedStatesDisplay(double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: screenHeight * 0.015),
      padding: EdgeInsets.all(screenWidth * 0.026),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Selected States:",
            style: TextStyle(
              color: Colors.black,
              fontSize: screenWidth * 0.033,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          selectedStates.isEmpty
              ? Text(
            "No states selected yet",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: screenWidth * 0.031,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
            ),
          )
              : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: selectedStates.map((stateName) {
                return Container(
                  margin: EdgeInsets.only(right: screenWidth * 0.02),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.blue.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stateName,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: screenWidth * 0.03,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.015),
                      GestureDetector(
                        onTap: () => toggleStateSelection(stateName),
                        child: Icon(
                          Icons.close,
                          size: screenWidth * 0.035,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBookingForm(double screenWidth, double screenHeight) {
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
            color: Colors.green,
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header text
          Text(
            "We'll create the perfect personalized trip just for you!",
            style: TextStyle(
              color: Colors.black,
              fontSize: screenWidth * 0.031,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: screenHeight * 0.001),

          Text(
            "Select the state(s) you would like to visit",
            style: TextStyle(
              color: Colors.black,
              fontSize: screenWidth * 0.031,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),

          // State selection grid
          _buildStateSelectionGrid(screenWidth, screenHeight),

          // Selected states display
          _buildSelectedStatesDisplay(screenWidth, screenHeight),

          SizedBox(height: screenHeight * 0.02),

          // Origin location input
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
              controller: _originController,
              decoration: InputDecoration(
                hintText: 'Where are you from?',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
              textAlignVertical: TextAlignVertical.center,
            ),
          ),

          SizedBox(height: screenHeight * 0.015),

          // Check-in and Check-out dates
          Row(
            children: [
              Expanded(
                child: Container(
                  height: screenHeight * 0.045,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _checkInController,
                    readOnly: true,
                    onTap: () => _selectDate(context, _checkInController, true),
                    decoration: InputDecoration(
                      hintText: 'Check In',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                    textAlignVertical: TextAlignVertical.center,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.026),
              Expanded(
                child: Container(
                  height: screenHeight * 0.045,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _checkOutController,
                    readOnly: true,
                    onTap: () => _selectDate(context, _checkOutController, false),
                    decoration: InputDecoration(
                      hintText: 'Check Out',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                    textAlignVertical: TextAlignVertical.center,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.015),

          // Number of Pax and Budget
          Row(
            children: [
              Expanded(
                child: Container(
                  height: screenHeight * 0.045,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _paxController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Number of Pax',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                    textAlignVertical: TextAlignVertical.center,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.026),
              Expanded(
                child: Container(
                  height: screenHeight * 0.045,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Maximum Budget',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                    textAlignVertical: TextAlignVertical.center,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.015),

          // Type of Trip and Flexibility
          Row(
            children: [
              Expanded(
                child: Container(
                  height: screenHeight * 0.045,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
                  alignment: Alignment.center,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedActivity,
                      dropdownColor: Colors.white,
                      hint: Text(
                        'Type of Trip',
                        style: TextStyle(fontSize: screenWidth * 0.036, color: Color(0xFFB1B1B1)),
                      ),
                      isExpanded: true,
                      style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
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
                            style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.026),
              Expanded(
                child: Container(
                  height: screenHeight * 0.045,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.021),
                  alignment: Alignment.center,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedFlex,
                      dropdownColor: Colors.white,
                      hint: Text(
                        'Flexibility',
                        style: TextStyle(fontSize: screenWidth * 0.036, color: Color(0xFFB1B1B1)),
                      ),
                      isExpanded: true,
                      style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
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
                            style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.015),

          // Search button
          Center(
            child: GestureDetector(
              onTap: () {
                Search(context);
              },
              child: Container(
                width: screenWidth * 0.39,
                height: screenHeight * 0.04,
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
          SizedBox(height: screenHeight * 0.001),
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

            // Attraction button
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
            ),

            // All in one button (active)
            Container(
              width: iconSize,
              height: iconSize,
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
        title: Text("Generate Itinerary",
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
              colors: [Color(0xFF02ED64), Color(0xFFFFFA02)],
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
                  _buildBookingForm(screenWidth, screenHeight),
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