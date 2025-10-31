import 'package:daily_manage_user_app/controller/admin/admin_chatbot_controller.dart';
import 'package:daily_manage_user_app/helpers/tools_colors.dart';
import 'package:daily_manage_user_app/screens/admin_screens/widgets/screens/chatbot_screen.dart';
import 'package:daily_manage_user_app/screens/common_screens/widgets/top_notification_widget.dart';
import 'package:daily_manage_user_app/screens/user_screens/widgets/screens/user_chatbot_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/room.dart';
import '../../../models/user.dart';

class UserChatbotOverlayWidget {
  static final UserChatbotOverlayWidget _instance =
      UserChatbotOverlayWidget._internal();

  factory UserChatbotOverlayWidget() => _instance;
  final AdminChatbotController chatbotController = AdminChatbotController();

  UserChatbotOverlayWidget._internal();

  OverlayEntry? _overlayEntry;

  // Biến này sẽ lưu trạng thái "mở" (true) hay "đóng" (false)
  bool _isExpanded = true;

  // --- 1. THÊM BIẾN ĐỂ LƯU CONTEXT ---
  BuildContext? _mainContext;

  void show(BuildContext context) {
    // --- SỬA Ở ĐÂY ---
    // Lưu context của UserMainScreen vào biến của class
    _mainContext = context;
    // 1. Lấy chiều cao của CurvedNavigationBar mà bạn đã set cứng
    const navBarHeight = 60.0;

    // 2. Lấy chiều cao của viền "cằm" (SafeArea) ở đáy điện thoại
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // 3. Khoảng cách bạn muốn icon cách thanh Nav Bar
    const margin = 15.0;

    // 4. Tính toán vị trí đáy (bottom) cuối cùng
    final totalBottomPosition = navBarHeight + bottomPadding + margin;

    // --- HẾT SỬA ---

    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (builderContext) => StatefulBuilder(
        builder: (setStateContext, setState) {
          return Positioned(
            right: 0,
            height: 70,
            bottom: totalBottomPosition,
            child: Container(
              padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: HelpersColors.primaryColor),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                  bottomLeft: Radius.circular(100),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- 6. DÙNG ANIMATEDSWITCHER ĐỂ ẨN/HIỆN ICON CHAT ---
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      // Hiệu ứng mờ dần và thu nhỏ
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      );
                    },
                    child: _isExpanded
                        ? GestureDetector(
                            onTap: () async {
                              // --- 3. KIỂM TRA VÀ SỬ DỤNG _mainContext ---
                              // Kiểm tra xem context bền bỉ có tồn tại không
                              if (_mainContext == null ||
                                  !_mainContext!.mounted) {
                                return; // An toàn: không làm gì nếu context đã mất
                              }

                              Room? room = await chatbotController
                                  .findOrCreateRoom(
                                    receiverId: '68ec68f8c7246d5addf76245',
                                  );
                              if (room != null) {
                                final sharedPreferences =
                                    await SharedPreferences.getInstance();
                                final userJson = sharedPreferences.getString(
                                  'user',
                                );
                                if (userJson != null) {
                                  final User user = User.fromJson(userJson);

                                  // Dùng _instance để gọi hàm hide() của class
                                  _instance.hide();
                                  await showDialog(
                                    context: _mainContext!,
                                    builder: (BuildContext context) {
                                      var screenSize = MediaQuery.of(
                                        context,
                                      ).size;
                                      return Dialog(
                                        // Thêm dòng này để đưa dialog lên trên cùng
                                        alignment: Alignment.topCenter,
                                        // Thêm dòng này để loại bỏ khoảng trống xung quanh
                                        insetPadding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16.0,
                                          ), // <-- Thêm dòng này
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(16),
                                            ),
                                          ),
                                          width: screenSize.width * 0.9,
                                          // Rộng bằng 80% màn hình
                                          height: screenSize.height * 0.85,
                                          // Cao bằng 50% màn hình
                                          child: UserChatbotScreen(
                                            roomId: room.id,
                                            senderId: user.id,
                                          ),
                                        ),
                                      );
                                    },
                                  );

                                  // 3. HIỂN THỊ LẠI ICON DÙNG _mainContext
                                  // (Code này giờ sẽ luôn chạy sau khi dialog đóng)
                                  if (_mainContext!.mounted) {
                                    _instance.show(_mainContext!);
                                  }
                                  ;
                                }

                                // showTopNotification(context: context, message: 'Đã tạo Id chat', type: NotificationType.success);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(3),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: HelpersColors.itemPrimary,
                                border: Border.all(
                                  width: 2,
                                  color: HelpersColors.itemCard,
                                ),
                              ),
                              child: Lottie.asset(
                                'assets/lotties/botchat.json',
                                repeat: true,
                              ),
                            ),
                          )
                        : const SizedBox(key: ValueKey('empty')),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Icon(
                      // TỰ ĐỘNG ĐỔI ICON
                      _isExpanded
                          ? Icons.keyboard_arrow_right
                          : Icons.keyboard_arrow_left,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
