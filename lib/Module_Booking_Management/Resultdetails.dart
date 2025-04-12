import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localquest/Module_Financial/Checkout.dart';

@override
void CheckoutBtn(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Checkout();
  }));
}

class Resultdetails extends StatefulWidget {
  @override
  _ResultdetailsState createState() => _ResultdetailsState();
}

class _ResultdetailsState extends State<Resultdetails> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("{ProductName}"),
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
                  Positioned(  //Bottombar
                    left: 0,
                    top: 690,
                    child: Container(
                      width: 420,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color(0xFF0816A7),
                      ),
                    ),
                  ),
                  Positioned(
                      left: 30,
                      top: 722,
                      child: Text(
                        "{Price}",
                        style: TextStyle(
                          color: Colors.white, // Text color
                          fontSize: 22, // Font size
                          fontWeight: FontWeight.bold, // Bold text
                        ),
                      ),
                  ),
                  Positioned(  //BooknowButton
                      left: 240,
                      top: 715,
                      child: GestureDetector(
                        onTap: () {
                          CheckoutBtn(context);
                        },
                      child: Container(
                        width: 150,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2), // Shadow color with opacity
                              blurRadius: 6, // Softness of the shadow
                              spreadRadius: 2, // How much the shadow spreads
                              offset: Offset(3, 3), // Position of the shadow (X, Y)
                            ),
                          ],
                        ),
                          child: Center(
                            child: Text(
                              "Book Now",
                              style: TextStyle(
                                color: Colors.black, // Text color
                                fontSize: 22, // Font size
                                fontWeight: FontWeight.bold, // Bold text
                            ),
                          ),
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
    );
  }
}