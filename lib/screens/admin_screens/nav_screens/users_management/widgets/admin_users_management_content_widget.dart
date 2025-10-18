import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/users_management/widgets/admin_users_search_widget.dart';
import 'package:flutter/material.dart';

import 'admin_users_widget.dart';
class AdminUsersManagementContentWidget extends StatefulWidget {
  const AdminUsersManagementContentWidget({super.key});

  @override
  State<AdminUsersManagementContentWidget> createState() => _AdminUsersManagementContentWidgetState();
}

class _AdminUsersManagementContentWidgetState extends State<AdminUsersManagementContentWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdminUsersSearchWidget(),
        AdminUsersWidget()
      ],
    );
  }
}
