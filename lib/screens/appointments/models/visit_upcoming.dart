import 'package:visitor_management/screens/appointments/models/visitor_model.dart';

class UpcomingVisitModel {
  final int visitId;
  final String purpose;
  final String appointmentDate;
  final String appointmentTime;
  final String appliedDateTime;
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

  final String qrType;
  final String issuedAt;
  final String qrData;

  final List<VisitorModel> visitors;

  UpcomingVisitModel({
    required this.visitId,
    required this.purpose,
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
    required this.qrType,
    required this.issuedAt,
    required this.qrData,
    required this.visitors,
  });

  factory UpcomingVisitModel.fromJson(Map<String, dynamic> json) {
    return UpcomingVisitModel(
      visitId: json['visitId'],
      purpose: json['purpose'] ?? '',
      appointmentDate: json['appointmentDate'] ?? '',
      appointmentTime: json['appointmentTime'] ?? '',
      appliedDateTime: json['appliedDateTime'] ?? '',
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

      qrType: json['qrType'] ?? '',
      issuedAt: json['issuedAt'] ?? '',
      qrData: json['qrData'] ?? '',

      visitors: (json['visitors'] as List? ?? [])
          .map((e) => VisitorModel.fromJson(e))
          .toList(),
    );
  }

  static List<UpcomingVisitModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((e) => UpcomingVisitModel.fromJson(e)).toList();
  }
}