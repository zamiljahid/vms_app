class UpcomingInviteModel {
  final String inviteDate;
  final String inviteTime;
  final DateTime issueDateTime;
  final String purpose;
  final String otherRole;
  final String otherName;
  final String otherPhone;
  final String? otherAddress;
  final String otherDesignation;
  final String otherCompanyName;

  UpcomingInviteModel({
    required this.inviteDate,
    required this.inviteTime,
    required this.issueDateTime,
    required this.purpose,
    required this.otherRole,
    required this.otherName,
    required this.otherPhone,
    this.otherAddress,
    required this.otherDesignation,
    required this.otherCompanyName,
  });

  factory UpcomingInviteModel.fromJson(Map<String, dynamic> json) {
    return UpcomingInviteModel(
      inviteDate: json['inviteDate'] ?? '',
      inviteTime: json['inviteTime'] ?? '',
      issueDateTime: DateTime.parse(json['issueDateTime']),
      purpose: json['purpose'] ?? '',
      otherRole: json['otherRole'] ?? '',
      otherName: json['otherName'] ?? '',
      otherPhone: json['otherPhone'] ?? '',
      otherAddress: json['otherAddress'],
      otherDesignation: json['otherDesignation'] ?? '',
      otherCompanyName: json['otherCompanyName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inviteDate': inviteDate,
      'inviteTime': inviteTime,
      'issueDateTime': issueDateTime.toIso8601String(),
      'purpose': purpose,
      'otherRole': otherRole,
      'otherName': otherName,
      'otherPhone': otherPhone,
      'otherAddress': otherAddress,
      'otherDesignation': otherDesignation,
      'otherCompanyName': otherCompanyName,
    };
  }
  static List<UpcomingInviteModel> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => UpcomingInviteModel.fromJson(json))
        .toList();
  }
}