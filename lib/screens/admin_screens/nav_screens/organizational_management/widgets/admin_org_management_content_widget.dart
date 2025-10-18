import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/organizational_management/widgets/tab_bar/admin_org_tabBar_widget.dart';
import 'package:flutter/material.dart';
class AdminOrgManagementContentWidget extends StatefulWidget {
  const AdminOrgManagementContentWidget({super.key});

  @override
  State<AdminOrgManagementContentWidget> createState() => _AdminOrgManagementContentWidgetState();
}

class _AdminOrgManagementContentWidgetState extends State<AdminOrgManagementContentWidget> {
  int _selectedIndex = 0; // mặc định chọn tab đầu tiên

  @override
  Widget build(BuildContext context) {
    return AdminOrgTabBarWidget(
      onTabSelected: (index) {
        print("Tab được chọn: $index");
        // 0 = Departments, 1 = Positions
      },
    );
  }
}
