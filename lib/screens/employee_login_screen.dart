import 'package:flutter/material.dart';
import 'package:visitor_management/api/api_client.dart';
import 'package:visitor_management/screens/shared_preference.dart';
import '../main.dart';
import 'dashboard_screen.dart';

class EmployeeLoginScreen extends StatefulWidget {
  const EmployeeLoginScreen({super.key});

  @override
  State<EmployeeLoginScreen> createState() => _EmployeeLoginScreenState();
}

class _EmployeeLoginScreenState extends State<EmployeeLoginScreen> {
  bool isAppKey = false;
  bool isVerify = false;
  bool _isObscure = true;
  bool isVerifying = false;
  bool isLogin = false;
  int? previousTheme;
  int companyTheme = 4;


  final TextEditingController appKeyController = TextEditingController();
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
     previousTheme = SharedPrefs.getInt('appThemeCode');
    _checkSavedAppKey();
  }

  Future<void> _checkSavedAppKey() async {
    final savedKey = await SharedPrefs.getString('key');

    if (savedKey != null && savedKey.isNotEmpty) {
      appKeyController.text = savedKey;
      _autoVerifyAppKey(savedKey);
    }
  }

  Future<void> _autoVerifyAppKey(String apiKey) async {
    setState(() => isVerifying = true);

    try {
      final company = await ApiClient().getCompanyData(apiKey);

      if (company != null && company.success) {
        setState(() {
          isVerify = true;
          // SharedPrefs.setString('company_id', company.companyId.toString());
          // SharedPrefs.setInt('appThemeCode', company.theme);
          // appThemeCode = company.theme;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).primaryColorLight,
            content: Text(
              company.message,
              style: TextStyle(color: Theme.of(context).primaryColorDark),
            ),
          ),
        );
      } else {
        SharedPrefs.remove('key');
        appKeyController.clear();
      }
    } catch (_) {
      SharedPrefs.remove('key');
      appKeyController.clear();
    } finally {
      setState(() => isVerifying = false);
    }
  }


  @override
  void dispose() {
    appKeyController.dispose();
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 170,
                      height: 170,
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
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).primaryColorLight.withOpacity(0.7),
                          width: 8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).primaryColorLight.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 4,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 110,
                      height: 110,
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
                const SizedBox(height: 10),
                Text(
                  "Visitor Management System",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),

                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColorDark.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: appKeyController,
                          readOnly: isVerify,
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.key,
                              color: Theme.of(context).primaryColor,
                            ),
                            hintText: 'App Key',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Contact your organization for the app key',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: isVerifying
                            ? null
                            : () async {
                          if (!isVerify) {
                            final apiKey = appKeyController.text.trim();
                            if (apiKey.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text('Please enter an app key.'),
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
                            setState(() => isVerifying = true);
                            try {
                              final company = await ApiClient().getCompanyData(apiKey);

                              if (company != null) {
                                if (company.success) {
                                  setState(() {
                                    isVerify = true; // mark as verified
                                    SharedPrefs.setString('key', appKeyController.text.trim());
                                    SharedPrefs.setString('company_id', company.companyId.toString());
                                    SharedPrefs.setInt('appThemeCode', company.theme);
                                    companyTheme = company.theme;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Theme.of(context).primaryColorLight,
                                      content: Text(
                                        company.message,
                                        style: TextStyle(color: Theme.of(context).primaryColorDark),
                                      ),
                                    ),
                                  );
                                } else {
                                  // Show server error message
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Error'),
                                      content: Text(company.message),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              } else {
                                // Fallback if null
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Error'),
                                    content: const Text('Failed to fetch data.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } catch (e) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Error'),
                                  content: Text('Something went wrong: $e'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            } finally {
                              setState(() => isVerifying = false);
                            }
                          } else {
                            setState(() {
                              isVerify = false;
                              appKeyController.clear();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColorDark,
                          foregroundColor: Theme.of(context).primaryColorLight,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isVerifying
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColorDark,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(isVerify ? 'Reset' : 'Verify'),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Visibility(
                  visible: isVerify,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColorLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Welcome Back',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildLoginForm(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _roundArrowButton(companyTheme),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColorLight,
                          ),
                        ),
                      ),
                    ],
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
        _neumorphicField(
          Icons.email,
          "Email",
          controller: loginController,
        ),
        const SizedBox(height: 16),
        _neumorphicField(
          Icons.lock,
          "Password",
          isPassword: true,
          controller: passwordController,
        ),
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
          icon: Icon(
            icon,
            color:
                Theme.of(
                  context,
                ).primaryColor,
          ),
          suffixIcon:
              isPassword
                  ? IconButton(
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                      color:
                          Theme.of(
                            context,
                          ).primaryColorDark,
                    ),
                  )
                  : null,
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
  Widget _roundArrowButton(int themeCode) {
    return GestureDetector(
      onTap: isLogin
          ? null
          : () async {
        if (loginController.text.trim().isEmpty ||
            passwordController.text.trim().isEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Missing Information'),
              content: const Text(
                'Please enter both Login ID and Password.',
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

        setState(() => isLogin = true);

        final loginId = loginController.text.trim();
        final password = passwordController.text.trim();

        final result = await ApiClient().loginUser(
          companyId: SharedPrefs.getString('company_id').toString(),
          loginId: loginId,
          password: password,
        );
        setState(() => isLogin = false);
        if (result['success'] == true) {
          SharedPrefs.setString('name', result['name']);
          SharedPrefs.setString('userId', result['userId']);
          SharedPrefs.setInt('roleId', result['roleId']);
          SharedPrefs.setString('accessToken', result['accessToken']);
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
          final newAppThemeCode = themeCode;
          if (previousTheme != newAppThemeCode) {
            await SharedPrefs.setInt('appThemeCode', newAppThemeCode);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MainClass()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => DashboardScreen()),
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
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColorLight,
        ),
        child: isLogin
            ? SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).primaryColorDark,
          ),
        )
            : Icon(
          Icons.arrow_forward,
          color: Theme.of(context).primaryColorDark,
        ),
      ),
    );
  }

}
