import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visitor_management/screens/employee_login_screen.dart';
import 'package:visitor_management/screens/select_screen.dart';
import 'package:visitor_management/screens/shared_preference.dart';
import 'package:visitor_management/screens/wrapper.dart';

import 'dashboard_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
          tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft),
          weight: 1),
    ]).animate(_bgController);

    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
          tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight),
          weight: 1),
    ]).animate(_bgController);

    _bgController.repeat();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero, // centered
      end: isMobile
          ? const Offset(0, -2) // shift up off screen on mobile
          : const Offset(1.5, 0), // shift right off screen on larger
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeInOut));

    Timer(const Duration(seconds: 4), () async {
      if (!mounted) return;

      final accessToken = SharedPrefs.getString('accessToken');

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
          (accessToken != null && accessToken.isNotEmpty)
              ? DashboardScreen()
              : SelectScreen(),
          transitionDuration: Duration.zero,
        ),
      );
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Widget _buildLogoAndWelcome() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 250,
              height: 250,
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
              width: 200,
              height: 200,
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
              width: 180,
              height: 180,
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
        const SizedBox(height: 30),
        Text(
          "Welcome to\nVisitor Management System",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorLight,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedBuilder(
          animation: _bgController,
          builder: (context, _) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColorDark,
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                  begin: _topAlignmentAnimation.value,
                  end: _bottomAlignmentAnimation.value,
                ),
              ),
              child: Center(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildLogoAndWelcome(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
