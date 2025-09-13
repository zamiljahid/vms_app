import 'dart:ui';
import 'package:visitor_management/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../screens/splash_screen.dart';
import '../screens/wrapper.dart';
import 'routes_names.dart';

class RouterGenerator {
  static Route<String> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstantName.splashScreen:
        return MaterialPageRoute(
          builder: (context) =>  SplashScreen(),
        );

      case RouteConstantName.dashboardScreen:
        return MaterialPageRoute(
          builder: (context) =>  DashboardScreen(),
        );
      default:
        return _errorRoute();
    }
  }

  static Route<String> _errorRoute() {
    return MaterialPageRoute(builder: (context) {
      return Wrapper(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(
              double.infinity,
              56.0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: AppBar(
                  backgroundColor:
                  Theme.of(context).primaryColorDark.withOpacity(0.8),
                  title: Text(
                    "Menu unavailable",
                    style: TextStyle(color: Theme.of(context).primaryColorLight),
                  ),
                  centerTitle: true,
                  leading: GestureDetector(
                    onTap: (){Navigator.pop(context);},
                    child: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).primaryColorLight,
                    ),
                  ),
                  elevation: 0.0,
                ),
              ),
            ),
          ),
          body: Center(
            child: Lottie.asset('animation/lockedPage.json',
                height:
                MediaQuery.of(context).size.height / 2),
          ),
        ),
      );
    });
  }
}
