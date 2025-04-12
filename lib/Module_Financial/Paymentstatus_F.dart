import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localquest/Homepage.dart';

class PaymentFailed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text(
              "Payment Failed",
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            Text(
              "Something went wrong. Please try again.",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Homepage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text("Continue", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
