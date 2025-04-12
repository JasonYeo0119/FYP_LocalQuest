import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localquest/Module_Financial/Paymentloading.dart';

@override
void Proceed(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Paymentloading();  //To payment loading
  }));
}

class Payment extends StatefulWidget {
  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();

  late Timer _timer;
  int _remainingSeconds = 600; // 10 minutes (600 seconds)

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel(); // Stop the timer when it reaches 0
        showTimeoutDialog(); // Show alert when time runs out
      }
    });
  }

  void showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents user from dismissing dialog
      builder: (context) {
        return AlertDialog(
          title: Text('Payment Timeout'),
          content: Text('Your payment session has expired. Please go back and try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous page
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel(); // Ensure timer is canceled when page is closed
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment"),
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
                  Positioned( //Timerbar
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 412,
                      height: 44,
                      decoration: BoxDecoration(color: Color(0xFFFFD60D)),
                    ),
                  ),
                  Positioned(
                    left: 37,
                    top: 11,
                    child: Text(
                      'Please complete your payment within ${formatTime(_remainingSeconds)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Irish Grover',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 70,
                    child: Text(
                      'Card Number : ',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Irish Grover',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(  //Cardinput
                    left: 20,
                    top: 100,
                    child: Material(
                      color: Colors.transparent, // No unwanted background
                      child: Container(
                        width: 375,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5), // Optional rounded corners
                          border: Border.all(color: Colors.black, width: 1), // Border styling
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8), // Padding for text input
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _controller2,
                          keyboardType: TextInputType.number, // Numeric keyboard
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly, // Only allows numbers
                            LengthLimitingTextInputFormatter(16), // Limits input to 16 digits
                          ],
                          decoration: InputDecoration(
                            border: InputBorder.none, // Removes default TextField border
                            isDense: true, // Reduces TextField height to fit container
                            contentPadding: EdgeInsets.zero, // Aligns text properly
                            hintText: 'Enter card number',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          textAlignVertical: TextAlignVertical.center, // Ensures proper vertical alignment
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 160,
                    child: Text(
                      'Date of Expiry : ',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Irish Grover',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(  //DOE
                    left: 20,
                    top: 190,
                    child: Material(
                      color: Colors.transparent, // No unwanted background
                      child: Container(
                        width: 100, // Adjust size as needed
                        height: 35, // Height to match the provided image
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5), // Optional rounded corners
                          border: Border.all(color: Colors.black, width: 1), // Border styling
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8), // Padding for text input
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            ExpiryDateFormatter(),
                          ],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Irish Grover',
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none, // Removes default TextField border
                            isCollapsed: true, // Reduces TextField height to fit container
                            contentPadding: EdgeInsets.zero, // Aligns text properly
                            hintText: 'MM/YY',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 220,
                    top: 160,
                    child: Text(
                      'CVV : ',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Irish Grover',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(  //DOE
                    left: 220,
                    top: 190,
                    child: Material(
                      color: Colors.transparent, // Ensures no unwanted background
                      child: Container(
                        width: 100,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5), // Optional rounded corners
                          border: Border.all(color: Colors.black, width: 1),
                        ),// Optional border
                        padding: EdgeInsets.symmetric(horizontal: 8), // Padding for text input
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _controller3,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Irish Grover',
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none, // Removes default TextField border
                            isCollapsed: true, // Reduces TextField height to fit container
                            contentPadding: EdgeInsets.zero, // Aligns text properly
                            hintText: 'CVV',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 250,
                    child: Text(
                      'Name on Card : ',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Irish Grover',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(  //Nameinput
                    left: 20,
                    top: 280,
                    child: Material(
                      color: Colors.transparent, // Ensures no unwanted background
                      child: Container(
                        width: 375,
                        height: 35,
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
                            hintText: 'Enter name on card',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          textAlignVertical: TextAlignVertical.center, // Ensures proper vertical alignment
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Bottom Bar
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
                  Positioned(  //Confirm Button
                    left: 240,
                    top: 715,
                    child: GestureDetector(
                      onTap: () {
                        Proceed(context);
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
                            "Proceed",
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
/// Custom input formatter to format text as MM/YY
class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll('/', ''); // Remove existing slashes
    if (text.length > 2) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}