import 'package:daily_manage_user_app/controller/leave_controller.dart';
import 'package:daily_manage_user_app/screens/auth_screens/nav_screens/home/dialogs/confirm_check_dialog.dart';
import 'package:daily_manage_user_app/screens/auth_screens/nav_screens/leave/dialogs/confirm_delete_dialog.dart';
import 'package:daily_manage_user_app/screens/auth_screens/nav_screens/leave/screens/leave_request_screen.dart';
import 'package:daily_manage_user_app/screens/common_screens/widgets/top_notification_widget.dart';
import 'package:daily_manage_user_app/widgets/dialog_confirm_widget.dart';
import 'package:flutter/material.dart';
import '../../../../../helpers/format_helper.dart';
import '../../../../../helpers/tools_colors.dart';
import '../../../../../models/leave.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers/leave_provider.dart';

class DetailLeaveRequest extends ConsumerStatefulWidget {
  final Leave leave;

  const DetailLeaveRequest({super.key, required this.leave});

  @override
  _DetailLeaveRequestState createState() => _DetailLeaveRequestState();
}

class _DetailLeaveRequestState extends ConsumerState<DetailLeaveRequest> {
  Color getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Color(0xFF00B2BF);

      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Color getStatusBackgroundColor(String status) {
    switch (status) {
      case 'Approved':
        return Color(0xFFCAE5E8);

      case 'Rejected':
        return Color(0xFFFFC0CB);
      default:
        return Colors.orange.shade50;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Approved':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.cancel;
      default:
        return Icons.timelapse;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _markAsRead();
  }

  void _markAsRead() async {
    final status = await LeaveController().updateLeaveRemoveIsNew(
      id: widget.leave.id,
    );
    if (status) {
      print('update isNew is false');
      // Navigator.of(context).pop(true);
      // / Cập nhật cục bộ trạng thái isNew trong LeaveProvider
      ref.read(leaveProvider.notifier).updateLeaveIsNew(widget.leave.id, false);
    } else {
      print('update isNew is error');
      // Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Lấy thông tin padding từ MediaQuery để tránh thanh điều hướng
    final EdgeInsets padding = MediaQuery.of(context).padding;

    final leaveAsyncValue = ref.watch(leaveProvider);
    //Vì sử dụng tới provider để quản lý trạng thái thay đổi, khi cập nhập quay lại màn hình này, thì phải set ở đây trạng thái theo đối tượng hiện tại
    final Leave currentLeave =
        leaveAsyncValue.valueOrNull?.firstWhere(
          (leave) => leave.id == widget.leave.id,
          orElse: () => widget.leave,
        ) ??
        widget.leave;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Leave Request Details'),
        centerTitle: true,
        backgroundColor: HelpersColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        // Áp dụng padding để tránh thanh trạng thái (trên) và thanh điều hướng (dưới)
        padding: EdgeInsets.only(
          bottom: padding.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),

        child: Column(
          children: [
            Container(
              // margin: const EdgeInsets.symmetric(vertical: 8),
              // padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: getStatusBackgroundColor(currentLeave.status),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2), // đổ bóng nhẹ
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon trạng thái
                        Icon(
                          getStatusIcon(currentLeave.status),
                          size: 40,
                          color: getStatusColor(currentLeave.status),
                        ),
                        const SizedBox(width: 16),

                        // Nội dung (Status + Requested time)
                        Text(
                          // 'Status: ${widget.leave.status}',
                          'Status: ${currentLeave.status}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: getStatusColor(currentLeave.status),
                          ),
                        ),






                      ],
                    ),
                  ),
                  Text(
                    'Requested on ${FormatHelper.formatDate_DD_MM_YYYY(currentLeave.dateCreated)} at ${FormatHelper.formatTimeHH_MM(currentLeave.dateCreated)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[800],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 20),

                  if (currentLeave.status == 'Pending')
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          // Nút Delete
                          InkWell(
                            onTap: () async {
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) => ConfirmDeleteDialog(
                                  title: 'Delete',
                                  content:
                                      'Do you want to delete this leave request?',
                                  onConfirm: () async {
                                    final success = await LeaveController()
                                        .deleteLeave(currentLeave.id);
                                    if (success) {
                                      showTopNotification(
                                        context: context,
                                        message:
                                            'You have successfully deleted your leave request.',
                                        type: NotificationType.success,
                                      );
                                      Navigator.of(context).pop(
                                        true,
                                      ); // đóng dialog & trả về result
                                      return true;
                                    } else {
                                      showTopNotification(
                                        context: context,
                                        message:
                                            'You haven\'t successfully deleted your leave request.',
                                        type: NotificationType.error,
                                      );
                                      return false;
                                    }
                                  },
                                ),
                              );

                              // Sau dialog, nếu thành công thì pop về màn danh sách kèm kết quả
                              if (result == true) {
                                // Navigator.of(context).pop(true); // đóng dialog & trả về result
                                // return true;
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: HelpersColors.itemSelected, // Màu nền đỏ
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(width: 16), // khoảng cách giữa 2 nút
                          // Nút Update
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return LeaveRequestScreen(
                                      leave: currentLeave,
                                    );
                                  },
                                ),
                              ).then((value) {
                                // Chỉ pop nếu màn hình LeaveRequestScreen trả về "true"
                                if (value == true) {
                                  // Navigator.of(context).pop(true);
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: HelpersColors.itemPrimary,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blueAccent),
                               ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Update',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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

                    _buildInfoCard(
                      icon: Icons.category,
                      title: 'Leave Type',
                      content: currentLeave.leaveType,
                    ),
                    _buildInfoCard(
                      icon: Icons.access_time,
                      title: 'Time Type',
                      content: currentLeave.leaveTimeType,
                    ),
                    _buildInfoCard(
                      icon: Icons.today,
                      title: 'Start Date',
                      content:
                          // '${FormatHelper.formatDate_DD_MM_YYYY(leave.startDate)} (${FormatHelper.formatTimeHH_MM(leave.startDate)})',
                          '${FormatHelper.formatTimeHH_MM_AP(currentLeave.startDate)} - ${FormatHelper.formatDate_DD_MM_YYYY(currentLeave.startDate)}',
                    ),
                    _buildInfoCard(
                      icon: Icons.event_available,
                      title: 'End Date',
                      content:
                          '${FormatHelper.formatTimeHH_MM_AP(currentLeave.endDate)} - ${FormatHelper.formatDate_DD_MM_YYYY(currentLeave.endDate)}',
                    ),
                    _buildInfoCard(
                      icon: Icons.note_alt,
                      title: 'Reason',
                      content: currentLeave.reason,
                      isMultiline: true,
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    bool isMultiline = false,
  }) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16), // giảm padding cho gọn
        child: Row(
          crossAxisAlignment: isMultiline
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: HelpersColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  12,
                ), // hoặc 20 nếu muốn tròn hơn
              ),
              child: Icon(icon, size: 22, color: HelpersColors.primaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
