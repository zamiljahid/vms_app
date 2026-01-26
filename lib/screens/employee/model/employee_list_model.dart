class EmployeeModel {
  final String employeeId;
  final String designation;
  final String department;
  final String branch;
  final int companyId;
  final String password;
  final String phone;
  final String email;
  final String name;
  final int roleId;
  final String roleName; // new field
  final String passport;
  final String nid;
  final bool isPassChange;

  EmployeeModel({
    required this.employeeId,
    required this.designation,
    required this.department,
    required this.branch,
    required this.companyId,
    required this.password,
    required this.phone,
    required this.email,
    required this.name,
    required this.roleId,
    required this.roleName, // new field
    required this.passport,
    required this.nid,
    required this.isPassChange,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      employeeId: json['employeeId'] ?? '',
      designation: json['designation'] ?? '',
      department: json['department'] ?? '',
      branch: json['branch'] ?? '',
      companyId: json['companyId'] ?? 0,
      password: json['password'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      roleId: json['roleId'] ?? 0,
      roleName: json['roleName'] ?? '', // new field
      passport: json['passport'] ?? '',
      nid: json['nid'] ?? '',
      isPassChange: json['isPassChange'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'designation': designation,
      'department': department,
      'branch': branch,
      'companyId': companyId,
      'password': password,
      'phone': phone,
      'email': email,
      'name': name,
      'roleId': roleId,
      'roleName': roleName, // new field
      'passport': passport,
      'nid': nid,
      'isPassChange': isPassChange,
    };
  }
}