import 'package:flutter/material.dart';

import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  bool isAppKey = false;
  bool isAdmin = false;
  bool _isObscure = true;

  // Controllers for login
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  // Controllers for register
  final TextEditingController registerNameController = TextEditingController();
  final TextEditingController registerPhoneController = TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPasswordController = TextEditingController();

  @override
  void initState() {
    isAdmin = true;
    super.initState();
  }

  @override
  void dispose() {
    // Dispose all controllers
    loginEmailController.dispose();
    loginPasswordController.dispose();

    registerNameController.dispose();
    registerPhoneController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();

    super.dispose();
  }

  void _handleLogin() {
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Theme.of(context).primaryColorLight,content: Text('Please fill in both email and password',style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),)),
      );
      return;
    }

    if (email == 'admin' && password == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Theme.of(context).primaryColorLight,content: Text('Login successful!',style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor))),
      );

      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardScreen()),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid login or password')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Theme.of(context).primaryColorLight),
            onPressed: () {
              setState(() {
                isAdmin = !isAdmin;
              });
            },
          ),
        ],
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                visible: isAdmin,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight, // Soft background
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        children: [
                          ToggleButtons(
                            isSelected: [isLogin, !isLogin],
                            onPressed: (index) {
                              setState(() {
                                isLogin = index == 0;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            selectedColor: Theme.of(context).primaryColorLight,
                            fillColor: Theme.of(context).primaryColorDark,
                            color: Theme.of(context).primaryColorDark,
                            borderColor: Colors.transparent,
                            selectedBorderColor: Colors.transparent,
                            children: [
                              _neumorphicTab("Login"),
                              _neumorphicTab("Register"),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Text(
                            isLogin ? 'Welcome Back' : 'Create Account',
                            style: TextStyle(
                              color:  Theme.of(context).primaryColorDark,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250), // Faster
                            transitionBuilder: (child, animation) {
                              final scaleAnim = Tween<double>(
                                begin: 0.9,
                                end: 1.0,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.fastOutSlowIn,
                              ));

                              final slideAnim = Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOut,
                              ));

                              return SlideTransition(
                                position: slideAnim,
                                child: ScaleTransition(
                                  scale: scaleAnim,
                                  child: child,
                                ),
                              );
                            },
                            child: isLogin
                                ? _buildLoginForm()
                                : _buildRegisterForm(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Visibility(
                visible: !isAdmin,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight, // Soft background
                      borderRadius: BorderRadius.circular(20),),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 30),
                          Text(
                            'Welcome Back',
                            style:  TextStyle(
                              color:Theme.of(context).primaryColorDark,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _neumorphicTab("Login"),
                          const SizedBox(height: 20),
                          _neumorphicField(Icons.key, "App Key", false),
                          const SizedBox(height: 20),
                          Visibility(
                            visible: isAppKey,
                            child: _buildLoginForm(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              _roundArrowButton(),
              if (isLogin) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {},
                  child:  Text(
                    "Forgot Password?",
                    style: TextStyle(color: Theme.of(context).primaryColorLight),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: ValueKey("login"),
      children: [
        _neumorphicField(Icons.email, "Email", false, controller: loginEmailController),
        const SizedBox(height: 20),
        _neumorphicField(Icons.lock, "Password", true, controller: loginPasswordController),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      key: ValueKey("register"),
      children: [
        _neumorphicField(Icons.person, "Name", false, controller: registerNameController),
        const SizedBox(height: 20),
        _neumorphicField(Icons.phone, "Phone Number", false, controller: registerPhoneController),
        const SizedBox(height: 20),
        _neumorphicField(Icons.email, "Email", false, controller: registerEmailController),
        const SizedBox(height: 20),
        _neumorphicField(Icons.lock, "Password", true, controller: registerPasswordController),
      ],
    );
  }

  Widget _neumorphicTab(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Text(title, style: TextStyle(fontSize: 16)),
    );
  }

  Widget _neumorphicField(IconData icon, String hint, bool isPassword, {TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword ? _isObscure : false,
          style:  TextStyle(color: Theme.of(context).primaryColorLight),
          decoration: InputDecoration(
            icon: Icon(icon, color: Theme.of(context).primaryColorLight),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                _isObscure ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).primaryColorLight,
              ),
              onPressed: () {
                setState(() {
                  _isObscure = !_isObscure;
                });
              },
            )
                : null,
            hintText: hint,
            hintStyle:  TextStyle(color: Theme.of(context).primaryColorLight),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _roundArrowButton() {
    return GestureDetector(
      onTap: () {
        if (isAdmin == true && isAppKey == false) {
          setState(() {
            isAppKey = !isAppKey;
          });
        } else if (isLogin) {
          _handleLogin();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColorLight,
        ),
        child: Icon(Icons.arrow_forward, color:Theme.of(context).primaryColorDark, size: 28),
      ),
    );
  }
}
