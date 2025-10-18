import 'package:daily_manage_user_app/helpers/tools_colors.dart';
import 'package:daily_manage_user_app/models/department.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../../../models/position.dart';


class AdminOrgTabPositionItemWidget extends ConsumerStatefulWidget {
  const AdminOrgTabPositionItemWidget({super.key, required this.position});

  final Position position;

  @override
  _AdminOrgTabPositionItemWidgetState createState() => _AdminOrgTabPositionItemWidgetState();
}

class _AdminOrgTabPositionItemWidgetState extends ConsumerState<AdminOrgTabPositionItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final int arrowCount = 3; // số icon nối đuôi nhau
  final double delaySeconds = 0.3; // khoảng trễ giữa các icon
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )
      ..repeat();

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0), // hơi lệch phải
      end: const Offset(0, 0), // trở về giữa
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _fadeAnimation = Tween<double>(
      begin: 1.0, // Rõ hoàn toàn
      end: 0.0, // Mờ dần
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0), // Xuất phát lệch phải
      end: const Offset(0, 0), // Chạy vào giữa
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigator.push(context, MaterialPageRoute(builder: (context) {
        //   return AdminWorkHoursDetailScreen(work: widget.work);
        // },));
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
            Stack(
              clipBehavior: Clip.none,

              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    // border: Border.all(color: Colors.black),
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.all(Radius.circular(8))
                    // border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Icon(FontAwesomeIcons.userTie,color: Colors.black.withOpacity(0.5),size: 16,),
                ),
              ],
            ),

            SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Text(
                      //   (widget.user.fullName != null && widget.user.fullName.isNotEmpty)
                      //       ? widget.user.fullName
                      //       : 'Anonymous',
                      //   style: TextStyle(
                      //     color: Colors.black,
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: 16,
                      //   ),
                      // ),
                      // Hiển thị tên với từ khóa được làm nổi bật

                      SizedBox(width: 5),


                      // Spacer(),
                      // Text(
                      //   FormatHelper.formatDate_DD_MM_YYYY(
                      //     widget.work.checkInTime,
                      //   ),
                      //   style: TextStyle(color: Colors.grey, fontSize: 12),
                      // ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.position.positionName,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      // Spacer(),
                      // if (widget.work.checkOutTime != null)
                      //   Text(
                      //     // 'Total: 5h30p'
                      //     'Total: ${FormatHelper.formatDurationHH_h_MM_p(widget.work.workTime!,)}', // Hiển thị tổng thời gian
                      //     style: TextStyle(fontSize: 13,color: HelpersColors.itemPrimary,fontWeight: FontWeight.bold),
                      //   ),
                    ],
                  ),
                ],
              ),
            ),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: const Icon(
                  Icons.keyboard_double_arrow_left,
                  color: Colors.grey,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
