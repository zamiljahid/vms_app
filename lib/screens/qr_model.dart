class QrVerifyResponse {
  final String status;
  final String message;
  final VisitData data;

  QrVerifyResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory QrVerifyResponse.fromJson(Map<String, dynamic> json) {
    final msg = json['message'];
    return QrVerifyResponse(
      status: msg['status'],
      message: msg['message'],
      data: VisitData.fromJson(msg['data']),
    );
  }
}

class VisitData {
  final int visitId;
  final String companyName;
  final String purpose;
  final String visitDate;
  final String requestTime;
  final String employeeName;
  final String employeeId;
  final String qrType;
  final List<Visitor> visitors;

  VisitData({
    required this.visitId,
    required this.companyName,
    required this.purpose,
    required this.visitDate,
    required this.requestTime,
    required this.employeeName,
    required this.employeeId,
    required this.qrType,
    required this.visitors,
  });

  factory VisitData.fromJson(Map<String, dynamic> json) {
    return VisitData(
      visitId: json['visitId'],
      companyName: json['companyName'],
      purpose: json['purpose'],
      visitDate: json['visitDate'],
      requestTime: json['requestTime'],
      employeeName: json['employeeName'],
      employeeId: json['employeeId'],
      qrType: json['qrType'],
      visitors: (json['visitorList'] as List)
          .map((e) => Visitor.fromJson(e))
          .toList(),
    );
  }
}

class Visitor {
  final String name;
  final String phone;
  final String? designation;
  final String? branch;

  Visitor({
    required this.name,
    required this.phone,
    this.designation,
    this.branch,
  });

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      name: json['name'],
      phone: json['phone'],
      designation: json['designation'], // may be null
      branch: json['branch'],           // may be null
    );
  }
}