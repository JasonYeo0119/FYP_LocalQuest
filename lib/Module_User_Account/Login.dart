import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localquest/Admin/Adminpage.dart';
import 'package:localquest/Homepage.dart';
import 'package:localquest/Module_User_Account/Signup.dart';
import 'package:localquest/Module_User_Account/ResetPassword.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obscureText = true;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  void toSignup(BuildContext ctx) {
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return Signup();
    }));
  }

  void toHomepage(BuildContext ctx) {
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return Homepage();
    }));
  }

  void toResetPassword(BuildContext ctx) {
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return ResetPassword();
    }));
  }

  signIn() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );

      // Check if the user is authenticated
      if (userCredential.user != null) {
        // Check if admin credentials
        if (email.text == "admin123@gmail.com" && password.text == "admin123") {
          // Navigate to AdminPage for admin credentials
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Adminpage()),
          );
        } else {
          // Check if email is verified for regular users
          if (!userCredential.user!.emailVerified) {
            // Sign out the user if email is not verified
            await FirebaseAuth.instance.signOut();

            // Show dialog asking user to verify email
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Email Not Verified'),
                  content: Text(
                    'Please verify your email address before logging in. '
                        'Check your email for the verification link.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        // Resend verification email
                        try {
                          UserCredential tempUser = await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: email.text,
                            password: password.text,
                          );
                          await tempUser.user!.sendEmailVerification();
                          await FirebaseAuth.instance.signOut();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Verification email sent. Please check your email.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error sending verification email: ${e.toString()}')),
                          );
                        }
                      },
                      child: Text('Resend Verification'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          } else {
            // Email is verified, navigate to Homepage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Homepage()),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        default:
          errorMessage = 'Login failed. Please check your credentials and try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: Please ensure your email and password are correct.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate responsive dimensions based on original design (411x787)
    final designWidth = 411.0;
    final designHeight = 787.0;

    // Scale factors
    final widthScale = screenWidth / designWidth;
    final heightScale = screenHeight / designHeight;

    // Use minimum scale to maintain aspect ratio
    final scale = widthScale < heightScale ? widthScale : heightScale;

    // Responsive helper function
    double responsive(double value) => value * scale;
    double responsiveWidth(double value) => value * widthScale;
    double responsiveHeight(double value) => value * heightScale;

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
              height: screenHeight - AppBar().preferredSize.height - MediaQuery.of(context).padding.top,
              decoration: BoxDecoration(color: Color(0xFF0816A7)),
              child: Stack(
                children: [
                  Positioned(  //Yellowsquarebox
                    left: responsiveWidth(53),
                    top: responsiveHeight(246),
                    child: Container(
                      width: responsiveWidth(303),
                      height: responsiveHeight(236),
                      decoration: ShapeDecoration(
                        color: Color(0xFF0816A7),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 3, color: Color(0xFFFFFF00)),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: responsiveWidth(45),
                    top: responsiveHeight(52),
                    child: Text(
                      'LocalQuest',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.irishGrover(
                          fontSize: responsive(64),
                          color:Colors.white,
                          fontWeight: FontWeight.w400
                      ),
                    ),
                  ),
                  Positioned(
                    left: responsiveWidth(26),
                    top: responsiveHeight(143),
                    child: Container(
                      width: responsiveWidth(359), // Constrain width for better text wrapping
                      child: Text(
                        "A platform that's universally chosen & designed to suit everyone's travel needs",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: responsive(10),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Logincontainer
                    left: responsiveWidth(144),
                    top: responsiveHeight(225),
                    child: Container(
                      width: responsiveWidth(120),
                      height: responsiveHeight(41),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: responsiveWidth(120),
                              height: responsiveHeight(41),
                              decoration: BoxDecoration(color: Color(0xFF0816A7)),
                            ),
                          ),
                          Positioned(
                            left: responsiveWidth(27),
                            top: responsiveHeight(3),
                            child: Text(
                              'Login',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: responsive(26),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: responsiveWidth(79),
                    top: responsiveHeight(283),
                    child: Text(
                      'Email:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive(15),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(  //Emailinput
                    left: responsiveWidth(79),
                    top: responsiveHeight(306),
                    child: Material(
                      color: Colors.transparent, // Ensures no unwanted background
                      child: Container(
                        width: responsiveWidth(251),
                        height: responsiveHeight(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5), // Optional rounded corners
                          border: Border.all(color: Colors.black, width: 1),
                        ),// Optional border
                        padding: EdgeInsets.symmetric(horizontal: responsive(8)), // Padding for text input
                        alignment: Alignment.center,
                        child: TextField(
                          controller: email,
                          decoration: InputDecoration(
                            border: InputBorder.none, // Removes default TextField border
                            isDense: true, // Reduces TextField height to fit container
                            contentPadding: EdgeInsets.zero, // Aligns text properly
                          ),
                          style: TextStyle(fontSize: responsive(14), color: Colors.black),
                          textAlignVertical: TextAlignVertical.center, // Ensures proper vertical alignment
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: responsiveWidth(79),
                    top: responsiveHeight(348),
                    child: Text(
                      'Password:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive(15),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(  //Passwordinput
                    left: responsiveWidth(79),
                    top: responsiveHeight(371),
                    child: Material(
                      color: Colors.transparent, // Ensures no unwanted background
                      child: Container(
                        width: responsiveWidth(251),
                        height: responsiveHeight(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5), // Optional rounded corners
                          border: Border.all(color: Colors.black, width: 1),
                        ),// Optional border
                        padding: EdgeInsets.symmetric(horizontal: responsive(8)), // Padding for text input
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: password,
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: TextStyle(fontSize: responsive(14), color: Colors.black),
                                textAlignVertical: TextAlignVertical.center,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              child: Icon(
                                _obscureText ? Icons.visibility_off : Icons.visibility,
                                size: responsive(18),
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: responsiveWidth(79),
                    top: responsiveHeight(405),
                    child: GestureDetector(
                      onTap: () {
                        toResetPassword(context);
                      },
                      child: Text(
                        'Forgot Password?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFFFFF00),
                          fontSize: responsive(12),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Loginbutton
                    left: responsiveWidth(157),
                    top: responsiveHeight(430),
                    child: GestureDetector(
                      onTap: () {
                        signIn();
                      },
                      child: Container(
                        width: responsiveWidth(96),
                        height: responsiveHeight(30),
                        decoration: ShapeDecoration(
                          color: Color(0xFFFFFF00),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: responsiveWidth(186),
                    top: responsiveHeight(435),
                    child: GestureDetector(
                      onTap: () {
                        signIn();
                      },
                      child: Text(
                        'Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: responsive(14),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: responsiveWidth(107),
                    top: responsiveHeight(499),
                    child: Container(
                      width: responsiveWidth(197), // Constrain width for better text layout
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Don't have an account?",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: responsive(14),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                                text: '\nSign up now',
                                style: TextStyle(
                                  color: Color(0xFFFFE900),
                                  fontSize: responsive(14),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    toSignup(context);
                                  }
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
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