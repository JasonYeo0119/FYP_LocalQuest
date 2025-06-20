import 'package:flutter/material.dart';
import 'package:localquest/Homepage.dart';
import 'package:localquest/Module_Booking_Management/Bookingattractionmain.dart';
import 'package:localquest/Module_Booking_Management/Bookinghotel.dart';
import 'package:localquest/Module_Booking_Management/Bookingtransportmain.dart';
import 'package:localquest/services/itinerary_service.dart';
import 'Itinerarydisplayscreen.dart';

@override
void Search(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Homepage();
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
  String? selectedActivity;
  String? selectedFlex;
  Set<String> selectedStates = {};
  String? selectedOriginState;
  String? selectedPax;
  String? selectedBudget;

  final ItineraryGenerator _itineraryGenerator = ItineraryGenerator();
  bool _isGenerating = false;

  final List<Map<String, dynamic>> states = [
    {"name": "Kuala Lumpur", "image": "lib/Image/kl.png"},
    {"name": "Penang", "image": "lib/Image/penang.png"},
    {"name": "Malacca", "image": "lib/Image/malacca.png"},
    {"name": "Kedah", "image": "lib/Image/kedah.png"},
    {"name": "Johor", "image": "lib/Image/johor.png"},
    {"name": "Pahang", "image": "lib/Image/pahang.png"},
    {"name": "Sabah", "image": "lib/Image/sabah.png"},
    {"name": "Sarawak", "image": "lib/Image/sarawak.png"},
    {"name": "Perak", "image": "lib/Image/perak.png"},
    {"name": "Terengganu", "image": "lib/Image/terengganu.png"},
    {"name": "Kelantan", "image": "lib/Image/kelantan.png"},
    {"name": "Putrajaya", "image": "lib/Image/putrajaya.png"},
  ];

  final List<String> malaysianStates = [
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
    "Terengganu"
  ];

  final List<String> paxOptions = [
    "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"
  ];

  final List<String> budgetOptions = [
    "1000", "1500", "2000", "2500", "3000", "3500",
    "4000", "4500", "5000", "10000", "20000", "30000", "50000"
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

  bool _validateForm() {
    if (selectedStates.isEmpty) {
      _showErrorMessage("Please select at least one state to visit");
      return false;
    }

    if (selectedOriginState == null || selectedOriginState!.trim().isEmpty) {
      _showErrorMessage("Please select your origin state");
      return false;
    }

    if (_checkInDate == null || _checkOutDate == null) {
      _showErrorMessage("Please select check-in and check-out dates");
      return false;
    }

    if (_checkInDate!.isAfter(_checkOutDate!) || _checkInDate!.isAtSameMomentAs(_checkOutDate!)) {
      _showErrorMessage("Trip must be at least 1 day long");
      return false;
    }

    if (selectedPax == null || int.tryParse(selectedPax!) == null || int.parse(selectedPax!) <= 0) {
      _showErrorMessage("Please select number of passengers");
      return false;
    }

    if (selectedBudget == null || double.tryParse(selectedBudget!) == null || double.parse(selectedBudget!) <= 0) {
      _showErrorMessage("Please select a budget amount");
      return false;
    }

    if (selectedActivity == null) {
      _showErrorMessage("Please select a trip type");
      return false;
    }

    if (selectedFlex == null) {
      _showErrorMessage("Please select flexibility level");
      return false;
    }

    // Additional validation for budget vs trip duration
    int tripDays = _checkOutDate!.difference(_checkInDate!).inDays;
    double budgetPerDay = double.parse(selectedBudget!) / tripDays;
    if (budgetPerDay < 50) {
      _showErrorMessage("Budget might be too low. Consider at least RM50 per day per person.");
      return false;
    }

    return true;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  TripType _convertToTripType(String? selected) {
    switch (selected?.toLowerCase()) {
      case 'adventure':
        return TripType.adventure;
      case 'chill':
        return TripType.chill;
      case 'mix':
        return TripType.mix;
      default:
        return TripType.mix;
    }
  }

  FlexibilityLevel _convertToFlexibilityLevel(String? selected) {
    switch (selected?.toLowerCase()) {
      case 'flexible':
        return FlexibilityLevel.flexible;
      case 'normal':
        return FlexibilityLevel.normal;
      case 'full':
        return FlexibilityLevel.full;
      default:
        return FlexibilityLevel.normal;
    }
  }

  Future<void> _generateItinerary() async {
    if (!_validateForm()) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      // Create trip request from form data
      TripRequest tripRequest = TripRequest(
        selectedStates: selectedStates,
        origin: selectedOriginState!.trim(),
        checkInDate: _checkInDate!,
        checkOutDate: _checkOutDate!,
        numberOfPax: int.parse(selectedPax!),
        maxBudget: double.parse(selectedBudget!),
        tripType: _convertToTripType(selectedActivity),
        flexibility: _convertToFlexibilityLevel(selectedFlex),
      );

      // Generate itinerary
      GeneratedItinerary? itinerary = await _itineraryGenerator.generateItinerary(tripRequest);

      setState(() {
        _isGenerating = false;
      });

      if (itinerary != null && itinerary.days.isNotEmpty) {
        if (itinerary.isWithinBudget) {
          _showSuccessMessage("Itinerary generated successfully! Total cost: RM${itinerary.totalCost.toStringAsFixed(2)}");
          // Navigate to itinerary display page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItineraryDisplayPage(itinerary: itinerary),
            ),
          );
        } else {
          _showErrorMessage("Generated itinerary exceeds budget (RM${itinerary.totalCost.toStringAsFixed(2)}). Try increasing budget or reducing requirements.");
        }
      } else {
        _showErrorMessage("Could not generate itinerary. Try different states, increase budget, or modify your requirements.");
      }

    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      print('Error generating itinerary: $e');
      _showErrorMessage("An error occurred while generating itinerary. Please check your internet connection and try again.");
    }
  }

  Widget _buildStateSelectionGrid(double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      height: screenHeight * 0.19,
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
            "Selected States (Suggest 2 days for each state) :",
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
          // Hot choices banner
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: screenHeight * 0.01),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.026,
              vertical: screenHeight * 0.008,
            ),
            decoration: BoxDecoration(
              color: Colors.yellowAccent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.black,
                  size: screenWidth * 0.04,
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Text(
                    "Kuala Lumpur, Penang and Malacca are popular destinations !! 🔥 ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.029,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

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
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedOriginState,
                dropdownColor: Colors.white,
                hint: Text(
                  'Which state you will arrive at Malaysia?',
                  style: TextStyle(fontSize: screenWidth * 0.036, color: Color(0xFFB1B1B1)),
                ),
                isExpanded: true,
                style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedOriginState = newValue;
                  });
                },
                items: malaysianStates
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
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedPax,
                      dropdownColor: Colors.white,
                      hint: Text(
                        'Number of Pax',
                        style: TextStyle(fontSize: screenWidth * 0.036, color: Color(0xFFB1B1B1)),
                      ),
                      isExpanded: true,
                      style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedPax = newValue;
                        });
                      },
                      items: paxOptions
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
                      value: selectedBudget,
                      dropdownColor: Colors.white,
                      hint: Text(
                        'Budget (MYR) /pax',
                        style: TextStyle(fontSize: screenWidth * 0.036, color: Color(0xFFB1B1B1)),
                      ),
                      isExpanded: true,
                      style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.black),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedBudget = newValue;
                        });
                      },
                      items: budgetOptions
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            "MYR $value",
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

          // Generate Itinerary button (Updated to call _generateItinerary instead of Search)
          Center(
            child: GestureDetector(
              onTap: _isGenerating ? null : _generateItinerary, // Changed from Search(context) to _generateItinerary
              child: Container(
                width: screenWidth * 0.39,
                height: screenHeight * 0.04,
                decoration: ShapeDecoration(
                  gradient: _isGenerating ?
                  LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade300]) :
                  LinearGradient(
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
                  child: _isGenerating ?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.04,
                        height: screenWidth * 0.04,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        'Generating...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.032,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ) :
                  Text(
                    'Generate Itinerary', // Changed from 'Search' to 'Generate Itinerary'
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.032, // Slightly smaller font to fit text
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