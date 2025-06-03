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
              Positioned(  //Yellowsquarebox
                left: 53,
                top: 246,
                child: Container(
                  width: 303,
                  height: 236,
                  decoration: ShapeDecoration(
                    color: Color(0xFF0816A7),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 3, color: Color(0xFFFFFF00)),
                    ),
                  ),
                ),
              ),
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
          Positioned(  //Logincontainer
            left: 144,
            top: 225,
            child: Container(
              width: 120,
              height: 41,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 120,
                      height: 41,
                      decoration: BoxDecoration(color: Color(0xFF0816A7)),
                    ),
                  ),
                  Positioned(
                    left: 27,
                    top: 3,
                    child: Text(
                      'Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
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
            left: 79,
            top: 283,
            child: Text(
              'Email:',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Positioned(  //Emailinput
            left: 79,
            top: 306,
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
                  controller: email,
                  decoration: InputDecoration(
                    border: InputBorder.none, // Removes default TextField border
                    isDense: true, // Reduces TextField height to fit container
                    contentPadding: EdgeInsets.zero, // Aligns text properly
                  ),
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  textAlignVertical: TextAlignVertical.center, // Ensures proper vertical alignment
                ),
              ),
            ),
          ),
          Positioned(
            left: 79,
            top: 348,
            child: Text(
              'Password:',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Positioned(  //Passwordinput
            left: 79,
            top: 371,
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
                        style: TextStyle(fontSize: 14, color: Colors.black),
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
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 79,
            top: 405,
            child: GestureDetector(
              onTap: () {
                toResetPassword(context);
              },
              child: Text(
                'Forgot Password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFFF00),
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          Positioned(  //Loginbutton
            left: 157,
            top: 430,
            child: GestureDetector(
              onTap: () {
                signIn();
              },
              child: Container(
                width: 96,
                height: 30,
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
            left: 186,
            top: 435,
            child: GestureDetector(
              onTap: () {
                signIn();
              },
              child: Text(
                'Login',
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
            left: 107,
            top: 499,
            child: Text.rich(
              TextSpan(
                children: [
              TextSpan(
              text: "Don't have an account? ",
              style: TextStyle(
              color: Colors.white,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
                text: 'Sign up now',
                style: TextStyle(
                  color: Color(0xFFFFE900),
                  fontSize: 12,
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
            ],
          ),
          ),
          ],
        ),
      ),
    );
  }
}