import 'package:flutter/material.dart';

import 'dashboard_screen.dart';

class VisitorLoginScreen extends StatefulWidget {
  const VisitorLoginScreen({super.key});

  @override
  State<VisitorLoginScreen> createState() => _VisitorLoginScreenState();
}

class _VisitorLoginScreenState extends State<VisitorLoginScreen> {
  bool isLogin = true;
  bool isAppKey = false;
  bool isAdmin = false;
  bool _isObscure = true;
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final TextEditingController registerNameController = TextEditingController();
  final TextEditingController registerNIDController = TextEditingController();
  final TextEditingController registerPassportController = TextEditingController();
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
    registerNIDController.dispose();
    registerPassportController.dispose();
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
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorDark,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.8),
                            offset: const Offset(8, 8),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.8),
                            offset: const Offset(-8, -8),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                          color: Theme.of(context).primaryColorLight.withOpacity(0.7),
                          width: 8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColorLight.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 4,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 140,
                      height: 140,
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
                        child: Image.asset('assets/images/logo2.png', fit: BoxFit.cover),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Visitor Management System",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorLight,
                    height: 1.3,
                  ),
                ),

                Visibility(
                  visible: isAdmin,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorLight,
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
                              fillColor: Theme.of(context).primaryColor,
                              color: Theme.of(context).primaryColorDark,
                              borderColor: Theme.of(context).primaryColorDark,
                              children: [
                                _neumorphicTab("Login"),
                                _neumorphicTab("Register"),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Text(
                              isLogin ? 'Welcome Back' : 'Create Account',
                              style: TextStyle(
                                color:  Theme.of(context).primaryColor,
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
        const SizedBox(height: 2),
        _neumorphicField(Icons.edit_document, "NID No.", false, controller: registerNIDController),
        const SizedBox(height: 2),
        _neumorphicField(Icons.edit_document, "Passport No.", false, controller: registerPassportController),
        const SizedBox(height: 2),
        _neumorphicField(Icons.phone, "Phone Number", false, controller: registerPhoneController),
        const SizedBox(height: 2),
        _neumorphicField(Icons.email, "Email", false, controller: registerEmailController),
        const SizedBox(height: 2),
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
          color: Theme.of(context).primaryColorDark.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword ? _isObscure : false,
          style:  TextStyle(color: Theme.of(context).primaryColorDark),
          decoration: InputDecoration(
            icon: Icon(icon, color: Theme.of(context).primaryColorDark),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                _isObscure ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).primaryColorDark,
              ),
              onPressed: () {
                setState(() {
                  _isObscure = !_isObscure;
                });
              },
            )
                : null,
            hintText: hint,
            hintStyle:  TextStyle(color: Theme.of(context).primaryColorDark),
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
