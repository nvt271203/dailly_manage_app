import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/works_management/screens/widgets/admin_work_hours_detail_body_widget.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/works_management/screens/widgets/admin_work_hours_detail_footer_widget.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/works_management/screens/widgets/admin_work_hours_detail_header_widget.dart';
import 'package:flutter/material.dart';

import '../../../../../helpers/tools_colors.dart';
import '../../../../../models/work.dart';

class AdminWorkHoursDetailScreen extends StatefulWidget {
  const AdminWorkHoursDetailScreen({super.key, required this.work});

  final Work work;

  @override
  State<AdminWorkHoursDetailScreen> createState() =>
      _AdminWorkHoursDetailScreenState();
}

class _AdminWorkHoursDetailScreenState
    extends State<AdminWorkHoursDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // Lấy thông tin padding từ MediaQuery để tránh thanh điều hướng
    final EdgeInsets padding = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: Colors.white,


      appBar: AppBar(title: Text('Detail Work'), centerTitle: true,

        backgroundColor: widget.work.checkOutTime == null ? Colors.orangeAccent: HelpersColors.itemCard,
        foregroundColor: Colors.white,

      ),
      body: Padding(
        padding: EdgeInsets.only(
          bottom: padding.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              AdminWorkHoursDetailHeaderWidget(work: widget.work),
              SizedBox(height: 10),
              Divider(height: 1),
              SizedBox(height: 20),
              AdminWorkHoursDetailBodyWidget(work: widget.work),
              SizedBox(height: 10),
              Divider(height: 1),
              SizedBox(height: 20),
              AdminWorkHoursDetailFooterWidget(work: widget.work),
          
            ],
          ),
        ),
      ),
    );
  }
}
