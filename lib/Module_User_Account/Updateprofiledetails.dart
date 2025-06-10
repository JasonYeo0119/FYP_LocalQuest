import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:localquest/Module_User_Account/Profile.dart';
import 'package:localquest/Module_User_Account/Profiledetails.dart';

class Updateprofiledetails extends StatefulWidget {
  final bool isVerified;
  final String changeType;

  const Updateprofiledetails({
    Key? key,
    this.isVerified = false,
    this.changeType = 'basic_info',
  }) : super(key: key);

  @override
  _UpdateprofiledetailsState createState() => _UpdateprofiledetailsState();
}

class _UpdateprofiledetailsState extends State<Updateprofiledetails> {
  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  String _selectedCountry = "+60";
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = true;
  bool _isSaving = false;

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

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  fetchUserDetails() async {
    setState(() => _isLoading = true);

    if (user != null) {
      try {
        DatabaseReference userRef = FirebaseDatabase.instance.ref().child("Users").child(user!.uid);
        DatabaseEvent event = await userRef.once();

        if (event.snapshot.exists) {
          setState(() {
            nameController.text = event.snapshot.child("name").value?.toString() ?? '';
            emailController.text = event.snapshot.child("email").value?.toString() ?? '';
            phoneController.text = event.snapshot.child("phone").value?.toString() ?? '';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  bool isPasswordStrong(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  String _getPasswordStrengthText(String password) {
    if (password.isEmpty) return '';
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!isPasswordStrong(password)) return 'Include uppercase, lowercase, number & special character';
    return 'Strong password!';
  }

  Color _getPasswordStrengthColor(String password) {
    if (password.isEmpty) return Colors.transparent;
    if (password.length < 8) return Colors.red;
    if (!isPasswordStrong(password)) return Colors.orange;
    return Colors.green;
  }

  Future<void> updateUserDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("Users").child(currentUser.uid);

      // Update based on change type
      if (widget.changeType == 'basic_info') {
        await userRef.update({
          "name": nameController.text.trim(),
          "phone": phoneController.text.trim(),
          "phoneCode": _selectedCountry,
        });
        _showSuccessSnackBar("Profile updated successfully!");
      }
      else if (widget.changeType == 'password') {
        await currentUser.updatePassword(passwordController.text);
        _showSuccessSnackBar("Password updated successfully!");
      }

      // Navigate back after successful update
      await Future.delayed(Duration(seconds: 1));
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Profile(),
        ),
      );
    } catch (e) {
      String errorMessage = 'Failed to update profile.';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'This email is already in use by another account.';
            break;
          case 'invalid-email':
            errorMessage = 'Please enter a valid email address.';
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak. Please choose a stronger password.';
            break;
          case 'requires-recent-login':
            errorMessage = 'Please log out and log back in before making this change.';
            break;
          default:
            errorMessage = e.message ?? 'Failed to update profile.';
        }
      }

      _showErrorSnackBar(errorMessage);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CountryPickerBottomSheet(
        countries: _countries,
        currentSelection: _selectedCountry,
        onSelected: (String selected) {
          setState(() => _selectedCountry = selected);
        },
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    bool isEmail = false,
    bool isRequired = true,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label + (isRequired ? ' *' : ''),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: isPassword ? (controller == passwordController ? _obscurePassword : _obscureConfirmPassword) : false,
            keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
            validator: validator ?? (isRequired ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            } : null),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Color(0xFF0816A7)),
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  controller == passwordController
                      ? (_obscurePassword ? Icons.visibility_off : Icons.visibility)
                      : (_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                ),
                onPressed: () {
                  setState(() {
                    if (controller == passwordController) {
                      _obscurePassword = !_obscurePassword;
                    } else {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    }
                  });
                },
              )
                  : suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF0816A7), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          if (isPassword && controller == passwordController && passwordController.text.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                _getPasswordStrengthText(passwordController.text),
                style: TextStyle(
                  fontSize: 12,
                  color: _getPasswordStrengthColor(passwordController.text),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phone Number *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: _showCountryPicker,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedCountry,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    }
                    if (value.length < 8) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF0816A7), width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getUpdateTitle() {
    switch (widget.changeType) {
      case 'password':
        return 'Update Password';
      default:
        return 'Update Profile';
    }
  }

  List<Widget> _buildFormFields() {
    switch (widget.changeType) {
      case 'password':
        return [
          _buildFormField(
            label: 'New Password',
            controller: passwordController,
            icon: Icons.lock_outline,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (!isPasswordStrong(value)) {
                return 'Password must be at least 8 characters with uppercase, lowercase, number & special character';
              }
              return null;
            },
          ),
          _buildFormField(
            label: 'Confirm New Password',
            controller: confirmPasswordController,
            icon: Icons.lock_outline,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ];
      default:
        return [
          _buildFormField(
            label: 'Full Name',
            controller: nameController,
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name is required';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          _buildPhoneField(),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_getUpdateTitle(), style: TextStyle(fontWeight: FontWeight.w600)),
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
            SizedBox(height: 16),
            Text('Loading profile...', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Update Info Card
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
                          Icon(
                            widget.changeType == 'email'
                                ? Icons.email_outlined
                                : widget.changeType == 'password'
                                ? Icons.lock_outline
                                : Icons.edit_outlined,
                            color: Color(0xFF0816A7),
                          ),
                          SizedBox(width: 8),
                          Text(
                            _getUpdateTitle(),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ..._buildFormFields(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : updateUserDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0816A7),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                  child: _isSaving
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Updating...', style: TextStyle(fontSize: 16)),
                    ],
                  )
                      : Text('Update Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),

              SizedBox(height: 20),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
              ),

              SizedBox(height: 100), // Extra space at bottom
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

// Country Picker Bottom Sheet
class CountryPickerBottomSheet extends StatefulWidget {
  final List<Map<String, String>> countries;
  final String currentSelection;
  final Function(String) onSelected;

  const CountryPickerBottomSheet({
    Key? key,
    required this.countries,
    required this.currentSelection,
    required this.onSelected,
  }) : super(key: key);

  @override
  _CountryPickerBottomSheetState createState() => _CountryPickerBottomSheetState();
}

class _CountryPickerBottomSheetState extends State<CountryPickerBottomSheet> {
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredCountries = widget.countries
        .where((country) =>
    country["name"]!.toLowerCase().contains(searchQuery.toLowerCase()) ||
        country["phone"]!.contains(searchQuery))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.public, color: Color(0xFF0816A7)),
                SizedBox(width: 8),
                Text(
                  'Select Country Code',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Search field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search country...",
                prefixIcon: Icon(Icons.search, color: Color(0xFF0816A7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF0816A7), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Countries list
          Expanded(
            child: ListView.builder(
              itemCount: filteredCountries.length,
              itemBuilder: (context, index) {
                var country = filteredCountries[index];
                bool isSelected = country["phone"] == widget.currentSelection;

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF0816A7).withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text(
                      country["name"]!,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Color(0xFF0816A7) : null,
                      ),
                    ),
                    subtitle: Text(
                      "Code: ${country["code"]}",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFF0816A7) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        country["phone"]!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    onTap: () {
                      widget.onSelected(country["phone"]!);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}