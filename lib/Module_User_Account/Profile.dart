import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:localquest/Homepage.dart';
import 'package:localquest/Module_Booking_Management/History.dart';
import 'package:localquest/Module_Booking_Management/Location.dart';
import 'package:localquest/Module_Smart_Development/Chatbotpage.dart';
import 'package:localquest/Module_User_Account/Bugreport.dart';
import 'package:localquest/Module_User_Account/Favourite.dart';
import 'package:localquest/Module_User_Account/Login.dart';
import 'package:flutter/material.dart';
import 'package:localquest/Module_User_Account/Profiledetails.dart';

@override
void Saved(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Favourite();
  }));
}

@override
void Bug(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return BugReport();
  }));
}

@override
void Mybookings(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return History();
  }));
}

@override
void Attractionlist(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Location();
  }));
}

@override
void Faq(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return ChatbotPage();
  }));
}

@override
void Logout(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Login();
  }));
}

void showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text(
              "Confirm Log out",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to log out?",
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Logout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Log out",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      );
    },
  );
}

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;
  String userName = "";
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    fetchUserName();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  fetchUserName() async {
    if (user != null) {
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("Users").child(user!.uid);
      DatabaseEvent event = await userRef.once();

      if (event.snapshot.exists) {
        setState(() {
          userName = event.snapshot.child("name").value.toString();
          isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          userName = "User not found";
          isLoading = false;
        });
        _animationController.forward();
      }
    }
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black12,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (iconColor ?? Color(0xFF0816A7)).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? Color(0xFF0816A7),
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF0816A7),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section with Gradient
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0816A7),
                      Color(0xFF0816A7).withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    // Welcome Text
                    if (isLoading)
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    else
                      Column(
                        children: [
                          Text(
                            'Hello!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            userName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 30),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Profile Options
              _buildProfileOption(
                icon: Icons.settings,
                title: 'Manage account details',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profiledetails()),
                ),
              ),

              _buildProfileOption(
                icon: Icons.favorite,
                title: 'View saved',
                onTap: () => Saved(context),
                iconColor: Colors.red,
              ),

              _buildProfileOption(
                icon: Icons.shopping_bag,
                title: 'My trips',
                onTap: () => Mybookings(context),
                iconColor: Colors.green,
              ),

              _buildProfileOption(
                icon: Icons.park,
                title: 'View attractions list',
                onTap: () => Attractionlist(context),
                iconColor: Colors.teal,
              ),

              _buildProfileOption(
                icon: Icons.question_answer,
                title: 'Chat with AI Chatbot',
                onTap: () => Faq(context),
                iconColor: Colors.purple,
              ),

              _buildProfileOption(
                icon: Icons.bug_report,
                title: 'Bug report',
                onTap: () => Bug(context),
                iconColor: Colors.orangeAccent,
              ),

              SizedBox(height: 30),

              // Logout Button
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => showLogoutConfirmation(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Log out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(
              icon: Icons.favorite,
              label: "Saved",
              isActive: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Favourite()),
              ),
            ),
            _buildBottomNavItem(
              icon: Icons.shopping_bag,
              label: "My Trips",
              isActive: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => History()),
              ),
            ),
            _buildBottomNavItem(
              icon: Icons.home,
              label: "Home",
              isActive: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Homepage()),
              ),
            ),
            _buildBottomNavItem(
              icon: Icons.park,
              label: "Attractions",
              isActive: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Location()),
              ),
            ),
            _buildBottomNavItem(
              icon: Icons.person,
              label: "Profile",
              isActive: true,
              onTap: () {}, // Current page
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Color(0xFF0816A7) : Colors.white70,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Color(0xFF0816A7) : Colors.white70,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}