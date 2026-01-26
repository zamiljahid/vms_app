import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:visitor_management/api/api_client.dart';
import 'package:visitor_management/screens/shared_preference.dart';
import 'package:visitor_management/screens/walkin/create_walkin_screen.dart';
import 'package:visitor_management/screens/walkin/model/walkin_model.dart';
import '../appointments/appointment_history_screen.dart';

class WalkInHistoryScreen extends StatefulWidget {
  const WalkInHistoryScreen({super.key});

  @override
  State<WalkInHistoryScreen> createState() => _WalkInHistoryScreenState();
}

class _WalkInHistoryScreenState extends State<WalkInHistoryScreen> {
  List<WalkInVisitorModel> walkins = [];
  bool isLoading = true;
  String? errorMessage, userId;
  int? role;

  @override
  void initState() {
    // userId = 'UGE980';
    // role = 2;
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
    final result = await api.getWalkInHistory(
      roleId: role!,
      employeeId: userId,
      visitorUserId: userId,
    );

    if (result is String) {
      setState(() {
        errorMessage = result;
        isLoading = false;
      });
    } else if (result is List<WalkInVisitorModel>) {
      setState(() {
        walkins = result;
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
                    'Walk In History',
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
                        itemCount: walkins.length,
                        itemBuilder: (context, index) {
                          return ListCard(walkins: walkins[index]);
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
  final WalkInVisitorModel walkins;
  const ListCard({super.key, required this.walkins});

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
    final walkins = widget.walkins;

    final DateTime scheduledUtc =
        walkins.scheduledDateTime ?? DateTime.now();

    final DateTime scheduledLocal = scheduledUtc.toLocal();

    final String formattedDate =
    DateFormat('d MMMM yyyy').format(scheduledLocal);

    final String formattedTime =
    DateFormat('hh:mm a').format(scheduledLocal);

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
              /// STATUS
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  walkins.status!.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorLight,
                    fontSize: 16,
                  ),
                ),
              ),

              /// HOST INFO
              const SizedBox(height: 12),
              Text(
                walkins.hostEmployeeName ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                walkins.hostCompanyName ?? '',
                style: const TextStyle(fontSize: 14),
              ),

              /// EXPAND SECTION
              SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 20),

                    Card(
                      color: Theme.of(context).primaryColorDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _infoRow(Icons.work_outline, "Purpose", walkins.purpose ?? '-'),
                            _infoRow(Icons.calendar_today, "Date", formattedDate),
                            _infoRow(Icons.access_time, "Time", formattedTime),
                            _infoRow(Icons.person_outline, "Host", walkins.hostEmployeeName ?? '-'),
                            _infoRow(Icons.business_outlined, "Company", walkins.hostCompanyName ?? '-'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// SINGLE VISITOR
                    Text(
                      "Visitor",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _visitorCard(walkins),                  ],
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

  Widget _visitorCard(WalkInVisitorModel visitor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColorDark,
          width: 1.5,
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
            backgroundColor:
            Theme.of(context).primaryColorDark.withOpacity(0.1),
            child: Icon(
              Icons.person,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visitor.visitorName ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),

                if (visitor.visitorPhone != null && visitor.visitorPhone!.isNotEmpty)
                  Text(
                    "Phone: ${visitor.visitorPhone!}",
                    style: const TextStyle(fontSize: 13),
                  ),

                if (visitor.visitorEmail != null && visitor.visitorEmail!.isNotEmpty)
                  Text(
                    "Email: ${visitor.visitorEmail!}",
                    style: const TextStyle(fontSize: 13),
                  ),

                if (visitor.visitorLocationOrCompany != null &&
                    visitor.visitorLocationOrCompany!.isNotEmpty)
                  Text(
                    "Address: ${visitor.visitorLocationOrCompany!}",
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}