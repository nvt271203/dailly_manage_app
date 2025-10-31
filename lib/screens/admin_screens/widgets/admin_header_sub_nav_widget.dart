import 'package:daily_manage_user_app/screens/admin_screens/detail_screens/admin_notification_screen.dart';
import 'package:flutter/material.dart';
import '../../../../../../helpers/tools_colors.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class AdminHeaderSubNavWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onMenuPressed;

  const AdminHeaderSubNavWidget({
    super.key,
    required this.title,
    required this.onMenuPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Đặt màu cho status bar
    // Đặt màu cho status bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: HelpersColors.itemCard,
        statusBarIconBrightness: Brightness.light, // icon trắng
      ),
    );
    return Container(
      // padding: const EdgeInsets.only(top: 24), // để tránh đè vào status bar
      decoration: BoxDecoration(
        color: HelpersColors.itemCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top:16, bottom: 16 ,right: 30),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onMenuPressed,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  width: 45,
                  height: 45,
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    FontAwesomeIcons.bars,
                    color: HelpersColors.itemCard,
                    size: 20,
                  ),
                ),
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      // color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // width: 45,
                    // height: 45,
                    // padding: const EdgeInsets.all(8),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  SizedBox(width: 20,),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return AdminNotificationScreen();
                  },));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(FontAwesomeIcons.solidBell,
                        color: Colors.white,
                        size: 20,
                      ),
                      Positioned(
                          top: -8,
                          right: -12
                          ,child: Container(
                        width: 20,
                        height: 20,

                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: Text('1',style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12
                        ),)),
                      ))
                    ],
                  ),
                ),
              )// giữ khoảng trống đối xứng bên phải
            ],
          ),
        ),
      ),
    );
  }
}
