import 'package:flutter/material.dart';
class ButtonIconTextWidget extends StatelessWidget {
  const ButtonIconTextWidget({super.key, required this.icon, required this.text, required this.color, required this.background, required this.onTap});
  final IconData icon;
  final String text;
  final Color color;
  final Color background;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color,size: 20,),
            SizedBox(width: 10,),
            Text(text, style: TextStyle(color: color,fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
}
