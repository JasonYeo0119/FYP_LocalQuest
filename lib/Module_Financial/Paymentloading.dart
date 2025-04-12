// ignore_for_file: unused_field

import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localquest/Module_Financial/Paymentstatus_S.dart';

class Paymentloading extends StatefulWidget {
  // The next page to navigate to after loading


  @override
  _PaymentloadingState createState() => _PaymentloadingState();
}

class _PaymentloadingState extends State<Paymentloading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();

    // Setup animation for loading indicator
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Timer to navigate after 6 seconds
    Timer(Duration(seconds: 6), () {
      setState(() {
        _isProcessing = false;
      });

      // Navigate to the next page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PaymentSuccess()),
        //MaterialPageRoute(builder: (context) => PaymentFailed()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Remove back button as this is a processing screen
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Card animation that rotates slightly
            RotationTransition(
              turns: _animation,
              child: Container(
                height: 80,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xFF0816A7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.credit_card,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),

            // Loading spinner
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0816A7)),
              strokeWidth: 3,
            ),
            SizedBox(height: 30),

            // Processing text
            Text(
              "Processing Payment",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0816A7),
              ),
            ),
            SizedBox(height: 15),

            // Description
            Text(
              "Please do not close this page",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),

            // Animated dots to indicate processing
            SizedBox(height: 10),
            _buildAnimatedDots(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: Interval(
              index * 0.3,
              0.3 + index * 0.3,
              curve: Curves.easeInOut,
            ),
          ),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: Color(0xFF0816A7),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}