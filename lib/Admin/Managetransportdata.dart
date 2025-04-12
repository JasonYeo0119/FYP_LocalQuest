import 'package:flutter/material.dart';
import 'package:localquest/Admin/TransportNew.dart';

@override
void AddNew(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Transportnew();
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
        title: Text("Manage Transport Data"),
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