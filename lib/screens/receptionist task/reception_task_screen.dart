import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:visitor_management/api/api_client.dart';

import '../../walk_in_action_button.dart';
import '../action_widget.dart';
import 'model/receptionist_task_model.dart';

class ReceptionTaskScreen extends StatefulWidget {
  const ReceptionTaskScreen({super.key});

  @override
  State<ReceptionTaskScreen> createState() => _ReceptionTaskScreenState();
}

class _ReceptionTaskScreenState extends State<ReceptionTaskScreen> {
  bool isLoading = true;
  String? errorMessage;

  List<ReceptionistTaskModel> invitations = [];
  List<ReceptionistTaskModel> appointments = [];
  List<ReceptionistTaskModel> walkIns = [];

  int expandedIndex = -1;
  Set<int> showListIndex = {};

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiClient().fetchReceptionistTasks(companyId: 1);

      setState(() {
        invitations = result.invitations
            .map((e) {
          try {
            return ReceptionistTaskModel.fromInviteJson(e);
          } catch (ex) {
            debugPrint('Invite parse error: $ex\nJSON: $e');
            return null;
          }
        })
            .whereType<ReceptionistTaskModel>()
            .toList();

        appointments = result.appointments
            .map((e) {
          try {
            return ReceptionistTaskModel.fromVisitJson(e);
          } catch (ex) {
            debugPrint('Visit parse error: $ex\nJSON: $e');
            return null;
          }
        })
            .whereType<ReceptionistTaskModel>()
            .toList();

        walkIns = result.walkIns
            .map((e) {
          try {
            return ReceptionistTaskModel.fromWalkInJson(e);
          } catch (ex) {
            debugPrint('WalkIn parse error: $ex\nJSON: $e');
            return null;
          }
        })
            .whereType<ReceptionistTaskModel>()
            .toList();

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch tasks';
        debugPrint('Fetch tasks catch: $e');
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
          // AppBar with blur
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
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  title: Text(
                    'Reception Tasks',
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

          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _collapsibleGlassContainer(
                    context, invitations, "Invitations", 0),
                _collapsibleGlassContainer(
                    context, appointments, "Appointments", 1),
                _collapsibleGlassContainer(
                    context, walkIns, "Walk-ins", 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _collapsibleGlassContainer(
      BuildContext context,
      List<ReceptionistTaskModel> items,
      String title,
      int index,
      ) {
    bool isExpanded = expandedIndex == index;
    double collapsedHeight = 65;
    double expandedHeight = MediaQuery.of(context).size.height * 0.64;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: isExpanded ? expandedHeight : collapsedHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).primaryColorLight.withOpacity(0.9),
            width: 2,
          ),
        ),
        onEnd: () {
          setState(() {
            if (isExpanded) {
              showListIndex.add(index);
            } else {
              showListIndex.remove(index);
            }
          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              children: [
                // Header
                GestureDetector(
                  onTap: () {
                    setState(() {
                      expandedIndex = isExpanded ? -1 : index;
                      showListIndex.remove(index);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorDark,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Theme.of(context).primaryColorLight,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),

                // Body: Expanded list with custom cards
                if (showListIndex.contains(index))
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : errorMessage != null
                        ? Center(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.white),
                        ))
                        : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: items.length,
                      itemBuilder: (context, idx) {
                        final item = items[idx];
                        switch (item.type) {
                          case ReceptionistTaskType.visit:
                            return VisitCard(visit: item);
                          case ReceptionistTaskType.invite:
                            return InviteCard(invite: item);
                          case ReceptionistTaskType.walkIn:
                            return WalkInCard(walkIn: item);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WalkInCard extends StatefulWidget {
  final ReceptionistTaskModel walkIn;
  const WalkInCard({super.key, required this.walkIn});

  @override
  State<WalkInCard> createState() => _WalkInCardState();
}

class _WalkInCardState extends State<WalkInCard> with SingleTickerProviderStateMixin {
  bool expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
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
    final walkIn = widget.walkIn;
    final scheduled = walkIn.scheduledDateTime != null ? "${walkIn.scheduledDateTime!.toLocal()}".split(" ")[0] : "";

    return GestureDetector(
      onTap: toggleExpand,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.white, Colors.grey[100]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorDark.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              walkIn.status.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorLight, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${walkIn.hostEmployeeName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              WalkInActionButton(
                onActionSuccess: () async {
                  if (mounted) {
                    final state = context.findAncestorStateOfType<_ReceptionTaskScreenState>();
                    state?.fetchTasks();
                  }
                }, walkinId: walkIn.walkInId!,
              )
            ],
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Divider(height: 20, thickness: 1.2),
              _infoRow(Icons.phone, "Phone", walkIn.manualPhone ?? ""),
              _infoRow(Icons.email, "Email", walkIn.manualEmail ?? ""),
              _infoRow(Icons.location_city, "Address", walkIn.manualAddress ?? ""),
              _infoRow(Icons.calendar_today, "Scheduled Date", scheduled),
              _infoRow(Icons.verified, "Has Passport", walkIn.hasPassport == true ? "Yes" : "No"),
              _infoRow(Icons.verified, "Has NID", walkIn.hasNid == true ? "Yes" : "No"),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 18, color: Theme.of(context).primaryColorDark),
        const SizedBox(width: 8),
        Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ]),
    );
  }
}
class InviteCard extends StatefulWidget {
  final ReceptionistTaskModel invite;
  const InviteCard({super.key, required this.invite});

  @override
  State<InviteCard> createState() => _InviteCardState();
}

class _InviteCardState extends State<InviteCard> with SingleTickerProviderStateMixin {
  bool expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
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
    final invite = widget.invite;
    final formattedDate = invite.inviteDate != null ? "${invite.inviteDate!.toLocal()}".split(" ")[0] : "";
    final formattedTime = invite.inviteTime ?? "";
    return GestureDetector(
      onTap: toggleExpand,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.white, Colors.grey[100]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("${invite.senderName} Sent Invitation to ${invite.receiverName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Divider(height: 20, thickness: 1.2),
              _infoRow(Icons.business, "Sender Company", invite.senderCompany ?? ""),
              _infoRow(Icons.business, "Receiver Company", invite.receiverCompany ?? ""),
              _infoRow(Icons.calendar_today, "Date", formattedDate),
              _infoRow(Icons.access_time, "Time", formattedTime),
              _infoRow(Icons.phone, "Sender Phone", invite.senderPhone ?? ""),
              _infoRow(Icons.phone, "Receiver Phone", invite.receiverPhone ?? ""),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 18, color: Theme.of(context).primaryColorDark),
        const SizedBox(width: 8),
        Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ]),
    );
  }
}

class VisitCard extends StatefulWidget {
  final ReceptionistTaskModel visit;
  const VisitCard({super.key, required this.visit});

  @override
  State<VisitCard> createState() => _VisitCardState();
}

class _VisitCardState extends State<VisitCard> with SingleTickerProviderStateMixin {
  bool expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
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
    final visit = widget.visit;
    final hasVisitors = visit.visitors != null && visit.visitors!.isNotEmpty;
    final formattedDate = visit.appointmentDate != null ? "${visit.appointmentDate!.toLocal()}".split(" ")[0] : "";
    final formattedTime = visit.appointmentTime ?? "";

    return GestureDetector(
      onTap: toggleExpand,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.white, Colors.grey[100]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorDark.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                visit.status.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorLight, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${visit.creatorName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                AppointmentActionButton(
                  visitId: visit.visitId!,
                  onActionSuccess: () async {
                    if (mounted) {
                      final state = context.findAncestorStateOfType<_ReceptionTaskScreenState>();
                      state?.fetchTasks();
                    }
                  },
                )
              ],
            ),
            SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: -1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 20, thickness: 1.2),
                  _infoRow(Icons.calendar_today, "Date", formattedDate),
                  _infoRow(Icons.access_time, "Time", formattedTime),
                  if (hasVisitors) ...[
                    const SizedBox(height: 8),
                    const Text("Visitors", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    ...visit.visitors!.map((v) => _visitorCard(v)).toList(),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 18, color: Theme.of(context).primaryColorDark),
        const SizedBox(width: 8),
        Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ]),
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