import 'package:flutter/material.dart';

import 'admin_leave_filter_widget.dart';
import 'admin_leaves_widget.dart';

class AdminLeavesReportContentWidget extends StatefulWidget {
  const AdminLeavesReportContentWidget({super.key});

  @override
  State<AdminLeavesReportContentWidget> createState() =>
      _AdminLeavesReportContentWidgetState();
}

class _AdminLeavesReportContentWidgetState
    extends State<AdminLeavesReportContentWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
              children: [
                AdminLeaveFilterWidget(),
                AdminLeavesWidget()
              ]);
  }
}
