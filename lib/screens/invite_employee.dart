import 'package:flutter/material.dart';
class CompanyModel {
  final int id;
  final String name;
  CompanyModel(this.id, this.name);
}


class InviteEmployee extends StatefulWidget {
  const InviteEmployee({super.key});

  @override
  State<InviteEmployee> createState() => _InviteEmployeeState();
}

class _InviteEmployeeState extends State<InviteEmployee> {
  final _formKey = GlobalKey<FormState>();

  final List<CompanyModel> _companies = [
    CompanyModel(1, "United Group"),
    CompanyModel(2, "Bashundhara Group"),
    CompanyModel(3, "Meghna Group"),
  ];
  int? _selectedCompanyId;
  final _phone = TextEditingController();
  final _employeeName= TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();


  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text =
        "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
        timeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B1F3A),

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
                            "Invitation",
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
                                value: _selectedCompanyId,
                                dropdownColor: Theme.of(context).primaryColorDark,
                                menuMaxHeight: 300,
                                isExpanded: true,
                                hint: Text(
                                  "Select Company",
                                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                                ),
                                decoration: InputDecoration(
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

                                items: _companies.map((company) {
                                  return DropdownMenuItem(
                                    value: company.id,
                                    child: Text(
                                      company.name,
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColorLight,
                                      ),
                                    ),
                                  );
                                }).toList(),

                                onChanged: (value) {
                                  setState(() {
                                    _selectedCompanyId = value;
                                  });
                                },

                                validator: (value) {
                                  if (value == null) {
                                    return "Please select a company";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            _field("Phone Number", _phone,
                                keyboard: TextInputType.phone),
                            _field("Employee Name", _employeeName,
                                keyboard: TextInputType.phone),



                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: _field("Date", dateController),
                              ),
                            ),

                            GestureDetector(
                              onTap: () => _selectTime(context),
                              child: AbsorbPointer(
                                child: _field("Time", timeController),
                              ),
                            ),

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
                                onPressed: () {},
                                child: Text(
                                  "Invite",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Theme.of(context).primaryColorLight),
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
        style: TextStyle(color: Theme.of(context).primaryColorDark),
        readOnly: false,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Theme.of(context).primaryColorDark),
          fillColor: Theme.of(context).primaryColorDark.withOpacity(0.06),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: Theme.of(context).primaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}
