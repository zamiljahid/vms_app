import 'package:flutter/material.dart';
import 'package:visitor_management/screens/shared_preference.dart';

import '../api/api_client.dart';
import '../main.dart';
import 'dashboard_screen.dart';

class VisitorLoginScreen extends StatefulWidget {
  const VisitorLoginScreen({super.key});

  @override
  State<VisitorLoginScreen> createState() => _VisitorLoginScreenState();
}

class _VisitorLoginScreenState extends State<VisitorLoginScreen> {
  bool isAdmin = true;
  bool _isObscure = true;
  bool isLoading = false;
  late PageController _pageController;

  final TextEditingController loginPhoneController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final TextEditingController registerNameController = TextEditingController();
  final TextEditingController registerNIDController = TextEditingController();
  final TextEditingController registerPassportController = TextEditingController();
  final TextEditingController registerPhoneController = TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPasswordController = TextEditingController();
  final TextEditingController registerAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    loginPhoneController.dispose();
    loginPasswordController.dispose();
    registerNameController.dispose();
    registerNIDController.dispose();
    registerPassportController.dispose();
    registerPhoneController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    super.dispose();
  }

  int _currentPage = 0;

  void _switchPage(int page) {
    _currentPage = page; // update immediately
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    setState(() {}); // rebuild immediately
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Align(
              alignment: Alignment.topLeft,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                  backgroundColor: Theme.of(context).primaryColorLight,
                ),
                child:  Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorDark,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(8, 8),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(-8, -8),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).primaryColorLight.withOpacity(0.9),
                      width: 8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).primaryColorLight.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 4,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorDark,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 8,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo2.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Visitor Management System",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorLight),
            ),
            const SizedBox(height: 30),

            _tabSelector(),
            const SizedBox(height: 20),
            SizedBox(
              height: 330,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Swipe only via buttons
                children: [
                  _authCard(_buildLoginForm(), "Welcome Back", 'login'),
                  _authCard(_buildRegisterForm(), "Create Account", 'register'),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  Widget _tabSelector() {
    return Container(
      width: 200,
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark, // background for inactive
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          // Login button
          Expanded(
            child: GestureDetector(
              onTap: () => _switchPage(0),
              child: Container(
                decoration: BoxDecoration(
                  color: _currentPage == 0 ? Colors.white : Colors.transparent,
                  border: _currentPage != 0
                      ? Border.all(color: Theme.of(context).primaryColorLight, width: 2)
                      : null,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: _currentPage == 0
                        ? Theme.of(context).primaryColorDark
                        : Theme.of(context).primaryColorLight, // change text color for inactive
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // Register button
          Expanded(
            child: GestureDetector(
              onTap: () => _switchPage(1),
              child: Container(
                decoration: BoxDecoration(
                  color: _currentPage == 1 ? Colors.white : Colors.transparent,
                  border: _currentPage != 1
                      ? Border.all(color: Theme.of(context).primaryColorLight, width: 2)
                      : null,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Register",
                  style: TextStyle(
                    color: _currentPage == 1
                        ? Theme.of(context).primaryColorDark
                        : Theme.of(context).primaryColorLight, // text color for inactive
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _authCard(Widget form, String title, String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Card(
        color: Theme.of(context).primaryColorLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                form,
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null // Disable button while loading
                        : () async {
                      setState(() => isLoading = true); // Start loading
                      if (type == 'login') {
                        if (loginPhoneController.text.trim().isEmpty ||
                            loginPasswordController.text.trim().isEmpty) {
                          setState(() => isLoading = false);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Missing Information'),
                              content: const Text(
                                'Please enter both Phone Number and Password.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }
                        final phone = loginPhoneController.text.trim();
                        final password = loginPasswordController.text.trim();
                        final result = await ApiClient().visitorLogin(
                          phone: phone,
                          password: password,
                        );
                        setState(() => isLoading = false);
                        if (result['success'] == true) {
                          SharedPrefs.setString('name', result['name']);
                          SharedPrefs.setString('userId', result['userId']);
                          SharedPrefs.setInt('roleId', result['roleId']);
                          SharedPrefs.setString('accessToken', result['accessToken']);
                          SharedPrefs.setInt('identity', result['identityId']);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Theme.of(context).primaryColorLight,
                              content: Text(
                                result['message'],
                                style: TextStyle(
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ),
                          );
                          final appTheme = SharedPrefs.getInt('appThemeCode');
                          if (appTheme != 4) {
                            await SharedPrefs.setInt('appThemeCode', 4);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => MainClass()),
                                  (Route<dynamic> route) => false,
                            );
                          } else {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => DashboardScreen()),
                                  (Route<dynamic> route) => false,
                            );
                          }
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Error'),
                              content: Text(result['message'] ?? 'Login failed'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                      else if (type == 'register') {
                        setState(() => isLoading = true);

                        final name = registerNameController.text.trim();
                        final phone = registerPhoneController.text.trim();
                        final email = registerEmailController.text.trim();
                        final address = registerAddressController.text.trim();
                        final password = registerPasswordController.text.trim();
                        final nid = registerNIDController.text.trim();
                        final passport = registerPassportController.text.trim();

                        // Validate required fields
                        if (name.isEmpty || phone.isEmpty || address.isEmpty || password.isEmpty) {
                          setState(() => isLoading = false);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Missing Information'),
                              content: const Text(
                                  'Please fill in all required fields (Name, Phone, Address, Password).'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }

                        // Validate either NID or Passport
                        if (nid.isEmpty && passport.isEmpty) {
                          setState(() => isLoading = false);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Missing Document'),
                              content: const Text('Please provide either NID or Passport number.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }

                        // Call API
                        final result = await ApiClient().visitorRegister(
                          name: name,
                          phone: phone,
                          email: email,
                          address: address,
                          password: password,
                          nid: nid,
                          passport: passport,
                        );
                        setState(() => isLoading = false);
                        if (result == "Registration Successful") {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Registration Successful'),
                              content: const Text('Your account has been registered. Please login now.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          registerNameController.clear();
                          registerPhoneController.clear();
                          registerEmailController.clear();
                          registerAddressController.clear();
                          registerPasswordController.clear();
                          registerNIDController.clear();
                          registerPassportController.clear();
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Error'),
                              content: Text(result.toString()), // fixed
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );

                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Theme.of(context).primaryColorDark,
                    ),
                    child: isLoading
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Theme.of(context).primaryColorLight,
                      ),
                    )
                        : Icon(
                      Icons.arrow_forward,
                      color: Theme.of(context).primaryColorLight,
                    ),
                  ),
                ),
                if (type == 'login')
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        print('Forget Password pressed');
                      },
                      child: Text(
                        "Forget Password?",
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        _neumorphicField(Icons.phone, "Phone", false, controller: loginPhoneController),
        const SizedBox(height: 10),
        _neumorphicField(Icons.lock, "Password", true, controller: loginPasswordController),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        _neumorphicField(Icons.person, "Name", false, controller: registerNameController),
        const SizedBox(height: 10),
        _neumorphicField(Icons.edit_document, "NID No.", false, controller: registerNIDController),
        const SizedBox(height: 10),
        _neumorphicField(Icons.edit_document, "Passport No.", false, controller: registerPassportController),
        const SizedBox(height: 10),
        _neumorphicField(Icons.phone, "Phone Number", false, controller: registerPhoneController),
        const SizedBox(height: 10),
        _neumorphicField(Icons.email, "Email", false, controller: registerEmailController),
        const SizedBox(height: 10),
        _neumorphicField(Icons.home, "Address", false, controller: registerAddressController),
        const SizedBox(height: 10),
        _neumorphicField(Icons.lock, "Password", true, controller: registerPasswordController),
      ],
    );
  }

  Widget _neumorphicField(IconData icon, String hint, bool isPassword, {TextEditingController? controller}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _isObscure : false,
        decoration: InputDecoration(
          icon: Icon(icon, color: Theme.of(context).primaryColorDark),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off, color: Theme.of(context).primaryColorDark),
            onPressed: () => setState(() => _isObscure = !_isObscure),
          )
              : null,
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}



