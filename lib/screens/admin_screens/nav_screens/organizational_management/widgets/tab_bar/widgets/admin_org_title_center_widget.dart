import 'package:daily_manage_user_app/helpers/tools_colors.dart';
import 'package:flutter/material.dart';

class AdminOrgTitleCenterWidget extends StatelessWidget {
  const AdminOrgTitleCenterWidget({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      width: double.infinity,
      decoration: BoxDecoration(
          color: HelpersColors.itemCard.withOpacity(0.1),
        borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: HelpersColors.itemCard),
        ),
      ),
    );
  }
}
