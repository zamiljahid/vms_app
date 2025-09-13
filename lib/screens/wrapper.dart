import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'no_internet_screen.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> with WidgetsBindingObserver {
  bool isConnected = true;

  final InternetConnectionChecker _connectionChecker =
      InternetConnectionChecker.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _checkInternetConnection();

    _connectionChecker.onStatusChange.listen((event) {
      final hasInternet = event == InternetConnectionStatus.connected;
      if (mounted && isConnected != hasInternet) {
        setState(() {
          isConnected = hasInternet;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkInternetConnection();
    }
  }

  Future<void> _checkInternetConnection() async {
    final hasInternet = await _connectionChecker.hasConnection;
    if (mounted && isConnected != hasInternet) {
      setState(() {
        isConnected = hasInternet;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isConnected ? widget.child : const NoInternetScreen();
  }
}
