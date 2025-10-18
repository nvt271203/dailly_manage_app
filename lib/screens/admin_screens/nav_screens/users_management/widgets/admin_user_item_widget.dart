import 'package:daily_manage_user_app/helpers/tools_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';

import '../../../../../helpers/format_helper.dart';
import '../../../../../models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers/admin/admin_user_filter_provider.dart';

class AdminUserItemWidget extends ConsumerStatefulWidget {
  const AdminUserItemWidget({super.key, required this.user});

  final User user;

  @override
  _AdminUserItemWidgetState createState() => _AdminUserItemWidgetState();
}

class _AdminUserItemWidgetState extends ConsumerState<AdminUserItemWidget>
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

  // Hàm xây dựng tên với từ khóa được làm nổi bật
  Widget _buildHighlightedName(
    BuildContext context,
    String fullName,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) {
      // Nếu không có từ khóa tìm kiếm, hiển thị tên bình thường
      return Text(
        // fullName,
        // Text(
        (widget.user.fullName != null && widget.user.fullName.isNotEmpty)
            ? widget.user.fullName
            : 'User ${widget.user.id}',

        //   style: TextStyle(
        //     color: Colors.black,
        //     fontWeight: FontWeight.bold,
        //     fontSize: 16,
        //   ),
        // ),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Chuyển tên và từ khóa tìm kiếm thành chữ thường để so sánh không phân biệt hoa thường
    final lowerFullName = fullName.toLowerCase();
    final lowerSearchQuery = searchQuery.toLowerCase();

    // Tìm các đoạn văn bản khớp với từ khóa
    List<TextSpan> textSpans = [];
    int startIndex = 0;

    while (startIndex < fullName.length) {
      // Tìm vị trí bắt đầu của từ khóa trong tên
      final index = lowerFullName.indexOf(lowerSearchQuery, startIndex);

      if (index == -1) {
        // Nếu không tìm thấy từ khóa, thêm phần còn lại của tên
        textSpans.add(
          TextSpan(
            text: fullName.substring(startIndex),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        break;
      }

      // Thêm phần văn bản trước từ khóa (nếu có)
      if (index > startIndex) {
        textSpans.add(
          TextSpan(
            text: fullName.substring(startIndex, index),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }

      // Thêm phần văn bản khớp với từ khóa (bôi màu xanh đậm)
      textSpans.add(
        TextSpan(
          text: fullName.substring(index, index + searchQuery.length),
          style: TextStyle(
            color: HelpersColors.itemCard, // Màu xanh đậm
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      // Cập nhật vị trí bắt đầu cho lần tìm kiếm tiếp theo
      startIndex = index + searchQuery.length;
    }

    return RichText(text: TextSpan(children: textSpans));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy từ khóa tìm kiếm từ provider
    final searchQuery = ref
        .watch(adminUserFilterProvider)
        .filterFullName
        .toLowerCase();
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
          color: widget.user.status == true ? Colors.white : Colors.white,
          // Colors.white : HelpersColors.bgFillTextField
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
                          widget.user.image == null || widget.user.image.isEmpty
                          ? AssetImage(
                                  widget.user.sex == 'Male'
                                      ? 'assets/images/avatar_boy_default.jpg'
                                      : widget.user.sex == "Female"
                                      ? 'assets/images/avatar_girl_default.jpg'
                                      : 'assets/images/avt_default_2.jpg',
                                )
                                as ImageProvider
                          : NetworkImage(widget.user.image),

                      // Sử dụng NetworkImage cho URLs
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -5,
                  right: -5,
                  child: Container(
                    width: 20,
                    height: 20,

                    decoration: BoxDecoration(
                      color: HelpersColors.itemCard,
                      shape: BoxShape.circle,
                      border: Border.all(width: 2, color: Colors.white),
                    ),
                  ),
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
                      Expanded(
                        child: _buildHighlightedName(
                          context,
                          widget.user.fullName,
                          searchQuery,
                        ),
                      ),
                      SizedBox(width: 10),
                      if (widget.user.birthDay != null)
                        Text(
                          widget.user.calculateAge().toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: widget.user.sex == 'Male'
                                ? HelpersColors.itemCard
                                : Colors.pink,
                          ),
                        ),
                      SizedBox(width: 5),

                      if (widget.user.sex != null && widget.user.sex != '')
                        Icon(
                          widget.user.sex == 'Male'
                              ? FontAwesomeIcons.mars
                              : FontAwesomeIcons.venus,
                          size: 14,
                          color: widget.user.sex == 'Male'
                              ? HelpersColors.itemCard
                              : Colors.pink,
                        ),

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
                  Row(
                    children: [
                      Row(
                        children: [
                          Row(
                            children: [
                              // Text(
                              //   widget.work.checkOutTime != null ?
                              //   'Worked:' : 'Working:',
                              //   style: TextStyle(fontSize: 13),
                              // ),
                              Text(
                                widget.user.email,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          // Text(
                          //   widget.work.checkOutTime != null
                          //       ? '${FormatHelper.formatTimeHH_MM(widget.work.checkOutTime!)}'
                          //       : 'Not Checkout',
                          //   style: TextStyle(fontSize: 13,
                          //     color: widget.work.checkOutTime != null ? null : Colors.red,
                          //   ),
                          // ),
                        ],
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
            if (!widget.user.status!)
              Transform.rotate(
                angle: -0.3,
                child: Container(
                  padding:EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  margin: EdgeInsets.only(right: 5),
                  color: HelpersColors.itemSelected.withOpacity(0.1),
                  child: Text(
                    'resigned',
                    style: TextStyle(
                      fontSize: 12,
                      color: HelpersColors.itemSelected,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
