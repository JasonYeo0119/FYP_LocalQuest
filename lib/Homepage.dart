import 'package:localquest/Module_Booking_Management/Bookingallinone.dart';
import 'package:localquest/Module_Booking_Management/Bookingattractionmain.dart';
import 'package:localquest/Module_Booking_Management/Bookinghotel.dart';
import 'package:localquest/Module_Booking_Management/Bookingtransportmain.dart';
import 'package:localquest/Module_Booking_Management/Chat.dart';
import 'package:localquest/Module_Booking_Management/History.dart';
import 'package:localquest/Module_Booking_Management/Hotelsearchscreen.dart';
import 'package:localquest/Module_Booking_Management/Location.dart';
import 'package:localquest/Module_Financial/Deals.dart';
import 'package:localquest/Module_Financial/Payment.dart';
import 'package:localquest/Module_User_Account/Favourite.dart';
import 'package:localquest/Module_User_Account/Profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@override
void toStay(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Bookinghotelmain();
  }));
}

@override
void toTransport(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Bookingtransportmain();
  }));
}

@override
void toAttraction(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Bookingattractionmain();
  }));
}

@override
void toAllinone(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Bookingallinone();
  }));
}

@override
void toViewdetails(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return History();
  }));
}

@override
void SpecialDeals(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Deals();
  }));
}

@override
void SavedIcon(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Favourite();
  }));
}

@override
void MytripsIcon(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return History();
  }));
}

@override
void AttractionsIcon(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Location();
  }));
}

@override
void ProfileIcon(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Profile();
  }));
}

@override
void Notification(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return NotificationPage();
  }));
}

