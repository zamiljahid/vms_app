import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  bool isAppKey = false;
  bool isAdmin = false;
  bool _isObscure = true;

  final TextEditingController loginAppKeyController = TextEditingController();
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isAdmin = true;
  }

  @override
  void dispose() {
    loginAppKeyController.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final appKey = loginAppKeyController.text.trim();
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text.trim();

    if (appKey.isEmpty||email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).primaryColorLight,
          content: Text(
            'Please fill in both app key,email and password',
            style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),
          ),
        ),
      );
      return;
    }

    if ( appKey =='admin'&& email == 'admin' && password == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).primaryColorLight,
          content: Text(
            'Login successful!',
            style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),
          ),
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid app key or login or password')),
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
                  ),
                ),

                const SizedBox(height: 30),

                /// ADMIN LOGIN
                Visibility(
                  visible: isAdmin,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        /// FIXED ToggleButtons
                        ToggleButtons(
                          isSelected: const [true],
                          onPressed: (_) {},
                          borderRadius: BorderRadius.circular(12),
                          selectedColor:
                          Theme.of(context).primaryColorLight,
                          fillColor: Theme.of(context).primaryColor,
                          color: Theme.of(context).primaryColorDark,
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              child: Text("Login"),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'Welcome Back',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        _buildLoginForm(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                _roundArrowButton(),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                        color: Theme.of(context).primaryColorLight),
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
        _neumorphicField(Icons.key, "App key",
            controller: loginAppKeyController),
        const SizedBox(height: 16),

        _neumorphicField(Icons.email, "Email",
            controller: loginEmailController),
        const SizedBox(height: 16),
        _neumorphicField(Icons.lock, "Password",
            isPassword: true,
            controller: loginPasswordController),
      ],
    );
  }


  Widget _neumorphicField(
      IconData icon,
      String hint, {
        bool isPassword = false,
        TextEditingController? controller,
      }) {
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
          icon: Icon(icon),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(_isObscure
                ? Icons.visibility
                : Icons.visibility_off),
            onPressed: () =>
                setState(() => _isObscure = !_isObscure),
          )
              : null,
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _roundArrowButton() {
    return GestureDetector(
      onTap: _handleLogin,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColorLight,
        ),
        child: Icon(Icons.arrow_forward,
            color: Theme.of(context).primaryColorDark),
      ),
    );
  }
}
