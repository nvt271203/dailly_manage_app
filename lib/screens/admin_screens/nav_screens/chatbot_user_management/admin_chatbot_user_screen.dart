import 'package:daily_manage_user_app/controller/auth_controller.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/chatbot_user_management/widgets/admin_chatbot_user_content_widget.dart';
import 'package:daily_manage_user_app/screens/admin_screens/widgets/drawer_list_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../providers/user_provider.dart';
import '../../widgets/admin_header_sub_nav_widget.dart';

class AdminChatbotUserScreen extends ConsumerStatefulWidget {
  const AdminChatbotUserScreen({super.key});

  @override
  _AdminChatbotUserScreenState createState() => _AdminChatbotUserScreenState();
}

class _AdminChatbotUserScreenState
    extends ConsumerState<AdminChatbotUserScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String _selectedDrawerItem = 'Chat Bot User';

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      drawer: DrawerListMenuWidget(
        user: user!,
        selectedDrawerItem: _selectedDrawerItem,
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AdminHeaderSubNavWidget(
          title: _selectedDrawerItem,
          icon: FontAwesomeIcons.robot,
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      // body: Column(children: [Expanded(child: WorkBoardContent())]),
      body: AdminChatbotUserContentWidget(),
    );
  }
}
