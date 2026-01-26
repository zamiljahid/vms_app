import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visitor_management/api/api_client.dart';

import '../shared_preference.dart';

class CreateWalkinScreen extends StatefulWidget {
  const CreateWalkinScreen({super.key});

  @override
  State<CreateWalkinScreen> createState() => _CreateWalkinScreenState();
}

class _CreateWalkinScreenState extends State<CreateWalkinScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _purpose = TextEditingController();
  final _passportOrNid = TextEditingController();
  final employeeIdController = TextEditingController();
  final visitorSearchController = TextEditingController();

  final dateController = TextEditingController();
  final timeController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DateTime appliedDateTime = DateTime.now();

  bool isRegistered = true;
  bool hasPassport = false;
  bool hasNid = false;
  bool isSubmitting = false;

  String? selectedEmployeeId,
      selectedEmployeeName,
      selectedVisitorId,
      selectedVisitorName;
  int? selectedEmployeeIID, selectedVisitorIID;
  bool _isSearchingEmployee = false;
  bool _isSearchingVisitor = false;

  List<dynamic> employeeSearchResults = [];
  List<dynamic> visitorSearchResults = [];

  Timer? _debounce;

  String formatDateTimeUtc(DateTime dateTime) {
    final utc = dateTime.toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    String three(int n) => n.toString().padLeft(3, '0');
    return "${utc.year}-"
        "${two(utc.month)}-"
        "${two(utc.day)} "
        "${two(utc.hour)}:"
        "${two(utc.minute)}:"
        "${two(utc.second)}."
        "${three(utc.millisecond)}+00";
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDate == null || selectedTime == null) {
      _showSnack("Please select date & time");
      return;
    }

    if (!isRegistered && !(hasPassport ^ hasNid)) {
      _showSnack("Select either Passport or NID");
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final scheduledDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final appliedDateTime = DateTime.now();
      final employeeId = selectedEmployeeIID ?? -1;

      // Visitor payload depends on registration
      final visitorId = isRegistered
          ? (selectedVisitorIID ?? -1)
          : -1; // if not registered, manual entry

      Map<String, dynamic> payload = {
        "IdentityId": visitorId,
        "ManualName": !isRegistered ? _name.text.trim() : null,
        "ManualPhone": !isRegistered ? _phone.text.trim() : null,
        "ManualEmail": !isRegistered ? _email.text.trim() : null,
        "ManualAddress": !isRegistered ? _address.text.trim() : null,
        "HasPassport": hasPassport,
        "HasNid": hasNid,
        "PassportOrNidField": (hasPassport || hasNid) ? _passportOrNid.text.trim() : null,
        "Purpose": _purpose.text.trim(),
        "ReceptionistId": SharedPrefs.getString('userId')?.toString(),
        "EmployeeId": employeeId,
        "ScheduledDateTime": scheduledDateTime.toUtc().toIso8601String(),
        "AppliedDateTime": appliedDateTime.toUtc().toIso8601String(),
      };

      print(payload.toString());

      final success = await ApiClient().createWalkin(payload: payload);

      if (!mounted) return;

      if (success) {
        _showSnack("Walk-in created successfully", success: true);
        _clearForm();
      } else {
        _showSnack("Failed to create walk-in");
      }
    } catch (e) {
      debugPrint("Submit error: $e");
      _showSnack("Something went wrong!");
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  void _addEmployee(dynamic employee) {
    setState(() {
      selectedEmployeeId = employee['employeeId'].toString();
      selectedEmployeeName = employee['name'];
      selectedEmployeeIID = employee['employeeIdentityId'];
      employeeSearchResults.clear();
      employeeIdController.clear();
      print(selectedEmployeeIID);
      print(selectedEmployeeName);
      print(selectedEmployeeId);
    });
  }

  void _removeEmployee() {
    setState(() {
      selectedEmployeeId = null;
      selectedEmployeeName = null;
      selectedEmployeeIID = null;
    });
  }

  void _addVisitor(dynamic visitor) {
    setState(() {
      if (visitor['userType'] == 'employee') {
        selectedVisitorId = visitor['employeeId'].toString();
      } else {
        selectedVisitorId = visitor['userId'].toString();
      }
      selectedVisitorName = visitor['name'];
      selectedVisitorIID = visitor['employeeIdentityId'];
      visitorSearchResults.clear();
      visitorSearchController.clear();
    });
  }

  void _removeVisitor() {
    setState(() {
      selectedVisitorId = null;
      selectedVisitorName = null;
      selectedVisitorIID = null;

    });
  }

  void _clearForm() {
    _formKey.currentState!.reset();
    _name.clear();
    _phone.clear();
    _email.clear();
    _address.clear();
    _passportOrNid.clear();
    setState(() {
      hasPassport = false;
      hasNid = false;
      appliedDateTime = DateTime.now();
      _removeVisitor();
    });
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Container(color: Theme.of(context).primaryColorDark),

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
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _circleButton(Icons.arrow_back),
                        const Text(
                          "Create Walk-in",
                          style: TextStyle(
                            color: Colors.white,
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
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Stack(
                                children: [
                                  AnimatedAlign(
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeOutCubic,
                                    alignment:
                                        isRegistered
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width /
                                              2 -
                                          32,
                                      height: 46,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),

                                  /// BUTTONS
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            setState(() {
                                              isRegistered = true;
                                              _clearForm();
                                            });
                                          },
                                          child: Center(
                                            child: AnimatedDefaultTextStyle(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              style: TextStyle(
                                                color:
                                                    isRegistered
                                                        ? Colors.white
                                                        : Colors.black87,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                              child: const Text("Registered"),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            setState(() {
                                              isRegistered = false;
                                              _clearForm();
                                            });
                                          },
                                          child: Center(
                                            child: AnimatedDefaultTextStyle(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              style: TextStyle(
                                                color:
                                                    !isRegistered
                                                        ? Colors.white
                                                        : Colors.black87,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                              child: const Text(
                                                "Not Registered",
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16,),

                            Text(
                              "Meeting Information",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 10,),
                            _field("Purpose", _purpose),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: _field(
                                  "Scheduled Date",
                                  dateController,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _selectTime(context),
                              child: AbsorbPointer(
                                child: _field(
                                  "Scheduled Time",
                                  timeController,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            Text(
                              "Employee Information",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (selectedEmployeeId == null)
                              TextFormField(
                                controller: employeeIdController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  labelText: "Search Employee",
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(
                                    context,
                                  ).primaryColorDark.withOpacity(0.06),
                                  suffixIcon:
                                      _isSearchingEmployee
                                          ? Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColorDark,
                                              ),
                                            ),
                                          )
                                          : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onChanged: (val) {
                                  if (_debounce?.isActive ?? false)
                                    _debounce!.cancel();

                                  _debounce = Timer(
                                    const Duration(milliseconds: 500),
                                    () async {
                                      if (val.trim().isEmpty) {
                                        setState(
                                          () => employeeSearchResults.clear(),
                                        );
                                        return;
                                      }

                                      setState(
                                        () => _isSearchingEmployee = true,
                                      );

                                      final results = await ApiClient()
                                          .searchEmployeeByPhone(val.trim());

                                      if (!mounted) return;
                                      setState(() {
                                        employeeSearchResults = results;
                                        _isSearchingEmployee = false;
                                      });
                                    },
                                  );
                                },
                              ),
                            if (employeeSearchResults.isNotEmpty)
                              Card(
                                color: Theme.of(context).primaryColorDark,
                                margin: const EdgeInsets.only(top: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: employeeSearchResults.length,
                                  itemBuilder: (context, index) {
                                    final e = employeeSearchResults[index];
                                    return ListTile(
                                      leading: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                      title: Text(
                                        e['name'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => _addEmployee(e),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            if (selectedEmployeeId != null)
                              if (selectedEmployeeId != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      const Text(
                                        "Employee:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Chip(
                                          label: Text(
                                            selectedEmployeeName ?? "",
                                          ),
                                          avatar: const Icon(Icons.person),
                                          deleteIcon: const Icon(Icons.close),
                                          onDeleted: _removeEmployee,
                                          backgroundColor: Colors.grey.shade200,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            SizedBox(height: 10),
                            Text(
                              "Visitor Information",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 10),
                            if (isRegistered) ...[
                              if (selectedVisitorId == null)
                                TextFormField(
                                  controller: visitorSearchController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: "Search Visitor",
                                    labelStyle: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                    filled: true,
                                    fillColor: Theme.of(
                                      context,
                                    ).primaryColorDark.withOpacity(0.06),
                                    suffixIcon:
                                        _isSearchingVisitor
                                            ? Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: SizedBox(
                                                height: 18,
                                                width: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 3,
                                                      color:
                                                          Theme.of(
                                                            context,
                                                          ).primaryColorDark,
                                                    ),
                                              ),
                                            )
                                            : null,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    if (_debounce?.isActive ?? false)
                                      _debounce!.cancel();

                                    _debounce = Timer(
                                      const Duration(milliseconds: 500),
                                      () async {
                                        if (val.trim().isEmpty) {
                                          setState(
                                            () => visitorSearchResults.clear(),
                                          );
                                          return;
                                        }

                                        setState(
                                          () => _isSearchingVisitor = true,
                                        );

                                        final results = await ApiClient()
                                            .searchEmployeeByPhone(val.trim());

                                        if (!mounted) return;
                                        setState(() {
                                          visitorSearchResults = results;
                                          _isSearchingVisitor = false;
                                        });
                                      },
                                    );
                                  },
                                ),
                              if (visitorSearchResults.isNotEmpty)
                                Card(
                                  color: Theme.of(context).primaryColorDark,
                                  margin: const EdgeInsets.only(top: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: visitorSearchResults.length,
                                    itemBuilder: (context, index) {
                                      final v = visitorSearchResults[index];
                                      return ListTile(
                                        leading: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        ),
                                        title: Text(
                                          v['name'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                          ),
                                          onPressed: () => _addVisitor(v),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              if (selectedVisitorId != null)
                                Row(
                                  children: [
                                    const Text(
                                      "Visitor:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Chip(
                                        label: Text(selectedVisitorName ?? ""),
                                        avatar: const Icon(Icons.person),
                                        deleteIcon: const Icon(Icons.close),
                                        onDeleted: _removeVisitor,
                                        backgroundColor: Colors.grey.shade200,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                            if (!isRegistered) ...[
                              _field("Name", _name),
                              _field(
                                "Phone",
                                _phone,
                                keyboard: TextInputType.phone,
                              ),
                              _field(
                                "Email",
                                _email,
                                keyboard: TextInputType.emailAddress,
                              ),
                              _field("Address", _address),

                              Row(
                                children: [
                                  Checkbox(
                                    value: hasPassport,
                                    onChanged: (v) {
                                      setState(() {
                                        hasPassport = v!;
                                        hasNid = false;
                                      });
                                    },
                                  ),
                                  const Text("Passport"),
                                  Checkbox(
                                    value: hasNid,
                                    onChanged: (v) {
                                      setState(() {
                                        hasNid = v!;
                                        hasPassport = false;
                                      });
                                    },
                                  ),
                                  const Text("NID"),
                                ],
                              ),
                              if (hasPassport || hasNid)
                                _field(
                                  hasPassport
                                      ? "Passport Number"
                                      : "NID Number",
                                  _passportOrNid,
                                ),
                            ],
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 55,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isSubmitting ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColorDark,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  isSubmitting ? "Submitting..." : "Submit",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
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
      onTap: () => Navigator.pop(context),
      child: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColorDark,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Theme.of(context).primaryColorDark),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
