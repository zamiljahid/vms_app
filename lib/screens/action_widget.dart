import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:visitor_management/api/api_client.dart';
import 'package:visitor_management/screens/shared_preference.dart';
import 'appointments/models/action_model.dart';
import 'package:intl/intl.dart';

class AppointmentActionButton extends StatefulWidget {
  final int visitId;
  final VoidCallback? onActionSuccess; // callback to refresh parent

  const AppointmentActionButton({
    super.key,
    required this.visitId,
    this.onActionSuccess,
  });

  @override
  State<AppointmentActionButton> createState() => _AppointmentActionButtonState();
}

class _AppointmentActionButtonState extends State<AppointmentActionButton> {
  bool isLoading = false;
  ActionModel? actionData;
  final ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  bool isPosting = false; // for showing loading while posting

  /// Fetch actions from API
  Future<void> getActions() async {
    setState(() {
      isLoading = true;
      actionData = null;
    });

    try {
      final data = await ApiClient().getActions(widget.visitId, '?visitId=');
      setState(() {
        actionData = data;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) isDialOpen.value = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Map API action strings to user-friendly labels
  String getActionLabel(String action) {
    switch (action) {
      case 'rejected':
        return 'Reject';
      case 'completed':
        return 'Complete';
      case 'approved':
        return 'Approve';
      case 'reschedule':
        return 'Reschedule';
      case 'waiting':
        return 'Waiting';
      default:
        return action;
    }
  }

  /// Map API action strings to asset icons
  String getActionIcon(String action) {
    switch (action) {
      case 'approved':
        return 'assets/images/approve.png';
      case 'rejected':
        return 'assets/images/reject.png';
      case 'completed':
        return 'assets/images/complete.png';
      case 'reschedule':
        return 'assets/images/reschedule.png';
      case 'waiting':
        return 'assets/images/waiting.png';
      default:
        return 'assets/images/default.png';
    }
  }
  Future<void> postAction(String action, {DateTime? newDateTime}) async {
    setState(() {
      isPosting = true;
    });

    final requestBody = {
      "visitId": widget.visitId,
      "walkinId": 0,
      "action": action,
      "newDateTime": newDateTime?.toIso8601String(),
      "receptionistId": SharedPrefs.getString('userId'),
    };

    try {
      final result = await ApiClient().postAction(requestBody);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );

      // Refresh actions inside the button
      await getActions();

      // 🔹 Notify parent to reload appointments
      if (widget.onActionSuccess != null) {
        widget.onActionSuccess!();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error posting action: $e")),
      );
    } finally {
      setState(() {
        isPosting = false;
      });
    }
  }
  /// Show date and time picker for reschedule
  Future<DateTime?> pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null) return null;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  void dispose() {
    isDialOpen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading FAB when fetching actions
    if (isLoading) {
      return SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColorDark,
            valueColor:
             AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColorDark),
          ),
        ),
      );
    }

    // Show loading overlay while posting action
    if (isPosting) {
      return SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          child: const CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    // Show SpeedDial with actions
    if (actionData != null) {
      return ValueListenableBuilder<bool>(
        valueListenable: isDialOpen,
        builder: (context, open, child) {
          return Stack(
            children: [
              if (open)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              SpeedDial(
                icon: Icons.touch_app,
                activeIcon: Icons.close,
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                foregroundColor: Theme.of(context).primaryColorDark,
                activeBackgroundColor: Theme.of(context).primaryColorDark,
                activeForegroundColor: Theme.of(context).primaryColorLight,
                iconTheme: const IconThemeData(size: 45),
                spacing: 10,
                openCloseDial: isDialOpen,
                overlayOpacity: 0.0,
                children: actionData!.allowedActions.map((action) {
                  return SpeedDialChild(
                    child: Image.asset(
                      getActionIcon(action),
                      width: 30,
                      height: 30,
                    ),
                    backgroundColor: Colors.white,
                    label: getActionLabel(action),
                    labelBackgroundColor: Theme.of(context).primaryColorDark,
                    labelStyle: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontWeight: FontWeight.bold,
                    ),
                    onTap: () async {
                      if (action == 'reschedule') {
                        final newDateTime = await pickDateTime();
                        if (newDateTime != null) {
                          await postAction(action, newDateTime: newDateTime);
                        }
                      } else {
                        await postAction(action);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          );
        },
      );
    }

    // Default FAB to fetch actions
    return FloatingActionButton(
      onPressed: getActions,
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      child: Icon(
        Icons.touch_app,
        size: 30,
        color: Theme.of(context).primaryColorDark,
      ),
    );
  }
}