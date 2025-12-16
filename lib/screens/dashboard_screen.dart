import 'package:flutter/material.dart';
import 'package:visitor_management/api/api_client.dart';
import 'package:visitor_management/screens/wrapper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> dashboardItems = [
    {"icon": Icons.person, "title": "Visitors"},
    {"icon": Icons.report, "title": "Reports"},
    {"icon": Icons.feedback, "title": "Feedback"},
    {"icon": Icons.settings, "title": "Settings"},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    itemCount: dashboardItems.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      return _buildNeumorphicCard(
                        icon: dashboardItems[index]['icon'],
                        title: dashboardItems[index]['title'],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ApiClient.performLogout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      foregroundColor: Theme.of(context).primaryColorDark,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('LOGOUT'),
                  ),
                ),
              ],
            ),
          ),
        ),
          bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(22.0),
          child: _buildBottomNav(),
        ),
      ),
    );
  }

  // Neumorphic card widget
  Widget _buildNeumorphicCard({required IconData icon, required String title}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorDark,
          borderRadius: BorderRadius.circular(20),
          boxShadow:  [
            BoxShadow(
              color: Theme.of(context).primaryColorLight,
              offset: Offset(-5, -5),
              blurRadius: 10,
            ),
            BoxShadow(
              color: Theme.of(context).primaryColorDark,
              offset: Offset(5, 5),
              blurRadius: 10,
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColorLight),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:Theme.of(context).primaryColorLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bottom navigation with neumorphic style
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow:  [
          BoxShadow(
            color: Theme.of(context).primaryColorLight,
            offset: Offset(-5, -5),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Theme.of(context).primaryColorDark,
            offset: Offset(5, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).secondaryHeaderColor,
        unselectedItemColor:Theme.of(context).primaryColor,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Alerts"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
