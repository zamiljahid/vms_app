import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:visitor_management/api/api_client.dart';
import 'package:visitor_management/screens/shared_preference.dart';
import 'create_appointment_screen.dart';
import 'appointment_history_screen.dart';
import 'models/visit_upcoming.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  List<UpcomingVisitModel> appointments = [];
  bool isLoading = true;
  String? errorMessage, userId;
  int? role;

  @override
  void initState() {
    userId = SharedPrefs.getString('userId');
    role = SharedPrefs.getInt('roleId');
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final api = ApiClient();
    final result = await api.getUpcomingVisits(
      roleId: role!,
      employeeId: userId,
      visitorUserId: userId,
    );

    if (result is String) {
      setState(() {
        errorMessage = result;
        isLoading = false;
      });
    } else if (result is List<UpcomingVisitModel>) {
      setState(() {
        appointments = result;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColorDark,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  title: Text(
                    'My Appointments',
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AppointmentHistoryScreen(),
                              ),
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorDark,
                              shape: BoxShape.circle,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.history, color: Colors.white, size: 25),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                    color: Theme.of(context).primaryColor.withOpacity(0.7),
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
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : errorMessage != null
                          ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.white),))
                          : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          return ListCard(appointment: appointments[index]);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateAppointmentScreen()),
          );
          if (result == true) {
            await fetchAppointments();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ListCard extends StatefulWidget {
  final UpcomingVisitModel appointment;
  const ListCard({super.key, required this.appointment});

  @override
  State<ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> with SingleTickerProviderStateMixin {
  bool expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleExpand() {
    setState(() {
      expanded = !expanded;
      expanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    final hasQr = appointment.qrData != null && appointment.qrData!.isNotEmpty;
// Parse date
    DateTime date = DateTime.parse(appointment.appointmentDate);
    String formattedDate = DateFormat("d MMMM yyyy").format(date); // 13 January 2026

// Parse time
    DateTime time = DateTime.parse("${appointment.appointmentDate} ${appointment.appointmentTime}");
    String formattedTime = DateFormat("hh:mm a").format(time);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: GestureDetector(
        onTap: toggleExpand,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey[100]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).primaryColorDark.withOpacity(0.8),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  appointment.status.toUpperCase(),
                  style:  TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorLight,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center, // vertically center with IconButton
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // left-align texts
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          appointment.hostEmployeeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4), // small spacing between name and company
                        Text(
                          appointment.hostCompanyName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.qr_code,
                      color: hasQr
                          ? Theme.of(context).primaryColorDark
                          : Theme.of(context).primaryColorDark.withOpacity(0.2),
                      size: 28,
                    ),
                    onPressed: hasQr
                        ? () => showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Scan QR to Verify",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),
                              QrImageView(
                                data: appointment.qrData!,
                                version: QrVersions.auto,
                                size: 180,
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
                    )
                        : null,
                  ),
                ],
              ),
              SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 20, thickness: 1.2),
                    Card(
                      color: Theme.of(context).primaryColorDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.black.withOpacity(0.15), width: 1), // subtle border shadow
                      ),
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoRow(Icons.work_outline, "Purpose", appointment.purpose),
                            _infoRow(Icons.calendar_today, "Date", formattedDate),
                            _infoRow(Icons.access_time, "Time", formattedTime),
                            _infoRow(Icons.person_outline, "Host", appointment.hostEmployeeName),
                            _infoRow(Icons.business_outlined, "Company", appointment.hostCompanyName),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                     Text(
                      "Visitors",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...appointment.visitors.map((v) => _visitorCard(v)).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).primaryColorLight),
          const SizedBox(width: 8),
          Text(
            "$title: ",
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Theme.of(context).primaryColorLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _visitorCard(visitor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColorDark, // border color
          width: 1.5, // border thickness
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColorDark.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Theme.of(context).primaryColorDark.withOpacity(0.1),
            child:  Icon(Icons.person, color: Theme.of(context).primaryColorDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visitor.visitorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                if (visitor.visitorPhone != null)
                  Text(
                    "Phone: ${visitor.visitorPhone!}",
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                  ),
                if (visitor.visitorEmail != null)
                  Text(
                    "Email: ${visitor.visitorEmail!}",
                    style:  TextStyle(color: Colors.black, fontSize: 13),
                  ),
                if (visitor.visitorLocationOrCompany != null)
                  Text(
                    "Address: ${visitor.visitorLocationOrCompany!}",
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}