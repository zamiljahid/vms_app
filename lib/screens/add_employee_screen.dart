import 'package:flutter/material.dart';

class RoleModel {
  final int id;
  final String name;
  RoleModel(this.id, this.name);
}

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

  // Roles with IDs
  final List<RoleModel> _roles = [
    RoleModel(1, "Admin"),
    RoleModel(2, "Employee"),
    RoleModel(3, "Receptionist"),
  ];

  int? _selectedRoleId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B1F3A),

      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // Background gradient
              Container(
                decoration:  BoxDecoration(
                  color: Theme.of(context).primaryColorDark,
                  // gradient: LinearGradient(
                  //   colors: [
                  //     Color(0xff4f7cff),
                  //     Color(0xff1c3b70),
                  //     Color(0xff08162d),
                  //   ],
                  //   begin: Alignment.topCenter,
                  //   end: Alignment.bottomCenter,
                  // ),
                ),
              ),

              // Top Header
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

                  // ✅ White border ONLY on bottom
                  border: const Border(
                    bottom: BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _circleButton(Icons.arrow_back_ios_new),
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

    ),

              // Form Container
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
                        child: Column(
                          children: [
                            DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<int>(
                                value: _selectedRoleId,
                                dropdownColor: Theme.of(context).primaryColorDark,
                                menuMaxHeight: 300,
                                isExpanded: true,
                                hint: Text(
                                  "Select Role Type",
                                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                                ),
                                decoration: InputDecoration(
                                  // labelText: "Role",
                                  labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                                  fillColor: Theme.of(context).primaryColorDark,
                                  filled: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).primaryColorDark,
                                      width: 1.5,
                                    ),
                                  ),
                                ),

                                style: TextStyle(color: Theme.of(context).primaryColorDark),
                                iconEnabledColor: Theme.of(context).primaryColorLight,

                                items: _roles.map((role) {
                                  return DropdownMenuItem(
                                    value: role.id,
                                    child: Text(
                                      role.name,
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColorLight,
                                      ),
                                    ),
                                  );
                                }).toList(),

                                onChanged: (value) {
                                  setState(() {
                                    _selectedRoleId = value;
                                  });
                                },

                                validator: (value) {
                                  if (value == null) {
                                    return "Please select a role";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            _field("Name", _name),
                            _field("Employee ID", _id),
                            _field("Phone Number", _phone,
                                keyboard: TextInputType.phone),
                            _field("Email", _email,
                                keyboard: TextInputType.emailAddress),
                            _field("Department", _dept),
                            _field("Designation", _designation),
                            _field("Password", _password, obscure: true),

                            const SizedBox(height: 20),
                            SizedBox(
                              height: 55,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColorDark,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: () {
                                  print("Selected Role ID = $_selectedRoleId");
                                },
                                child:  Text(
                                  "Add Employee",
                                  style: TextStyle(
                                      fontSize: 18, color: Theme.of(context).primaryColorLight),
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

  Widget _field(
      String label,
      TextEditingController controller, {
        bool obscure = false,
        TextInputType keyboard = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        style:  TextStyle(color: Theme.of(context).primaryColorDark),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:  TextStyle(color: Theme.of(context).primaryColorDark),
          fillColor: Theme.of(context).primaryColorDark.withOpacity(0.06),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
             BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}
