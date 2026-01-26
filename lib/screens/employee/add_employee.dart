import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../shared_preference.dart';
import 'model/role_model.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _id = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _dept = TextEditingController();
  final _designation = TextEditingController();
  final _password = TextEditingController();
  final _branch = TextEditingController();
  final _passport = TextEditingController();
  final _nid = TextEditingController();

  bool isLoading = true;
  List<RoleModel>? roles;
  int? _selectedRoleId;
  String? _selectedRoleName;

  @override
  void initState() {
    super.initState();
    fetchRoles();
  }

  Future<void> fetchRoles() async {
    setState(() {
      isLoading = true;
      roles = null;
    });
    try {
      final data = await ApiClient().getRoles();
      setState(() {
        roles = data.toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load roles: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addEmployee() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedRoleId == null || _selectedRoleName == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a role')));
      return;
    }

    final payload = {
      "employeeId": _id.text.trim(),
      "name": _name.text.trim(),
      "phone": _phone.text.trim(),
      "email": _email.text.trim(),
      "department": _dept.text.trim(),
      "designation": _designation.text.trim(),
      "password": _password.text.trim(),
      "companyId": SharedPrefs.getString('company_id'),
      "roleId": _selectedRoleId,
      "roleName": _selectedRoleName,
      "passport": _passport.text.trim(),
      "nid": _nid.text.trim(),
      "isPassChange": true,
      "branch": _branch.text.trim()
    };

    setState(() => isLoading = true);

    try {
      await ApiClient().addEmployee(payload, SharedPrefs.getInt('roleId')!,);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee added successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add employee: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    border: const Border(
                      bottom: BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: _circleButton(Icons.arrow_back),
                        ),
                        Text(
                          "Add Employee",
                          style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 42),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 15,
                right: 15,
                top: 130,
                bottom: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: BorderRadius.circular(38),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child:Column(
                          children: [
                            SizedBox(height: 5,),
                            DropdownButtonFormField<int>(
                              value: _selectedRoleId,
                              hint:  Text('Select Role Type'),
                              decoration: InputDecoration(
                                labelText: 'Role',
                                labelStyle: TextStyle(color: Theme.of(context).primaryColorDark),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColorDark, // normal border color
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).secondaryHeaderColor, // focus border color
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1), // optional fill
                              ),
                              items: roles
                                  ?.map(
                                    (r) => DropdownMenuItem(
                                  value: r.roleId,
                                  child: Text(r.roleName),
                                ),
                              )
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedRoleId = val;
                                  _selectedRoleName =
                                      roles?.firstWhere((r) => r.roleId == val).roleName;
                                });
                              },
                              validator: (val) =>
                              val == null ? 'Please select a role' : null,
                            ),
                            const SizedBox(height: 15),
                            _field("Name", _name),
                            _field("Employee ID", _id),
                            _field("Phone Number", _phone, keyboard: TextInputType.phone),
                            _field("Email", _email, keyboard: TextInputType.emailAddress),
                            _field("Department", _dept),
                            _field("Designation", _designation),
                            _field("Branch", _branch),
                            _field("Passport", _passport),
                            _field("NID", _nid),
                            _field("Password", _password, obscure: true),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 55,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColorDark,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: addEmployee,
                                child:  Text(
                                  "Add Employee",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _circleButton(IconData icon) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).primaryColorDark,
      ),
      child: Icon(icon, color: Theme.of(context).primaryColorLight, size: 20),
    );
  }



  Widget _field(String label, TextEditingController controller,
      {bool obscure = false, TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding:  EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Theme.of(context).primaryColorDark),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColorDark, // normal border color
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).secondaryHeaderColor, // focus border color
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1), // optional fill
        ),
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }
}