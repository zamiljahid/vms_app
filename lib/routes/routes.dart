import 'dart:ui';
import 'package:visitor_management/screens/add_employee_screen.dart';
import 'package:visitor_management/screens/create_appointment_screen.dart';
import 'package:visitor_management/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:visitor_management/screens/invite_employee.dart';
import 'package:visitor_management/screens/manage_appointment_screen.dart';
import 'package:visitor_management/screens/reception_log_screen.dart';
import 'package:visitor_management/screens/scan_qr_screen.dart';
import 'package:visitor_management/screens/walk-in_screen.dart';
import '../screens/appointment_screen.dart';
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
      case RouteConstantName.addEmployeeScreen:
        return MaterialPageRoute(
          builder: (context) =>  AddEmployeeScreen(),
        );
      case RouteConstantName.inviteEmployeeScreen:
        return MaterialPageRoute(
          builder: (context) =>  InviteEmployee(),
        );
      case RouteConstantName.appointmentScreen:
        return MaterialPageRoute(
          builder: (context) =>  AppointmentScreen(),
        );
      case RouteConstantName.manageAppointmentScreen:
        return MaterialPageRoute(
          builder: (context) =>  ManageAppointmentsScreen(),
        );
      case RouteConstantName.receptionLogScreen:
        return MaterialPageRoute(
          builder: (context) =>  ReceptionLogScreen(),
        );
      case RouteConstantName.scanQRScreen:
        return MaterialPageRoute(
          builder: (context) =>  ScanQRScreen(),
        );
      case RouteConstantName.walkInScreen:
        return MaterialPageRoute(
          builder: (context) =>  WalkInScreen(),
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
          body:


          Center(
            child: Image.asset('assets/images/error.png')


            // Lottie.asset('animation/lockedPage.json',
            //     height:
            //     MediaQuery.of(context).size.height / 2),
          ),
        ),
      );
    });
  }
}
