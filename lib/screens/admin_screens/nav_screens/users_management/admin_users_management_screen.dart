import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/users_management/widgets/admin_users_management_content_widget.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/users_management/widgets/screens/admin_create_new_user_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../controller/auth_controller.dart';
import '../../../../helpers/tools_colors.dart';
import '../../../../providers/user_provider.dart';
import '../../widgets/admin_header_sub_nav_widget.dart';
import '../leaves_management/admin_leaves_report_screen.dart';
import '../organizational_management/admin_organization_management_screen.dart';
import '../report_management/admin_report_screen.dart';
import '../works_management/admin_work_hours_report_screen.dart';

class AdminUsersManagementScreen extends ConsumerStatefulWidget {
  const AdminUsersManagementScreen({super.key});

  @override
  _AdminUsersManagementScreenState createState() =>
      _AdminUsersManagementScreenState();
}

class _AdminUsersManagementScreenState
    extends ConsumerState<AdminUsersManagementScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedDrawerItem = 'Users Management';
  final AuthController _authController = AuthController();
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
                  colors: [
                    HelpersColors.itemCard,
                    HelpersColors.itemCard,
                  ],
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
            _buildDrawerItem(
              context,
              icon: Icons.access_time_filled_outlined,
              title: 'Works Management',
              targetScreen: AdminWorkHoursReportScreen(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.text_snippet_sharp,
              title: 'Reports Management',
              targetScreen: AdminReportScreen(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.block,
              title: 'Leaves Management',
              targetScreen: AdminLeavesReportScreen(),
            ),
            _buildDrawerItem(
              context,
              icon: CupertinoIcons.person_2_fill,
              title: 'Users Management',
              targetScreen: AdminUsersManagementScreen(),
            ),
            _buildDrawerItem(
              context,
              icon: FontAwesomeIcons.landmark,
              title: 'Org Management',
              targetScreen: AdminOrganizationManagementScreen(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.logout_rounded,
              title: 'Logout',
              targetScreen: AdminUsersManagementScreen(),
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
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? targetScreen,
    VoidCallback? onTap,
  }) {
    final bool isSelected = title == _selectedDrawerItem;

    return InkWell(
      onTap:
          onTap ??
          () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => targetScreen!),
            );
          },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? HelpersColors.itemCard : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: HelpersColors.itemCard),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                // Icon leading
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: HelpersColors.itemCard),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Icon(icon, color: HelpersColors.itemCard, size: 20),
                ),

                SizedBox(width: 12),

                // Title (Text)
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : HelpersColors.itemCard,
                    ),
                  ),
                ),

                // Trailing icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: isSelected ? Colors.white : HelpersColors.itemCard,
                ),
              ],
            ),
          ),
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
          title: 'Users Management',
          icon: CupertinoIcons.person_2_fill,
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      // body: Column(children: [Expanded(child: WorkBoardContent())]),
      body: AdminUsersManagementContentWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AdminCreateNewUserScreen();
          },));
        },
        backgroundColor: HelpersColors.itemCard,
        child: Icon(Icons.add,color: Colors.white,), // Biểu tượng dấu +
      ),
    );
  }
}
