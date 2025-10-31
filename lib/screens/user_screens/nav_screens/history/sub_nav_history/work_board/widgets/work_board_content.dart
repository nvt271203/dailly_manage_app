import 'package:flutter/material.dart';

import '../../../../../../../helpers/tools_colors.dart';
import '../../../../../../auth_screens/widgets/todo_list_table_widget.dart';

class WorkBoardContent extends StatefulWidget {
  const WorkBoardContent({super.key});

  @override
  State<WorkBoardContent> createState() => _WorkBoardContentState();
}

class _WorkBoardContentState extends State<WorkBoardContent> {
  final DateTime _selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return TodoListTableWidget(
    );
  }
}
