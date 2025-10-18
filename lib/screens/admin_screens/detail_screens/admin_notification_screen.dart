import 'package:flutter/material.dart';

import '../../../helpers/tools_colors.dart';
class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({super.key});

  @override
  State<AdminNotificationScreen> createState() => _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HelpersColors.itemCard,
        foregroundColor: Colors.white,
        title: Text('Notification', style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),),
        centerTitle: true,

      ),
      body: Center(child: Text('Notification'),),
    );
  }
}
