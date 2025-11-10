import 'package:daily_manage_user_app/controller/admin/admin_chatbot_controller.dart';
import 'package:daily_manage_user_app/helpers/tools_colors.dart';
import 'package:daily_manage_user_app/screens/admin_screens/widgets/screens/chatbot_screen.dart';
import 'package:daily_manage_user_app/screens/common_screens/widgets/top_notification_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/room.dart';
import '../../../models/user.dart';

class ChatbotOverlayWidget {
  static final ChatbotOverlayWidget _instance = ChatbotOverlayWidget._internal();
  factory ChatbotOverlayWidget() => _instance;
  final AdminChatbotController chatbotController = AdminChatbotController();
  ChatbotOverlayWidget._internal();

  OverlayEntry? _overlayEntry;

  void show(BuildContext context) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 25,
        bottom: 25,
        child: GestureDetector(
          onTap: () async{

            Room? room = await chatbotController.findOrCreateRoom(receiverId: '68ec68f8c7246d5addf76245');
            if(room != null){
              final sharedPreferences = await SharedPreferences.getInstance();
              final userJson = sharedPreferences.getString('user');
              if (userJson != null) {
                final User user = User.fromJson(userJson);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    var screenSize = MediaQuery.of(context).size;
                    return Dialog(
                      // Thêm dòng này để đưa dialog lên trên cùng
                      alignment: Alignment.topCenter,
                      // Thêm dòng này để loại bỏ khoảng trống xung quanh
                      insetPadding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0), // <-- Thêm dòng này
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(16))),
                        width: screenSize.width * 0.9, // Rộng bằng 80% màn hình
                        height: screenSize.height * 0.85, // Cao bằng 50% màn hình
                        child: ChatbotScreen(roomId: room.id,senderId: user.id),
                      ),
                    );
                  },
                );
              }


              // showTopNotification(context: context, message: 'Đã tạo Id chat', type: NotificationType.success);
            }


          },
          child: Container(
            padding: EdgeInsets.all(10),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: HelpersColors.itemCard,
              border: Border.all(width: 2,color: Colors.white)
            ),
            child: Lottie.asset(
              'assets/lotties/botchat.json',
              repeat: true,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
