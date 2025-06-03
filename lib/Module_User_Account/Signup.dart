import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localquest/Homepage.dart';
import 'package:localquest/Module_User_Account/Login.dart';
import 'package:localquest/Module_User_Account/Verification.dart';

@override
void toVerification(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Verification();
  }));
}

@override
void toHomepage(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Homepage();
  }));
}

class Signup extends StatefulWidget {
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final name = TextEditingController();
  final email = TextEditingController();
  final number = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  late DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('Users');

  bool _obscureText = true;
  bool _obscureText2 = true;
  String _selectedCountry = "MY (+60)"; // Default selection
  final List<Map<String, String>> _countries = [
    {"name": "Malaysia", "code": "MY", "phone": "+60"},
    {"name": "Afghanistan", "code": "AF", "phone": "+93"},
    {"name": "Albania", "code": "AL", "phone": "+355"},
    {"name": "Algeria", "code": "DZ", "phone": "+213"},
    {"name": "Andorra", "code": "AD", "phone": "+376"},
    {"name": "Angola", "code": "AO", "phone": "+244"},
    {"name": "Antigua and Barbuda", "code": "AG", "phone": "+1-268"},
    {"name": "Argentina", "code": "AR", "phone": "+54"},
    {"name": "Armenia", "code": "AM", "phone": "+374"},
    {"name": "Australia", "code": "AU", "phone": "+61"},
    {"name": "Austria", "code": "AT", "phone": "+43"},
    {"name": "Azerbaijan", "code": "AZ", "phone": "+994"},
    {"name": "Bahamas", "code": "BS", "phone": "+1-242"},
    {"name": "Bahrain", "code": "BH", "phone": "+973"},
    {"name": "Bangladesh", "code": "BD", "phone": "+880"},
    {"name": "Barbados", "code": "BB", "phone": "+1-246"},
    {"name": "Belarus", "code": "BY", "phone": "+375"},
    {"name": "Belgium", "code": "BE", "phone": "+32"},
    {"name": "Belize", "code": "BZ", "phone": "+501"},
    {"name": "Benin", "code": "BJ", "phone": "+229"},
    {"name": "Bhutan", "code": "BT", "phone": "+975"},
    {"name": "Bolivia", "code": "BO", "phone": "+591"},
    {"name": "Bosnia and Herzegovina", "code": "BA", "phone": "+387"},
    {"name": "Botswana", "code": "BW", "phone": "+267"},
    {"name": "Brazil", "code": "BR", "phone": "+55"},
    {"name": "Brunei", "code": "BN", "phone": "+673"},
    {"name": "Bulgaria", "code": "BG", "phone": "+359"},
    {"name": "Burkina Faso", "code": "BF", "phone": "+226"},
    {"name": "Burundi", "code": "BI", "phone": "+257"},
    {"name": "Cabo Verde", "code": "CV", "phone": "+238"},
    {"name": "Cambodia", "code": "KH", "phone": "+855"},
    {"name": "Cameroon", "code": "CM", "phone": "+237"},
    {"name": "Canada", "code": "CA", "phone": "+1"},
    {"name": "Central African Republic", "code": "CF", "phone": "+236"},
    {"name": "Chad", "code": "TD", "phone": "+235"},
    {"name": "Chile", "code": "CL", "phone": "+56"},
    {"name": "China", "code": "CN", "phone": "+86"},
    {"name": "Colombia", "code": "CO", "phone": "+57"},
    {"name": "Comoros", "code": "KM", "phone": "+269"},
    {"name": "Congo (Congo-Brazzaville)", "code": "CG", "phone": "+242"},
    {"name": "Costa Rica", "code": "CR", "phone": "+506"},
    {"name": "Croatia", "code": "HR", "phone": "+385"},
    {"name": "Cuba", "code": "CU", "phone": "+53"},
    {"name": "Cyprus", "code": "CY", "phone": "+357"},
    {"name": "Czech Republic", "code": "CZ", "phone": "+420"},
    {"name": "Denmark", "code": "DK", "phone": "+45"},
    {"name": "Djibouti", "code": "DJ", "phone": "+253"},
    {"name": "Dominica", "code": "DM", "phone": "+1-767"},
    {"name": "Dominican Republic", "code": "DO", "phone": "+1-809"},
    {"name": "DR Congo (Congo-Kinshasa)", "code": "CD", "phone": "+243"},
    {"name": "Ecuador", "code": "EC", "phone": "+593"},
    {"name": "Egypt", "code": "EG", "phone": "+20"},
    {"name": "El Salvador", "code": "SV", "phone": "+503"},
    {"name": "Equatorial Guinea", "code": "GQ", "phone": "+240"},
    {"name": "Eritrea", "code": "ER", "phone": "+291"},
    {"name": "Estonia", "code": "EE", "phone": "+372"},
    {"name": "Eswatini", "code": "SZ", "phone": "+268"},
    {"name": "Ethiopia", "code": "ET", "phone": "+251"},
    {"name": "Fiji", "code": "FJ", "phone": "+679"},
    {"name": "Finland", "code": "FI", "phone": "+358"},
    {"name": "France", "code": "FR", "phone": "+33"},
    {"name": "Gabon", "code": "GA", "phone": "+241"},
    {"name": "Gambia", "code": "GM", "phone": "+220"},
    {"name": "Georgia", "code": "GE", "phone": "+995"},
    {"name": "Germany", "code": "DE", "phone": "+49"},
    {"name": "Ghana", "code": "GH", "phone": "+233"},
    {"name": "Greece", "code": "GR", "phone": "+30"},
    {"name": "Grenada", "code": "GD", "phone": "+1-473"},
    {"name": "Guatemala", "code": "GT", "phone": "+502"},
    {"name": "Guinea", "code": "GN", "phone": "+224"},
    {"name": "Guinea-Bissau", "code": "GW", "phone": "+245"},
    {"name": "Guyana", "code": "GY", "phone": "+592"},
    {"name": "Haiti", "code": "HT", "phone": "+509"},
    {"name": "Honduras", "code": "HN", "phone": "+504"},
    {"name": "Hungary", "code": "HU", "phone": "+36"},
    {"name": "Iceland", "code": "IS", "phone": "+354"},
    {"name": "India", "code": "IN", "phone": "+91"},
    {"name": "Indonesia", "code": "ID", "phone": "+62"},
    {"name": "Iran", "code": "IR", "phone": "+98"},
    {"name": "Iraq", "code": "IQ", "phone": "+964"},
    {"name": "Ireland", "code": "IE", "phone": "+353"},
    {"name": "Israel", "code": "IL", "phone": "+972"},
    {"name": "Italy", "code": "IT", "phone": "+39"},
    {"name": "Jamaica", "code": "JM", "phone": "+1-876"},
    {"name": "Japan", "code": "JP", "phone": "+81"},
    {"name": "Jordan", "code": "JO", "phone": "+962"},
    {"name": "Kazakhstan", "code": "KZ", "phone": "+7"},
    {"name": "Kenya", "code": "KE", "phone": "+254"},
    {"name": "Kiribati", "code": "KI", "phone": "+686"},
    {"name": "Korea, North", "code": "KP", "phone": "+850"},
    {"name": "Korea, South", "code": "KR", "phone": "+82"},
    {"name": "Kosovo", "code": "XK", "phone": "+383"},
    {"name": "Kuwait", "code": "KW", "phone": "+965"},
    {"name": "Kyrgyzstan", "code": "KG", "phone": "+996"},
    {"name": "Laos", "code": "LA", "phone": "+856"},
    {"name": "Latvia", "code": "LV", "phone": "+371"},
    {"name": "Lebanon", "code": "LB", "phone": "+961"},
    {"name": "Lesotho", "code": "LS", "phone": "+266"},
    {"name": "Liberia", "code": "LR", "phone": "+231"},
    {"name": "Libya", "code": "LY", "phone": "+218"},
    {"name": "Liechtenstein", "code": "LI", "phone": "+423"},
    {"name": "Lithuania", "code": "LT", "phone": "+370"},
    {"name": "Luxembourg", "code": "LU", "phone": "+352"},
    {"name": "Madagascar", "code": "MG", "phone": "+261"},
    {"name": "Malawi", "code": "MW", "phone": "+265"},
    {"name": "Maldives", "code": "MV", "phone": "+960"},
    {"name": "Mali", "code": "ML", "phone": "+223"},
    {"name": "Malta", "code": "MT", "phone": "+356"},
    {"name": "Marshall Islands", "code": "MH", "phone": "+692"},
    {"name": "Mauritania", "code": "MR", "phone": "+222"},
    {"name": "Mauritius", "code": "MU", "phone": "+230"},
    {"name": "Mexico", "code": "MX", "phone": "+52"},
    {"name": "Micronesia", "code": "FM", "phone": "+691"},
    {"name": "Moldova", "code": "MD", "phone": "+373"},
    {"name": "Monaco", "code": "MC", "phone": "+377"},
    {"name": "Mongolia", "code": "MN", "phone": "+976"},
    {"name": "Montenegro", "code": "ME", "phone": "+382"},
    {"name": "Morocco", "code": "MA", "phone": "+212"},
    {"name": "Mozambique", "code": "MZ", "phone": "+258"},
    {"name": "Myanmar (Burma)", "code": "MM", "phone": "+95"},
    {"name": "Namibia", "code": "NA", "phone": "+264"},
    {"name": "Nauru", "code": "NR", "phone": "+674"},
    {"name": "Nepal", "code": "NP", "phone": "+977"},
    {"name": "Netherlands", "code": "NL", "phone": "+31"},
    {"name": "New Zealand", "code": "NZ", "phone": "+64"},
    {"name": "Nicaragua", "code": "NI", "phone": "+505"},
    {"name": "Niger", "code": "NE", "phone": "+227"},
    {"name": "Nigeria", "code": "NG", "phone": "+234"},
    {"name": "North Macedonia", "code": "MK", "phone": "+389"},
    {"name": "Norway", "code": "NO", "phone": "+47"},
    {"name": "Oman", "code": "OM", "phone": "+968"},
    {"name": "Pakistan", "code": "PK", "phone": "+92"},
    {"name": "Palau", "code": "PW", "phone": "+680"},
    {"name": "Palestine", "code": "PS", "phone": "+970"},
    {"name": "Panama", "code": "PA", "phone": "+507"},
    {"name": "Papua New Guinea", "code": "PG", "phone": "+675"},
    {"name": "Paraguay", "code": "PY", "phone": "+595"},
    {"name": "Peru", "code": "PE", "phone": "+51"},
    {"name": "Philippines", "code": "PH", "phone": "+63"},
    {"name": "Poland", "code": "PL", "phone": "+48"},
    {"name": "Portugal", "code": "PT", "phone": "+351"},
    {"name": "Qatar", "code": "QA", "phone": "+974"},
    {"name": "Romania", "code": "RO", "phone": "+40"},
    {"name": "Russia", "code": "RU", "phone": "+7"},
    {"name": "Rwanda", "code": "RW", "phone": "+250"},
    {"name": "Saint Kitts and Nevis", "code": "KN", "phone": "+1-869"},
    {"name": "Saint Lucia", "code": "LC", "phone": "+1-758"},
    {"name": "Saint Vincent and the Grenadines", "code": "VC", "phone": "+1-784"},
    {"name": "Samoa", "code": "WS", "phone": "+685"},
    {"name": "San Marino", "code": "SM", "phone": "+378"},
    {"name": "Sao Tome and Principe", "code": "ST", "phone": "+239"},
    {"name": "Saudi Arabia", "code": "SA", "phone": "+966"},
    {"name": "Senegal", "code": "SN", "phone": "+221"},
    {"name": "Serbia", "code": "RS", "phone": "+381"},
    {"name": "Seychelles", "code": "SC", "phone": "+248"},
    {"name": "Sierra Leone", "code": "SL", "phone": "+232"},
    {"name": "Singapore", "code": "SG", "phone": "+65"},
    {"name": "Slovakia", "code": "SK", "phone": "+421"},
    {"name": "Slovenia", "code": "SI", "phone": "+386"},
    {"name": "Solomon Islands", "code": "SB", "phone": "+677"},
    {"name": "Somalia", "code": "SO", "phone": "+252"},
    {"name": "South Africa", "code": "ZA", "phone": "+27"},
    {"name": "South Sudan", "code": "SS", "phone": "+211"},
    {"name": "Spain", "code": "ES", "phone": "+34"},
    {"name": "Sri Lanka", "code": "LK", "phone": "+94"},
    {"name": "Sudan", "code": "SD", "phone": "+249"},
    {"name": "Suriname", "code": "SR", "phone": "+597"},
    {"name": "Sweden", "code": "SE", "phone": "+46"},
    {"name": "Switzerland", "code": "CH", "phone": "+41"},
    {"name": "Syria", "code": "SY", "phone": "+963"},
    {"name": "Taiwan", "code": "TW", "phone": "+886"},
    {"name": "Tajikistan", "code": "TJ", "phone": "+992"},
    {"name": "Tanzania", "code": "TZ", "phone": "+255"},
    {"name": "Thailand", "code": "TH", "phone": "+66"},
    {"name": "Timor-Leste", "code": "TL", "phone": "+670"},
    {"name": "Togo", "code": "TG", "phone": "+228"},
    {"name": "Tonga", "code": "TO", "phone": "+676"},
    {"name": "Trinidad and Tobago", "code": "TT", "phone": "+1-868"},
    {"name": "Tunisia", "code": "TN", "phone": "+216"},
    {"name": "Turkey", "code": "TR", "phone": "+90"},
    {"name": "Turkmenistan", "code": "TM", "phone": "+993"},
    {"name": "Tuvalu", "code": "TV", "phone": "+688"},
    {"name": "Uganda", "code": "UG", "phone": "+256"},
    {"name": "Ukraine", "code": "UA", "phone": "+380"},
    {"name": "United Arab Emirates", "code": "AE", "phone": "+971"},
    {"name": "United Kingdom", "code": "GB", "phone": "+44"},
    {"name": "United States", "code": "US", "phone": "+1"},
    {"name": "Uruguay", "code": "UY", "phone": "+598"},
    {"name": "Uzbekistan", "code": "UZ", "phone": "+998"},
    {"name": "Vanuatu", "code": "VU", "phone": "+678"},
    {"name": "Vatican City", "code": "VA", "phone": "+39-06"},
    {"name": "Venezuela", "code": "VE", "phone": "+58"},
    {"name": "Vietnam", "code": "VN", "phone": "+84"},
    {"name": "Yemen", "code": "YE", "phone": "+967"},
    {"name": "Zambia", "code": "ZM", "phone": "+260"},
    {"name": "Zimbabwe", "code": "ZW", "phone": "+263"}
  ];

