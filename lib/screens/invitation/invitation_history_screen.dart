import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:visitor_management/api/api_client.dart';
import '../shared_preference.dart';
import 'models/history_invitation.dart';

class InvitationHistoryScreen extends StatefulWidget {
  const InvitationHistoryScreen({super.key});

  @override
  State<InvitationHistoryScreen> createState() =>
      _InvitationHistoryScreenState();
}

class _InvitationHistoryScreenState extends State<InvitationHistoryScreen> {
  late Future<dynamic> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = ApiClient().getInviteHistory(SharedPrefs.getInt('identity')!);
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
                future: _historyFuture,
                builder: (context, snapshot) {
                  // ⏳ Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
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
                  final List<InviteHistoryModel> invites = snapshot.data;
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context)
                            .primaryColorLight
                            .withOpacity(0.9),
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
                            return HistoryCard(invite: invites[index]);
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
            backgroundColor:
            Theme.of(context).primaryColorLight.withOpacity(0.9),
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
              'Invitation History',
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class HistoryCard extends StatefulWidget {
  final InviteHistoryModel invite;
  const HistoryCard({super.key, required this.invite});

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final invite = widget.invite;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => setState(() => expanded = !expanded),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invite.otherName,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text("Company: ${invite.otherCompanyName}"),
              Text("Purpose: ${invite.purpose}"),
              Text("Date: ${invite.inviteDate}"),
              Text("Time: ${invite.inviteTime}"),
              if (expanded) ...[
                const Divider(),
                Text("Designation: ${invite.otherDesignation}"),
                Text("Phone: ${invite.otherPhone}"),
                if (invite.otherAddress != null)
                  Text("Address: ${invite.otherAddress}"),
              ],
            ],
          ),
        ),
      ),
    );
  }
}