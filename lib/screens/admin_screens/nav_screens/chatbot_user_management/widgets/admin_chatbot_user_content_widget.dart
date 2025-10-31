import 'package:flutter/material.dart';
class AdminChatbotUserContentWidget extends StatefulWidget {
  const AdminChatbotUserContentWidget({super.key});

  @override
  State<AdminChatbotUserContentWidget> createState() => _AdminChatbotUserContentWidgetState();
}

class _AdminChatbotUserContentWidgetState extends State<AdminChatbotUserContentWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Admin Chatbot User Content'),
      ),
    );
  }
}