  @override
  void _showCountryPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CountryPickerDialog(
          countries: _countries,
          onSelected: (String selected) {
            setState(() {
              _selectedCountry = "${selected.split(' ')[0]} (${selected.split(' ')[1]})";
            });
          },
        );
      },
    );
  }

  @override
  signUp() async {
    try {
      // Create user with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      String phoneCode = _selectedCountry.split('(')[1].replaceAll(')', '').trim();

      // Store user details in Firebase Realtime Database
      // Note: Don't store password in database for security reasons
      await dbRef.child(userCredential.user!.uid).set({
        'name': name.text,
        'phone': number.text,
        'email': email.text,
        'uid': userCredential.user!.uid,
        'phoneCode': phoneCode,
        'emailVerified': false, // Track email verification status
      });

      // Show success message and navigate to verification page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Account created successfully! Please check your email to verify your account."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to email verification page
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EmailVerificationPage(userEmail: email.text))
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup Failed: ${e.toString()}")),
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
                  Positioned(  //Yellowsquarebox
                    left: 53,
                    top: 246,
                    child: Container(
                      width: 303,
                      height: 435,
                      decoration: ShapeDecoration(
                        color: Color(0xFF0816A7),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 3, color: Color(0xFFFFFF00)),
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //SignupContainer
                    left: 148,
                    top: 225,
                    child: Container(
                      width: 110,
                      height: 41,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 112,
                              height: 41,
                              decoration: BoxDecoration(color: Color(0xFF0816A7)),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            top: 6,
                            child: Text(
                              'Sign Up',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
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
                      'Name:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(  //Nameinput
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
                          controller: name,
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
                      'Email Address:',
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
                    left: 80,
                    top: 413,
                    child: Text(
                      'Phone Number:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(  //CountryCodeSelect
                    left: 79,
                    top: 436,
                    child: GestureDetector(
                        onTap: () => _showCountryPicker(context),
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
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        )
                    ),
                  ),
                  Positioned(  //Phonenuminput
                    left: 181,
                    top: 436,
                    child: Material(
                      color: Colors.transparent, // Ensures no unwanted background
                      child: Container(
                        width: 150,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5), // Optional rounded corners
                          border: Border.all(color: Colors.black, width: 1),
                        ),// Optional border
                        padding: EdgeInsets.symmetric(horizontal: 8), // Padding for text input
                        alignment: Alignment.center,
                        child: TextField(
                          controller: number,
                          keyboardType: TextInputType.number,
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
                    left: 80,
                    top: 478,
                    child: Text(
                      'Password:',
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
                    top: 501,
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
                                  border: InputBorder.none, // Removes default TextField border
                                  isDense: true, // Reduces TextField height to fit container
                                  contentPadding: EdgeInsets.zero, // Aligns text properly
                                ),
                                style: TextStyle(fontSize: 14, color: Colors.black),
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
                    left: 80,
                    top: 543,
                    child: Text(
                      'Confirm Password:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(  //Confirmpasswordinput
                    left: 79,
                    top: 566,
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
                                controller: confirmPassword,
                                obscureText: _obscureText2,
                                decoration: InputDecoration(
                                  border: InputBorder.none, // Removes default TextField border
                                  isDense: true, // Reduces TextField height to fit container
                                  contentPadding: EdgeInsets.zero, // Aligns text properly
                                ),
                                style: TextStyle(fontSize: 14, color: Colors.black),
                                textAlignVertical: TextAlignVertical.center, // Ensures proper vertical alignment
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscureText2 = !_obscureText2;
                                });
                              },
                              child: Icon(
                                _obscureText2 ? Icons.visibility_off : Icons.visibility,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(  //Signupbutton
                    left: 155,
                    top: 620,
                    child: GestureDetector(
                      onTap: () async {
                        // Validates all fields
                        if (name.text.isEmpty ||
                            email.text.isEmpty ||
                            number.text.isEmpty ||
                            password.text.isEmpty) {
                          // Show an error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please fill all fields')),
                          );
                          return;
                        }
                        // Check if passwords match
                        if (password.text != confirmPassword.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Passwords do not match')),
                          );
                          return;
                        }
                        // Validate email input on every change
                        if (email.text.isNotEmpty && !email.text.endsWith('.com')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Please enter a valid email address'),
                                duration: Duration(seconds: 2)),
                          );
                          return;
                        }
                        if (password.text.isNotEmpty && password.text.length<8) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please enter a password with minimum 8 characters')),
                          );
                          return;
                        }

                        signUp();
                      },
                      child: Container(
                        width: 100,
                        height: 30,
                        decoration: ShapeDecoration(
                          color: Color(0xFFFFFF00),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Sign Up',
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
                  ),
                  Positioned(
                    left: 107,
                    top: 698,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: 'Login now',
                            style: TextStyle(
                              color: Color(0xFFFFE900),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Navigate to login page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Login()), // Replace with your login page widget
                                );
                              },
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

// Email Verification Page
class EmailVerificationPage extends StatefulWidget {
  final String userEmail;

  EmailVerificationPage({required this.userEmail});

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    // Check if email is already verified
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isEmailVerified) {
      sendVerificationEmail();

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

  Future<void> checkEmailVerified() async {
    // Reload user to get latest verification status
    await FirebaseAuth.instance.currentUser?.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });

    if (isEmailVerified) {
      timer?.cancel();
      // Update verification status in database
      await FirebaseDatabase.instance
          .ref()
          .child('Users')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .update({'emailVerified': true});

      // Navigate to homepage
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
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification email sent')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerified
        ? Homepage()
        : Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0816A7),
        title: Text('Verify Email', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: Color(0xFF0816A7)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 30),
              Text(
                'Verify Your Email',
                style: GoogleFonts.irishGrover(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'A verification email has been sent to:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                widget.userEmail,
                style: TextStyle(
                  color: Color(0xFFFFFF00),
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Text(
                'Please check your email and click on the verification link to continue.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: sendVerificationEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFFF00),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'Resend Verification Email',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                child: Text(
                  'Back to Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                      widget.onSelected("${country["code"]} ${country["phone"]}");
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