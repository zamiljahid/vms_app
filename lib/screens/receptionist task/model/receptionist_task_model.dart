enum ReceptionistTaskType {
  visit,
  walkIn,
  invite,
}

class ReceptionistTaskModel {
  // Common
  final ReceptionistTaskType type;
  final String purpose;
  final String status;
  final DateTime appliedOrIssuedDateTime;

  // Visit specific
  final int? visitId;
  final DateTime? appointmentDate;
  final String? appointmentTime;
  final List<VisitorModel>? visitors;
  final String? creatorId;
  final String? creatorName;
  final String? creatorPhone;
  final String? creatorEmail;

  // Walk-in specific
  final int? walkInId;
  final String? manualName;
  final String? manualPhone;
  final String? manualEmail;
  final String? manualAddress;
  final bool? hasPassport;
  final bool? hasNid;
  final String? passportOrNidField;
  final DateTime? scheduledDateTime;

  // Host info for walk-in
  final String? hostEmployeeId;
  final String? hostEmployeeName;
  final String? hostEmployeePhone;
  final String? hostEmployeeEmail;
  final String? hostDesignation;
  final String? hostDepartment;
  final String? hostCompanyName;

  // Invite specific
  final DateTime? inviteDate;
  final String? inviteTime;
  final String? senderName;
  final String? receiverName;
  final String? senderPhone;
  final String? receiverPhone;
  final String? senderEmail;
  final String? receiverEmail;
  final String? senderAddress;
  final String? receiverAddress;
  final String? senderDesignation;
  final String? receiverDesignation;
  final String? senderCompany;
  final String? receiverCompany;
  final String? senderIdentityType;
  final String? receiverIdentityType;

  ReceptionistTaskModel({
    required this.type,
    required this.purpose,
    required this.status,
    required this.appliedOrIssuedDateTime,

    // Visit
    this.visitId,
    this.appointmentDate,
    this.appointmentTime,
    this.visitors,
    this.creatorId,
    this.creatorName,
    this.creatorPhone,
    this.creatorEmail,

    // Walk-in
    this.walkInId,
    this.manualName,
    this.manualPhone,
    this.manualEmail,
    this.manualAddress,
    this.hasPassport,
    this.hasNid,
    this.passportOrNidField,
    this.scheduledDateTime,
    this.hostEmployeeId,
    this.hostEmployeeName,
    this.hostEmployeePhone,
    this.hostEmployeeEmail,
    this.hostDesignation,
    this.hostDepartment,
    this.hostCompanyName,

    // Invite
    this.inviteDate,
    this.inviteTime,
    this.senderName,
    this.receiverName,
    this.senderPhone,
    this.receiverPhone,
    this.senderEmail,
    this.receiverEmail,
    this.senderAddress,
    this.receiverAddress,
    this.senderDesignation,
    this.receiverDesignation,
    this.senderCompany,
    this.receiverCompany,
    this.senderIdentityType,
    this.receiverIdentityType,
  });

  // Visit JSON
// Visit JSON
  factory ReceptionistTaskModel.fromVisitJson(Map<String, dynamic> json) {
    return ReceptionistTaskModel(
      type: ReceptionistTaskType.visit,
      visitId: json['visitId'] as int?,
      purpose: json['purpose']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      appointmentDate: json['appointmentDate'] != null
          ? DateTime.tryParse(json['appointmentDate'].toString())
          : null,
      appointmentTime: json['appointmentTime']?.toString(),
      appliedOrIssuedDateTime: json['appliedDateTime'] != null
          ? DateTime.tryParse(json['appliedDateTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      visitors: (json['visitors'] as List?)
          ?.map((e) => VisitorModel.fromJson(e))
          .toList(),
      creatorId: json['creatorId']?.toString(),
      creatorName: json['creatorName']?.toString(),
      creatorPhone: json['creatorPhone']?.toString(),
      creatorEmail: json['creatorEmail']?.toString(),
    );
  }

// Walk-in JSON
  factory ReceptionistTaskModel.fromWalkInJson(Map<String, dynamic> json) {
    return ReceptionistTaskModel(
      type: ReceptionistTaskType.walkIn,
      walkInId: json['walkInId'] as int?,
      purpose: json['purpose']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      manualName: json['manualName']?.toString(),
      manualPhone: json['manualPhone']?.toString(),
      manualEmail: json['manualEmail']?.toString(),
      manualAddress: json['manualAddress']?.toString(),
      hasPassport: json['hasPassport'] as bool?,
      hasNid: json['hasNid'] as bool?,
      passportOrNidField: json['passportOrNidField']?.toString(),
      scheduledDateTime: json['scheduledDateTime'] != null
          ? DateTime.tryParse(json['scheduledDateTime'].toString())
          : null,
      appliedOrIssuedDateTime: json['appliedDateTime'] != null
          ? DateTime.tryParse(json['appliedDateTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      hostEmployeeId: json['hostEmployeeId']?.toString(),
      hostEmployeeName: json['hostEmployeeName']?.toString(),
      hostEmployeePhone: json['hostEmployeePhone']?.toString(),
      hostEmployeeEmail: json['hostEmployeeEmail']?.toString(),
      hostDesignation: json['hostDesignation']?.toString(),
      hostDepartment: json['hostDepartment']?.toString(),
      hostCompanyName: json['hostCompanyName']?.toString(),
    );
  }

  // Invite JSON
  factory ReceptionistTaskModel.fromInviteJson(Map<String, dynamic> json) {
    return ReceptionistTaskModel(
      type: ReceptionistTaskType.invite,
      purpose: json['purpose'],
      status: 'invited',
      inviteDate: DateTime.parse(json['inviteDate']),
      inviteTime: json['inviteTime'],
      appliedOrIssuedDateTime: DateTime.parse(json['issueDateTime']),
      senderName: json['senderName'],
      receiverName: json['receiverName'],
      senderPhone: json['senderPhone'],
      receiverPhone: json['receiverPhone'],
      senderEmail: json['senderEmail'],
      receiverEmail: json['receiverEmail'],
      senderAddress: json['senderAddress'],
      receiverAddress: json['receiverAddress'],
      senderDesignation: json['senderDesignation'],
      receiverDesignation: json['receiverDesignation'],
      senderCompany: json['senderCompanyName'],
      receiverCompany: json['receiverCompanyName'],
      senderIdentityType: json['senderIdentityType'],
      receiverIdentityType: json['receiverIdentityType'],
    );
  }
}

class VisitorModel {
  final int? visitorIdentityId;
  final String? visitorEmployeeId;
  final String? visitorUserId; // Keep as String? but handle the conversion
  final String? visitorName;
  final String? visitorPhone;
  final String? visitorEmail;
  final String? visitorLocationOrCompany;

  VisitorModel({
    this.visitorIdentityId,
    this.visitorEmployeeId,
    this.visitorUserId,
    this.visitorName,
    this.visitorPhone,
    this.visitorEmail,
    this.visitorLocationOrCompany,
  });

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    return VisitorModel(
      visitorIdentityId: json['visitorIdentityId'] as int?,
      // Use .toString() to safely handle int or String types from JSON
      visitorUserId: json['visitorUserId']?.toString(),
      visitorEmployeeId: json['visitorEmployeeId']?.toString(),
      visitorName: json['visitorName']?.toString(),
      visitorPhone: json['visitorPhone']?.toString(),
      visitorEmail: json['visitorEmail']?.toString(),
      visitorLocationOrCompany: json['visitorLocationOrCompany']?.toString(),
    );
  }
}