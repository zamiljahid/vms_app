import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  bool _isObscure = true;
  final Color backgroundColor = Color(0xFFE0E5EC);
  final Color shadowLight = Colors.white;
  final Color shadowDark = Color(0xFFA3B1C6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              ToggleButtons(
                isSelected: [isLogin, !isLogin],
                onPressed: (index) {
                  setState(() {
                    isLogin = index == 0;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                selectedColor: Color(0xFF6C84F9),
                fillColor: backgroundColor,
                color: Color(0xFF888FA6),
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
                  color: const Color(0xFF444D6E),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: isLogin ? _buildLoginForm() : _buildRegisterForm(),
              ),

              const SizedBox(height: 30),
              _roundArrowButton(),
              if (isLogin) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Color(0xFF888FA6)),
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
        _neumorphicField(Icons.email, "Email", false),
        const SizedBox(height: 18),
        _neumorphicField(Icons.lock, "Password", true),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      key: ValueKey("register"),
      children: [
        _neumorphicField(Icons.person, "Name", false),
        const SizedBox(height: 18),
        _neumorphicField(Icons.phone, "Phone Number", false),
        const SizedBox(height: 18),
        _neumorphicField(Icons.email, "Email", false),
        const SizedBox(height: 18),
        _neumorphicField(Icons.lock, "Password", true),
      ],
    );
  }

  Widget _neumorphicTab(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Text(title, style: TextStyle(fontSize: 16)),
    );
  }

  Widget _neumorphicField(IconData icon, String hint, bool isPassword) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: shadowLight, offset: Offset(-6, -6), blurRadius: 12),
          BoxShadow(color: shadowDark, offset: Offset(6, 6), blurRadius: 12),
        ],
      ),
      child: TextField(
        obscureText: isPassword ? _isObscure : false,
        style: const TextStyle(color: Color(0xFF3B4B61)),
        decoration: InputDecoration(
          icon: Icon(icon, color: Color(0xFF6C84F9)),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _isObscure ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isObscure = !_isObscure;
              });
            },
          )
              : null,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9BA9C3)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _roundArrowButton() {
    return GestureDetector(
      onTap: () {
        // Handle submit here
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          boxShadow: [
            BoxShadow(color: shadowLight, offset: Offset(-6, -6), blurRadius: 12),
            BoxShadow(color: shadowDark, offset: Offset(6, 6), blurRadius: 12),
          ],
        ),
        child: const Icon(Icons.arrow_forward, color: Color(0xFF6C84F9), size: 28),
      ),
    );
  }
}
