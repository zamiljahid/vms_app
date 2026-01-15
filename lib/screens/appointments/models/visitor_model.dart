class VisitorModel {
  final int visitorIdentityId;
  final int visitorUserId;
  final String? visitorEmployeeId;
  final String visitorName;
  final String visitorPhone;
  final String visitorEmail;
  final String visitorLocationOrCompany;

  VisitorModel({
    required this.visitorIdentityId,
    required this.visitorUserId,
    this.visitorEmployeeId,
    required this.visitorName,
    required this.visitorPhone,
    required this.visitorEmail,
    required this.visitorLocationOrCompany,
  });

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    return VisitorModel(
      visitorIdentityId: json['visitorIdentityId'] ?? 0,
      visitorUserId: json['visitorUserId'] ?? 0,
      visitorEmployeeId: json['visitorEmployeeId'],
      visitorName: json['visitorName'] ?? '',
      visitorPhone: json['visitorPhone'] ?? '',
      visitorEmail: json['visitorEmail'] ?? '',
      visitorLocationOrCompany: json['visitorLocationOrCompany'] ?? '',
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