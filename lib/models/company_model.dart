class CompanyModel {
  bool? success;
  String? message;
  int? companyId;
  String? companyName;
  int? theme;
  String? appKey;
  bool? isActive;
  bool? isAndroid;
  bool? isIos;

  CompanyModel({
    this.success,
    this.message,
    this.companyId,
    this.companyName,
    this.theme,
    this.appKey,
    this.isActive,
    this.isAndroid,
    this.isIos,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    final data = json['data']; // <-- THIS is the fix

    return CompanyModel(
      success: json['success'],
      message: json['message'],
      companyId: data?['companyId'],
      companyName: data?['companyName'],
      theme: data?['theme'],
      appKey: data?['appKey'],
      isActive: data?['isActive'],
      isAndroid: data?['isAndroid'],
      isIos: data?['isIos'],
    );
  }
}