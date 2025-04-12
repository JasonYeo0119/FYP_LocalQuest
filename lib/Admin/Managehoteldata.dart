import 'package:flutter/material.dart';
import 'package:localquest/Admin/HotelNew.dart';

@override
void AddNew(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Hotelnew();
  }));
}

class Managehoteldata extends StatefulWidget {
  @override
  ManagehoteldataState createState() => ManagehoteldataState();
}

class ManagehoteldataState extends State<Managehoteldata> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Hotel Data"),
        actions: [
          IconButton(
            icon: Icon(Icons.add), // Change to any icon you want
            onPressed: () {
              AddNew(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 770,
              decoration: BoxDecoration(color: Colors.transparent),
              child: Stack(
                children: [
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}