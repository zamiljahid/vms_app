import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final noInternetProvider = ChangeNotifierProvider((_) => NoInternetNotifier());

class NoInternetNotifier extends ChangeNotifier {
  NoInternetNotifier() {
    isLoading = false;
  }
  bool isLoading = false;

  setLoadingTrue() {
    isLoading = true;
    notifyListeners();
  }

  setLoadingFalse() {
    isLoading = false;
    notifyListeners();
  }
}