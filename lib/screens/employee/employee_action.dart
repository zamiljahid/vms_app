import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:visitor_management/api/api_client.dart';
import 'model/role_model.dart';

class EmployeeActionButton extends StatefulWidget {
  final String employeeId;
  final String currentRoleName; // NEW: current role of the employee
  final VoidCallback? onActionSuccess;

  const EmployeeActionButton({
    super.key,
    required this.employeeId,
    required this.currentRoleName, // pass current role
    this.onActionSuccess,
  });

  @override
  State<EmployeeActionButton> createState() => _EmployeeActionButtonState();
}

class _EmployeeActionButtonState extends State<EmployeeActionButton> {
  bool isLoading = false;
  bool isPosting = false;
  List<RoleModel>? roles;
  final ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  /* ---------------- FETCH ROLES ---------------- */
  Future<void> getActions() async {
    setState(() {
      isLoading = true;
      roles = null;
    });

    try {
      final data = await ApiClient().getRoles();
      setState(() {
        roles = data.where((r) => r.roleName != widget.currentRoleName).toList();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) isDialOpen.value = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /* ---------------- LABELS & ICONS ---------------- */
  String getRoleLabel({int? roleId, bool isRemove = false}) {
    if (isRemove) return 'Remove Employee';

    switch (roleId) {
      case 1:
        return 'Admin';
      case 2:
        return 'Employee';
      case 3:
        return 'Receptionist';
      default:
        return 'Unknown Role';
    }
  }

  String getRoleIcon({int? roleId, bool isRemove = false}) {
    if (isRemove) return 'assets/images/remove.png';

    switch (roleId) {
      case 1:
        return 'assets/images/admin.png';
      case 2:
        return 'assets/images/employee.png';
      case 3:
        return 'assets/images/receptionist.png';
      default:
        return 'assets/images/default.png';
    }
  }
  Future<void> manageEmployeeRoleAction({
    required String action,
    int? roleId,
  }) async {
    setState(() => isPosting = true);
    try {
      print(widget.employeeId.toString());
      print(action.toString());
      print(roleId.toString());
      await ApiClient().manageEmployeeRole(
        employeeId: widget.employeeId,
        action: action,
        roleId: roleId ?? 0,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            action == 'remove'
                ? 'Employee removed successfully'
                : 'Role updated successfully',
          ),
        ),
      );

      widget.onActionSuccess?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed: $e')),
      );
    } finally {
      setState(() => isPosting = false);
    }
  }

  /* ---------------- CONFIRM REMOVE ---------------- */
  Future<bool> confirmRemove() async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Employee'),
        content:
        const Text('Are you sure you want to remove this employee?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:  Text('Cancel', style: TextStyle(color: Theme.of(context).primaryColorDark),),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColorDark),
            onPressed: () => Navigator.pop(context, true),
            child:  Text('Remove', style: TextStyle(color: Theme.of(context).primaryColorLight),),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  void dispose() {
    isDialOpen.dispose();
    super.dispose();
  }

  /* ---------------- UI ---------------- */
  @override
  Widget build(BuildContext context) {
    if (isLoading || isPosting) {
      return FloatingActionButton(
        onPressed: () {},
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        child: const CircularProgressIndicator(color: Colors.white),
      );
    }

    if (roles != null) {
      final actions = [
        // Only show roles that are not the current role
        ...roles!.map((r) => {
          'roleId': r.roleId,
          'isRemove': false,
        }),
        {
          'roleId': null,
          'isRemove': true,
        },
      ];

      return ValueListenableBuilder<bool>(
        valueListenable: isDialOpen,
        builder: (context, open, _) {
          return Stack(
            children: [
              if (open)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              SpeedDial(
                icon: Icons.touch_app,
                activeIcon: Icons.close,
                openCloseDial: isDialOpen,
                overlayOpacity: 0.0,
                spacing: 12,
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                foregroundColor: Theme.of(context).primaryColorDark,
                activeBackgroundColor: Theme.of(context).primaryColorDark,
                activeForegroundColor: Theme.of(context).primaryColorLight,
                iconTheme: const IconThemeData(size: 45),
                direction: SpeedDialDirection.up, // open to left
                children: actions.map((a) {
                  final bool isRemove = a['isRemove'] as bool;
                  final int? roleId = a['roleId'] as int?;
                  return SpeedDialChild(
                    child: Image.asset(
                      getRoleIcon(roleId: roleId, isRemove: isRemove),
                      width: 28,
                      height: 28,
                    ),
                    backgroundColor: Colors.white,
                    label: getRoleLabel(roleId: roleId, isRemove: isRemove),
                    labelBackgroundColor:
                    isRemove ? Colors.red : Theme.of(context).primaryColorDark,
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    onTap: () async {
                      if (isRemove) {
                        final ok = await confirmRemove();
                        if (!ok) return;
                        await manageEmployeeRoleAction(action: 'remove');
                      } else {
                        await manageEmployeeRoleAction(
                            action: 'update', roleId: roleId);
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

    // Default FAB
    return FloatingActionButton(
      onPressed: getActions,
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      child: Icon(
        Icons.touch_app,
        color: Theme.of(context).primaryColorDark,
      ),
    );
  }
}