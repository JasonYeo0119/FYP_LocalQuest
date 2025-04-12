import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Dealdetails extends StatefulWidget {
  @override
  _DealdetailsState createState() => _DealdetailsState();
}

class _DealdetailsState extends State<Dealdetails> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Deal Details"),
        backgroundColor: Color(0xFF0816A7),
      ),
      body: SingleChildScrollView( // Prevents overflow issues
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 800,
              decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
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