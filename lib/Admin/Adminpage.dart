import 'package:flutter/material.dart';
import 'package:localquest/Admin/Manageattractiondata.dart';
import 'package:localquest/Admin/Managedealsdata.dart';
import 'package:localquest/Admin/Managehoteldata.dart';
import 'package:localquest/Admin/Managetransportdata.dart';
import 'package:localquest/Admin/Vieworders.dart';
import 'package:localquest/Module_User_Account/Login.dart';


class Adminpage extends StatefulWidget {
  @override
  AdminpageState createState() => AdminpageState();
}

class AdminpageState extends State<Adminpage> {
  final List<String> items = [
    "Manage Hotel Data",
    "Manage Transport Data",
    "Manage Attraction Data",
    "Manage Deals Data",
    "View Orders"
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin"), automaticallyImplyLeading: false,),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]),
            leading: Icon(Icons.manage_accounts), // Customizable icon
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to different pages based on index
              switch (index) {
                case 0:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Managehoteldata()));
                  break;
                case 1:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Managetransportdata()));
                  break;
                case 2:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Manageattractiondata()));
                  break;
                case 3:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Managedealsdata()));
                  break;
                case 4:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Vieworders()));
              }
            },
          );
        },
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
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              child: Column(  //Log Out
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.login_rounded, color: Colors.white),
                  Text("Logout", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => History()),
            //     );
            //   },
            //   child: Column(  //Mytrips
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Icon(Icons.shopping_bag, color: Colors.white),
            //       Text("My Trips", style: TextStyle(color: Colors.white)),
            //     ],
            //   ),
            // ),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => Homepage()),
            //     );
            //   },
            //   child: Column(  //Home
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Icon(Icons.home, color: Colors.white),
            //       Text("Home", style: TextStyle(color: Colors.white)),
            //     ],
            //   ),
            // ),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => Location()),
            //     );
            //   },
            //   child: Column(  //Attraction
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Icon(Icons.park, color: Colors.white),
            //       Text("Attractions", style: TextStyle(color: Colors.white)),
            //     ],
            //   ),
            // ),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => Profile()),
            //     );
            //   },
            //   child: Column(  //Profile
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Icon(Icons.person, color: Color(0xFF0816A7)),
            //       Text("Profile", style: TextStyle(color: Color(0xFF0816A7))),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}