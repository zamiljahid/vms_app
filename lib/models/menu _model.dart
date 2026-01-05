class MenuModel {
  final int menuId;
  final String menuName;

  MenuModel({
    required this.menuId,
    required this.menuName,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      menuId: json['menuId'],
      menuName: json['menuName'],
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
  });
}
