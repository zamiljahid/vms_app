class CompanyModel {
  final bool success;
  final String message;
  final int companyId;
  final String companyName;
  final int theme;
  final String appKey;
  final bool isActive;
  final bool isAndroid;
  final bool isIos;

  CompanyModel({
    required this.success,
    required this.message,
    required this.companyId,
    required this.companyName,
    required this.theme,
    required this.appKey,
    required this.isActive,
    required this.isAndroid,
    required this.isIos,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      companyId: json['companyId'] ?? 0,
      companyName: json['companyName'] ?? '',
      theme: json['theme'] ?? 0,
      appKey: json['appKey'] ?? '',
      isActive: json['isActive'] ?? false,
      isAndroid: json['isAndroid'] ?? false,
      isIos: json['isIos'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'companyId': companyId,
      'companyName': companyName,
      'theme': theme,
      'appKey': appKey,
      'isActive': isActive,
      'isAndroid': isAndroid,
      'isIos': isIos,
    };
  }
}
