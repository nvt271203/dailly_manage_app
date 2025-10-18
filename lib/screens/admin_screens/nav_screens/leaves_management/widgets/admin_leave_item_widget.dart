import 'package:daily_manage_user_app/controller/admin/admin_leave_controller.dart';
import 'package:daily_manage_user_app/controller/admin/admin_work_controller.dart';
import 'package:daily_manage_user_app/providers/admin/admin_leave_filter_provider.dart';
import 'package:daily_manage_user_app/providers/admin/admin_user_filter_provider.dart';
import 'package:daily_manage_user_app/screens/common_screens/widgets/top_notification_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../helpers/format_helper.dart';
import '../../../../../helpers/tools_colors.dart';
import '../../../../../models/leave.dart';

class AdminLeaveItemWidget extends ConsumerStatefulWidget {
  AdminLeaveItemWidget({super.key, required this.leave});

  Leave leave;

  @override
  _AdminLeaveItemWidgetState createState() => _AdminLeaveItemWidgetState();
}

class _AdminLeaveItemWidgetState extends ConsumerState<AdminLeaveItemWidget> {
  @override
  Widget build(BuildContext context) {
    print('leave-toString - ${widget.leave.toString()}');
    final color = widget.leave.status == 'Pending'
        // ? Color(0xFFFFD700)
        // ? Color(0xFFFFCC33)
        ? Colors.orange
        : widget.leave.status == 'Approved'
        // ? Color(0xFF00B2BF)
        ? HelpersColors.itemCard
        : Colors.red;

    final icon = widget.leave.status == 'Pending'
        ? Icons.timelapse_rounded
        : widget.leave.status == 'Approved'
        ? Icons.check_circle
        : Icons.cancel;
    final totalDaysLeaves =
        widget.leave.endDate.difference(widget.leave.startDate).inDays + 1;

    return Padding(
      padding: EdgeInsetsGeometry.only(left: 10, right: 10),
      child: Container(
        margin: const EdgeInsets.only(top: 25, left: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12, // Màu bóng
              blurRadius: 6, // Độ mờ của bóng
              offset: Offset(0, 3), // Vị trí đổ bóng (ngang, dọc)
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
          // border: Border.all(color: color, width: 2),
          // borderRadius: const BorderRadius.only(
          //   topRight: Radius.circular(20),
          //   bottomLeft: Radius.circular(20),
          // ),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -15,
              left: 15,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  border: Border.all(
                    width: 1,
                    color: Colors.grey.withOpacity(0.1),
                  ),
                  color: Color(0xFFEDECEB),

                  // color: Color(0xFFDDDDDD).withOpacity(0.5),
                ),
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          ref
                              .read(adminLeaveFilterProvider)
                              .sortField
                              .contains('startDate')
                              ? 'Time off: '
                              : 'Data sent: ',
                          style: const TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),

                        if( ref
                            .read(adminLeaveFilterProvider)
                            .sortField
                            .contains('startDate'))
                          Row(
                            children: [
                              Text(
                                FormatHelper.formatDate_DD_MM(
                                  widget.leave.startDate,
                                ),
                                style: const TextStyle(fontSize: 12),
                              ),
                              const Text(' - '),
                              Text(
                                FormatHelper.formatDate_DD_MM(widget.leave.endDate),
                                style: const TextStyle(fontSize: 12),
                              ),
                              // // const Spacer(),
                              // const Icon(Icons.chevron_right_outlined),
                            ],
                          ),
                        if( !ref
                            .read(adminLeaveFilterProvider)
                            .sortField
                            .contains('startDate'))
                          Row(
                            children: [
                              Text(
                                '${FormatHelper.formatDate_DD_MM(widget.leave.dateCreated)}',
                                style: const TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                ' (${FormatHelper.formatTimeHH_MM(widget.leave.dateCreated)})',
                                style: const TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),


                      ],
                    ),

                    // Row(
                    //   children: [
                    //     const Text('Time off: '),
                    //     Text(
                    //       FormatHelper.formatDate_DD_MM(leave.startDate),
                    //       style: const TextStyle(fontSize: 12),
                    //     ),
                    //     const Text(' - '),
                    //     Text(
                    //       FormatHelper.formatDate_DD_MM(leave.endDate),
                    //       style: const TextStyle(fontSize: 12),
                    //     ),
                    //     // // const Spacer(),
                    //     // const Icon(Icons.chevron_right_outlined),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  Row(
                    children: [
                      // ClipRRect(
                      //   borderRadius: BorderRadius.all(Radius.circular(100)),
                      //   child: Image.network(
                      //     // 'https://res.cloudinary.com/doiar6ybd/image/upload/v1753864338/users/rinoadsrlke9aoj5bfxj.jpg',
                      //     widget.work.user?['image'] ?? 'https://res.cloudinary.com/doiar6ybd/image/upload/v1753864338/users/rinoadsrlke9aoj5bfxj.jpg',
                      //
                      //     width: 50,
                      //     height: 50,
                      //     fit: BoxFit.cover,
                      //   ),
                      // ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          // border: Border.all(color: Colors.black),
                          color: Colors.white,
                          shape: BoxShape.circle,
                          // border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: ClipOval(
                          child: Image(
                            // image: user?.image == null || user!.image.isEmpty
                            //     ? AssetImage(
                            //   user?.sex == 'Male'
                            //       ? 'assets/images/avatar_boy_default.jpg'
                            //       : user?.sex == "Female"
                            //   ? 'assets/images/avatar_girl_default.jpg'
                            //   : 'assets/images/avt_default_2.jpg',
                            // ) as ImageProvider
                            //     : NetworkImage(user.image),
                            image:
                                widget.leave.user?.image == null ||
                                    widget.leave.user!.image.isEmpty
                                ? AssetImage(
                                        widget.leave.user?.sex == 'Male'
                                            ? 'assets/images/avatar_boy_default.jpg'
                                            : widget.leave.user?.sex == "Female"
                                            ? 'assets/images/avatar_girl_default.jpg'
                                            : 'assets/images/avt_default_2.jpg',
                                      )
                                      as ImageProvider
                                : NetworkImage(widget.leave.user!.image),

                            // Sử dụng NetworkImage cho URLs
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.leave.user?.fullName == null ||
                                          widget.leave.user!.fullName == ''
                                      ? 'Anonymous'
                                      : widget.leave.user!.fullName,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        // 'Total: 5h30p'
                                        'Department: ', // Hiển thị tổng thời gian
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      Expanded(
                                        child: Text(
                                          // 'Total: 5h30p'
                                          widget.leave.user?.department?.name ?? 'Unset',
                                          // Hiển thị tổng thời gian
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Position: ',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    Text(
                                      widget.leave.user?.position?.positionName ?? 'Unset',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),

                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      // Content 1: timer
                      Text(
                        ref
                                .read(adminLeaveFilterProvider)
                                .sortField
                                .contains('startDate')
                            ? 'Data sent:  '
                            : 'Time off: ',
                        style: const TextStyle(fontSize: 13),
                      ),

                      if (ref
                          .read(adminLeaveFilterProvider)
                          .sortField
                          .contains('startDate'))
                        Row(
                          children: [
                            Text(
                              FormatHelper.formatDate_DD_MM(
                                widget.leave.dateCreated,
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const Text(' ('),
                            Text(
                              FormatHelper.formatTimeHH_MM(
                                widget.leave.dateCreated,
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const Text(')'),

                            // // const Spacer(),
                            // const Icon(Icons.chevron_right_outlined),
                          ],
                        ),
                      if (!ref
                          .read(adminLeaveFilterProvider)
                          .sortField
                          .contains('startDate'))
                        Row(
                          children: [
                            Text(
                              FormatHelper.formatDate_DD_MM(
                                widget.leave.startDate,
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const Text(' - '),
                            Text(
                              FormatHelper.formatDate_DD_MM(widget.leave.endDate),
                              style: const TextStyle(fontSize: 12),
                            ),
                            // // const Spacer(),
                            // const Icon(Icons.chevron_right_outlined),
                          ],
                        ),

                    ],
                  ),

                  Row(
                    children: [
                      Text('Type: ', style: const TextStyle(fontSize: 13)),
                      Text(
                        '${widget.leave.leaveType}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Duration: ', style: TextStyle(fontSize: 13)),
                      Text(
                        '$totalDaysLeaves day -  ${widget.leave.leaveTimeType}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: Row(
                  children: [
                    Text(
                      widget.leave.status,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.leave.isNew == true)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  // decoration: BoxDecoration(
                  //   color: color,
                  //   borderRadius: const BorderRadius.only(
                  //     topLeft: Radius.circular(10),
                  //   ),
                  // ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'New',
                        style: TextStyle(
                          color: HelpersColors.itemSelected,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: HelpersColors.itemSelected,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
