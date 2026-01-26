class AllCompanyListModel {
  final int companyId;
  final String companyName;
  final int theme;
  final String appKey;
  final bool isActive;
  final bool isAndroid;
  final bool isIos;

  AllCompanyListModel({
    required this.companyId,
    required this.companyName,
    required this.theme,
    required this.appKey,
    required this.isActive,
    required this.isAndroid,
    required this.isIos,
  });

  factory AllCompanyListModel.fromJson(Map<String, dynamic> json) {
    return AllCompanyListModel(
      companyId: json['companyId'],
      companyName: json['companyName'],
      theme: json['theme'],
      appKey: json['appKey'],
      isActive: json['isActive'],
      isAndroid: json['isAndroid'],
      isIos: json['isIos'],
    );
  }
}


class AllCompanyListResponse {
  final bool success;
  final String message;
  final List<AllCompanyListModel> companies;

  AllCompanyListResponse({
    required this.success,
    required this.message,
    required this.companies,
  });

  factory AllCompanyListResponse.fromJson(Map<String, dynamic> json) {
    return AllCompanyListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      companies: (json['data'] as List)
          .map((e) => AllCompanyListModel.fromJson(e))
          .toList(),
    );
  }
}