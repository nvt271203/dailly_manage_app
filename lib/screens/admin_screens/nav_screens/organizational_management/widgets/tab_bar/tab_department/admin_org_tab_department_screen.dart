import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/organizational_management/widgets/tab_bar/tab_department/widgets/admin_org_tab_departments_widget.dart';
import 'package:flutter/material.dart';

import '../../../../../../../helpers/tools_colors.dart';
import 'dialogs/admin_org_tab_department_add_diaglog.dart';
class AdminOrgTabDepartmentScreen extends StatefulWidget {
  const AdminOrgTabDepartmentScreen({super.key});

  @override
  State<AdminOrgTabDepartmentScreen> createState() => _AdminOrgTabDepartmentScreenState();
}

class _AdminOrgTabDepartmentScreenState extends State<AdminOrgTabDepartmentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AdminOrgTabDepartmentAddWidget(),
          // Padding(
          //   padding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
          //   child: Container(
          //     height: 1,
          //     width: double.infinity,
          //     color: HelpersColors.itemCard,
          //   ),
          // ),
          AdminOrgTabDepartmentsWidget()

        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: HelpersColors.itemCard, // màu theo theme của bạn
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AdminOrgTabDepartmentAddDialog(),
          );
        },
      ),
    );
  }
}
