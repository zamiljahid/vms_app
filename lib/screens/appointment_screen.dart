import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'create_appointment_screen.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> appointments = [
      {
        "status": "Pending",
        "qrData": "APPT12345",
        "company": "TechCorp",
        "date": "2025-12-30",
        "employee": "John Doe",
        "department": "IT",
        "designation": "Software Engineer",
        "createdBy": "Admin",
        "visitors": ["Alice", "Bob"]
      },
      {
        "status": "Confirmed",
        "qrData": "",
        "company": "BizGroup",
        "date": "2025-12-31",
        "employee": "Jane Smith",
        "department": "HR",
        "designation": "HR Manager",
        "createdBy": "Admin",
        "visitors": ["Charlie"]
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Appointments'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            color: Theme.of(context).primaryColorLight,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                child: Column(
                  children: appointments.map((appointment) {
                    return AppointmentCard(appointment: appointment);
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CreateAppointmentScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AppointmentCard extends StatefulWidget {
  final Map<String, dynamic> appointment;
  const AppointmentCard({super.key, required this.appointment});

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    final hasQr = appointment["qrData"] != null && appointment["qrData"] != "";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          setState(() {
            expanded = !expanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${appointment['employee']} (${appointment['status']})",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.qr_code,
                      color: hasQr ? Colors.blue : Colors.grey,
                      size: 28,
                    ),
                    onPressed: hasQr
                        ? () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("QR Code"),
                          content: Center(
                            child: QrImageView(
                              data: appointment['qrData'],
                              version: QrVersions.auto,
                              size: 100,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Close"),
                            ),
                          ],
                        ),
                      );
                    }
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Show more info when expanded
              if (expanded) ...[
                Text("Company: ${appointment['company']}"),
                Text("Date: ${appointment['date']}"),
                Text("Department: ${appointment['department']}"),
                Text("Designation: ${appointment['designation']}"),
                Text("Created by: ${appointment['createdBy']}"),
                const SizedBox(height: 8),
                const Text(
                  "Visitors:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...List.generate(
                  appointment['visitors'].length,
                      (index) => Card(
                    color: Colors.grey[100],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(appointment['visitors'][index]),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
