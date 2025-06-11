import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localquest/Homepage.dart';
import 'package:localquest/Module_User_Account/Login.dart';

@override
void toHomepage(BuildContext ctx) {
  Navigator.of(ctx).pushReplacement(MaterialPageRoute(builder: (_) {
    return Homepage();
  }));
}

@override
void toLogin(BuildContext ctx) {
  Navigator.of(ctx).pushReplacement(MaterialPageRoute(builder: (_) {
    return Login();
  }));
}

class Verification extends StatefulWidget {
  @override
  _VerificationState createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;
  int resendTimer = 60;

  @override
  void initState() {
    super.initState();

    // Check if user is logged in
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // If no user is logged in, go back to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      });
      return;
    }

    // Check if email is already verified
    isEmailVerified = user.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      // Start the resend timer
      startResendTimer();

      // Check email verification status every 3 seconds
      timer = Timer.periodic(
        Duration(seconds: 3),
            (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startResendTimer() {
    setState(() {
      canResendEmail = false;
      resendTimer = 60;
    });

    Timer.periodic(Duration(seconds: 1), (timer) {
      if (resendTimer > 0) {
        setState(() {
          resendTimer--;
        });
      } else {
        setState(() {
          canResendEmail = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Reload user to get latest verification status
    await user.reload();

    setState(() {
      isEmailVerified = user.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();

      // Update verification status in database
      await FirebaseDatabase.instance
          .ref()
          .child('Users')
          .child(user.uid)
          .update({'emailVerified': true});

      // Show success message and navigate to homepage
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Email verified successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
      );
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification email sent to ${user.email}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending verification email: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0816A7),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        height: screenHeight,
        decoration: BoxDecoration(color: Color(0xFF0816A7)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.06),

                // LocalQuest Title
                Text(
                  'LocalQuest',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.irishGrover(
                    fontSize: screenWidth * 0.15,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // Subtitle
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                  child: Text(
                    "A platform that's universally chosen & designed to suit everyone's\ntravel needs",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.025,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.08),

                // Main Content Container
                Stack(
                  children: [
                    // Yellow border container
                    Container(
                      width: screenWidth * 0.8,
                      height: screenHeight * 0.45,
                      decoration: ShapeDecoration(
                        color: Color(0xFF0816A7),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 3, color: Color(0xFFFFFF00)),
                        ),
                      ),
                    ),

                    // Content inside the container
                    Container(
                      width: screenWidth * 0.8,
                      height: screenHeight * 0.45,
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Column(
                        children: [
                          // Email Verification Title
                          Container(
                            width: screenWidth * 0.4,
                            height: screenHeight * 0.05,
                            decoration: BoxDecoration(color: Color(0xFF0816A7)),
                            alignment: Alignment.center,
                            child: Text(
                              'Email Verification',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.05,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          // Email verification message
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'A verification email has been sent to:\n',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.03,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                  ),
                                ),
                                TextSpan(
                                  text: '${user?.email ?? "your email"}\n\n',
                                  style: TextStyle(
                                    color: Color(0xFFFFFF00),
                                    fontSize: screenWidth * 0.03,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    height: 1.50,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Please check your email and click on the verification link to continue. This page will automatically redirect once your email is verified.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.03,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          // Email verification status indicator
                          Container(
                            height: screenHeight * 0.08,
                            child: isEmailVerified
                                ? Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: screenWidth * 0.15,
                            )
                                : SizedBox(
                              width: screenWidth * 0.15,
                              height: screenWidth * 0.15,
                              child: CircularProgressIndicator(
                                color: Color(0xFFFFFF00),
                                strokeWidth: 3,
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Resend email link
                          GestureDetector(
                            onTap: canResendEmail ? () {
                              sendVerificationEmail();
                              startResendTimer();
                            } : null,
                            child: Text(
                              canResendEmail
                                  ? "Resend Verification Email"
                                  : "Resend Email (${resendTimer}s)",
                              style: TextStyle(
                                color: canResendEmail ? Color(0xFFFFFF00) : Colors.grey,
                                fontSize: screenWidth * 0.03,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Check Status button
                          GestureDetector(
                            onTap: checkEmailVerified,
                            child: Container(
                              width: screenWidth * 0.35,
                              height: screenHeight * 0.045,
                              decoration: BoxDecoration(
                                color: Color(0xFFFFFF00),
                                border: Border.all(width: 1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Check Status',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenWidth * 0.035,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.03),

                // Back to Login
                GestureDetector(
                  onTap: () async {
                    // Sign out the user and go back to login
                    await FirebaseAuth.instance.signOut();
                    toLogin(context);
                  },
                  child: Text(
                    'Back to Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.035,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}