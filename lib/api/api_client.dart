import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/company_model.dart';
import '../screens/select_screen.dart';
import '../screens/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


const String baseUrl = 'https://vms-api-805981895260.us-central1.run.app/';
const String companyValidatorUrl = 'api/Company/validate';
const String employeeLoginUrl = 'api/Auth/employee-login';


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


  Future<Map<String, dynamic>> loginUser({
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


}