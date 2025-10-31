import 'package:flutter/material.dart';

import '../../../helpers/tools_colors.dart';
class DrawerItemMenuWidget extends StatelessWidget {
  const DrawerItemMenuWidget({super.key,

    required this.icon,
    required this.title,
    this.isSelected = false, // Mặc định là không được chọn
    this.targetScreen,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final bool isSelected;
  final Widget? targetScreen;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
      onTap ??
              () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => targetScreen!),
            );
          },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? HelpersColors.itemCard : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: HelpersColors.itemCard),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                // Icon leading
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: HelpersColors.itemCard),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Icon(icon, color: HelpersColors.itemCard, size: 20),
                ),

                SizedBox(width: 12),

                // Title (Text)
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : HelpersColors.itemCard,
                    ),
                  ),
                ),

                // Trailing icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: isSelected ? Colors.white : HelpersColors.itemCard,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
