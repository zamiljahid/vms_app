class RoleModel {
  final int roleId;
  final String roleName;

  RoleModel({
    required this.roleId,
    required this.roleName,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      roleId: json['roleId'] ?? 0,
      roleName: json['roleName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'roleName': roleName,
    };
  }
}