import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visitor_management/api/api_client.dart';
import 'package:visitor_management/screens/invitation/send_invitation_screen.dart';

import '../shared_preference.dart';
import 'invitation_history_screen.dart';
import 'models/upcoming_invitation.dart';

class InvitationScreen extends StatefulWidget {
  const InvitationScreen({super.key});

  @override
  State<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
  late Future<dynamic> _inviteFuture;

  @override
  void initState() {
    super.initState();
    _inviteFuture = ApiClient().getUpcomingInvites(
      SharedPrefs.getInt('identity')!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).primaryColorDark,
      body: Column(
        children: [
          _buildAppBar(context),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: FutureBuilder<dynamic>(
                future: _inviteFuture,
                builder: (context, snapshot) {
                  // ⏳ Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data is String) {
                    return Center(
                      child: Text(
                        snapshot.data ?? 'No data found',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }
                  final List<UpcomingInviteModel> invites = snapshot.data;
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).primaryColorLight.withOpacity(0.9),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: invites.length,
                          itemBuilder: (context, index) {
                            return ListCard(invite: invites[index]);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const SendInvitationScreen(),
            ),
          );
          if (result == true) {
            setState(() {
              _inviteFuture = ApiClient().getUpcomingInvites(
                SharedPrefs.getInt('identity')!,
              );
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return PreferredSize(
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
            backgroundColor: Theme.of(
              context,
            ).primaryColorLight.withOpacity(0.9),
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
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
            title: Text(
              'Invitation',
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
                          builder: (context) => const InvitationHistoryScreen(),
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
                        child: Icon(
                          Icons.history,
                          color: Colors.white,
                          size: 25,
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
}

class ListCard extends StatefulWidget {
  final UpcomingInviteModel invite;

  const ListCard({super.key, required this.invite});

  @override
  State<ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<ListCard>
    with SingleTickerProviderStateMixin {
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
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String formatDateWithOrdinal(DateTime date) {
    String day = date.day.toString();
    String suffix = 'th';

    if (!(date.day >= 11 && date.day <= 13)) {
      switch (date.day % 10) {
        case 1:
          suffix = 'st';
          break;
        case 2:
          suffix = 'nd';
          break;
        case 3:
          suffix = 'rd';
          break;
      }
    }

    String month = DateFormat('MMMM').format(date); // January, February, etc.
    String year = date.year.toString();

    return '$day$suffix $month $year';
  }

  void toggleExpand() {
    setState(() {
      expanded = !expanded;
      expanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final invite = widget.invite;
    DateTime date = DateTime.parse(invite.inviteDate);
    String formattedDate = DateFormat(
      "d MMMM yyyy",
    ).format(date); // 13 January 2026

    DateTime time = DateTime.parse("${invite.inviteDate} ${invite.inviteTime}");
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
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
                  "${invite.otherRole == 'RECEIVER' ? 'Sent' : 'Received'} invitation for "
                      "${formatDateWithOrdinal(DateTime.parse(invite.inviteDate))}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorLight,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // left-align texts
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    invite.otherName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // small spacing between name and company
                  Text(
                    invite.otherCompanyName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: Theme.of(context).primaryColorDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Colors.black.withOpacity(0.15),
                          width: 1,
                        ), // subtle border shadow
                      ),
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoRow(
                              Icons.work_outline,
                              "Purpose",
                              invite.purpose,
                            ),
                            _infoRow(
                              Icons.calendar_today,
                              "Date",
                              formattedDate,
                            ),
                            _infoRow(Icons.access_time, "Time", formattedTime),
                            _infoRow(
                              Icons.person_outline,
                              "Host",
                              invite.otherName,
                            ),
                            _infoRow(
                              Icons.business_outlined,
                              "Company",
                              invite.otherCompanyName,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
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
            backgroundColor: Theme.of(
              context,
            ).primaryColorDark.withOpacity(0.1),
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
                    style: TextStyle(color: Colors.black, fontSize: 13),
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
