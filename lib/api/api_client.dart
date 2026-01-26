import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/company_model.dart';
import '../models/menu _model.dart';
import '../screens/all_company_list_model.dart';
import '../screens/appointments/models/action_model.dart';
import '../screens/appointments/models/manage_appointment_model.dart';
import '../screens/appointments/models/visit_history.dart';
import '../screens/appointments/models/visit_upcoming.dart';
import '../screens/employee/add_employee.dart';
import '../screens/employee/model/employee_list_model.dart';
import '../screens/employee/model/role_model.dart';
import '../screens/invitation/models/history_invitation.dart';
import '../screens/invitation/models/upcoming_invitation.dart';
import '../screens/qr_model.dart';
import '../screens/select_screen.dart';
import '../screens/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../screens/walkin/model/walkin_model.dart';

const String baseUrl = 'https://vms-api-805981895260.us-central1.run.app/api/';
const String companyValidatorUrl = 'Company/validate';
const String employeeLoginUrl = 'Auth/employee-login';
const String visitorLoginUrl = 'Auth/visitor-login';
const String manageAppointmentUrl = 'appointment-list/manage-appointments';
const String visitorRegisterUrl = 'User/registerUser';
const String upcomingInvitesUrl = 'invitation/upcoming';
const String inviteHistoryUrl = 'invitation/history';
const String searchEmployeeUrl = 'User/by-phone';
const String getCompanyListUrl = 'Company';
const String getActionsUrl = 'Visit/actions';
const String sendInvitationUrl = 'invitation/send';
const String createAppointmentUrl = 'Visit/apply';
const String postActionUrl = 'Visit/action';
const String visitHistoryUrl = 'appointment-list/employee-appointment-history';
const String upcomingVisitsUrl = 'appointment-list/my-upcoming-visits';
const String qrVerifyUrl = 'qr/verify';
const String createWalkinUrl = 'walkin';
const String walkinUrl = 'walkin/getWalkInByEmpId';
const String walkinHistoryUrl = 'walkin/getWalkInHistory';
const String menuUrl = 'Menu/get-menus?roleId=';
const String addEmployeeUrl = 'Employee/add_employee?role_id=';
const String companyInvitationUrl = 'invitation/upcoming-by-company?companyId=';
const String companyAppointmentUrl = 'appointment-list/appointments-by-company?companyId=';
const String companyWalkInUrl = 'walkin/getWalkInByCompanyId?companyId=';



class ReceptionistApiResult {
  final List<dynamic> invitations;
  final List<dynamic> appointments;
  final List<dynamic> walkIns;

  ReceptionistApiResult({
    required this.invitations,
    required this.appointments,
    required this.walkIns,
  });
}

