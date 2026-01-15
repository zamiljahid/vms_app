import 'package:visitor_management/screens/appointments/models/visitor_model.dart';

class VisitHistoryModel {
  final int visitId;
  final String purpose;
  final int hostIdentityId;
  final String appointmentDate;
  final String appointmentTime;
  final DateTime appliedDateTime;
  final String status;

  final String hostEmployeeId;
  final String hostEmployeeName;
  final String hostDesignation;
  final String hostDepartment;
  final String hostPhone;
  final String hostEmail;
  final String hostCompanyName;
  final String hostCompanyAddress;

  final String creatorId;
  final String creatorName;
  final String creatorPhone;
  final String creatorEmail;

  final List<VisitorModel> visitors;

  VisitHistoryModel({
    required this.visitId,
    required this.purpose,
    required this.hostIdentityId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.appliedDateTime,
    required this.status,
    required this.hostEmployeeId,
    required this.hostEmployeeName,
    required this.hostDesignation,
    required this.hostDepartment,
    required this.hostPhone,
    required this.hostEmail,
    required this.hostCompanyName,
    required this.hostCompanyAddress,
    required this.creatorId,
    required this.creatorName,
    required this.creatorPhone,
    required this.creatorEmail,
    required this.visitors,
  });

  factory VisitHistoryModel.fromJson(Map<String, dynamic> json) {
    return VisitHistoryModel(
      visitId: json['visitId'],
      purpose: json['purpose'] ?? '',
      hostIdentityId: json['hostIdentityId'],
      appointmentDate: json['appointmentDate'] ?? '',
      appointmentTime: json['appointmentTime'] ?? '',
      appliedDateTime: DateTime.parse(json['appliedDateTime']),
      status: json['status'] ?? '',
      hostEmployeeId: json['hostEmployeeId'] ?? '',
      hostEmployeeName: json['hostEmployeeName'] ?? '',
      hostDesignation: json['hostDesignation'] ?? '',
      hostDepartment: json['hostDepartment'] ?? '',
      hostPhone: json['hostPhone'] ?? '',
      hostEmail: json['hostEmail'] ?? '',
      hostCompanyName: json['hostCompanyName'] ?? '',
      hostCompanyAddress: json['hostCompanyAddress'] ?? '',
      creatorId: json['creatorId'] ?? '',
      creatorName: json['creatorName'] ?? '',
      creatorPhone: json['creatorPhone'] ?? '',
      creatorEmail: json['creatorEmail'] ?? '',
      visitors: (json['visitors'] as List<dynamic>)
          .map((v) => VisitorModel.fromJson(v))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visitId': visitId,
      'purpose': purpose,
      'hostIdentityId': hostIdentityId,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'appliedDateTime': appliedDateTime.toIso8601String(),
      'status': status,
      'hostEmployeeId': hostEmployeeId,
      'hostEmployeeName': hostEmployeeName,
      'hostDesignation': hostDesignation,
      'hostDepartment': hostDepartment,
      'hostPhone': hostPhone,
      'hostEmail': hostEmail,
      'hostCompanyName': hostCompanyName,
      'hostCompanyAddress': hostCompanyAddress,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorPhone': creatorPhone,
      'creatorEmail': creatorEmail,
      'visitors': visitors.map((v) => v?.toJson()).toList(),
    };
  }

  static List<VisitHistoryModel> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => VisitHistoryModel.fromJson(json))
        .toList();
  }
}
