import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/chatbot_user_management/admin_chatbot_user_screen.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/organizational_management/admin_organization_management_screen.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/users_management/admin_users_management_screen.dart';
import 'package:daily_manage_user_app/screens/admin_screens/widgets/admin_header_sub_nav_widget.dart';
import 'package:daily_manage_user_app/screens/admin_screens/widgets/chatbot_overlay_widget.dart';
import 'package:daily_manage_user_app/screens/admin_screens/widgets/drawer_item_menu_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../controller/auth_controller.dart';
import '../../helpers/tools_colors.dart';
import '../../providers/user_provider.dart';
import 'nav_screens/leaves_management/admin_leaves_report_screen.dart';
import 'nav_screens/report_management/admin_report_screen.dart';
import 'nav_screens/works_management/admin_work_hours_report_screen.dart';
import 'nav_screens/works_management/widgets/admin_work_hours_report_content_widget.dart';

class AdminMainScreen extends ConsumerStatefulWidget {
  const AdminMainScreen({super.key});

  @override
  _AdminMainScreenState createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends ConsumerState<AdminMainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ChatbotOverlayWidget().show(context); // ✅ Chỉ bật ở Admin
    });
  }

  String _selectedDrawerItem = 'Works Management';
  AuthController _authController = AuthController();

  Widget _buildDrawer(user) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [HelpersColors.itemCard, HelpersColors.itemCard],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50),
                  Row(
                    children: [
                      Container(
                        // padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: user?.image == null || user!.image.isEmpty
                              ? Image.asset(
                                  user?.sex == 'Male'
                                      ? 'assets/images/avatar_boy_default.jpg'
                                      : user?.sex == 'Male'
                                      ? 'assets/images/avatar_girl_default.jpg'
                                      : 'assets/images/avt_default_2.jpg',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  user.image,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          (user?.fullName == null ||
                                  user!.fullName.trim().isEmpty)
                              ? 'New User'
                              : user.fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            DrawerItemMenuWidget(
              icon: Icons.access_time_filled_outlined,
              title: 'Works Management',
              targetScreen: AdminWorkHoursReportScreen(),
                isSelected: _selectedDrawerItem == 'Works Management',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminWorkHoursReportScreen()),
                );
              },
            ),

            DrawerItemMenuWidget(
              icon: Icons.text_snippet_sharp,
              title: 'Reports Management',
              targetScreen: AdminReportScreen(),
              isSelected: _selectedDrawerItem == 'Reports Management',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminReportScreen()),
                );
              },
            ),
            DrawerItemMenuWidget(
              icon: Icons.block,
              title: 'Leaves Management',
              targetScreen: AdminLeavesReportScreen(),
              isSelected: _selectedDrawerItem == 'Leaves Management',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminLeavesReportScreen()),
                );
              },
            ),

            DrawerItemMenuWidget(
              icon: CupertinoIcons.person_2_fill,
              title: 'Users Management',
              targetScreen: AdminUsersManagementScreen(),
              isSelected: _selectedDrawerItem == 'Users Management',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminUsersManagementScreen()),
                );
              },
            ),
            DrawerItemMenuWidget(
              icon: FontAwesomeIcons.landmark,
              title: 'Org Management',
              targetScreen: AdminOrganizationManagementScreen(),
              isSelected: _selectedDrawerItem == 'Org Management',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminOrganizationManagementScreen()),
                );
              },
            ),
            //-------------
            DrawerItemMenuWidget(
              icon: FontAwesomeIcons.robot,
              title: 'Chat Bot User',
              targetScreen: AdminChatbotUserScreen(),
              isSelected: _selectedDrawerItem == 'Chat Bot User',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminChatbotUserScreen()),
                );
              },
            ),
            DrawerItemMenuWidget(
              icon: Icons.logout_rounded,
              title: 'Logout',
              targetScreen: AdminUsersManagementScreen(),
              isSelected: _selectedDrawerItem == 'Logout',
              onTap: () {
                _authController.logoutUser(context);
              },
            ),

            // _buildDrawerItem(
            //   context,
            //   icon: Icons.view_timeline_outlined,
            //   title: 'Work Gantt',
            //   targetScreen: SubNavWorkGanttScreen(),
            // ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      drawer: _buildDrawer(user),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AdminHeaderSubNavWidget(
          title: 'Work Hours Report',
          icon: Icons.access_time_filled_outlined,
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      // body: Column(children: [Expanded(child: WorkBoardContent())]),
      body: AdminWorkHoursReportContentWidget(),
    );
  }
}
