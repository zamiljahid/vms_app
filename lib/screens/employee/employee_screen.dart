import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:visitor_management/api/api_client.dart';
import 'package:visitor_management/screens/appointments/models/manage_appointment_model.dart';
import 'package:visitor_management/screens/employee/add_employee.dart';
import 'package:visitor_management/screens/employee/model/employee_list_model.dart';
import 'package:visitor_management/screens/shared_preference.dart';
import '../action_widget.dart';
import '../appointments/create_appointment_screen.dart';
import 'employee_action.dart';


class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() =>
      _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  List<EmployeeModel> employee = [];
  bool isLoading = true;
  String? errorMessage, userId;
  int? role;

  @override
  void initState() {
    userId = SharedPrefs.getString('userId');
    role = SharedPrefs.getInt('roleId');
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final result = await ApiClient().getEmployeesByCompany(
          companyCode: SharedPrefs.getString('key').toString());
      final filteredResult = result.where((e) => e.employeeId != userId).toList();
      setState(() {
        employee = filteredResult;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme
          .of(context)
          .primaryColorDark,
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
                  backgroundColor: Theme
                      .of(
                    context,
                  )
                      .primaryColorLight
                      .withOpacity(0.9),
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme
                              .of(context)
                              .primaryColorDark,
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
                    'Manage Employee',
                    style: TextStyle(
                      color: Theme
                          .of(context)
                          .primaryColorDark,
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
                    color: Theme
                        .of(context)
                        .primaryColor
                        .withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme
                          .of(
                        context,
                      )
                          .primaryColorLight
                          .withOpacity(0.9),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child:
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : errorMessage != null
                          ? Center(child: Text(errorMessage!))
                          : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: employee.length,
                        itemBuilder: (context, index) {
                          return ListCard(
                            employee: employee[index],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate and wait for result
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEmployeeScreen()),
          );
          if (result == true) {
            await fetchEmployees();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ListCard extends StatefulWidget {
  final EmployeeModel employee;

  const ListCard({super.key, required this.employee});

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

  void toggleExpand() {
    setState(() {
      expanded = !expanded;
      expanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final employee = widget.employee;
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
                  color: Theme
                      .of(context)
                      .primaryColorDark
                      .withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme
                        .of(context)
                        .primaryColorDark
                        .withOpacity(0.8),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  employee.roleName.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme
                        .of(context)
                        .primaryColorLight,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 10),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                // vertically center with IconButton
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                Theme
                                    .of(
                                  context,
                                )
                                    .secondaryHeaderColor, // background color
                              ),
                              child: Icon(
                                Icons.person,
                                size: 15,
                                color:
                                Theme
                                    .of(
                                  context,
                                )
                                    .primaryColorDark, // icon color
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Name: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                employee.name,
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Phone
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                Theme
                                    .of(
                                  context,
                                )
                                    .secondaryHeaderColor, // background color
                              ),
                              child: Icon(
                                Icons.phone,
                                size: 15,
                                color: Theme
                                    .of(context)
                                    .primaryColorDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Phone: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                employee.phone,
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Email
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                Theme
                                    .of(
                                  context,
                                )
                                    .secondaryHeaderColor, // background color
                              ),
                              child: Icon(
                                Icons.email,
                                size: 15,
                                color: Theme
                                    .of(context)
                                    .primaryColorDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Email: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                employee.email,
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  EmployeeActionButton(
                    onActionSuccess: () async {
                      if (mounted) {
                        final state = context.findAncestorStateOfType<_EmployeeScreenState>();
                        state?.fetchEmployees();
                      }
                    }, employeeId: employee.employeeId,
                    currentRoleName: employee.roleName,
                  )
                ],
              ),
              SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Divider(height: 20, thickness: 1.2),
                    const SizedBox(height: 12),
                    Text(
                      "Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme
                            .of(context)
                            .primaryColorDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _detailsCard(employee),
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
          Icon(icon, size: 18, color: Theme
              .of(context)
              .primaryColorLight),
          const SizedBox(width: 8),
          Text(
            "$title: ",
            style: TextStyle(
              fontSize: 14,
              color: Theme
                  .of(context)
                  .primaryColorLight,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Theme
                    .of(context)
                    .primaryColorLight,
              ),
            ),
          ),
        ],
      ),
    );
  }



// Widget for Employee/Visitor Details Card
  Widget _detailsCard(EmployeeModel employee) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme
              .of(context)
              .primaryColorDark,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme
                .of(context)
                .primaryColorDark
                .withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon + name
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme
                    .of(context)
                    .primaryColorDark
                    .withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: Theme
                      .of(context)
                      .primaryColorDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  employee.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Employee Details
          _buildDetailRow("Employee ID", employee.employeeId),
          _buildDetailRow("Designation", employee.designation),
          _buildDetailRow("Department", employee.department),
          if (employee.branch.isNotEmpty) _buildDetailRow(
              "Branch", employee.branch),
          _buildDetailRow("Role", "${employee.roleName}"),
          _buildDetailRow("Phone", employee.phone),
          _buildDetailRow("Email", employee.email),
          _buildDetailRow("Passport", employee.passport),
          _buildDetailRow("NID", employee.nid),
        ],
      ),
    );
  }

// Helper method to display a label-value pair
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        "$label: $value",
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }
}
