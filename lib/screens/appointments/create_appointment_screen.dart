import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:visitor_management/api/api_client.dart';
import 'package:visitor_management/screens/shared_preference.dart';

import '../../models/company_model.dart';
import '../all_company_list_model.dart';

class CreateAppointmentScreen extends StatefulWidget {
  const CreateAppointmentScreen({super.key});

  @override
  State<CreateAppointmentScreen> createState() =>
      _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _visitPurpose = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isSubmitting = false;
  final TextEditingController employeeSearchController = TextEditingController();
  final TextEditingController visitorSearchController = TextEditingController();
  bool _isSearchingVisitor = false;
  bool _isSearchingEmployee = false;
  int? selectedCompanyId;
  List<AllCompanyListModel> companyList = [];
  bool isLoadingCompanies = true;
  String? companyError;
  List<Map<String, dynamic>> employeeSearchResults = [];
  List<Map<String, dynamic>> visitorSearchResults = [];

  String? selectedEmployeeId;
  int? selectedEmployeeIdentityId;
  String? selectedEmployeeName;
  List<Map<String, dynamic>> visitorList = [];

  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    print('IDENTITY ID: ${SharedPrefs.getInt('identityId')}');
    loadCompanies();
    _addCurrentUserAsVisitor();

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

  void _addEmployee(Map<String, dynamic> employee) {
    setState(() {
      selectedEmployeeId = employee['employeeId'];
      selectedEmployeeIdentityId = employee['employeeIdentityId'];
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
  void _addCurrentUserAsVisitor() async {
    final identityId = SharedPrefs.getInt('identity');
    final name = SharedPrefs.getString('name');
    if (identityId != null && name != null && name.isNotEmpty) {
      final alreadyAdded = visitorList.any((v) => v['id'] == identityId);
      if (!alreadyAdded) {
        setState(() {
          visitorList.insert(0, {
            'id': identityId,
            'name': name,
            'isCurrentUser': true,
          });
        });
      }
    }
    print("Visitor list after adding current user:");
    visitorList.forEach((v) => print("Visitor: ${v['name']} (ID: ${v['id']})"));
  }
  void _addVisitor(Map<String, dynamic> visitor) {
    final visitorId = visitor['id'];
    if (visitorId == selectedEmployeeIdentityId) {
      _showMessage("Host cannot be added as a visitor!");
      return;
    }
    final alreadyAdded = visitorList.any((v) => v['id'] == visitorId);
    if (!alreadyAdded) {
      setState(() {
        visitorList.add(visitor);
        visitorSearchResults.clear();
        visitorSearchController.clear();
      });
    } else {
      _showMessage("Visitor already added");
    }
    print("Visitor list after adding visitor:");
    visitorList.forEach((v) => print("Visitor: ${v['name']} (ID: ${v['id']})"));
  }
  void _removeVisitor(dynamic id) {
    setState(() {
      visitorList.removeWhere((v) => v['id'] == id && v['isCurrentUser'] != true);
    });

    // Print visitor list for debugging
    print("Visitor list after removal:");
    visitorList.forEach((v) => print("Visitor: ${v['name']} (ID: ${v['id']})"));
  }

  Future<void> _searchVisitorByPhone(String phone) async {
    setState(() {
      _isSearchingVisitor = true;
      visitorSearchResults.clear();
    });

    final url = Uri.parse(
        'https://vms-api-805981895260.us-central1.run.app/api/User/by-phone?phone=$phone');

    try {
      final response = await http.get(url, headers: {'accept': '*/*'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final alreadyAdded = visitorList.any((v) => v['id'] == data['identityId']);
        if (!alreadyAdded) {
          setState(() {
            visitorSearchResults = [
              {
                'id': data['identityId'],
                'name': data['name'],
                'userId': data['userId'],
                'userType': data['userType'],
              }
            ];
          });
        } else {
          _showMessage("Visitor already added");
        }
      } else {
        setState(() => visitorSearchResults.clear());
      }
    } catch (e) {
      _showMessage("Network error. Please check internet");
    } finally {
      setState(() => _isSearchingVisitor = false);
    }
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
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }


  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
        final now = DateTime.now();
        final dt = DateTime(
            now.year, now.month, now.day, picked.hour, picked.minute);
        timeController.text = DateFormat('hh:mm:ss a').format(dt);
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return "$hours:$minutes:00"; // seconds = 00
  }
  Future<void> _submitAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDate == null || selectedTime == null) {
      _showMessage('Please select date & time');
      return;
    }

    setState(() => isSubmitting = true);


    final appointmentTime = _formatTimeOfDay(selectedTime!);

    final appointmentDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    ).toUtc();

    final jsonData = {
      "companyId": selectedCompanyId ?? 0,
      "employeeId": selectedEmployeeId ?? "", // string like "UGE01"
      "visitorIds": visitorList.map((v) => v['id']).toList(),
      "purpose": _visitPurpose.text.trim(),
      "createdByUserId": SharedPrefs.getInt('identity'),
      "appliedDateTime": DateTime.now().toUtc().toIso8601String(),
      "appointmentDate": appointmentDateTime.toIso8601String(),
      "appointmentTime": appointmentTime, // now in HH:mm:ss format
    };
    try {
      final success = await ApiClient().createAppointment(
        baseUrl: baseUrl,
        body: jsonData,
      );

      if (!mounted) return;

      if (success) {
        _showMessage('Appointment created successfully ✅');
        _resetForm();
        Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.pop(context, true);
        });
      }
    } catch (e) {
      if (mounted) _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _visitPurpose.clear();

    setState(() {
      selectedCompanyId = null;
      selectedDate = null;
      selectedTime = null;
      visitorList.clear();
    });
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
                          "Appointment",
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
                                      labelStyle: TextStyle(color: Theme.of(context).primaryColorDark),
                                      fillColor: Theme.of(context).primaryColorDark.withOpacity(0.06),
                                      filled: true,
                                      suffixIcon: _isSearchingEmployee
                                          ? Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 4,
                                            color: Theme.of(context).primaryColorDark,
                                          ),
                                        ),
                                      )
                                          : null,
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
                                      ),
                                    ),
                                    onChanged: (val) {
                                      if (_debounce?.isActive ?? false) {
                                        _debounce!.cancel();
                                      }

                                      _debounce = Timer(const Duration(milliseconds: 500), () async {
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
                                          final results =
                                          await ApiClient().searchEmployeeByPhone(phone);

                                          if (!mounted) return;

                                          setState(() {
                                            employeeSearchResults = results;
                                          });
                                        } catch (e) {
                                          if (!mounted) return;
                                          _showMessage("Network error. Please check internet");
                                        } finally {
                                          if (!mounted) return;
                                          setState(() {
                                            _isSearchingEmployee = false;
                                          });
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            const SizedBox(height: 10),

// EMPLOYEE SEARCH RESULTS
                            if (employeeSearchResults.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Theme.of(context).primaryColorDark, width: 2),
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
                                        color: Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Card(
                                      color: Theme.of(context).primaryColorDark,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      elevation: 4,
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(maxHeight: 100),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: employeeSearchResults.length,
                                            itemBuilder: (context, index) {
                                              final employee = employeeSearchResults[index];
                                              return ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor: Theme.of(context).primaryColorLight,
                                                  child: Icon(
                                                    Icons.person,
                                                    color: Theme.of(context).primaryColorDark,
                                                    size: 24,
                                                  ),
                                                ),
                                                title: Text(
                                                  employee['name'],
                                                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                                                ),
                                                trailing: IconButton(
                                                  icon: Icon(Icons.add, color: Theme.of(context).primaryColorLight),
                                                  onPressed: () => _addEmployee(employee),
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
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Theme.of(context).primaryColorDark, width: 2),
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
                                        color: Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Chip(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      backgroundColor: Colors.grey.shade200,
                                      label: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: Theme.of(context).primaryColorDark,
                                            child: Icon(
                                              Icons.person,
                                              color: Theme.of(context).primaryColorLight,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            selectedEmployeeName ?? "",
                                            style: TextStyle(
                                              color: Theme.of(context).primaryColorDark,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      deleteIcon: const Icon(Icons.close, size: 20),
                                      onDeleted: _removeEmployee,
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(height: 10,),
                            TextFormField(
                              controller: visitorSearchController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: "Add Visitors",
                                labelStyle: TextStyle(color: Theme.of(context).primaryColorDark),
                                fillColor: Theme.of(context).primaryColorDark.withOpacity(0.06),
                                filled: true,
                                suffixIcon: _isSearchingVisitor
                                    ? Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 4,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  ),
                                )
                                    : null,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
                                ),
                              ),
                              onChanged: (val) {
                                if (_debounce?.isActive ?? false) _debounce!.cancel();
                                _debounce = Timer(const Duration(milliseconds: 500), () {
                                  if (val.trim().isNotEmpty) _searchVisitorByPhone(val.trim());
                                  else setState(() => visitorSearchResults.clear());
                                });
                              },
                            ),
                            if (visitorSearchResults.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Theme.of(context).primaryColorDark, width: 2),
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
                                        color: Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Card(
                                      color: Theme.of(context).primaryColorDark,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      elevation: 4,
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(maxHeight: 100),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: visitorSearchResults.length,
                                            itemBuilder: (context, index) {
                                              final visitor = visitorSearchResults[index];
                                              return ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor: Theme.of(context).primaryColorLight,
                                                  child: Icon(
                                                    Icons.person,
                                                    color: Theme.of(context).primaryColorDark,
                                                    size: 24,
                                                  ),
                                                ),
                                                title: Text(
                                                  visitor['name'],
                                                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                                                ),
                                                trailing: IconButton(
                                                  icon: Icon(Icons.add, color: Theme.of(context).primaryColorLight),
                                                  onPressed: () => _addVisitor(visitor),
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
                            const SizedBox(height: 10),
                            if (visitorList.isNotEmpty)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Theme.of(context).primaryColorDark, width: 2),
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
                                      "Visitors",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 10,
                                      children: visitorList
                                          .map(
                                            (v) => Chip(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          backgroundColor: Colors.grey.shade200,
                                          label: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircleAvatar(
                                                radius: 18,
                                                backgroundColor: Theme.of(context).primaryColorDark,
                                                child: Icon(
                                                  Icons.person,
                                                  color: Theme.of(context).primaryColorLight,
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                v['name'],
                                                style: TextStyle(
                                                  color: Theme.of(context).primaryColorDark,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          deleteIcon: const Icon(Icons.close, size: 20),
                                          onDeleted: () => _removeVisitor(v['id']),
                                        ),
                                      )
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(height: 10,),

                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: _field("Appointment Date", dateController),
                              ),
                            ),
                            SizedBox(height: 10,),

                            GestureDetector(
                              onTap: () => _selectTime(context),
                              child: AbsorbPointer(
                                child: _field("Appointment Time", timeController),
                              ),
                            ),
                            SizedBox(height: 10,),

                            _field("Purpose of Visit", _visitPurpose),
                            const SizedBox(height: 10),
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
                                onPressed: isSubmitting ? null : _submitAppointment,                                child: Text(
                                isSubmitting ? "Submitting..." : "Take Appointment",                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context).primaryColorLight,
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
              if (isSubmitting)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.35),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
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