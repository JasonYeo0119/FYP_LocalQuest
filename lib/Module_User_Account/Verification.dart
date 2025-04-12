import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localquest/Homepage.dart';
import 'package:localquest/Module_User_Account/Signup.dart';

@override
void toHomepage(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Homepage();
  }));
}

@override
void toSignup(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Signup();
  }));
}

class Verification extends StatefulWidget {
  @override
  _VerificationState createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  int _secondsRemaining = 60; // Start at 60 seconds
  bool _isButtonDisabled = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _isButtonDisabled = true;
      _secondsRemaining = 60;
    });

    _timer?.cancel(); // Ensure any previous timer is canceled
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isButtonDisabled = false;
        });
      }
    });
  }

  void _resendOTP() {
    if (_isButtonDisabled) return;

    // TODO: Implement OTP resend logic here
    print("OTP Resent!");

    _startCountdown(); // Restart the countdown when clicked
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0816A7),
        automaticallyImplyLeading: false,  //Remove if want back button
      ),
      body: SingleChildScrollView( // Prevents overflow issues
        child: Column(
          children: [
            Container(  //background
              width: double.infinity,
              height: 787,
              decoration: BoxDecoration(color: Color(0xFF0816A7)),
              child: Stack(
                children: [
                  Positioned(
                    left: 45,
                    top: 52,
                    child: Text(
                      'LocalQuest',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.irishGrover(
                          fontSize: 64,
                          color:Colors.white,
                          fontWeight: FontWeight.w400
                      ),
                    ),
                  ),
                  Positioned(
                    left: 26,
                    top: 143,
                    child: Text(
                      "A platform that's universally chosen & designed to suit everyone's travel needs",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned( //Yellowsquarebox
                    left: 53,
                    top: 246,
                    child: Container(
                      width: 303,
                      height: 246,
                      decoration: ShapeDecoration(
                        color: Color(0xFF0816A7),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 3, color: Color(0xFFFFFF00)),
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //VerificationContainer
                    left: 127,
                    top: 225,
                    child: Container(
                      width: 163,
                      height: 41,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 153,
                              height: 41,
                              decoration: BoxDecoration(color: Color(0xFF0816A7)),
                            ),
                          ),
                          Positioned(
                            left: 5.24,
                            top: 6,
                            child: SizedBox(
                              width: 143.57,
                              child: Text(
                                'Verification',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 77,
                    top: 272,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'An ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                          TextSpan(
                            text: 'One-Time-Passcode (OTP)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              height: 1.50,
                            ),
                          ),
                          TextSpan(
                            text: ' has been sent\nto your email. Please enter the OTP to\ncomplete the verification process.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 78,
                    top: 339,
                    child: Text(
                      'Enter the OTP:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(  //OTPinput
                    left: 77,
                    top: 360,
                    child: Material(
                      color: Colors.transparent, // Ensures no unwanted background
                      child: Container(
                        width: 251,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5), // Optional rounded corners
                          border: Border.all(color: Colors.black, width: 1),
                        ),// Optional border
                        padding: EdgeInsets.symmetric(horizontal: 8), // Padding for text input
                        alignment: Alignment.center,
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none, // Removes default TextField border
                            isDense: true, // Reduces TextField height to fit container
                            contentPadding: EdgeInsets.zero, // Aligns text properly
                          ),
                          style: TextStyle(fontSize: 14, color: Colors.black),
                          textAlignVertical: TextAlignVertical.center, // Ensures proper vertical alignment
                          keyboardType: TextInputType.number, // Allows only number input
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly, // Restricts input to digits (0-9)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 79,
                    top: 396,
                    child: GestureDetector(
                      onTap: _isButtonDisabled ? null : _resendOTP,
                      child: Text(
                        _isButtonDisabled ? "Resend OTP ($_secondsRemaining s)" : "Resend OTP",
                        style: TextStyle(
                          color: _isButtonDisabled ? Colors.grey : Color(0xFFFFFF00),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Submitbutton
                    left: 157,
                    top: 433,
                    child: GestureDetector(
                      onTap: () {
                        toHomepage(context);
                      },
                      child: Container(
                        width: 96,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFF00),
                          border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 181,
                    top: 438,
                    child: GestureDetector(
                      onTap: () {
                        toHomepage(context);
                      },
                      child: Text(
                        'Submit',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 133,
                    top: 505,
                    child: GestureDetector(
                      onTap: () {
                        toSignup(context);
                      },
                      child: Text(
                        'Back to Previous Page',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
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