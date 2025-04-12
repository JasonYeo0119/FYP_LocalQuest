import 'package:flutter/material.dart';

class Vieworders extends StatefulWidget {
  @override
  ViewordersState createState() => ViewordersState();
}

class ViewordersState extends State<Vieworders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Orders"),
      ),
    );
  }
}