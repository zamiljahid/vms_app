import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visitor_management/screens/all_company_list_model.dart';

import '../../api/api_client.dart';
import '../../models/company_model.dart';
import '../shared_preference.dart';

class SendInvitationScreen extends StatefulWidget {
  const SendInvitationScreen({super.key});

  @override
  State<SendInvitationScreen> createState() => _SendInvitationScreenState();
}

class _SendInvitationScreenState extends State<SendInvitationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isInviting = false;
  final purpose = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  String? selectedEmployeeId;
  int? selectedEmployeeIdentityId;
  String? selectedEmployeeName;
  bool _isSearchingEmployee = false;
  int? selectedCompanyId;
  List<AllCompanyListModel> companyList = [];
  bool isLoadingCompanies = true;
  String? companyError;
  List<Map<String, dynamic>> employeeSearchResults = [];
  final TextEditingController employeeSearchController =
      TextEditingController();
  Timer? _debounce;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    loadCompanies();
  }

  Future<void> loadCompanies() async {
    setState(() {
      isLoadingCompanies = true;
      companyError = null;
    });

    try {
      companyList = await ApiClient().fetchCompaniesFixed();
      print(
        "Companies loaded: ${companyList.map((c) => c.companyName).toList()}",
      );
    } catch (e) {
      companyError = e.toString();
      print("Error loading companies: $companyError");
    } finally {
      setState(() {
        isLoadingCompanies = false;
      });
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Add selected employee
  void _addEmployee(Map<String, dynamic> employee) {
    setState(() {
      selectedEmployeeId = employee['employeeId']; // e.g., "UGE01"
      selectedEmployeeIdentityId = employee['employeeIdentityId']; // integer 3
      selectedEmployeeName = employee['name'];

      print("Selected Employee ID (string): $selectedEmployeeId");
      print("Selected Employee Identity ID (int): $selectedEmployeeIdentityId");

      employeeSearchResults.clear();
      employeeSearchController.clear();
    });
  }

  // Remove employee
  void _removeEmployee() {
    setState(() {
      selectedEmployeeId = null;
      selectedEmployeeName = null;
      selectedEmployeeIdentityId = null;
    });
  }

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
        dateController.text = "${picked.day}-${picked.month}-${picked.year}";
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

  Future<void> onInvitePressed() async {
    if (selectedCompanyId == null) {
      _showMessage("Please select a company");
      return;
    }

    if (selectedEmployeeIdentityId == null) {
      _showMessage("Please select an employee");
      return;
    }

    if (purpose.text.trim().isEmpty) {
      _showMessage("Purpose is required");
      return;
    }

    if (selectedDate == null) {
      _showMessage("Please select a date");
      return;
    }

    if (selectedTime == null) {
      _showMessage("Please select a time");
      return;
    }

    setState(() => _isInviting = true);

    try {
      // Format date as YYYY-MM-DD
      final inviteDate =
          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

      // Format time as HH:mm:ss
      final inviteTime =
          "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00";

      // Send API
      await ApiClient().sendInvitation(
        senderIdentityId: SharedPrefs.getInt('identity')!,
        receiverIdentityId: selectedEmployeeIdentityId!,
        purpose: purpose.text.trim(),
        inviteDate: inviteDate,
        inviteTime: inviteTime,
        issueDateTime: DateTime.now().toUtc().toIso8601String(),
      );

      if (!mounted) return;

      // Clear all values
      setState(() {
        selectedCompanyId = null;
        selectedEmployeeId = null;
        selectedEmployeeIdentityId = null;
        selectedEmployeeName = null;
        purpose.clear();
        dateController.clear();
        timeController.clear();
        employeeSearchController.clear();
        selectedDate = null;
        selectedTime = null;
        employeeSearchResults.clear();
      });

      _showMessage("Invitation sent successfully");
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _isInviting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final validCompanies = companyList.where((c) => c.companyId != null).toList();

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _circleButton(Icons.arrow_back),
                        Text(
                          "Send Invitation",
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
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                          DropdownButtonFormField<int>(
                            items: companyList
                                .map(
                                  (c) => DropdownMenuItem<int>(
                                value: c.companyId,
                                child: Text(
                                  c.companyName,
                                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                                ),
                              ),
                            )
                                .toList(),
                            value: selectedCompanyId,
                            onChanged: (val) {
                              setState(() {
                                selectedCompanyId = val;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: "Select Company",
                              labelStyle: TextStyle(color: Theme.of(context).primaryColorDark),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              filled: true,
                              fillColor: Colors.white, // optional background color
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorDark,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorDark,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorDark,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            dropdownColor: Colors.white,
                            style: TextStyle(color: Theme.of(context).primaryColorDark),
                          ),
                            if (selectedEmployeeId == null)
                              Column(
                                children: [
                                  const SizedBox(height: 15),
                                  TextFormField(
                                    controller: employeeSearchController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      labelText: "Search Employee",
                                      labelStyle: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      fillColor: Theme.of(
                                        context,
                                      ).primaryColorDark.withOpacity(0.06),
                                      filled: true,
                                      suffixIcon:
                                          _isSearchingEmployee
                                              ? Padding(
                                                padding: EdgeInsets.all(12),
                                                child: SizedBox(
                                                  height: 18,
                                                  width: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 4,
                                                        color:
                                                            Theme.of(
                                                              context,
                                                            ).primaryColorDark,
                                                      ),
                                                ),
                                              )
                                              : null,
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(
                                                context,
                                              ).primaryColorDark,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(
                                                context,
                                              ).primaryColorDark,
                                        ),
                                      ),
                                    ),
                                    onChanged: (val) {
                                      if (_debounce?.isActive ?? false) {
                                        _debounce!.cancel();
                                      }

                                      _debounce = Timer(
                                        const Duration(milliseconds: 500),
                                        () async {
                                          final phone = val.trim();

                                          if (phone.isEmpty) {
                                            setState(() {
                                              employeeSearchResults.clear();
                                              _isSearchingEmployee = false;
                                            });
                                            return;
                                          }

                                          setState(() {
                                            _isSearchingEmployee = true;
                                            employeeSearchResults.clear();
                                          });

                                          try {
                                            final results = await ApiClient()
                                                .searchEmployeeByPhone(phone);

                                            if (!mounted) return;

                                            setState(() {
                                              employeeSearchResults = results;
                                            });
                                          } catch (e) {
                                            if (!mounted) return;
                                            _showMessage(
                                              "Network error. Please check internet",
                                            );
                                          } finally {
                                            if (!mounted) return;
                                            setState(() {
                                              _isSearchingEmployee = false;
                                            });
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            const SizedBox(height: 10),
                            if (employeeSearchResults.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Theme.of(context).primaryColorDark,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Search Results",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Card(
                                      color: Theme.of(context).primaryColorDark,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 4,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxHeight: 100,
                                          ),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount:
                                                employeeSearchResults.length,
                                            itemBuilder: (context, index) {
                                              final employee =
                                                  employeeSearchResults[index];
                                              return ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor:
                                                      Theme.of(
                                                        context,
                                                      ).primaryColorLight,
                                                  child: Icon(
                                                    Icons.person,
                                                    color:
                                                        Theme.of(
                                                          context,
                                                        ).primaryColorDark,
                                                    size: 24,
                                                  ),
                                                ),
                                                title: Text(
                                                  employee['name'],
                                                  style: TextStyle(
                                                    color:
                                                        Theme.of(
                                                          context,
                                                        ).primaryColorLight,
                                                  ),
                                                ),
                                                trailing: IconButton(
                                                  icon: Icon(
                                                    Icons.add,
                                                    color:
                                                        Theme.of(
                                                          context,
                                                        ).primaryColorLight,
                                                  ),
                                                  onPressed:
                                                      () => _addEmployee(
                                                        employee,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (selectedEmployeeId != null)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Theme.of(context).primaryColorDark,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Selected Employee",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Chip(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      backgroundColor: Colors.grey.shade200,
                                      label: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor:
                                                Theme.of(
                                                  context,
                                                ).primaryColorDark,
                                            child: Icon(
                                              Icons.person,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColorLight,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            selectedEmployeeName ?? "",
                                            style: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColorDark,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      deleteIcon: const Icon(
                                        Icons.close,
                                        size: 20,
                                      ),
                                      onDeleted: _removeEmployee,
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(height: 10),
                            _field("Purpose", purpose),
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
                                  backgroundColor:
                                      Theme.of(context).primaryColorDark,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed:
                                    _isInviting ? null : onInvitePressed,
                                child:
                                    _isInviting
                                        ? Text(
                                          "Inviting...",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).primaryColorLight,
                                          ),
                                        )
                                        : Text(
                                          "Invite",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).primaryColorLight,
                                          ),
                                        ),
                              ),
                            ),
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
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColorDark,
        ),
        child: Icon(icon, color: Theme.of(context).primaryColorLight, size: 20),
      ),
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
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
