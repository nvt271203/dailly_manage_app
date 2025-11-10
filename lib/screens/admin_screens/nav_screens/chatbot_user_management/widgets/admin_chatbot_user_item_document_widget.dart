import 'package:daily_manage_user_app/helpers/format_helper.dart';
import 'package:daily_manage_user_app/helpers/tools_colors.dart';
import 'package:daily_manage_user_app/models/document.dart';
import 'package:flutter/material.dart';
import '../../../../../models/work.dart';

class AdminChatbotUserItemDocumentWidget extends StatefulWidget {
  const AdminChatbotUserItemDocumentWidget({super.key, required this.document});

  final Document document;

  @override
  State<AdminChatbotUserItemDocumentWidget> createState() =>
      _AdminChatbotUserItemDocumentWidgetState();
}

class _AdminChatbotUserItemDocumentWidgetState
    extends State<AdminChatbotUserItemDocumentWidget>
    with SingleTickerProviderStateMixin {
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) {
        //       return AdminWorkHoursDetailScreen(work: widget.work);
        //     },
        //   ),
        // );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                // border: Border.all(color: Colors.black),
                color: Colors.white,
                shape: BoxShape.circle,
                // border: Border.all(color: Colors.white, width: 4),
              ),
              child: Icon(
                Icons.picture_as_pdf,
                color: HelpersColors.itemSelected,
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
                          widget.document.name,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            FormatHelper.formatDate_DD_MM_YYYY(
                              widget.document.uploadedAt,
                            ),
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          SizedBox(height: 5,),
                          Text(
                            widget.document.isTrain == true
                                ? 'Trained'
                                : 'Not train',
                            style: TextStyle(
                              color: widget.document.isTrain == true
                                  ? HelpersColors.itemCard
                                  : Colors.grey,
                              fontWeight: widget.document.isTrain == true ? FontWeight.bold : null,
                              fontSize: 12,
                            ),
                          ),
                        ],
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
                              // Text(
                              //   widget.work.checkOutTime != null
                              //       ? 'Worked:'
                              //       : 'Working:',
                              //   style: TextStyle(fontSize: 13),
                              // ),
                              // Text(
                              //   '   ${FormatHelper.formatTimeHH_MM(widget.work.checkInTime)} - ',
                              //   style: TextStyle(fontSize: 13),
                              // ),
                            ],
                          ),
                          // Text(
                          //   widget.work.checkOutTime != null
                          //       ? '${FormatHelper.formatTimeHH_MM(widget.work.checkOutTime!)}'
                          //       : 'Not Checkout',
                          //   style: TextStyle(
                          //     fontSize: 13,
                          //     color: widget.work.checkOutTime != null
                          //         ? null
                          //         : Colors.red,
                          //   ),
                          // ),
                        ],
                      ),
                      // Spacer(),
                      // if (widget.work.checkOutTime != null)
                      // Text(
                      //   // 'Total: 5h30p'
                      //   'Total: ${FormatHelper.formatDurationHH_h_MM_p(widget.work.workTime!)}', // Hiển thị tổng thời gian
                      //   style: TextStyle(
                      //     fontSize: 13,
                      //     color: HelpersColors.itemPrimary,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Icon(
                  Icons.keyboard_double_arrow_left,
                  color: HelpersColors.itemCard,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
