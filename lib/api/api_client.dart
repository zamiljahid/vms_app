import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/company_model.dart';
import '../models/menu _model.dart';
import '../screens/select_screen.dart';
import '../screens/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


const String baseUrl = 'https://vms-api-805981895260.us-central1.run.app/';
const String companyValidatorUrl = 'api/Company/validate';
const String employeeLoginUrl = 'api/Auth/employee-login';
const String visitorLoginUrl = 'api/Auth/visitor-login';
const String visitorRegisterUrl = 'api/User/registerUser';
const String menuUrl = 'api/Menu/get-menus?roleId=';

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
  Future<CompanyModel?> getCompanyData(String api) async {
    final deviceType = getDeviceCategory();
    final url = Uri.parse('$baseUrl$companyValidatorUrl?appKey=$api&deviceType=$deviceType');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      return CompanyModel.fromJson(data);
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }


  Future<Map<String, dynamic>> employeeLogin({
    required String companyId,
    required String loginId,
    required String password,
  })
  async {
    final url = Uri.parse(baseUrl + employeeLoginUrl);
    final payload = {
      'companyId': companyId,
      'loginId': loginId,
      'password': password,
    };
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

  Future<Map<String, dynamic>> visitorLogin({
    required String phone,
    required String password,
  })
  async {
    final url = Uri.parse(baseUrl + visitorLoginUrl);
    final payload = {
      'phone': phone,
      'password': password,
    };
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

  Future<Map<String, dynamic>> visitorRegister({
    required String phone,
    required String password,
    required String email,
    required String name,
    required String address,
    required String passport,
    required String nid,
  })
  async {
    final url = Uri.parse(baseUrl + visitorRegisterUrl);
    final payload = {
      'phone': phone,
      'password': password,
      'name': name,
      'email': email,
      'address': address,
      'passport': password,
      'nid': nid,
    };
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

  Future<ApiResponse<List<MenuModel>>> getMenusByRole(
      int roleId) async {
    try {
      final uri = Uri.parse(baseUrl + menuUrl + roleId.toString(),
      );

      final response = await http
          .get(
        uri,
        headers: {
          'accept': '*/*',
        },
      )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['success'] == true) {
          final List list = decoded['data'];

          final menus = list
              .map((e) => MenuModel.fromJson(e))
              .toList();

          return ApiResponse(
            success: true,
            data: menus,
          );
        } else {
          return ApiResponse(
            success: false,
            message: decoded['message'] ?? 'Failed to load menus',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message:
          'Server error (${response.statusCode})',
        );
      }
    }
    on SocketException {
      return ApiResponse(
        success: false,
        message: 'No internet connection',
      );
    }
    on HttpException {
      return ApiResponse(
        success: false,
        message: 'HTTP error occurred',
      );
    }
    on FormatException {
      return ApiResponse(
        success: false,
        message: 'Invalid response format',
      );
    }
    on TimeoutException {
      return ApiResponse(
        success: false,
        message: 'Request timeout',
      );
    }
    catch (e) {
      return ApiResponse(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }
}