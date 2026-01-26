class WalkInVisitorModel {
  final int? walkInId;
  final int? visitorIdentityId;
  final int? visitorUserId;
  final String? visitorEmployeeId;
  final String? visitorName;
  final String? visitorPhone;
  final String? visitorEmail;
  final String? visitorLocationOrCompany;

  final String? hostEmployeeId;
  final String? hostEmployeeName;
  final String? hostEmployeePhone;
  final String? hostEmployeeEmail;
  final String? hostDesignation;
  final String? hostDepartment;
  final String? hostCompanyName;

  final String? manualName;
  final String? manualPhone;
  final String? manualEmail;
  final String? manualAddress;

  final bool? hasPassport;
  final bool? hasNid;
  final String? passportOrNidField;

  final String? purpose;
  final DateTime? scheduledDateTime;
  final DateTime? appliedDateTime;
  final String? status;

  WalkInVisitorModel({
    this.walkInId,
    this.visitorIdentityId,
    this.visitorUserId,
    this.visitorEmployeeId,
    this.visitorName,
    this.visitorPhone,
    this.visitorEmail,
    this.visitorLocationOrCompany,
    this.hostEmployeeId,
    this.hostEmployeeName,
    this.hostEmployeePhone,
    this.hostEmployeeEmail,
    this.hostDesignation,
    this.hostDepartment,
    this.hostCompanyName,
    this.manualName,
    this.manualPhone,
    this.manualEmail,
    this.manualAddress,
    this.hasPassport,
    this.hasNid,
    this.passportOrNidField,
    this.purpose,
    this.scheduledDateTime,
    this.appliedDateTime,
    this.status,
  });

  factory WalkInVisitorModel.fromJson(Map<String, dynamic> json) {
    return WalkInVisitorModel(
      walkInId: json['walkInId'],
      visitorIdentityId: json['visitorIdentityId'],
      visitorUserId: json['visitorUserId'],
      visitorEmployeeId: json['visitorEmployeeId'],
      visitorName: json['visitorName'],
      visitorPhone: json['visitorPhone'],
      visitorEmail: json['visitorEmail'],
      visitorLocationOrCompany: json['visitorLocationOrCompany'],
      hostEmployeeId: json['hostEmployeeId'],
      hostEmployeeName: json['hostEmployeeName'],
      hostEmployeePhone: json['hostEmployeePhone'],
      hostEmployeeEmail: json['hostEmployeeEmail'],
      hostDesignation: json['hostDesignation'],
      hostDepartment: json['hostDepartment'],
      hostCompanyName: json['hostCompanyName'],
      manualName: json['manualName'],
      manualPhone: json['manualPhone'],
      manualEmail: json['manualEmail'],
      manualAddress: json['manualAddress'],
      hasPassport: json['hasPassport'],
      hasNid: json['hasNid'],
      passportOrNidField: json['passportOrNidField'],
      purpose: json['purpose'],
      scheduledDateTime: json['scheduledDateTime'] != null
          ? DateTime.parse(json['scheduledDateTime'])
          : null,
      appliedDateTime: json['appliedDateTime'] != null
          ? DateTime.parse(json['appliedDateTime'])
          : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walkInId': walkInId,
      'visitorIdentityId': visitorIdentityId,
      'visitorUserId': visitorUserId,
      'visitorEmployeeId': visitorEmployeeId,
      'visitorName': visitorName,
      'visitorPhone': visitorPhone,
      'visitorEmail': visitorEmail,
      'visitorLocationOrCompany': visitorLocationOrCompany,
      'hostEmployeeId': hostEmployeeId,
      'hostEmployeeName': hostEmployeeName,
      'hostEmployeePhone': hostEmployeePhone,
      'hostEmployeeEmail': hostEmployeeEmail,
      'hostDesignation': hostDesignation,
      'hostDepartment': hostDepartment,
      'hostCompanyName': hostCompanyName,
      'manualName': manualName,
      'manualPhone': manualPhone,
      'manualEmail': manualEmail,
      'manualAddress': manualAddress,
      'hasPassport': hasPassport,
      'hasNid': hasNid,
      'passportOrNidField': passportOrNidField,
      'purpose': purpose,
      'scheduledDateTime': scheduledDateTime?.toIso8601String(),
      'appliedDateTime': appliedDateTime?.toIso8601String(),
      'status': status,
    };
  }
}