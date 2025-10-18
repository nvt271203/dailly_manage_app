import 'package:daily_manage_user_app/helpers/tools_colors.dart';
import 'package:daily_manage_user_app/models/work.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AdminWorkHoursDetailFooterWidget extends StatefulWidget {
  const AdminWorkHoursDetailFooterWidget({super.key, required this.work});

  final Work work;

  @override
  State<AdminWorkHoursDetailFooterWidget> createState() =>
      _AdminWorkHoursDetailFooterWidgetState();
}

class _AdminWorkHoursDetailFooterWidgetState
    extends State<AdminWorkHoursDetailFooterWidget> {

  @override
  Widget build(BuildContext context) {
    Color colorStatus = widget.work.checkOutTime == null ? Colors.orange : HelpersColors.itemCard;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5))
            ,color: colorStatus,

          ),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: Text('Mission',style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.white
          ),),
        ),
        // SizedBox(height: 10,),
        IntrinsicHeight(
          child: Row(
            
            
            children: [
              SizedBox(width: 20,),
              Container( width: 3,color: colorStatus,),
              SizedBox(width: 10,),
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    _buildItemReport(
                      title: 'Report',
                      subTitle: 'Yesterday\'s tasks and results',
                      content: widget.work.report == null || widget.work.report == ''?
                      'Report not submitted' :
                      widget.work.report,
                      colorStatus: colorStatus
                    ),
                    SizedBox(height: 10,),
                    _buildItemReport(
                      title: 'Plan',
                      subTitle: 'Today\'s goals and plans',
                      content: widget.work.plan == null || widget.work.plan == ''?
                      'Plan not submitted' :
                      widget.work.plan,
                        colorStatus: colorStatus

                    ),
                    SizedBox(height: 10,),
                    _buildItemReport(
                      title: 'Note',
                      subTitle: 'Notes and support needs',
                      content: widget.work.note == null || widget.work.note == '' ?
                      '' :
                      widget.work.note,
                        colorStatus: colorStatus

                    ),
                    SizedBox(height: 10,),

                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemReport({
    required String title,
    required String subTitle,
    required String content,
    required Color colorStatus
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            // color: Colors.black.withOpacity(0.2), // màu bóng
            spreadRadius: 1, // độ lan
            // blurRadius: 5, // độ mờ
            // offset: Offset(0, 3), // dịch chuyển bóng: x=0, y=3
color: Colors.black12,            blurRadius: 3, // Độ mờ của bóng
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: colorStatus,
              ),
            ),
          ),
          Row(
            children: [
              Container(height: 1, width: 80, color: colorStatus),
            ],
          ),
          SizedBox(height: 5),
          Text(
            subTitle,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: colorStatus.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Text(
                  content,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
              ),
              SizedBox(width: 10),
              if(content.contains('not'))
                  Icon(Icons.warning_outlined,color: Colors.orangeAccent,)
            ],
          ),
        ],
      ),
    );
  }
}
