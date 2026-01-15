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
  final _employeeIdController = TextEditingController(); // NEW

  final dateController = TextEditingController();
  final timeController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DateTime appliedDateTime = DateTime.now();

  bool hasPassport = false;
  bool hasNid = false;

  bool isSubmitting = false;

  // ================= DATE FORMATTER =================
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

  // ================= PICKERS =================
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
        dateController.text =
        "${picked.year}-${picked.month}-${picked.day}";
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

    if (!(hasPassport ^ hasNid)) {
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

      Map<String, dynamic> payload = {
        "IdentityId": -1,
        "ManualName": _name.text.trim(),
        "ManualPhone": _phone.text.trim(),
        "ManualEmail": _email.text.trim(),
        "ManualAddress": _address.text.trim(),
        "HasPassport": hasPassport,
        "HasNid": hasNid,
        "PassportOrNidField": _passportOrNid.text.trim(),
        "Purpose": _purpose.text.trim(),
        "ReceptionistId": SharedPrefs.getString('userId')?.toString(),
        "EmployeeId": int.tryParse(_employeeIdController.text.trim()) ?? 0,
        "ScheduledDateTime": scheduledDateTime.toUtc().toIso8601String(),
        "AppliedDateTime": appliedDateTime.toUtc().toIso8601String(),
      };
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
  // ================= HELPERS =================
  void _clearForm() {
    _formKey.currentState!.reset();
    _name.clear();
    _phone.clear();
    _email.clear();
    _address.clear();
    _purpose.clear();
    _passportOrNid.clear();
    _employeeIdController.clear();
    dateController.clear();
    timeController.clear();

    setState(() {
      selectedDate = null;
      selectedTime = null;
      hasPassport = false;
      hasNid = false;
      appliedDateTime = DateTime.now();
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

  // ================= UI =================
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
                              fontWeight: FontWeight.bold),
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
                            _field("Name", _name),
                            _field("Phone", _phone,
                                keyboard: TextInputType.phone),
                            _field("Email", _email,
                                keyboard:
                                TextInputType.emailAddress),
                            _field("Address", _address),
                            _field("Purpose", _purpose),

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

                            _field(
                              hasPassport
                                  ? "Passport Number"
                                  : "NID Number",
                              _passportOrNid,
                            ),

                            _field("Employee ID", _employeeIdController,
                                keyboard: TextInputType.number), // NEW

                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: _field(
                                    "Scheduled Date",
                                    dateController),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _selectTime(context),
                              child: AbsorbPointer(
                                child: _field(
                                    "Scheduled Time",
                                    timeController),
                              ),
                            ),

                            const SizedBox(height: 20),
                            SizedBox(
                              height: 55,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                isSubmitting ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  Theme.of(context)
                                      .primaryColorDark,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  isSubmitting
                                      ? "Submitting..."
                                      : "Submit",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .primaryColorLight,
                                    fontSize: 16,
                                    fontWeight:
                                    FontWeight.w600,
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

  Widget _field(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (v) =>
        v == null || v.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Theme.of(context).primaryColorDark),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}