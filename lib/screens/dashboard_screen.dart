import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:visitor_management/screens/shared_preference.dart';
import 'package:visitor_management/screens/splash_screen.dart';
import '../../api/api_client.dart';
import '../../routes/menu_title_list.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/menu _model.dart';
import 'appointments/appointment_screen.dart';
import 'menu_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  String? menuName, profilePic;
  int? role;

  Future<ApiResponse<List<MenuModel>>>? menuList;

  late AnimationController _animationController;
  late Animation<double> animation;
  late Animation<double> scaleAnimation;

  DateTime? _lastPressed;

  @override
  void initState() {
    menuList = ApiClient().getMenusByRole(SharedPrefs.getInt('roleId')??4);
    role = SharedPrefs.getInt('roleId');
    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 250))
      ..addListener(() {
        setState(() {});
      });
    animation = Tween<double>(begin: 0, end: .9).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn));
    scaleAnimation = Tween<double>(begin: 1, end: 0.7).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    final backButtonHasBeenPressed = _lastPressed == null ||
        now.difference(_lastPressed!) > Duration(seconds: 2);
    if (backButtonHasBeenPressed) {
      _lastPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Theme.of(context).primaryColorLight,
            content: Center(
                child: Text(
                  'Press again to exit',
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                ))),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: FutureBuilder<ApiResponse<List<MenuModel>>>(
        future: menuList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.black,
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (!snapshot.hasData || snapshot.data!.success == false) {
            return Center(
              child: Text(snapshot.data?.message ?? 'Failed to load menus'),
            );
          }
          final List<MenuModel> menus = snapshot.data!.data ?? [];
          return HomeWidget(
            dashboardList: menus,
            role: role ?? 4,
          );
        },
      ),
    );

  }
}

class HomeWidget extends StatefulWidget {
  final List dashboardList;
  final int role;

  const HomeWidget({
    super.key,
    required this.dashboardList,
    required this.role,
  });

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {

  @override
  void initState() {
    super.initState();
  }

  Future onGoBack(dynamic value) async {
    if (mounted) {
      setState(() {});
    }

    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Column(
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
                  backgroundColor:
                  Theme.of(context).primaryColorLight.withOpacity(0.9),
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () async {
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Logout'),
                            content: const Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false), // Cancel
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true), // Confirm
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await SharedPrefs.remove('name');
                          await SharedPrefs.remove('userId');
                          await SharedPrefs.remove('roleId');
                          await SharedPrefs.remove('accessToken');

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => SplashScreen()),
                                (Route<dynamic> route) => false,
                          );
                        }
                      },

                      child: Container(
                        decoration:  BoxDecoration(
                          color: Theme.of(context).primaryColorDark,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.exit_to_app,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),

                  title: Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          // Optional: logo action
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration:  BoxDecoration(
                            color: Theme.of(context).primaryColorDark,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(
                            'assets/images/logo2.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        SharedPrefs.getString('name').toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColorDark,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      // Add your button action here
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorDark,
                        shape: BoxShape.circle,
                      ),
                      padding:  EdgeInsets.all(6),
                      child: Image.asset(
                        color: Theme.of(context).primaryColorLight,
                        'assets/images/editProfile.png', // replace with your image
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),
            Divider(color: Theme.of(context)
                .primaryColorLight,),
            Text(
              'My Menus',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context)
                    .primaryColorLight,
                decoration: TextDecoration.none,
              ),
            ),
            Divider(color: Theme.of(context)
                .primaryColorLight,),
            SizedBox(height: 10,),
            MenuItems(
              dashboardList: widget.dashboardList,
              onBack: (dynamic value) {
                onGoBack(value);
              },
            ),
        ],
      ),
    );
  }
}

class MenuItems extends StatelessWidget {
  const MenuItems({
    super.key,
    required this.onBack,
    required this.dashboardList,
  });

  final List dashboardList;
  final Function(Object?) onBack;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimationLimiter(
        child: GridView.builder(
          padding: const EdgeInsets.all(12.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: dashboardList.length,
          itemBuilder: (BuildContext context, int i) {
            return AnimationConfiguration.staggeredGrid(
              position: i,
              duration: const Duration(milliseconds: 500),
              columnCount: 2, // Matches the `crossAxisCount`
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: MenuCard(
                    menuTitle: ChooseMenu.getTitle(
                        menuName: dashboardList[i].menuName.toString()),
                    menuIconPath: ChooseMenu.getIcon(
                        menuName: dashboardList[i].menuName.toString()),
                    onPressed: () {
                      String route = ChooseMenu.getRoutes(
                        menuName: dashboardList[i].menuName.toString(),
                      );
                      Navigator.pushNamed(
                        context,
                        route,
                      ).then(onBack);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
