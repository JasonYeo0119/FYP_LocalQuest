import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:localquest/Module_User_Account/Updateprofiledetails.dart';


class Profiledetails extends StatefulWidget {
  @override
  _ProfiledetailsState createState() => _ProfiledetailsState();
}

class _ProfiledetailsState extends State<Profiledetails> {

  final user=FirebaseAuth.instance.currentUser;  //Retrieve current logged in user

  bool _obscureText = true;
  String _selectedCountry = "";

  // Form controllers to hold the data
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController number = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController phoneCode = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserDetails(); // Call function to get user name from database
  }

  // 🔹 Fetch User Name from Firebase Realtime Database
  fetchUserDetails() async {
    if (user != null) {
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("Users").child(user!.uid);
      DatabaseEvent event = await userRef.once(); // Get data once

      if (event.snapshot.exists) {
        setState(() {
          name.text = event.snapshot.child("name").value.toString();
          email.text = event.snapshot.child("email").value.toString();
          number.text = event.snapshot.child("phone").value.toString();
          password.text = event.snapshot.child("password").value.toString();
          _selectedCountry = event.snapshot.child("phoneCode").value.toString();
        });
      } else {
          print("User not found in database");
        };
      }
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Account Details"),
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
                  Positioned(
                    left: 30,
                    top: 29,
                    child: Text(
                      'Name:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Irish Grover',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(  //Name
                    left: 30,
                    top: 64,
                    child: Material(
                      color: Colors.transparent, // Ensures no unwanted background
                      child: Container(
                        width: 351,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5), // Optional rounded corners
                          border: Border.all(color: Colors.black, width: 1),
                        ),// Optional border
                        padding: EdgeInsets.symmetric(horizontal: 8), // Padding for text input
                        alignment: Alignment.center,
                        child: TextField(
                          readOnly: true,
                          controller: name,
                          decoration: InputDecoration(
                            border: InputBorder.none, // Removes default TextField border
                            isDense: true, // Reduces TextField height to fit container
                            contentPadding: EdgeInsets.zero, // Aligns text properly
                          ),
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          textAlignVertical: TextAlignVertical.center, // Ensures proper vertical alignment
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 30,
                    top: 120,
                    child: Text(
                      'Password:',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Irish Grover',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(  //Password
                    left: 30,
                    top: 155,
                    child: Material(
                      color: Colors.transparent, // Ensures no unwanted background
                      child: Container(
                        width: 351,
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
                                readOnly: true,
                                controller: password,
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                  border: InputBorder.none, // Removes default TextField border
                                  isDense: true, // Reduces TextField height to fit container
                                  contentPadding: EdgeInsets.zero, // Aligns text properly
                                ),
                                style: TextStyle(fontSize: 16, color: Colors.black),
                                textAlignVertical: TextAlignVertical.center, // Ensures proper vertical alignment
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
                    left: 30,
                    top: 211,
                    child: Text(
                      'Email:',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Irish Grover',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(  //Email
                    left: 30,
                    top: 246,
                    child: Material(
                      color: Colors.transparent, // Ensures no unwanted background
                      child: Container(
                        width: 351,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5), // Optional rounded corners
                          border: Border.all(color: Colors.black, width: 1),
                        ),// Optional border
                        padding: EdgeInsets.symmetric(horizontal: 8), // Padding for text input
                        alignment: Alignment.center,
                        child: TextField(
                          readOnly: true,
                          controller: email,
                          decoration: InputDecoration(
                            border: InputBorder.none, // Removes default TextField border
                            isDense: true, // Reduces TextField height to fit container
                            contentPadding: EdgeInsets.zero, // Aligns text properly
                          ),
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          textAlignVertical: TextAlignVertical.center, // Ensures proper vertical alignment
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 30,
                    top: 302,
                    child: Text(
                      'Phone Number:',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Irish Grover',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(  //CountryCode
                    left: 30,
                    top: 337,
                    child: GestureDetector(
                        child: Container(
                          width: 100,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5), // Optional rounded corners
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8), // Padding for text input
                          alignment: Alignment.center,
                          child: Text(
                            _selectedCountry,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        )
                    ),
                  ),
                  Positioned(  //Numberbar
                    left: 145,
                    top: 337,
                    child: Material(
                      color: Colors.transparent, // Ensures no unwanted background
                      child: Container(
                        width: 235,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5), // Optional rounded corners
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8), // Padding for text input
                        alignment: Alignment.center,
                        child: TextField(
                          readOnly: true,
                          controller: number,
                          keyboardType: TextInputType.number, // Sets numeric keyboard
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allows only numbers
                          decoration: InputDecoration(
                            border: InputBorder.none, // Removes default TextField border
                            isDense: true, // Reduces TextField height to fit container
                            contentPadding: EdgeInsets.zero, // Aligns text properly
                          ),
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          textAlignVertical: TextAlignVertical.center, // Ensures proper vertical alignment
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 160,
                    top: 410,
                    child: MaterialButton(
                      color: Color(0xFF0816A7),
                      textColor: Colors.white,
                      child: Text("Edit"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Updateprofiledetails(),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    name.dispose();
    email.dispose();
    number.dispose();
    password.dispose();
    super.dispose();
  }
}

class CountryPickerDialog extends StatefulWidget {
  final List<Map<String, String>> countries;
  final Function(String) onSelected;

  CountryPickerDialog({required this.countries, required this.onSelected});

  @override
  _CountryPickerDialogState createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<CountryPickerDialog> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredCountries = widget.countries
        .where((country) =>
    country["name"]!.toLowerCase().contains(searchQuery.toLowerCase()) ||
        country["phone"]!.contains(searchQuery))
        .toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        height: 400,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            // Search Bar
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search country name...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 10),

            // Country List
            Expanded(
              child: ListView.builder(
                itemCount: filteredCountries.length,
                itemBuilder: (context, index) {
                  var country = filteredCountries[index];
                  return ListTile(
                    title: Text("${country["name"]} (${country["code"]})"),
                    subtitle: Text("Phone: ${country["phone"]}"),
                    onTap: () {
                      widget.onSelected("${country["code"]} (${country["phone"]})");
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

