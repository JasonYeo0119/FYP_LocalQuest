import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localquest/Module_User_Account/Login.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    // Basic email validation
    if (!emailController.text.contains('@') || !emailController.text.endsWith('.com')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      setState(() {
        isLoading = false;
      });

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Password Reset Email Sent'),
            content: Text(
              'A password reset email has been sent to ${emailController.text.trim()}. '
                  'Please check your email and follow the instructions to reset your password.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });

      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0816A7),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          },
        ),
        title: Text('Reset Password', style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),),
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
                    "A platform that's universally chosen & designed to suit everyone's travel needs",
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
                      height: screenHeight * 0.38,
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
                      height: screenHeight * 0.38,
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Column(
                        children: [
                          // Reset Password Title
                          Container(
                            width: screenWidth * 0.6,
                            height: screenHeight * 0.05,
                            decoration: BoxDecoration(color: Color(0xFF0816A7)),
                            alignment: Alignment.center,
                            child: Text(
                              'Reset Password',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.065,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.01),

                          // Instruction text
                          Text(
                            'Enter your email address to receive a password reset link:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.035,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.01),

                          // Email label and input
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Email:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.037,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.01),

                          // Email input field
                          Material(
                            color: Colors.transparent,
                            child: Container(
                              width: double.infinity,
                              height: screenHeight * 0.04,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.black, width: 1),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                              alignment: Alignment.center,
                              child: TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.black,
                                ),
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.04),

                          // Send Reset Email button
                          GestureDetector(
                            onTap: isLoading ? null : resetPassword,
                            child: Container(
                              width: screenWidth * 0.4,
                              height: screenHeight * 0.05,
                              decoration: ShapeDecoration(
                                color: isLoading ? Colors.grey : Color(0xFFFFFF00),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(width: 1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: isLoading
                                  ? SizedBox(
                                width: screenWidth * 0.05,
                                height: screenWidth * 0.05,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                                  : Text(
                                'Send Reset Email',
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

                          SizedBox(height: screenHeight * 0.025),

                          // Back to Login link
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => Login()),
                              );
                            },
                            child: Text(
                              'Back to Login',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.04,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}