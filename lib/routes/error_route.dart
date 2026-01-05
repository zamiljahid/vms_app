import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../screens/wrapper.dart';

class ErrorRouteScreen extends StatefulWidget {
  const ErrorRouteScreen({super.key});

  @override
  State<ErrorRouteScreen> createState() => _ErrorRouteScreenState();
}

class _ErrorRouteScreenState extends State<ErrorRouteScreen> {
  @override
  Widget build(BuildContext context) {
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
          child: Image.asset('assets/images/error.png')

          // Lottie.asset('animation/lockedPage.json',
          //     height:
          //     MediaQuery.of(context).size.height / 2),
        ),
      ),
    );
  }
}
