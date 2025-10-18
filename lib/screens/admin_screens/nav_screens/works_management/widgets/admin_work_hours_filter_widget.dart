import 'package:daily_manage_user_app/providers/admin/admin_work_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../helpers/format_helper.dart';
import '../../../../../helpers/tools_colors.dart';
import '../../../../common_screens/widgets/top_notification_widget.dart';
class AdminWorkHoursFilterWidget extends ConsumerStatefulWidget {
  const AdminWorkHoursFilterWidget({super.key
  ,required this.onDateRangeSelected,
  });
  final void Function(DateTime? startDate, DateTime? endDate) onDateRangeSelected;
  @override
  _AdminWorkHoursFilterWidgetState createState() => _AdminWorkHoursFilterWidgetState();
}

class _AdminWorkHoursFilterWidgetState extends ConsumerState<AdminWorkHoursFilterWidget> {
  DateTime? _selectedDateStart;
  DateTime? _selectedDateEnd;
  bool _errorStartDate = false;
  String _textErrorDayStart = 'Day start is required';

  // Biến trạng thái để kiểm soát việc hiển thị bộ lọc
  bool _isFilterVisible = false;

  // Widget _buildTextTitle({required String title}) {
  //   return Container(
  //     padding: EdgeInsets.only(bottom: 5),
  //     child: Row(
  //       children: [
  //         Text(
  //           title,
  //           style: TextStyle(color: HelpersColors.itemPrimary, fontSize: 15),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Future<void> _pickDateStart() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateStart ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime.now().toLocal(),
      locale: const Locale('en'), // ✅ Đặt ngôn ngữ thành tiếng Anh
    );

    if (picked != null) {
      if (_selectedDateEnd != null && picked.isAfter(_selectedDateEnd!)) {
        showTopNotification(context: context, message: 'Start date cannot be after end date.', type: NotificationType.error);
        return;
      }

      setState(() {
        _selectedDateStart = picked;
        if (_selectedDateStart != null && _selectedDateEnd != null) {
          widget.onDateRangeSelected(_selectedDateStart, _selectedDateEnd);
        }
        // if(_selectedDateStart != null && _selectedDateEnd != null){
        //   ref.read(adminWorkProvider.notifier)
        //       .loadWorksByUserFirstPage(
        //     isRefresh: true,
        //     startDate: _selectedDateStart,
        //     endDate: _selectedDateEnd
        //   );
        //   _refreshController.refreshCompleted();
        //   _refreshController.loadComplete();
        // }
      });
    }
  }

  Future<void> _pickDateEnd() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateEnd ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime.now().toLocal(),
      locale: const Locale('en'), // ✅ Đặt ngôn ngữ thành tiếng Anh
    );

    if (picked != null) {
      if (_selectedDateStart != null && picked.isBefore(_selectedDateStart!)) {
        showTopNotification(context: context, message: 'End date cannot be before start date.', type: NotificationType.error);
        return;
      }

      setState(() {
        _selectedDateEnd = picked;
        if (_selectedDateStart != null && _selectedDateEnd != null) {
          widget.onDateRangeSelected(_selectedDateStart, _selectedDateEnd);
        }
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return
    //   Align(
    //   alignment: AlignmentDirectional.centerEnd,
    //   child: AnimatedContainer(
    //     duration: const Duration(milliseconds: 300),
    //     curve: Curves.easeOut,
    //     padding: EdgeInsets.all(5),
    //     decoration: BoxDecoration(
    //       color: HelpersColors.bgFillTextField,
    //       borderRadius: BorderRadius.all(Radius.circular(10)),
    //     ),
    //     width: _isFilterVisible
    //         ? MediaQuery.of(context).size.width
    //         : _selectedDateStart != null && _selectedDateEnd != null ? 104 :
    //
    //     50, // icon (40) + padding hai bên (10+10) + width
    //     height: _isFilterVisible
    //         ? 50
    //         : 50,
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.end,
    //       children: [
    //         // AnimatedContainer để điều khiển chiều rộng một cách linh hoạt
    //         Flexible(
    //           child: AnimatedContainer(
    //             duration: const Duration(milliseconds: 300),
    //             curve: Curves.easeOut,
    //             // Khi _isFilterVisible là false, width = 0.
    //             // Khi _isFilterVisible là true, width sẽ là chiều rộng tối đa còn lại.
    //             // Nếu không muốn dùng chiều rộng vô cực, bạn có thể đặt một giá trị cụ thể ở đây
    //             width: _isFilterVisible ? MediaQuery.of(context).size.width - 60 - 10 : 0, // 60 = 40 (icon) + 10 (SizedBox)
    //             child: Align(
    //               alignment: Alignment.centerLeft,
    //               child: SingleChildScrollView(
    //                 scrollDirection: Axis.horizontal,
    //                 reverse: true, // Đảm bảo cuộn từ phải sang
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.start,
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: [
    //                     InkWell(
    //                       onTap: () {
    //                         _pickDateStart();
    //                       },
    //                       child: Column(
    //                         children: [
    //                           Container(
    //                             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    //                             decoration: BoxDecoration(
    //                               // color: HelpersColors.bgFillTextField,
    //                               color: _selectedDateStart == null ? Colors.white : HelpersColors.itemCard,
    //                               border: Border.all(
    //                                 color: _errorStartDate
    //                                     ? HelpersColors.itemSelected
    //                                     : HelpersColors.bgFillTextField,
    //                                 width: 1,
    //                               ),
    //                               borderRadius: BorderRadius.all(Radius.circular(10)),
    //                             ),
    //                             child: Row(
    //                               children: [
    //                                 Icon(Icons.calendar_today,
    //                                   color: _selectedDateStart == null ? HelpersColors.itemPrimary : Colors.white,
    //
    //                                   size: 20,),
    //                                 SizedBox(width: 10),
    //                                 Text(
    //                                   _selectedDateStart == null
    //                                       ? 'Start Date'
    //                                       : FormatHelper.formatDate_DD_MM_YYYY(
    //                                     _selectedDateStart!,
    //                                   ),
    //                                   style: TextStyle(
    //                                       color: _selectedDateStart == null ? HelpersColors.itemPrimary : Colors.white,
    //
    //
    //                                       fontSize: 12),
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //                           if (_errorStartDate)
    //                             Align(
    //                               alignment: AlignmentDirectional.topStart,
    //                               child: Text(
    //                                 _textErrorDayStart,
    //                                 style: TextStyle(color: HelpersColors.itemSelected),
    //                               ),
    //                             ),
    //                         ],
    //                       ),
    //                     ),
    //                     SizedBox(width: 7,),
    //                     InkWell(
    //                       onTap: () {
    //                         _pickDateEnd();
    //                       },
    //                       child: Column(
    //                         children: [
    //                           Container(
    //                             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    //                             decoration: BoxDecoration(
    //                               color: _selectedDateEnd != null ? HelpersColors.itemPrimary : Colors.white,
    //
    //
    //
    //                               border: Border.all(
    //                                 color: _errorStartDate
    //                                     ? HelpersColors.itemSelected
    //                                     : HelpersColors.bgFillTextField,
    //                                 width: 1,
    //                               ),
    //                               borderRadius: BorderRadius.all(Radius.circular(10)),
    //                             ),
    //                             child: Row(
    //                               children: [
    //                                 Icon(Icons.calendar_today,
    //                                   color: _selectedDateEnd == null ? HelpersColors.itemPrimary : Colors.white,
    //                                   size: 20,),
    //                                 SizedBox(width: 10),
    //                                 Text(
    //                                   _selectedDateEnd == null
    //                                       ? 'End Date'
    //                                       : FormatHelper.formatDate_DD_MM_YYYY(
    //                                     _selectedDateEnd!,
    //                                   ),
    //                                   style: TextStyle(
    //
    //                                       color: _selectedDateEnd == null ? HelpersColors.itemPrimary : Colors.white,
    //
    //
    //
    //                                       fontSize: 12),
    //
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //                           if (_errorStartDate)
    //                             Align(
    //                               alignment: AlignmentDirectional.topStart,
    //                               child: Text(
    //                                 _textErrorDayStart,
    //                                 style: TextStyle(color: HelpersColors.itemSelected),
    //                               ),
    //                             ),
    //                         ],
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ),
    //
    //         // Đảm bảo có một SizedBox giữa bộ lọc và icon
    //         // const SizedBox(width: 10),
    //         // Icon lọc, được bọc trong GestureDetector để bắt sự kiện chạm
    //         if(_selectedDateStart!= null && _selectedDateEnd != null)
    //         GestureDetector(
    //           onTap: () {
    //             setState(() {
    //               _selectedDateStart = null;
    //               _selectedDateEnd = null;
    //               widget.onDateRangeSelected(null, null); // ✅ Báo về parent để load lại dữ liệu
    //               // _isFilterVisible = !_isFilterVisible; // Đảo ngược trạng thái
    //             });
    //           },
    //           child: Container(
    //             margin: EdgeInsets.only(right: 7, left: 7),
    //             height: 40,
    //             width: 40,
    //             decoration: BoxDecoration(
    //               color: HelpersColors.itemSelected,
    //               borderRadius: const BorderRadius.all(Radius.circular(10)),
    //             ),
    //             child: Icon(
    //               CupertinoIcons.trash_fill,
    //               color: Colors.white,
    //               size: 20,
    //             ),
    //           ),
    //         ),
    //         GestureDetector(
    //           onTap: () {
    //             setState(() {
    //               _isFilterVisible = !_isFilterVisible; // Đảo ngược trạng thái
    //             });
    //           },
    //           child: Container(
    //             height: 40,
    //             width: 40,
    //             decoration: BoxDecoration(
    //               color: HelpersColors.itemTextField.withOpacity(0.3),
    //               borderRadius: const BorderRadius.all(Radius.circular(10)),
    //             ),
    //             child: Icon(
    //               Icons.filter_alt_rounded,
    //               color: HelpersColors.itemPrimary,
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
      Container(
        padding: EdgeInsets.all(10),
        color: HelpersColors.bgFillTextField,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AnimatedContainer để điều khiển chiều rộng một cách linh hoạt
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 10,),
                  Text('Filter', style: TextStyle(color: HelpersColors.itemCard,fontWeight: FontWeight.bold),),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      _pickDateStart();
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            // color: HelpersColors.bgFillTextField,
                            color: _selectedDateStart == null ? Colors.white : HelpersColors.itemCard,
                            border: Border.all(
                              color: _errorStartDate
                                  ? HelpersColors.itemSelected
                                  : HelpersColors.bgFillTextField,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          height: 40,
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                color: _selectedDateStart == null ? HelpersColors.itemPrimary : Colors.white,

                                size: 20,),
                              SizedBox(width: 10),
                              Text(
                                _selectedDateStart == null
                                    ? 'Start Date'
                                    : FormatHelper.formatDate_DD_MM_YYYY(
                                  _selectedDateStart!,
                                ),
                                style: TextStyle(
                                    color: _selectedDateStart == null ? HelpersColors.itemPrimary : Colors.white,


                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        if (_errorStartDate)
                          Align(
                            alignment: AlignmentDirectional.topStart,
                            child: Text(
                              _textErrorDayStart,
                              style: TextStyle(color: HelpersColors.itemSelected),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 7,),
                  InkWell(
                    onTap: () {
                      _pickDateEnd();
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          height: 40,
                          decoration: BoxDecoration(
                            color: _selectedDateEnd != null ? HelpersColors.itemPrimary : Colors.white,



                            border: Border.all(
                              color: _errorStartDate
                                  ? HelpersColors.itemSelected
                                  : HelpersColors.bgFillTextField,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                color: _selectedDateEnd == null ? HelpersColors.itemPrimary : Colors.white,
                                size: 20,),
                              SizedBox(width: 10),
                              Text(
                                _selectedDateEnd == null
                                    ? 'End Date'
                                    : FormatHelper.formatDate_DD_MM_YYYY(
                                  _selectedDateEnd!,
                                ),
                                style: TextStyle(

                                    color: _selectedDateEnd == null ? HelpersColors.itemPrimary : Colors.white,



                                    fontSize: 12),

                              ),
                            ],
                          ),
                        ),
                        if (_errorStartDate)
                          Align(
                            alignment: AlignmentDirectional.topStart,
                            child: Text(
                              _textErrorDayStart,
                              style: TextStyle(color: HelpersColors.itemSelected),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        
            // Đảm bảo có một SizedBox giữa bộ lọc và icon
            // const SizedBox(width: 10),
            // Icon lọc, được bọc trong GestureDetector để bắt sự kiện chạm
            if(_selectedDateStart!= null || _selectedDateEnd != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDateStart = null;
                    _selectedDateEnd = null;
                    widget.onDateRangeSelected(null, null); // ✅ Báo về parent để load lại dữ liệu
                    // _isFilterVisible = !_isFilterVisible; // Đảo ngược trạng thái
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 7, left: 7),
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: HelpersColors.itemSelected,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Center(child: Text('Clear', style: TextStyle(color: Colors.white),)),
                ),
              ),
          ],
        ),
      );
  }
}
