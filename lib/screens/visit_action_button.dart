import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VisitActionButton extends StatefulWidget {
  final bool isEntry; // true = entry, false = exit
  final int visitId;
  final String receptionistId;

  const VisitActionButton({
    super.key,
    required this.isEntry,
    required this.visitId,
    required this.receptionistId,
  });

  @override
  State<VisitActionButton> createState() => _VisitActionButtonState();
}

class _VisitActionButtonState extends State<VisitActionButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isEntry ? Colors.green : Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 6,
            ),
            onPressed: _isLoading ? null : () => _handleVisitAction(context),
            child: Text(
              widget.isEntry ? 'CHECK-IN' : 'CHECK-OUT',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColorLight,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),

        // Loading overlay
        if (_isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: _uniqueLoader(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Unique loading indicator
  Widget _uniqueLoader() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: CircularProgressIndicator(
          strokeWidth: 6,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Future<void> _handleVisitAction(BuildContext context) async {
    setState(() => _isLoading = true);

    final url = Uri.parse(
      widget.isEntry
          ? 'https://vms-api-805981895260.us-central1.run.app/api/Visit/confirm-checkin?visitId=${widget.visitId}'
          : 'https://vms-api-805981895260.us-central1.run.app/api/Visit/confirm-checkout?visitId=${widget.visitId}',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'receptionistId': widget.receptionistId}),
      );

      if (!context.mounted) return;

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final message = body['message'] ?? 'Action successful';

        // Show success dialog
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

        if (context.mounted) Navigator.pop(context); // Close screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed: ${response.statusCode} ${response.reasonPhrase}',
            ),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }
}