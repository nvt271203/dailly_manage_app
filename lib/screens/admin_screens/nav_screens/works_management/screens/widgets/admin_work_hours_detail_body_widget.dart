import 'dart:async';

import 'package:daily_manage_user_app/helpers/tools_colors.dart';
import 'package:flutter/material.dart';

import '../../../../../../helpers/format_helper.dart';
import '../../../../../../models/work.dart';

class AdminWorkHoursDetailBodyWidget extends StatefulWidget {
  const AdminWorkHoursDetailBodyWidget({super.key, required this.work});

  final Work work;

  @override
  State<AdminWorkHoursDetailBodyWidget> createState() =>
      _AdminWorkHoursDetailBodyWidgetState();
}

class _AdminWorkHoursDetailBodyWidgetState
    extends State<AdminWorkHoursDetailBodyWidget> {

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Nếu chưa checkout (workTime null) thì tạo bộ đếm
    if (widget.work.workTime == null) {
      _timer = Timer.periodic(Duration(seconds: 1), (_) {
        setState(() {

        }); // Cập nhật giao diện mỗi giây
      });
    }
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWorking = widget.work.checkOutTime == null;
    final workDuration = widget.work.workTime ??
        DateTime.now().difference(widget.work.checkInTime);


    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color:
                widget.work.checkOutTime == null ||
                    widget.work.checkOutTime == ''
                ? Colors.orange
                : HelpersColors.itemCard,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: Text(
            widget.work.checkOutTime == null || widget.work.checkOutTime == ''
                ? 'Working'
                : 'Woked',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
        IntrinsicHeight(
          child: Row(
            children: [
              SizedBox(width: 20),
              Container(
                width: 3,
                color:
                    widget.work.checkOutTime == null ||
                        widget.work.checkOutTime == ''
                    ? Colors.orange
                    : HelpersColors.itemCard,
              ),
              SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),

                  Row(
                    children: [
                      Icon(Icons.access_time_filled_outlined, size: 20),
                      SizedBox(width: 5),
                      Text('Check-In Time:  '),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time_filled_outlined, size: 20),
                      SizedBox(width: 5),
                      Text('Check-Out Time: ', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time_filled_outlined, size: 20),
                      SizedBox(width: 5),
                      Text(
                        'Total Working Time: ',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  Text(
                    '${FormatHelper.formatTimeHH_MM(widget.work.checkInTime)}',
                    style: TextStyle(
                      color: HelpersColors.itemCard,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,

                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.work.checkOutTime != null
                        ? '${FormatHelper.formatTimeHH_MM(widget.work.checkOutTime!)}'
                        : 'Not Checkout !',
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.work.checkOutTime != null
                          ? HelpersColors.itemCard
                          : HelpersColors.itemSelected,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.work.workTime == null ||
                        widget.work.workTime == '' ||
                        widget.work.workTime == 0
                        ? '${FormatHelper.formatDuration(workDuration)}'
                        : '${FormatHelper.formatDurationHH_h_MM_p(widget.work.workTime!)}',

                    style: TextStyle(
                      fontSize: 13,
                      color: widget.work.checkOutTime != null
                          ? HelpersColors.itemCard
                          : HelpersColors.itemSelected,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
