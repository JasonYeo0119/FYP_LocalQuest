import 'package:flutter/material.dart';
import 'package:localquest/Admin/Manageattractiondata.dart';
import 'package:localquest/Admin/Managedealsdata.dart';
import 'package:localquest/Admin/Managetransportdata.dart';
import 'package:localquest/Admin/Viewbugreport.dart';
import 'package:localquest/Admin/Vieworders.dart';
import 'package:localquest/Module_User_Account/Login.dart';

class Adminpage extends StatefulWidget {
  @override
  AdminpageState createState() => AdminpageState();
}

class AdminpageState extends State<Adminpage> {
  final List<Map<String, dynamic>> items = [
    {
      "title": "Hotel Data",
      "icon": Icons.hotel,
      "color": Colors.blue,
    },
    {
      "title": "Transport Data",
      "icon": Icons.directions_bus,
      "color": Colors.green,
    },
    {
      "title": "Attraction Data",
      "icon": Icons.place,
      "color": Colors.orange,
    },
    {
      "title": "Deals Data",
      "icon": Icons.local_offer,
      "color": Colors.purple,
    },
    {
      "title": "All Bookings",
      "icon": Icons.shopping_cart,
      "color": Colors.teal,
    },
    {
      "title": "Bug Reports", // New item
      "icon": Icons.bug_report,
      "color": Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Admin Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Management Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),

            // Grid of Admin Options
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        // Navigate to different pages based on index
                        switch (index) {
                          case 0:
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Adminpage()));
                            break;
                          case 1:
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ManageTransportData()));
                            break;
                          case 2:
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Manageattractiondata()));
                            break;
                          case 3:
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Managedealsdata()));
                            break;
                          case 4:
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Vieworders()));
                            break;
                          case 5: // New case for bug reports
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ViewBugReports()));
                            break;
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: item['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                item['icon'],
                                size: 32,
                                color: item['color'],
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              item['title'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
            top: BorderSide(color: Colors.black, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.login_rounded, color: Colors.white),
                  Text("Logout", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}