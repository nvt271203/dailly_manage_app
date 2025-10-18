import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'admin_work_hours_filter_widget.dart';
import 'admin_work_hours_list_widget.dart';

class AdminWorkHoursReportContentWidget extends StatefulWidget {
  const AdminWorkHoursReportContentWidget({super.key});

  @override
  State<AdminWorkHoursReportContentWidget> createState() =>
      _AdminWorkHoursReportContentWidgetState();
}

class _AdminWorkHoursReportContentWidgetState
    extends State<AdminWorkHoursReportContentWidget> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Text('work hours report content'),
        // AdminWorkHoursFilterWidget(),
        AdminWorkHoursFilterWidget(
          onDateRangeSelected: (start, end) {
            setState(() {
              _startDate = start;
              _endDate = end;
            });
          },
        ),
        AdminWorkHoursListWidget(startDate: _startDate, endDate: _endDate),
      ],
    );
  }
}
