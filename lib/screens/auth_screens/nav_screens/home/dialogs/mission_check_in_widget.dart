import 'package:flutter/material.dart';

import '../../../../../helpers/tools_colors.dart';
class MissionCheckInWidget extends StatefulWidget {
  // final void Function(String report_management, String plan, String result) onCheckOut;
  // phải sử dụng Future vì nó lắng nghe call back. chờ sau khi upload như nào thì tiếp tục set isLoading
  final Future<bool> Function(String report, String plan, String note)
  onCheckIn;
  // final Future<bool> Function(String? report_management, String? plan, String? note) onLater;
  // final String? idWork;
  final VoidCallback onLater;

  // final String idWork;

  const MissionCheckInWidget({
    super.key,
    required this.onCheckIn,
    required this.onLater,
    // this.idWork
    // required this.idWork,
  });

  @override
  State<MissionCheckInWidget> createState() => _MissionCheckInWidgetState();
}

class _MissionCheckInWidgetState extends State<MissionCheckInWidget> {
  TextEditingController reportController = TextEditingController();
  TextEditingController planController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  bool isLoadingCheckIn = false;
  bool isLoadingLater = false;

  String? _reportError;
  String? _planError;
  String? _noteError;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus(); // 👈 Ẩn bàn phím sau khi build
    });
  }
  @override
  void dispose() {
    reportController.dispose();
    planController.dispose();
    noteController.dispose();
    super.dispose();
  }
  void _handleCheckIn()async{
    final report = reportController.text.trim();
    final plan = planController.text.trim();
    final result = noteController.text.trim();

    setState(() {
      final specialOrDigitsOnlyRegex = RegExp(r'^[^a-zA-Z]+$');

      _reportError = report.isEmpty
          ? "Please enter your report"
          : specialOrDigitsOnlyRegex.hasMatch(report)
          ? "Report must contain letters"
          : null;

      _planError = plan.isEmpty
          ? "Please enter your plan"
          : specialOrDigitsOnlyRegex.hasMatch(plan)
          ? "Plan must contain letters"
          : null;
    });


    if (_reportError == null &&
        _planError == null &&
        _noteError == null) {

      setState(() {
        isLoadingCheckIn = true;
      });
      // Chờ quá trình call back
      await widget.onCheckIn(
        report,
        plan,
        result,
      );

      // if (success) {
      //   // if (context.mounted) Navigator.of(context).pop();
      // }
      setState(() {
        isLoadingCheckIn = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    final rootContext = context; // context gốc của MissionDialogWidget
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mission',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: HelpersColors.primaryColor,
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      // _handleButtonLater();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: HelpersColors.itemSelected,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildMissionField(
                icon: Icons.assignment,
                title: 'Report',
                label: "What did you do yesterday? *",
                hint:
                "Write what you did yesterday, including tasks and results",
                color: Colors.blue,
                controller: reportController,
                errorText: _reportError,
              ),
              const SizedBox(height: 12),
              _buildMissionField(
                icon: Icons.event_note,
                title: 'Plan',
                label: "What do you plan to do today? *",
                hint:
                "Write your plan for today, including key goals or tasks",
                color: Colors.blue,
                controller: planController,
                errorText: _planError,
              ),
              const SizedBox(height: 12),
              _buildMissionField(
                icon: Icons.fact_check,
                title: 'Note',
                label: "Do you need any help today?",
                hint: "Write if you need any help, support, or guidance today",
                color: Colors.blue,
                controller: noteController,
                errorText: null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    // Button later
                    child: InkWell(
                      onTap: ()  {
                        _handleCheckIn();
                      },

                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: HelpersColors.itemPrimary,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child:
                        isLoadingCheckIn
                            ? Center(
                          child: SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                            :
                        Center(
                          child: const Text(
                            // 'Later',
                            'Check In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(


                      onTap: () async {
                        setState(() {
                          isLoadingLater = true;
                        });
                        await Future.delayed(Duration(seconds: 1)); // 👈 nếu onLater không phải async, thì dùng delay giả lập

                        widget.onLater();

                        setState(() {
                          isLoadingLater = false;
                        });
                        },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: HelpersColors.itemSelected,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Center(
                          child: isLoadingLater ? Container(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(color: Colors.white,)) : Text(
                            // 'Save',
                            'Later',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildMissionField({
    required IconData icon,
    required String title,
    required String label,
    required String hint,
    required Color color,
    required TextEditingController controller,
    required String? errorText,
  }) {
    return Stack(
      children: [
        Container(
          // height: 170,
          margin: const EdgeInsets.only(left: 20, top: 25),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(width: 55),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15),
                    // Text(
                    //   label,
                    //   style: TextStyle(
                    //     fontWeight: FontWeight.bold,
                    //     color: color,
                    //   ),
                    // ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: label.replaceAll('*', '').trim(), // phần label không có dấu *
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                              fontSize: 14,
                            ),
                          ),
                          if (label.contains('*'))
                            TextSpan(
                              text: ' *',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red, // màu đỏ cho dấu *
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),
                    TextField(
                      controller: controller,
                      maxLines: 4,
                      style: const TextStyle(
                        fontSize:
                        13, // 👈 Điều chỉnh tại đây (hoặc 12 nếu bạn muốn nhỏ hơn nữa)
                      ),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: const TextStyle(color: Colors.blueGrey),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 5,
                        ),

                        helperText: errorText != null ? '$errorText' : null,
                        helperStyle: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: errorText != null
                                ? Colors.redAccent
                                : Colors.transparent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: errorText != null
                                ? Colors.redAccent
                                : HelpersColors.itemPrimary,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: errorText != null
                                ? Colors.redAccent
                                : color.withOpacity(0.5),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: HelpersColors.itemTextField,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 5),

              Icon(icon, color: Colors.white),
              SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 5),
            ],
          ),
        ),
      ],
    );
  }
}
