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
  final user = FirebaseAuth.instance.currentUser;
  bool _obscurePassword = true;
  String _selectedCountry = "";
  bool _isLoading = true;

  // Form controllers
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController number = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    setState(() => _isLoading = true);

    if (user != null) {
      try {
        DatabaseReference userRef = FirebaseDatabase.instance.ref().child("Users").child(user!.uid);
        DatabaseEvent event = await userRef.once();

        if (event.snapshot.exists) {
          setState(() {
            name.text = event.snapshot.child("name").value?.toString() ?? '';
            email.text = event.snapshot.child("email").value?.toString() ?? '';
            number.text = event.snapshot.child("phone").value?.toString() ?? '';
            password.text = event.snapshot.child("password").value?.toString() ?? '';
            _selectedCountry = event.snapshot.child("phoneCode").value?.toString() ?? '+60';
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
          _showErrorSnackBar("User profile not found");
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorSnackBar("Failed to load profile: ${e.toString()}");
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showVerificationDialog(String changeType) async {
    final TextEditingController currentPasswordController = TextEditingController();
    bool obscurePassword = true;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.security, color: Color(0xFF0816A7)),
                  SizedBox(width: 12),
                  Text('Verify Identity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To change your $changeType, please enter your current password for security verification.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: currentPasswordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF0816A7), width: 2),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0816A7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Verify'),
                  onPressed: () async {
                    await _verifyPassword(currentPasswordController.text, changeType);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _verifyPassword(String currentPassword, String changeType) async {
    if (currentPassword.isEmpty) {
      _showErrorSnackBar("Please enter your current password");
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0816A7)),
                  SizedBox(height: 16),
                  Text('Verifying...'),
                ],
              ),
            ),
          ),
        ),
      );

      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPassword,
      );

      await user!.reauthenticateWithCredential(credential);

      Navigator.of(context).pop(); // Close loading dialog
      Navigator.of(context).pop(); // Close verification dialog

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Updateprofiledetails(
            isVerified: true,
            changeType: changeType,
          ),
        ),
      );

      _showSuccessSnackBar('Verification successful! You can now update your $changeType.');

    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorSnackBar('Verification failed. Please check your password.');
    }
  }

  void _handleEdit() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'What would you like to edit?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 24),
            _buildEditOption(
              icon: Icons.person_outline,
              title: 'Name & Phone',
              subtitle: 'Update your personal information',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Updateprofiledetails(
                      isVerified: true,
                      changeType: 'basic_info',
                    ),
                  ),
                );
              },
            ),
            _buildEditOption(
              icon: Icons.lock_outline,
              title: 'Password',
              subtitle: 'Update your password (requires verification)',
              onTap: () {
                Navigator.of(context).pop();
                _showVerificationDialog('password');
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEditOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFF0816A7).withOpacity(0.1),
          child: Icon(icon, color: Color(0xFF0816A7)),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    bool isPhone = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: isPhone ? _buildPhoneField() : _buildRegularField(controller, icon, isPassword),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularField(TextEditingController controller, IconData icon, bool isPassword) {
    return TextField(
      controller: controller,
      readOnly: true,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFF0816A7)),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        )
            : null,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
    );
  }

  Widget _buildPhoneField() {
    return Row(
      children: [
        Container(
          width: 100,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Text(
            _selectedCountry,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
        Expanded(
          child: TextField(
            controller: number,
            readOnly: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Profile Details", style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFF0816A7),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF0816A7)),
            SizedBox(height: 10),
            Text('Loading profile...', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchUserDetails,
        color: Color(0xFF0816A7),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile Header
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFF0816A7),
                        child: Text(
                          name.text.isNotEmpty ? name.text[0].toUpperCase() : 'U',
                          style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        name.text.isEmpty ? 'User' : name.text,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        email.text,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _handleEdit,
                        icon: Icon(Icons.edit),
                        label: Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0816A7),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 5),

              // Profile Information Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Color(0xFF0816A7)),
                          SizedBox(width: 8),
                          Text(
                            'Account Information',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      _buildProfileField(
                        label: 'Full Name',
                        controller: name,
                        icon: Icons.person_outline,
                      ),
                      _buildProfileField(
                        label: 'Email Address',
                        controller: email,
                        icon: Icons.email_outlined,
                      ),
                      _buildProfileField(
                        label: 'Phone Number',
                        controller: number,
                        icon: Icons.phone_outlined,
                        isPhone: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    number.dispose();
    password.dispose();
    super.dispose();
  }
}