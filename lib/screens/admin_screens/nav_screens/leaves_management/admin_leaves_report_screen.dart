import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/leaves_management/widgets/admin_leaves_report_content_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../controller/auth_controller.dart';
import '../../../../helpers/tools_colors.dart';
import '../../../../providers/user_provider.dart';
import '../../widgets/admin_header_sub_nav_widget.dart';
import '../../widgets/drawer_list_menu_widget.dart';
import '../organizational_management/admin_organization_management_screen.dart';
import '../report_management/admin_report_screen.dart';
import '../users_management/admin_users_management_screen.dart';
import '../works_management/admin_work_hours_report_screen.dart';
class AdminLeavesReportScreen extends ConsumerStatefulWidget {
  const AdminLeavesReportScreen({super.key});

  @override
  _AdminLeavesReportScreenState createState() => _AdminLeavesReportScreenState();
}

class _AdminLeavesReportScreenState extends ConsumerState<AdminLeavesReportScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String _selectedDrawerItem = 'Leaves Management';
  final AuthController _authController = AuthController();
  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);
    return Scaffold(

      backgroundColor: Colors.white,
      key: _scaffoldKey,
      drawer: DrawerListMenuWidget(user: user!, selectedDrawerItem: _selectedDrawerItem),
      appBar:
      PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AdminHeaderSubNavWidget(
          title: 'Leaves Report',
          icon: Icons.block,
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      // body: Column(children: [Expanded(child: WorkBoardContent())]),
      body: AdminLeavesReportContentWidget(),
    );
  }
}
