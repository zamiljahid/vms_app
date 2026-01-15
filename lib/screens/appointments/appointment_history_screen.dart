import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'create_appointment_screen.dart';

class AppointmentHistoryScreen extends StatelessWidget {
  const AppointmentHistoryScreen({super.key});

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
      body: Column(
        children: [
          PreferredSize(
            preferredSize: const Size(double.infinity, 56.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: AppBar(
                  centerTitle: true,
                  backgroundColor: Theme.of(context).primaryColorLight.withOpacity(0.9),
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColorDark,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    'Appointment History',
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.7), // glass
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).primaryColorLight.withOpacity(0.9),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          return ListCard(
                            appointment: appointments[index],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListCard extends StatefulWidget {
  final Map<String, dynamic> appointment;
  const ListCard({super.key, required this.appointment});

  @override
  State<ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> {
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
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent, // optional: for glass style
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min, // shrink to fit content
                              children: [
                                const Text(
                                  "Scan QR to Verify",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                QrImageView(
                                  data: appointment['qrData'],
                                  version: QrVersions.auto,
                                  size: 150, // size of QR image
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Close"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 8),
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
