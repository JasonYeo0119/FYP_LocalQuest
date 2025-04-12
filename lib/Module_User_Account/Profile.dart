import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:localquest/Homepage.dart';
import 'package:localquest/Module_Booking_Management/History.dart';
import 'package:localquest/Module_Booking_Management/Location.dart';
import 'package:localquest/Module_Smart_Development/Chatbotpage.dart';
import 'package:localquest/Module_User_Account/Favourite.dart';
import 'package:localquest/Module_User_Account/Login.dart';
import 'package:flutter/material.dart';
import 'package:localquest/Module_User_Account/Profiledetails.dart';


@override
void Saved(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Favourite();
  }));
}

@override
void Mybookings(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return History();
  }));
}

@override
void Attractionlist(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Location();
  }));
}

@override
void Faq(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Chatbotpage();
  }));
}

@override
void Logout(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Login();
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
void HomeIcon(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Homepage();
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
void ManageProfileDetails(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Profiledetails();
  }));
}

void showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirm Log out"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Logout(context); // Call the logout function
            },
            child: Text("Log out", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}


class _ProfileState extends State<Profile> {

  final user=FirebaseAuth.instance.currentUser;  //Retrieve current logged in user
  String userName = ""; // Placeholder text while fetching data

  @override
  void initState() {
    super.initState();
    fetchUserName(); // Call function to get user name from database
  }

  // 🔹 Fetch User Name from Firebase Realtime Database
  fetchUserName() async {
    if (user != null) {
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("Users").child(user!.uid);
      DatabaseEvent event = await userRef.once(); // Get data once

      if (event.snapshot.exists) {
        setState(() {
          userName = event.snapshot.child("name").value.toString(); // Retrieve name
        });
      } else {
        setState(() {
          userName = "User not found";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Color(0xFF0816A7),
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
                  Positioned(  //Usernamebar
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 500,
                      height: 100,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 20,
                    child: Text('Hello ! $userName',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(  //Manageaccdetailsbar
                    left: 0,
                    top: 100,
                    child: GestureDetector(
                      onTap: () {
                        ManageProfileDetails(context);
                      },
                    child: Container(
                      width: 500,
                      height: 60,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          )
                      ),
                    ),
                  ),
                  ),
                  Positioned(  //Manageaccdetailicon
                    left: 20,
                    top: 112,
                    child: Icon(
                      Icons.settings,
                      color: Colors.black,
                      size: 35,
                    ),
                  ),
                  Positioned(
                    left: 80,
                    top: 120,
                    child: GestureDetector(
                      onTap: () {
                        ManageProfileDetails(context);
                      },
                    child: Text(
                      'Manage account details',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    ),
                  ),
                  Positioned(  //Savedbar
                    left: 0,
                    top: 159,
                    child: GestureDetector(
                      onTap: () {
                        Saved(context);
                      },
                      child: Container(
                        width: 500,
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            )
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Savedicon
                    left: 20,
                    top: 171,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.black,
                      size: 35,
                    ),
                  ),
                  Positioned(
                    left: 80,
                    top: 179,
                    child: GestureDetector(
                      onTap: () {
                        Saved(context);
                      },
                      child: Text(
                        'View saved',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Mytripssbar
                    left: 0,
                    top: 218,
                    child: GestureDetector(
                      onTap: () {
                        Mybookings(context);
                      },
                      child: Container(
                        width: 500,
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            )
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Mytripsicon
                    left: 20,
                    top: 230,
                    child: Icon(
                      Icons.shopping_bag,
                      color: Colors.black,
                      size: 35,
                    ),
                  ),
                  Positioned(
                    left: 80,
                    top: 238,
                    child: GestureDetector(
                      onTap: () {
                        Mybookings(context);
                      },
                      child: Text(
                        'My trips',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Attractionslistbar
                    left: 0,
                    top: 277,
                    child: GestureDetector(
                      onTap: () {
                        Attractionlist(context);
                      },
                      child: Container(
                        width: 500,
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            )
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Attractionslisticon
                    left: 20,
                    top: 289,
                    child: Icon(
                      Icons.park,
                      color: Colors.black,
                      size: 35,
                    ),
                  ),
                  Positioned(
                    left: 80,
                    top: 297,
                    child: GestureDetector(
                      onTap: () {
                        Attractionlist(context);
                      },
                      child: Text(
                        'View attractions list',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //FAQbar
                    left: 0,
                    top: 336,
                    child: GestureDetector(
                      onTap: () {
                        Faq(context);
                      },
                      child: Container(
                        width: 500,
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            )
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //FAQicon
                    left: 20,
                    top: 348,
                    child: Icon(
                      Icons.question_answer,
                      color: Colors.black,
                      size: 35,
                    ),
                  ),
                  Positioned(
                    left: 80,
                    top: 356,
                    child: GestureDetector(
                      onTap: () {
                        Faq(context);
                      },
                      child: Text(
                        'Frequent Asked Questions (FAQ)',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Logoutbutton
                    left: 124,
                    top: 430,
                    child: GestureDetector(
                      onTap: () {
                        showLogoutConfirmation(context);
                      },
                      child: Container(
                        width: 150,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            )
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 177,
                    top: 436,
                    child: GestureDetector(
                      onTap: () {
                        showLogoutConfirmation(context);
                      },
                      child: Text(
                        'Log out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Logout Icon
                    left: 132,
                    top: 435,
                    child: GestureDetector(
                      onTap: () {
                        showLogoutConfirmation(context);
                      },
                      child: Icon(Icons.login_rounded, size: 30),
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
            GestureDetector(
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Homepage()),
                );
              },
              child: Column(  //Home
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home, color: Colors.white),
                  Text("Home", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            GestureDetector(
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              },
              child: Column(  //Profile
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, color: Color(0xFF0816A7)),
                  Text("Profile", style: TextStyle(color: Color(0xFF0816A7))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}