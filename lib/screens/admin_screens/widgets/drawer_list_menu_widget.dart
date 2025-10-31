import 'package:daily_manage_user_app/screens/admin_screens/widgets/drawer_title_menu_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../controller/auth_controller.dart';
import '../../../helpers/tools_colors.dart';
import '../../../models/user.dart';
import '../nav_screens/chatbot_user_management/admin_chatbot_user_screen.dart';
import '../nav_screens/leaves_management/admin_leaves_report_screen.dart';
import '../nav_screens/organizational_management/admin_organization_management_screen.dart';
import '../nav_screens/report_management/admin_report_screen.dart';
import '../nav_screens/users_management/admin_users_management_screen.dart';
import '../nav_screens/works_management/admin_work_hours_report_screen.dart';
import 'drawer_item_menu_widget.dart';
class DrawerListMenuWidget extends StatelessWidget {
  const DrawerListMenuWidget({super.key, required this.user, required this.selectedDrawerItem});
  final User user;
  final String selectedDrawerItem;
  @override
  Widget build(BuildContext context) {
    final AuthController _authController = AuthController();
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerTitleMenuWidget(user: user),
            SizedBox(height: 10),
            DrawerItemMenuWidget(
              icon: Icons.access_time_filled_outlined,
              title: 'Works Management',
              targetScreen: AdminWorkHoursReportScreen(),
              isSelected: selectedDrawerItem == 'Works Management',
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
              isSelected: selectedDrawerItem == 'Reports Management',
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
              isSelected: selectedDrawerItem == 'Leaves Management',
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
              isSelected: selectedDrawerItem == 'Users Management',
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
              isSelected: selectedDrawerItem == 'Org Management',
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
              isSelected: selectedDrawerItem == 'Chat Bot User',
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
              isSelected: selectedDrawerItem == 'Logout',
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
}
