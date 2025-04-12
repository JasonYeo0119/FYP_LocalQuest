import 'package:flutter/material.dart';
import 'package:localquest/Admin/DealsNew.dart';

@override
void AddNew(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Dealsnew();
  }));
}

class Managedealsdata extends StatefulWidget {
  @override
  ManagedealsdataState createState() => ManagedealsdataState();
}

class ManagedealsdataState extends State<Managedealsdata> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Deals Data"),
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