class ApiClient {
  static void performLogout(BuildContext context) {
    SharedPrefs.remove('name');
    SharedPrefs.remove('userId');
    SharedPrefs.remove('roleId');
    SharedPrefs.remove('accessToken');
    SharedPrefs.remove('company_id');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SelectScreen()),
    );
  }

  String getDeviceCategory() {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else {
      return 'unknown';
    }
  }

  Future<CompanyModel?> getCompanyData(String api)
  async {
    final deviceType = getDeviceCategory();
    final url = Uri.parse(
      '$baseUrl$companyValidatorUrl?appKey=$api&deviceType=$deviceType',
    );
    final response = await http.get(url);
    print(url.toString());
    print(response.body.toString());
    try {
      final data = json.decode(response.body);
      // data["data"]["success"] = data["success"];
      // data["data"]["message"] = data["message"];
      return CompanyModel.fromJson(data);
      // return CompanyModel.fromJson(data["data"]);
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  Future<List<AllCompanyListModel>> fetchCompaniesFixed() async {
    final url = Uri.parse(baseUrl + getCompanyListUrl);
    final response = await http.get(url);

    print(url.toString());
    print(response.body);

    final decoded = json.decode(response.body);

    final companyResponse = AllCompanyListResponse.fromJson(decoded);

    return companyResponse.companies;
  }

  Future<Map<String, dynamic>> employeeLogin({
    required String companyId,
    required String loginId,
    required String password,
  }) async {
    final url = Uri.parse(baseUrl + employeeLoginUrl);
    final payload = {
      'companyId': companyId,
      'loginId': loginId,
      'password': password,
    };
    print(url.toString());
    print(loginId.toString());
    print(loginId.toString());
    print(password.toString());
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      print(response.body.toString());
      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Empty response from server'};
      }
    } catch (e) {
      if (kDebugMode) print('Login exception: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> visitorLogin({
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse(baseUrl + visitorLoginUrl);
    final payload = {'phone': phone, 'password': password};
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );
      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Empty response from server'};
      }
    } catch (e) {
      if (kDebugMode) print('Login exception: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<ReceptionistApiResult> fetchReceptionistTasks({
    required int companyId,
  })
  async {
    final invitationUrl = Uri.parse(baseUrl + companyInvitationUrl + '$companyId');
    final appointmentUrl = Uri.parse(baseUrl + companyAppointmentUrl + '$companyId');
    final walkInUrl = Uri.parse(baseUrl + companyWalkInUrl + '$companyId');

    List<dynamic> invitationsJson = [];
    List<dynamic> appointmentsJson = [];
    List<dynamic> walkInsJson = [];

    try {
      // Fetch all three APIs
      final responses = await Future.wait([
        http.get(invitationUrl),
        http.get(appointmentUrl),
        http.get(walkInUrl),
      ]);

      // Debug print status
      debugPrint('Invitation status: ${responses[0].statusCode}');
      debugPrint('Appointment status: ${responses[1].statusCode}');
      debugPrint('Walk-in status: ${responses[2].statusCode}');

      if (responses[0].statusCode == 200 && responses[0].body.isNotEmpty) {
        invitationsJson = jsonDecode(responses[0].body);
      }

      if (responses[1].statusCode == 200 && responses[1].body.isNotEmpty) {
        appointmentsJson = jsonDecode(responses[1].body);
      }

      if (responses[2].statusCode == 200 && responses[2].body.isNotEmpty) {
        walkInsJson = jsonDecode(responses[2].body);
      }
    } catch (e) {
      debugPrint('Fetch receptionist tasks error: $e');
    }

    return ReceptionistApiResult(
      invitations: invitationsJson,
      appointments: appointmentsJson,
      walkIns: walkInsJson,
    );
  }

  Future<String> visitorRegister({
    required String phone,
    required String password,
    required String email,
    required String name,
    required String address,
    required String passport,
    required String nid,
  }) async {
    final url = Uri.parse(baseUrl + visitorRegisterUrl);

    final payload = {
      'phone': phone,
      'password': password,
      'name': name,
      'email': email,
      'address': address,
      'passport': passport,
      'nid': nid,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        print(jsonEncode(payload));
        print(response.body);
      }

      return response.body.trim(); // ✅ plain text
    } catch (e) {
      if (kDebugMode) print('Registration exception: $e');
      return 'Something went wrong. Please try again.';
    }
  }

  Future<ApiResponse<List<MenuModel>>> getMenusByRole(int roleId) async {
    try {
      final uri = Uri.parse(baseUrl + menuUrl + roleId.toString());

      final response = await http
          .get(uri, headers: {'accept': '*/*'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['success'] == true) {
          final List list = decoded['data'];

          final menus = list.map((e) => MenuModel.fromJson(e)).toList();

          return ApiResponse(success: true, data: menus);
        } else {
          return ApiResponse(
            success: false,
            message: decoded['message'] ?? 'Failed to load menus',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: 'Server error (${response.statusCode})',
        );
      }
    } on SocketException {
      return ApiResponse(success: false, message: 'No internet connection');
    } on HttpException {
      return ApiResponse(success: false, message: 'HTTP error occurred');
    } on FormatException {
      return ApiResponse(success: false, message: 'Invalid response format');
    } on TimeoutException {
      return ApiResponse(success: false, message: 'Request timeout');
    } catch (e) {
      return ApiResponse(success: false, message: 'Unexpected error: $e');
    }
  }

  Future<dynamic> getUpcomingInvites(int identityId) async {
    try {
      final response = await http
          .get(
            Uri.parse(baseUrl + upcomingInvitesUrl + '?identityId=$identityId'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData == null ||
            decodedData is! List ||
            decodedData.isEmpty) {
          return 'No data found';
        }

        return UpcomingInviteModel.listFromJson(decodedData);
      } else {
        return 'Failed to load data (Code: ${response.statusCode})';
      }
    } on SocketException {
      return 'No internet connection. Please check your network.';
    } on HttpException {
      return 'Server error occurred.';
    } on FormatException {
      return 'Invalid response format from server.';
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<dynamic> getInviteHistory(int identityId) async {
    try {
      final response = await http
          .get(
            Uri.parse(baseUrl + inviteHistoryUrl + '?identityId=$identityId'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData == null ||
            decodedData is! List ||
            decodedData.isEmpty) {
          return 'No data found';
        }

        return InviteHistoryModel.listFromJson(decodedData);
      } else {
        return 'Failed to load data (Code: ${response.statusCode})';
      }
    } on SocketException {
      return 'No internet connection. Please check your network.';
    } on HttpException {
      return 'Server error occurred.';
    } on FormatException {
      return 'Invalid response format from server.';
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<ActionModel> postAction(Map<String, dynamic> requestBody) async {
    final url = Uri.parse(baseUrl + postActionUrl);

    try {
      final response = await http.post(
        url,
        headers: {"Accept": "*/*", "Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return ActionModel.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw errorData['message'] ??
            'Failed to post action: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error posting action: $e';
    }
  }

  Future<ActionModel> getActions(int visitId, String actionType) async {
    final url = Uri.parse(
      baseUrl + getActionsUrl + actionType + visitId.toString(),
    );

    try {
      final response = await http
          .get(url, headers: {'Accept': '*/*'})
          .timeout(const Duration(seconds: 10)); // timeout

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          return ActionModel.fromJson(jsonData);
        } catch (e) {
          throw Exception('Failed to parse action data: $e');
        }
      } else if (response.statusCode == 400) {
        throw Exception('Bad request. Please check the visitId.');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Unauthorized. Please check your credentials.');
      } else if (response.statusCode == 404) {
        throw Exception('Visit actions not found.');
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception(
          'Failed to load visit actions. Status code: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw Exception('No Internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<ManageAppointmentModel>> getManageAppointments(
    String employeeId,
  ) async {
    final url = Uri.parse(
      baseUrl + manageAppointmentUrl + "?employeeId=$employeeId",
    );

    try {
      final response = await http
          .get(url, headers: {'Accept': '*/*'})
          .timeout(const Duration(seconds: 10)); // timeout

      print(response.body.toString());
      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          return jsonData
              .map((item) => ManageAppointmentModel.fromJson(item))
              .toList();
        } catch (e) {
          throw Exception('Failed to parse appointments: $e');
        }
      } else if (response.statusCode == 400) {
        throw Exception('Bad request. Please check your parameters.');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Unauthorized. Please check your credentials.');
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint not found.');
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception(
          'Failed to load appointments. Status code: ${response.statusCode}',
        );
      }
    } on SocketException {
      // No internet / network error
      throw Exception('No Internet connection. Please check your network.');
    } on TimeoutException {
      // Request timeout
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      // Any other unexpected errors
      throw Exception('Unexpected error: $e');
    }
  }

  Future<dynamic> getVisitHistory(String employeeId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$visitHistoryUrl?employeeId=$employeeId'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData == null ||
            decodedData is! List ||
            decodedData.isEmpty) {
          return 'No data found';
        }

        return VisitHistoryModel.listFromJson(decodedData);
      } else {
        return 'Failed to load data (Code: ${response.statusCode})';
      }
    }
    // 🌐 Internet / VPN / DNS issue
    on SocketException {
      return 'No internet connection. Please check your network.';
    }
    // ⏳ Server error
    on HttpException {
      return 'Server error occurred.';
    }
    // ❌ Invalid JSON
    on FormatException {
      return 'Invalid response format from server.';
    }
    // ❌ Unknown error
    catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<QrVerifyResponse> verifyQr(String encryptedQr) async {
    final response = await http.post(
      Uri.parse(baseUrl + qrVerifyUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'encryptedQr': encryptedQr}),
    );

    if (response.statusCode == 200) {
      return QrVerifyResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('QR verification failed');
    }
  }

  Future<dynamic> getUpcomingVisits({
    required int roleId,
    String? employeeId,
    String? visitorUserId,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'roleId': roleId.toString(), // <-- convert int to String
      };
      if (roleId == 4 && visitorUserId != null) {
        queryParams['visitorUserId'] = visitorUserId.toString();
      } else if ((roleId == 1 || roleId == 2 || roleId == 3) &&
          employeeId != null) {
        queryParams['employeeId'] = employeeId;
      }
      final uri = Uri.parse(
        baseUrl + upcomingVisitsUrl,
      ).replace(queryParameters: queryParams);

      print(uri.toString());
      print(visitorUserId.toString());

      final response = await http
          .get(uri, headers: {'Accept': '*/*'})
          .timeout(const Duration(seconds: 15));

      // Success
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData == null ||
            decodedData is! List ||
            decodedData.isEmpty) {
          return 'No data found';
        }

        return UpcomingVisitModel.listFromJson(decodedData);
      } else {
        return 'Failed to load data (Code: ${response.statusCode})';
      }
    }
    // Network error
    on SocketException {
      return 'No internet connection. Please check your network.';
    }
    // Server error
    on HttpException {
      return 'Server error occurred.';
    }
    // Invalid JSON
    on FormatException {
      return 'Invalid response format from server.';
    }
    // Unknown error
    catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<bool> createWalkin({required Map<String, dynamic> payload}) async {
    final url = Uri.parse(baseUrl + createWalkinUrl);

    try {
      final response = await http.post(
        url,
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );
      print(url.toString());
      print(jsonEncode(payload).toString());
      print(response.body.toString());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint("Create Walkin API Error: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Create Walkin API Exception: $e");
      return false;
    }
  }

  Future<bool> sendInvitation({
    required int senderIdentityId,
    required int receiverIdentityId,
    required String purpose,
    required String inviteDate,
    required String inviteTime,
    required String issueDateTime,
  }) async {
    final url = Uri.parse(baseUrl + sendInvitationUrl);

    final body = {
      "senderIdentityId": senderIdentityId,
      "receiverIdentityId": receiverIdentityId,
      "purpose": purpose,
      "inviteDate": inviteDate,
      "inviteTime": inviteTime,
      "issueDateTime": issueDateTime,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'accept': '*/*'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to send invitation (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error. Please check internet');
    }
  }

  Future<List<EmployeeModel>> getEmployeesByCompany({
    required String companyCode,
  }) async {
    final uri = Uri.parse(baseUrl +
      'Employee/by-company?companyCode=$companyCode',
    );

    try {
      final response = await http
          .get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          return decoded
              .map<EmployeeModel>(
                  (json) => EmployeeModel.fromJson(json))
              .toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else if (response.statusCode == 404) {
        throw Exception('Employees not found');
      } else {
        throw Exception(
          'Server error (${response.statusCode})',
        );
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on FormatException {
      throw Exception('Invalid JSON format');
    } on HttpException {
      throw Exception('HTTP error occurred');
    } on TimeoutException {
      throw Exception('Request timeout');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  Future<void> addEmployee(Map<String, dynamic> payload, int roleId) async {

    final url = Uri.parse(baseUrl + addEmployeeUrl+ roleId.toString());

    final response = await http.post(
      url,
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    print(url.toString());
    print(jsonEncode(payload).toString());
    print(response.body.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Employee added successfully: ${response.body}");
    } else {
      // Error
      throw Exception(
          "Failed to add employee. Status: ${response.statusCode}, Body: ${response.body}");
    }
  }

  Future<List<Map<String, dynamic>>> searchEmployeeByPhone(String phone) async {
    final url = Uri.parse(baseUrl + searchEmployeeUrl + '?phone=$phone');

    try {
      final response = await http.get(url, headers: {'accept': '*/*'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return [
          {
            'employeeId': data['employeeId'],
            'employeeIdentityId': data['identityId'],
            'name': data['name'],
            'userId': data['userId'],
            'userType': data['userType'],
          },
        ];
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Network error. Please check internet');
    }
  }

  Future<bool> createAppointment({
    required String baseUrl,
    required Map<String, dynamic> body,
  }) async {
    try {
      final url = Uri.parse(baseUrl + createAppointmentUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print(url.toString());
      print(jsonEncode(body).toString());
      print(response.body.toString());

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CompanyModel>> fetchCompanies() async {
    final url = Uri.parse(baseUrl + getCompanyListUrl);
    try {
      final response = await http.get(url);
      print(url.toString());
      print(response.body.toString());
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List data = decoded['data'];

        return data.map((e) {
          return CompanyModel.fromJson({
            ...e,
            'success': decoded['success'],
            'message': decoded['message'],
          });
        }).toList();
      } else {
        throw Exception(
          "Failed to load companies: ${response.statusCode} ${response.reasonPhrase}",
        );
      }
    } on http.ClientException catch (e) {
      throw Exception("Network error: ${e.message}");
    } on FormatException catch (e) {
      throw Exception("Invalid JSON format: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }
  Future<dynamic> getWalkInByRole({
    required int roleId,
    String? employeeId,
    String? visitorUserId,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'roleId': roleId.toString(),
      };
      if (roleId == 4 && visitorUserId != null) {
        queryParams['visitorUserId'] = visitorUserId;
      } else if ((roleId == 1 || roleId == 2 || roleId == 3) &&
          employeeId != null) {
        queryParams['employeeId'] = employeeId;
      } else {
        return 'Invalid role or missing required parameter';
      }
      final uri = Uri.parse(baseUrl + walkinUrl,
      ).replace(queryParameters: queryParams);

      print('REQUEST URL: $uri');

      final response = await http
          .get(
        uri,
        headers: {'Accept': '*/*'},
      )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData == null ||
            decodedData is! List ||
            decodedData.isEmpty) {
          return 'No data found';
        }
        return decodedData
            .map<WalkInVisitorModel>(
                (e) => WalkInVisitorModel.fromJson(e))
            .toList();
      } else {
        return 'Failed to load data (Code: ${response.statusCode})';
      }
    }
    on SocketException {
      return 'No internet connection. Please check your network.';
    }
    on HttpException {
      return 'Server error occurred.';
    }
    on FormatException {
      return 'Invalid response format from server.';
    }
    catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<void> manageEmployeeRole({
    required String employeeId,
    required String action,
    required int roleId,
  }) async {
    final uri = Uri.parse(
      'https://vms-api-805981895260.us-central1.run.app/api/Employee/manage',
    );
    try {
      final response = await http
          .post(
        uri,
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'employeeId': employeeId,
          'action': action,
          'roleId': roleId,
        }),
      )
          .timeout(const Duration(seconds: 15));


      print(uri.toString());
      print(employeeId.toString());
      print(action.toString());
      print(roleId.toString());
      print(response.body.toString());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }
      throw HttpException(
        'Failed to manage employee (Status: ${response.statusCode})',
      );
    }
    on SocketException {
      throw Exception('No internet connection');
    }
    on TimeoutException {
      throw Exception('Request timed out');
    }
    on HttpException catch (e) {
      throw Exception(e.message);
    }
    catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<RoleModel>> getRoles() async {
    try {
      final uri = Uri.parse(baseUrl + 'Employee/roleIDs');

      final response = await http
          .get(uri, headers: {
        'Content-Type': 'application/json',
      })
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          return decoded
              .map<RoleModel>((e) => RoleModel.fromJson(e))
              .toList();
        } else {
          throw const FormatException('Invalid response format');
        }
      } else {
        throw HttpException(
          'Failed to load roles (Status: ${response.statusCode})',
        );
      }
    }
    on SocketException {
      throw Exception('No internet connection');
    }
    on HttpException catch (e) {
      throw Exception(e.message);
    }
    on FormatException catch (e) {
      throw Exception('Data format error: ${e.message}');
    }
    catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  Future<dynamic> getWalkInHistory({
    required int roleId,
    String? employeeId,
    String? visitorUserId,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'roleId': roleId.toString(),
      };
      if (roleId == 4 && visitorUserId != null) {
        queryParams['visitorUserId'] = visitorUserId;
      } else if ((roleId == 1 || roleId == 2 || roleId == 3) &&
          employeeId != null) {
        queryParams['employeeId'] = employeeId;
      } else {
        return 'Invalid role or missing required parameter';
      }
      final uri = Uri.parse(baseUrl + walkinHistoryUrl,
      ).replace(queryParameters: queryParams);

      print('REQUEST URL: $uri');

      final response = await http
          .get(
        uri,
        headers: {'Accept': '*/*'},
      )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData == null ||
            decodedData is! List ||
            decodedData.isEmpty) {
          return 'No data found';
        }
        return decodedData
            .map<WalkInVisitorModel>(
                (e) => WalkInVisitorModel.fromJson(e))
            .toList();
      } else {
        return 'Failed to load data (Code: ${response.statusCode})';
      }
    }
    on SocketException {
      return 'No internet connection. Please check your network.';
    }
    on HttpException {
      return 'Server error occurred.';
    }
    on FormatException {
      return 'Invalid response format from server.';
    }
    catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }
}
