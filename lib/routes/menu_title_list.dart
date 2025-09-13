
import 'routes_names.dart';

class ChooseMenu {
  static String getTitle({required String menuCode}) {
    switch (menuCode) {
      case "Dashboard":
        return "Dashboard";
      default:
        return menuCode;
    }
  }

  static String? getIcon({required String menuCode}) {
    switch (menuCode) {
      case "Dashboard":
        return 'assets/icons/menu/search.png';

      default:
        return 'assets/icons/menu/error.png';
    }
  }

  static String getRoutes({required String menuCode}) {
    switch (menuCode) {
      case "Dashboard":
        return RouteConstantName.dashboardScreen;

      default:
        return RouteConstantName.errorRoute;
    }
  }
}
