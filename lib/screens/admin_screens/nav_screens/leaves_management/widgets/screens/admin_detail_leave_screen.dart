import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/users_management/widgets/screens/admin_information_user_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../controller/admin/admin_leave_controller.dart';
import '../../../../../../helpers/format_helper.dart';
import '../../../../../../helpers/tools_colors.dart';
import '../../../../../../models/leave.dart';
import '../../../../../../models/user.dart';
import '../../../../../../providers/admin/admin_leave_provider.dart';
import '../../../../../../widgets/dialog_confirm_widget.dart';
import '../../../../../common_screens/widgets/top_notification_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dialogs/admin_confirm_delete_dialog.dart';

class AdminDetailLeaveScreen extends ConsumerStatefulWidget {
  const AdminDetailLeaveScreen({super.key, required this.leave});

  final Leave leave;

  @override
  _AdminDetailLeaveScreenState createState() => _AdminDetailLeaveScreenState();
}

class _AdminDetailLeaveScreenState
    extends ConsumerState<AdminDetailLeaveScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _markAsRead();
  }

  void _markAsRead() async {
    final status = await AdminLeaveController().leaveRemoveIsNew(
      id: widget.leave.id,
    );
    if (status != null) {
      print('update isNew is success');
      // Navigator.of(context).pop(true);
      // / Cập nhật cục bộ trạng thái isNew trong LeaveProvider
      ref
          .read(adminLeaveProvider.notifier)
          .updateLeaveIsNew(widget.leave.id, false);
    } else {
      print('update isNew is error');
      // Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = MediaQuery.of(context).padding;
    print('leave detail-toString - ${widget.leave.toString()}');

    // final color = widget.leave.status == 'Pending'
    //     // ? Color(0xFFFFD700)
    //     // ? Color(0xFFFFCC33)
    //     ? Colors.orange
    //     : widget.leave.status == 'Approved'
    //     ? Color(0xFF00B2BF)
    //     : Colors.red;
    // final icon = widget.leave.status == 'Pending'
    //     ? Icons.timelapse_rounded
    //     : widget.leave.status == 'Approved'
    //     ? Icons.check_circle
    //     : Icons.cancel;
    // final totalDaysLeaves =
    //     widget.leave.endDate.difference(widget.leave.startDate).inDays + 1;



    Future<void> _showDialogConfirmLeave(String leaveStatus, Color background) {
      return showDialog(
        context: context,
        builder: (context) {
          return DialogConfirmWidget(
            title: "Confirm",
            content: "Are you sure you want to ${leaveStatus} this status?",
            color: background,
            onConfirm: () async {
              final result = await AdminLeaveController().leaveRequestHandel(
                id: widget.leave.id,
                status: leaveStatus,
              );
              if (result != null) {
                showTopNotification(
                  context: context,
                  message: 'Your leave request has been approved.',
                  type: NotificationType.success,
                );
                setState(() {
                  widget.leave.status = leaveStatus;
                });
                // Cập nhật trạng thái trong provider
                ref
                    .read(adminLeaveProvider.notifier)
                    .updateLeaveStatus(widget.leave.id, leaveStatus);
              }
              Navigator.pop(context); // đóng dialog sau khi confirm
            },
          );
        },
      );
    }
    Widget _buildDevider(Color color) {
      return Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
        child: Container(height: 1, color: color.withOpacity(0.3)),
      );
    }
    Widget _buildLeaveRequestButtonHandle(
      String title,
      IconData icon,
      Color background,
    ) {
      return Container(
        child: Row(
          children: [
            Text(title, style: TextStyle(color: Colors.white)),
            SizedBox(width: 20),
            Icon(icon, size: 22, color: Colors.white),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
      );
    }

    Widget _buildInfoCard({
      required IconData icon,
      required String title,
      required String content,
      bool isMultiline = false,
    }) {
      return Padding(
        padding: const EdgeInsets.all(16), // giảm padding cho gọn
        child: Row(
          crossAxisAlignment: isMultiline
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: HelpersColors.itemCard.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  10,
                ), // hoặc 20 nếu muốn tròn hơn
              ),
              child: Icon(icon, size: 22, color: HelpersColors.itemCard),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: HelpersColors.itemCard,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: HelpersColors.itemCard,
        foregroundColor: Colors.white,
        title: Text(
          'Leave Detail',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          bottom: padding.bottom,
          // top: 16,
          // left: 16,
          // right: 16,
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              // color: HelpersColors.bgFillTextField,
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
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
                            widget.leave.user == null ||
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
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.leave.user?.fullName == null ||
                                widget.leave.user!.fullName.isEmpty
                            ? 'Anonymous'
                            : widget.leave.user!.fullName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      if (widget.leave.user?.email != null &&
                          widget.leave.user!.email.isNotEmpty)
                        Text(
                          widget.leave.user!.email,
                          style: TextStyle(color: Colors.grey),
                        ),
                      Row(
                        children: [
                          Text(
                            'Department: ', // Hiển thị tổng thời gian
                            style: TextStyle(fontSize: 13),
                          ),
                          Text(
                            widget.leave.user?.department?.name ?? 'Unset',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Position: ', style: TextStyle(fontSize: 13)),
                          Text(
                            widget.leave.user?.position?.positionName ?? 'Unset',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            if (widget.leave.user == null) {
                              return const Center(
                                child: Text("No user information"),
                              );
                            }

                            return AdminInformationUserScreen(
                              user: widget.leave.user!,
                            );
                          },
                        ),
                      );
                    },

                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_double_arrow_right,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildDevider(HelpersColors.itemCard),
                    _buildInfoCard(
                      icon: FontAwesomeIcons.calendar,
                      title: 'Data Sent',
                      content: '${
                          FormatHelper.formatTimeHH_MM(widget.leave.dateCreated)
                      } - ${FormatHelper.formatDate_DD_MM_YYYY(widget.leave.dateCreated)}',
                    ),
                    _buildDevider(HelpersColors.itemCard),
                    _buildInfoCard(
                      icon: Icons.pending_actions,
                      title: 'Status',
                      content: widget.leave.status,
                    ),
                    if (widget.leave.rejectionReason != null &&
                        widget.leave.rejectionReason != '')
                    _buildDevider(HelpersColors.itemCard),
                    if (widget.leave.rejectionReason != null &&
                        widget.leave.rejectionReason != '')
                      _buildInfoCard(
                        icon: FontAwesomeIcons.ban,
                        title: 'Rejected Reason',
                        content: widget.leave.rejectionReason.toString(),
                      ),
                    _buildDevider(HelpersColors.itemCard),
                    _buildInfoCard(
                      icon: Icons.category,
                      title: 'Leave Type',
                      content: widget.leave.leaveType,
                    ),
                    _buildDevider(HelpersColors.itemCard),
                    _buildInfoCard(
                      icon: Icons.access_time,
                      title: 'Time Type',
                      content: widget.leave.leaveTimeType,
                    ),
                    _buildDevider(HelpersColors.itemCard),
                    _buildInfoCard(
                      icon: Icons.today,
                      title: 'Start Date',
                      content:
                          // '${FormatHelper.formatDate_DD_MM_YYYY(leave.startDate)} (${FormatHelper.formatTimeHH_MM(leave.startDate)})',
                          '${FormatHelper.formatTimeHH_MM(widget.leave.startDate)} - ${FormatHelper.formatDate_DD_MM_YYYY(widget.leave.startDate)}',
                    ),
                    _buildDevider(HelpersColors.itemCard),
                    _buildInfoCard(
                      icon: Icons.event_available,
                      title: 'End Date',
                      content:
                          '${FormatHelper.formatTimeHH_MM(widget.leave.endDate)} - ${FormatHelper.formatDate_DD_MM_YYYY(widget.leave.endDate)}',
                    ),
                    _buildDevider(HelpersColors.itemCard),
                    _buildInfoCard(
                      icon: Icons.note_alt,
                      title: 'Reason',
                      content: widget.leave.reason,
                      isMultiline: true,
                    ),
                    _buildDevider(HelpersColors.itemCard),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.leave.status == 'Pending'
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              color: Colors.blueGrey.withOpacity(0.1),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (widget.leave.status != 'Approved')
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AdminConfirmDeleteDialog(
                                      title: 'Reject Leave Request',
                                      content:
                                          'Please provide a reason for rejecting this leave request.',
                                      onConfirm: (rejectionReason) async {
                                        final resultRequestRejected =
                                            await AdminLeaveController()
                                                .leaveRequestHandel(
                                                  id: widget.leave.id,
                                                  status: 'Rejected',
                                                  rejectionReason:
                                                      rejectionReason,
                                                );
                                        if (resultRequestRejected != null) {
                                          setState(() {
                                            widget.leave.rejectionReason =
                                                rejectionReason;
                                            widget.leave.status = 'Rejected';
                                          });
                                          showTopNotification(
                                            context: context,
                                            message:
                                                'This leave request has been deleted.',
                                            type: NotificationType.success,
                                          );
                                        } else {
                                          showTopNotification(
                                            context: context,
                                            message:
                                                'This leave request has been failed.',
                                            type: NotificationType.error,
                                          );
                                        }
                                        return true;
                                      },
                                    );
                                  },
                                );
                              },
                              child: _buildLeaveRequestButtonHandle(
                                'Rejected',
                                Icons.cancel,
                                HelpersColors.itemSelected,
                              ),
                            ),
                          ),
                        if (widget.leave.status != 'Rejected')
                          SizedBox(width: 20),
                        if (widget.leave.status != 'Rejected')
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                _showDialogConfirmLeave(
                                  'Approved',
                                  Color(0xFF00B2BF),
                                );
                              },
                              child: _buildLeaveRequestButtonHandle(
                                'Approved',
                                Icons.check_circle,
                                HelpersColors.itemCard,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
