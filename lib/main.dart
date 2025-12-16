import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visitor_management/routes/routes.dart';
import 'package:visitor_management/screens/add_employee_screen.dart';
import 'package:visitor_management/screens/appointment_screen.dart';
import 'package:visitor_management/screens/invite_employee.dart';
import 'package:visitor_management/screens/select_screen.dart';
import 'package:visitor_management/screens/shared_preference.dart';
import 'package:visitor_management/screens/splash_screen.dart';



import 'constants/custom_theme.dart';
import 'screens/login_screen.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs.init();
  runApp(const ProviderScope(child: MainClass()));
}

class MainClass extends StatefulWidget {
  const MainClass({Key? key}) : super(key: key);

  @override
  MainClassState createState() => MainClassState();
}

class MainClassState extends State<MainClass> {
  late int appThemeCode;

  @override
  void initState() {
    super.initState();
    loadAppTheme();
  }

  Future<void> loadAppTheme() async {
    final int? storedThemeCode = SharedPrefs.getInt('appThemeCode');
    if (storedThemeCode != null) {
      appThemeCode = storedThemeCode;
      setState(() {});
    } else {
      appThemeCode = 4;
      setState(() {});
    }
  }

  ThemeData getThemeFromCode(int themeCode) {
    switch (themeCode) {
      case 1:
        return CustomTheme.blueTheme;
      case 2:
        return CustomTheme.redTheme;
      case 3:
        return CustomTheme.greenTheme;

        case 4:
        return CustomTheme.purpleTheme;

      default:
        return CustomTheme.blueTheme;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Visitor Management System",
      debugShowCheckedModeBanner: false,
      // theme:getThemeFromCode(appThemeCode),
      theme: CustomTheme.greenTheme,
      onGenerateRoute: RouterGenerator.generateRoute,
      home: SelectScreen(),
    );
  }
}