import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/organizational_management/widgets/tab_bar/tab_position/diaglogs/admin_org_tab_position_add_dialog.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/organizational_management/widgets/tab_bar/tab_position/widgets/admin_org_tab_positions_widget.dart';
import 'package:flutter/material.dart';

import '../../../../../../../helpers/tools_colors.dart';
class AdminOrgTabPositionScreen extends StatefulWidget {
  const AdminOrgTabPositionScreen({super.key});

  @override
  State<AdminOrgTabPositionScreen> createState() => _AdminOrgTabPositionScreenState();
}

class _AdminOrgTabPositionScreenState extends State<AdminOrgTabPositionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10,),
          // AdminOrgTabDepartmentsWidget()
          Expanded(child: AdminOrgTabPositionsWidget())
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: HelpersColors.itemCard, // màu theo theme của bạn
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AdminOrgTabPositionAddDialog(),
          );
        },
      ),
    );  }
}
