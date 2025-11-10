import 'package:daily_manage_user_app/controller/admin/admin_chatbot_controller.dart';
import 'package:daily_manage_user_app/screens/admin_screens/widgets/screens/chatbot_screen.dart';
import 'package:daily_manage_user_app/screens/common_screens/widgets/top_notification_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../helpers/tools_colors.dart';
import '../../../../../models/room.dart';
import '../../../../../models/user.dart';
import '../../../../common_screens/widgets/button_icon_text_widget.dart';
import '../../../../user_screens/widgets/screens/user_chatbot_screen.dart';

class AdminChatbotUserStatisticalWidget extends StatefulWidget {
  const AdminChatbotUserStatisticalWidget({super.key});

  @override
  State<AdminChatbotUserStatisticalWidget> createState() =>
      _AdminChatbotUserStatisticalWidgetState();
}

class _AdminChatbotUserStatisticalWidgetState
    extends State<AdminChatbotUserStatisticalWidget> {
  AdminChatbotController chatbotController = AdminChatbotController();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        Room? room = await chatbotController
            .findOrCreateRoom(
          receiverId: '690d67a280e885cb0be9ebab',
        );

        if (room != null) {
          final sharedPreferences =
          await SharedPreferences.getInstance();
          final userJson = sharedPreferences.getString(
            'user',
          );
          if (userJson != null) {
            final User user = User.fromJson(userJson);
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                var screenSize = MediaQuery
                    .of(
                  context,
                )
                    .size;


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
              },);
          }
        }

      },
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Column(
                children: [
                  Lottie.asset(
                    'assets/lotties/botchat.json',
                    repeat: true,
                    width: 80,
                  ),
                  ButtonIconTextWidget(
                    icon: Icons.check_circle,
                    text: 'Done',
                    color: HelpersColors.itemCard,
                    background: HelpersColors.itemCard.withOpacity(0.2),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Last updated: 23/08/2023'),
                    Text('Knowledge: 2 File'),

                    Text('Today\'s Question: 45'),
                    Text('Today\'s Answer: 30'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