// @override
// void Backuppage(BuildContext ctx) {
//   Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
//     return Backup();
//   }));
// }

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "LocalQuest",
          style: GoogleFonts.irishGrover(
              fontSize: 28,
              color:Colors.white,
              fontWeight: FontWeight.w400
          ),
        ),
        backgroundColor: Color(0xFF0816A7),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined), // Change to any icon you want
            onPressed: () {
              Notification(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView( // Prevents overflow issues
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 727,
              decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
              child: Stack(
                children: [
                  Positioned(  //Orange box
                    left: 64,
                    top: 40,
                    child: Opacity(
                      opacity: 0.80,
                      child: Container(
                        width: 128,
                        height: 135,
                        decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(1.00, 0.00),
                            end: Alignment(-1, 0),
                            colors: [Color(0xFFFF4502), Color(0xFFFFFF00)],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Stayicon
                    left: 84,
                    top: 50,
                    child: GestureDetector(
                      onTap: () {
                        toStay(context);
                      },
                      child: Opacity(
                        opacity: 0.8,
                        child: Icon(
                          Icons.hotel_outlined, // Choose an icon
                          color: Color(0xFFF16908),
                          size: 90, // Adjust the size
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 103,
                    top: 140,
                    child: GestureDetector(
                      onTap: () {
                        toStay(context);
                      },
                      child: Text(
                        'Stay',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.irishGrover(
                            fontSize: 20,
                            color:Colors.black,
                            fontWeight: FontWeight.w400
                        ), // Style
                      ),
                    ),
                  ),
                  Positioned(  //Purplebox
                    left: 217,
                    top: 40,
                    child: Opacity(
                      opacity: 0.80,
                      child: Container(
                        width: 128,
                        height: 135,
                        decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(1.00, 0.00),
                            end: Alignment(-1, 0),
                            colors: [Color(0xFF7107F3), Color(0xFFFF02FA)],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Trainicon
                    left: 235,
                    top: 55,
                    child: GestureDetector(
                      onTap: () {
                        toTransport(context);
                      },
                      child: Opacity(
                        opacity: 0.8,
                        child: Icon(
                          Icons.directions_train_outlined, // Choose an icon
                          color: Color(0xFF720ACD),
                          size: 90, // Adjust the size
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 235,
                    top: 140,
                    child: GestureDetector(
                      onTap: () {
                        toTransport(context);
                      },
                      child: Text(
                        'Transport',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.irishGrover(
                            fontSize: 20,
                            color:Colors.black,
                            fontWeight: FontWeight.w400
                        ), // Style
                      ),
                    ),
                  ),
                  Positioned(  //Bluebox
                    left: 64,
                    top: 198,
                    child: Opacity(
                      opacity: 0.80,
                      child: Container(
                        width: 128,
                        height: 135,
                        decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(1.00, 0.00),
                            end: Alignment(-1, 0),
                            colors: [Color(0xFF0C1FF7), Color(0xFF02BFFF)],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Attractionicon
                    left: 82,
                    top: 207,
                    child: GestureDetector(
                      onTap: () {
                        toAttraction(context);
                      },
                      child: Opacity(
                        opacity: 0.8,
                        child: Icon(
                          Icons.park_outlined, // Choose an icon
                          color: Color(0xFF0239FF),
                          size: 90, // Adjust the size
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 77,
                    top: 295,
                    child: GestureDetector(
                      onTap: () {
                        toAttraction(context);
                      },
                      child: Text(
                        'Attractions',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.irishGrover(
                            fontSize: 20,
                            color:Colors.black,
                            fontWeight: FontWeight.w400
                        ), // Style
                      ),
                    ),
                  ),
                  Positioned(  //Greenbox
                    left: 217,
                    top: 198,
                    child: Opacity(
                      opacity: 0.80,
                      child: Container(
                        width: 128,
                        height: 135,
                        decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(1.00, 0.00),
                            end: Alignment(-1, 0),
                            colors: [Color(0xFF02ED64), Color(0xFFFFFA02)],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Allinoneicon
                    left: 235,
                    top: 207,
                    child: GestureDetector(
                      onTap: () {
                        toAllinone(context);
                      },
                      child: Opacity(
                        opacity: 0.8,
                        child: Icon(
                          Icons.dashboard_outlined, // Choose an icon
                          color: Color(0xFF219407),
                          size: 90, // Adjust the size
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 234,
                    top: 295,
                    child: GestureDetector(
                      onTap: () {
                        toAllinone(context);
                      },
                      child: Text(
                        'All-in-One',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.irishGrover(
                            fontSize: 20,
                            color:Colors.black,
                            fontWeight: FontWeight.w400
                        ), // Style
                      ),
                    ),
                  ),
                  Positioned(
                    left: 32,
                    top: 375,
                    child: Text(
                      'Upcoming Trip',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(  //Whitebarshowcomingtrip
                    left: 30,
                    top: 405,
                    child: Container(
                      width: 348,
                      height: 76,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
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
                  Positioned(
                    left: 47,
                    top: 420,
                    child: Text(
                      'Bus [ Penang Sentral - KL Sentral ]',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 47,
                    top: 440,
                    child: Text(
                      'KKKL Express ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 47,
                    top: 460,
                    child: Text(
                      '3 February 2025 - 14:30 - Seat 03',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 219,
                    top: 460,
                    child: Text(
                      'Confirmed',
                      style: TextStyle(
                        color: Color(0xFF0FC106),
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 302,
                    top: 460,
                    child: GestureDetector(
                      onTap: () {
                        toViewdetails(context);
                      },
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          color: Color(0xFF0181F9),
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 280,
                    top: 420,
                    child: Text(
                      '5h 12m',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 265,
                    top: 427,
                    child: Container(
                      width: 13,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 0.50,
                            strokeAlign: BorderSide.strokeAlignCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 317,
                    top: 427,
                    child: Container(
                      width: 13,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 0.50,
                            strokeAlign: BorderSide.strokeAlignCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 32,
                    top: 520,
                    child: GestureDetector(
                      onTap: () {
                        SpecialDeals(context);
                      },
                    child: Text(
                      'Special Deals',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  ),
                  Positioned(  //Deals image
                    left: 31,
                    top: 550,
                    child: Container(
                      width: 188,
                      height: 134,
                      decoration: ShapeDecoration(
                        image: DecorationImage(
                          image: AssetImage('lib/Image/special deals 1.jpg'),
                          fit: BoxFit.fill,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(color: Colors.black, width: 0.5), // Top border
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(  // Wrap in GestureDetector for navigation
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Favourite()),
                );
              },
              child: Column(  //Saved
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite, color: Colors.white),
                  Text("Saved", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            GestureDetector(  // Wrap in GestureDetector for navigation
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => History()),
                );
              },
              child: Column(  //Mytrips
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag, color: Colors.white),
                  Text("My Trips", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            GestureDetector(  // Wrap in GestureDetector for navigation
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Payment()), //Backup
                );
              },
            child: Column(  //Home
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home, color: Color(0xFF0816A7)),
                Text("Home", style: TextStyle(color: Color(0xFF0816A7))),
              ],
            ),
            ),
            GestureDetector(  // Wrap in GestureDetector for navigation
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Location()),
                );
              },
              child: Column(  //Attraction
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.park, color: Colors.white),
                  Text("Attractions", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            GestureDetector(  // Wrap in GestureDetector for navigation
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              },
              child: Column(  //Profile
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, color: Colors.white),
                  Text("Profile", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
