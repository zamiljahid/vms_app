
import 'routes_names.dart';

class ChooseMenu {
  static String getTitle({required String menuName}) {
    switch (menuName) {
      case "Dashboard":
        return "Dashboard";
      case "Appointment":
        return "My Appointments";
      case "Invite":
        return "Send Invitation";
      case "Add Employee":
        return "Add Employee";
      case "Reception Log":
        return "Reception Log";
      case "Manage Appointments":
        return "Manage Appointments";
      case "Walk-In":
        return "Walk-In";
      case "Scan QR":
        return "Scan QR";
      default:
        return menuName;
    }
  }

  static String? getIcon({required String menuName}) {
    switch (menuName) {
      case "Dashboard":
        return 'assets/images/search.png';
      case "Appointment":
        return 'assets/images/myAppointments.png';
        case "Invite":
          return 'assets/images/invitation.png';
      case "Add Employee":
        return 'assets/images/addEmployee.png';
      case "Reception Log":
        return 'assets/images/receptionLog.png';
      case "Manage Appointments":
        return 'assets/images/manageAppointment.png';
      case "Walk-In":
        return 'assets/images/walkIn.png';
      case "Scan QR":
        return 'assets/images/scanQR.png';
      default:
        return 'assets/images/error.png';
    }
  }

  static String getRoutes({required String menuName}) {
    switch (menuName) {
      case "Dashboard":
        return RouteConstantName.dashboardScreen;
      case "Appointment":
        return RouteConstantName.appointmentScreen;
      case "Invite":
        return RouteConstantName.inviteEmployeeScreen;
      case "Add Employee":
        return RouteConstantName.addEmployeeScreen;
      case "Reception Log":
        return RouteConstantName.receptionLogScreen;
      case "Manage Appointments":
        return RouteConstantName.manageAppointmentScreen;
      case "Walk-In":
        return RouteConstantName.walkInScreen;
      case "Scan QR":
        return RouteConstantName.scanQRScreen;
      default:
        return RouteConstantName.errorRoute;
    }
  }
}
