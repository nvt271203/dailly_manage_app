import 'package:daily_manage_user_app/helpers/format_helper.dart';
import 'package:daily_manage_user_app/helpers/tools_colors.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../models/work.dart';
import '../screens/admin_work_hours_detail_screen.dart';

class AdminWorkHoursItemWidget extends StatefulWidget {
  const AdminWorkHoursItemWidget({super.key, required this.work});

  final Work work;

  @override
  State<AdminWorkHoursItemWidget> createState() =>
      _AdminWorkHoursItemWidgetState();
}

class _AdminWorkHoursItemWidgetState extends State<AdminWorkHoursItemWidget> {
  @override
  Widget build(BuildContext context) {
    print('image user: ${widget.work.user!.image}');
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AdminWorkHoursDetailScreen(work: widget.work);
            },
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12, // Màu bóng
              blurRadius: 6, // Độ mờ của bóng
              offset: Offset(0, 3), // Vị trí đổ bóng (ngang, dọc)
            ),
          ],
          // color: HelpersColors.bgFillTextField,
          color: Colors.white,
        ),

        child: Row(
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
                image: DecorationImage(image:

                widget.work.user!.image == null ||
                    widget.work.user!.image.isEmpty
                    ? AssetImage(
                  widget.work.user?.sex == 'Male'
                      ? 'assets/images/avatar_boy_default.jpg'
                      : widget.work.user?.sex == "Female"
                      ? 'assets/images/avatar_girl_default.jpg'
                      : 'assets/images/avt_default_2.jpg',
                )
                as ImageProvider
                    :
                NetworkImage(widget.work.user!.image.toString()),
                  fit: BoxFit.cover
                )
                // border: Border.all(color: Colors.white, width: 4),
              ),
              // child: ClipOval(
              //   child: Image(
              //     // image: user?.image == null || user!.image.isEmpty
              //     //     ? AssetImage(
              //     //   user?.sex == 'Male'
              //     //       ? 'assets/images/avatar_boy_default.jpg'
              //     //       : user?.sex == "Female"
              //     //   ? 'assets/images/avatar_girl_default.jpg'
              //     //   : 'assets/images/avt_default_2.jpg',
              //     // ) as ImageProvider
              //     //     : NetworkImage(user.image),
              //     image:
              //         widget.work.user!['image'] == null ||
              //             widget.work.user!['image'].isEmpty
              //         ? AssetImage(
              //                 widget.work.user?['sex'] == 'Male'
              //                     ? 'assets/images/avatar_boy_default.jpg'
              //                     : widget.work.user?['sex'] == "Female"
              //                     ? 'assets/images/avatar_girl_default.jpg'
              //                     : 'assets/images/avt_default_2.jpg',
              //               )
              //               as ImageProvider
              //         :
              //         NetworkImage(widget.work.user!['image'].toString()),
              //
              //     // Sử dụng NetworkImage cho URLs
              //     fit: BoxFit.cover,
              //     width: double.infinity,
              //     height: double.infinity,
              //   ),
              // ),
            ),

            SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.work.user!.fullName == null || widget.work.user!.fullName == ''  ?  'User ${widget.work.userId}' : widget.work.user!.fullName,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                        
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        FormatHelper.formatDate_DD_MM_YYYY(
                          widget.work.checkInTime,
                        ),
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Row(
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.work.checkOutTime != null
                                    ? 'Worked:'
                                    : 'Working:',
                                style: TextStyle(fontSize: 13),
                              ),
                              Text(
                                '   ${FormatHelper.formatTimeHH_MM(widget.work.checkInTime)} - ',
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          Text(
                            widget.work.checkOutTime != null
                                ? '${FormatHelper.formatTimeHH_MM(widget.work.checkOutTime!)}'
                                : 'Not Checkout',
                            style: TextStyle(
                              fontSize: 13,
                              color: widget.work.checkOutTime != null
                                  ? null
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      if (widget.work.checkOutTime != null)
                        Text(
                          // 'Total: 5h30p'
                          'Total: ${FormatHelper.formatDurationHH_h_MM_p(widget.work.workTime!)}', // Hiển thị tổng thời gian
                          style: TextStyle(
                            fontSize: 13,
                            color: HelpersColors.itemPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
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
