class ManageAppointmentModel {
  int visitId;
  String purpose;
  String appointmentDate;
  String appointmentTime;
  DateTime appliedDateTime;
  String status;
  String creatorId;
  String creatorName;
  String creatorPhone;
  String creatorEmail;
  List<Visitor> visitors;

  ManageAppointmentModel({
    required this.visitId,
    required this.purpose,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.appliedDateTime,
    required this.status,
    required this.creatorId,
    required this.creatorName,
    required this.creatorPhone,
    required this.creatorEmail,
    required this.visitors,
  });

  factory ManageAppointmentModel.fromJson(Map<String, dynamic> json) {
    return ManageAppointmentModel(
      visitId: json['visitId'],
      purpose: json['purpose'],
      appointmentDate: json['appointmentDate'],
      appointmentTime: json['appointmentTime'],
      appliedDateTime: DateTime.parse(json['appliedDateTime']),
      status: json['status'],
      creatorId: json['creatorId'],
      creatorName: json['creatorName'],
      creatorPhone: json['creatorPhone'],
      creatorEmail: json['creatorEmail'],
      visitors: (json['visitors'] as List)
          .map((v) => Visitor.fromJson(v))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visitId': visitId,
      'purpose': purpose,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'appliedDateTime': appliedDateTime.toIso8601String(),
      'status': status,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorPhone': creatorPhone,
      'creatorEmail': creatorEmail,
      'visitors': visitors.map((v) => v.toJson()).toList(),
    };
  }
}

class Visitor {
  int visitorIdentityId;
  int? visitorUserId;
  String? visitorEmployeeId;
  String visitorName;
  String visitorPhone;
  String visitorEmail;
  String visitorLocationOrCompany;

  Visitor({
    required this.visitorIdentityId,
    this.visitorUserId,
    this.visitorEmployeeId,
    required this.visitorName,
    required this.visitorPhone,
    required this.visitorEmail,
    required this.visitorLocationOrCompany,
  });

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      visitorIdentityId: json['visitorIdentityId'],
      visitorUserId: json['visitorUserId'],
      visitorEmployeeId: json['visitorEmployeeId'],
      visitorName: json['visitorName'],
      visitorPhone: json['visitorPhone'],
      visitorEmail: json['visitorEmail'],
      visitorLocationOrCompany: json['visitorLocationOrCompany'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visitorIdentityId': visitorIdentityId,
      'visitorUserId': visitorUserId,
      'visitorEmployeeId': visitorEmployeeId,
      'visitorName': visitorName,
      'visitorPhone': visitorPhone,
      'visitorEmail': visitorEmail,
      'visitorLocationOrCompany': visitorLocationOrCompany,
    };
  }
}