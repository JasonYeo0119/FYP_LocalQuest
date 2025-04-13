import 'package:flutter/material.dart';
import 'package:localquest/Admin/Adminpage.dart';
import 'package:localquest/Admin/TransportNew.dart';

@override
void AddNew(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Transportnew();
  }));
}

void Home(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Adminpage();
  }));
}

class Managetransportdata extends StatefulWidget {
  @override
  ManagetransportdataState createState() => ManagetransportdataState();
}

class ManagetransportdataState extends State<Managetransportdata> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transport Data"),
        actions: [
          IconButton(
            icon: Icon(Icons.home_filled),
            onPressed: () {
              Home(context);
            },
          ),
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