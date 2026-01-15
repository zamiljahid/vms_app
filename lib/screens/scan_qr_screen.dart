import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:visitor_management/api/api_client.dart';
import 'package:visitor_management/screens/qr_camera_screen.dart';
import 'package:visitor_management/screens/qr_model.dart';
import 'package:intl/intl.dart';
import 'package:visitor_management/screens/shared_preference.dart';
import 'package:visitor_management/screens/visit_action_button.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  bool _loading = false;
  QrVerifyResponse? _qrData;

  Future<void> _scanAndVerify() async {
    final encryptedQr = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );

    if (encryptedQr == null) return;

    setState(() => _loading = true);

    try {
      final result = await ApiClient().verifyQr(encryptedQr);
      setState(() => _qrData = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR verification failed')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 40,
                        width: 40,
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

                    const SizedBox(width: 16),

                    // Title
                    Expanded(
                      child: Center(
                        child: Text(
                          "Scan QR to Verify",
                          style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Placeholder for symmetry
                    SizedBox(width: 56), // Same width as back button + spacing
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.circular(38),
              ),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _qrData == null
                  ? _scanButton(context)
                  : _verifiedCard(_qrData!.data),
            ),
          ),
        ],
      ),
    );
  }
  Widget _scanButton(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 80,
          icon: Icon(Icons.qr_code_scanner,
              color: Theme.of(context).primaryColor),
          onPressed: _scanAndVerify,
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to Scan QR code',
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _verifiedCard(VisitData data) {
    final isEntry = data.qrType.toUpperCase() == 'ENTRY';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColorDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).primaryColorLight.withOpacity(0.8),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center, // 👈 center text
                  child: Text(
                    isEntry ? 'ENTRY' : 'EXIT',
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    data.companyName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _headerRow(Icons.badge, 'Employee', data.employeeName),
                _headerRow(Icons.work_outline, 'Purpose', data.purpose),
                _headerRow(Icons.calendar_today, 'Visit Date', formatDate(data.visitDate)),
                _headerRow(Icons.access_time, 'Request Time', formatTime(data.requestTime)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// 👥 Visitors Section
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Visitors',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
          ),

          const SizedBox(height: 12),

          ...data.visitors.map(
                (v) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(.1),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          v.phone,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        if (v.designation != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            v.designation!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (v.branch != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            v.branch!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isEntry ? Colors.green : Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 6,
              ),
              onPressed: () async {
                final isEntry = data.qrType == 'ENTRY';
                final visitId = data.visitId;
                final receptionistId = SharedPrefs.getString('userId') ?? '';

                final url = Uri.parse(
                  isEntry
                      ? 'https://vms-api-805981895260.us-central1.run.app/api/Visit/confirm-checkin?visitId=$visitId'
                      : 'https://vms-api-805981895260.us-central1.run.app/api/Visit/confirm-checkout?visitId=$visitId',
                );

                try {
                  final response = await http.post(
                    url,
                    headers: {
                      'accept': '*/*',
                      'Content-Type': 'application/json',
                    },
                    body: jsonEncode({'receptionistId': receptionistId}),
                  );

                  if (response.statusCode == 200) {
                    final body = jsonDecode(response.body);
                    final message = body['message'] ?? 'Action successful';
                    if (!context.mounted) return;

                    await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Success'),
                        content: Text(message),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );

                    if (context.mounted) Navigator.pop(context);
                  } else {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                        Text('Failed: ${response.statusCode} ${response.reasonPhrase}'),
                      ),
                    );
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                    ),
                  );
                }
              },
              child: Text(
                isEntry ? 'CHECK-IN' : 'CHECK-OUT',
                style:  TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).primaryColorLight,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final day = date.day;
    final suffix = getDaySuffix(day);
    final monthYear = DateFormat('MMMM yyyy').format(date);
    return '$day$suffix $monthYear';
  }

  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
  String formatTime(String timeString) {
    final time = DateFormat.Hms().parse(timeString); // parse "HH:mm:ss"
    return DateFormat.jm().format(time); // format to "03:44 PM"
  }
  Widget _headerRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}