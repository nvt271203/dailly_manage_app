import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/organizational_management/widgets/tab_bar/tab_department/admin_org_tab_department_screen.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/organizational_management/widgets/tab_bar/tab_position/admin_org_tab_position_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminOrgTabBarWidget extends StatefulWidget {
  final ValueChanged<int> onTabSelected; // callback cho parent

  const AdminOrgTabBarWidget({
    super.key,
    required this.onTabSelected,
  });

  @override
  State<AdminOrgTabBarWidget> createState() => _AdminOrgTabBarWidgetState();
}

class _AdminOrgTabBarWidgetState extends State<AdminOrgTabBarWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Lắng nghe sự thay đổi tab để callback ra ngoài
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        widget.onTabSelected(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TabBar(
            physics: NeverScrollableScrollPhysics(),
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            // indicator: BoxDecoration(
            //   // Tùy chỉnh màu nền khi tab được chọn
            //   color: Colors.blue.withOpacity(0.1), // Màu nền khi tab được chọn
            //   borderRadius: BorderRadius.circular(8.0),
            // ),
            // indicatorPadding: const EdgeInsets.all(4.0), // Điều chỉnh padding để bao quanh ta
            indicatorSize: TabBarIndicatorSize.tab, // 👈 Phủ toàn bộ tab

            labelPadding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding cho tab
            tabs: const [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon( FontAwesomeIcons.buildingUser, size: 20), // Biểu tượng bên trái
                    SizedBox(width: 20.0), // Khoảng cách giữa icon và text
                    Text("Departments",style: TextStyle(fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FontAwesomeIcons.userTie, size: 20), // Biểu tượng bên trái
                    SizedBox(width: 20.0),
                    Text("Positions",style: TextStyle(fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(), // 🚀 Tắt vuốt ngang
              children: const [
                AdminOrgTabDepartmentScreen(),
                AdminOrgTabPositionScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
