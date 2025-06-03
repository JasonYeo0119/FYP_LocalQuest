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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0816A7),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
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
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
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
                  Positioned( // Yellow square box
                    left: 53,
                    top: 246,
                    child: Container(
                      width: 303,
                      height: 350,
                      decoration: ShapeDecoration(
                        color: Color(0xFF0816A7),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 3, color: Color(0xFFFFFF00)),
                        ),
                      ),
                    ),
                  ),
                  Positioned( // Verification Container
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
                                'Email Verification',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
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
                    top: 280,
                    child: Container(
                      width: 250,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'A verification email has been sent to:\n',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                              ),
                            ),
                            TextSpan(
                              text: '${user?.email ?? "your email"}\n\n',
                              style: TextStyle(
                                color: Color(0xFFFFFF00),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                height: 1.50,
                              ),
                            ),
                            TextSpan(
                              text: 'Please check your email and click on the verification link to continue. This page will automatically redirect once your email is verified.',
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
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // Email verification status indicator
                  Positioned(
                    left: 160,
                    top: 380,
                    child: Container(
                      width: 100,
                      height: 100,
                      child: isEmailVerified
                          ? Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 60,
                      )
                          : SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFFF00),
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 79,
                    top: 490,
                    child: GestureDetector(
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
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  Positioned( // Check Status button
                    left: 140,
                    top: 520,
                    child: GestureDetector(
                      onTap: checkEmailVerified,
                      child: Container(
                        width: 130,
                        height: 35,
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
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 133,
                    top: 570,
                    child: GestureDetector(
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