
import 'routes_names.dart';

class ChooseMenu {
  static String getTitle({required String menuName}) {
    switch (menuName) {
      case "Dashboard":
        return "Dashboard";
      case "Take Appointment":
        return "Take Appointments";
      case "Invite":
        return "Send Invitation";
      case "Add Employee":
        return "Add Employee";
      default:
        return menuName;
    }
  }

  static String? getIcon({required String menuName}) {
    switch (menuName) {
      case "Dashboard":
        return 'assets/images/search.png';
      case "Take Appointment":
        return 'assets/images/appointment.png';
        case "Invite":
          return 'assets/images/invitation.png';
      case "Add Employee":
        return 'assets/images/addEmployee.png.png';
      default:
        return 'assets/icons/menu/error.png';
    }
  }

  static String getRoutes({required String menuName}) {
    switch (menuName) {
      case "Dashboard":
        return RouteConstantName.dashboardScreen;
      case "Take Appointment":
        return RouteConstantName.appointmentScreen;
      case "Invite":
        return RouteConstantName.inviteEmployeeScreen;
      case "Add Employee":
        return RouteConstantName.addEmployeeScreen;
      default:
        return RouteConstantName.errorRoute;
    }
  }
}
