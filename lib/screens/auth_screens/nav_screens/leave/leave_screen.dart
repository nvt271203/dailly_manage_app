import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:daily_manage_user_app/controller/leave_controller.dart';
import 'package:daily_manage_user_app/helpers/format_helper.dart';
import 'package:daily_manage_user_app/helpers/tools_colors.dart';
import 'package:daily_manage_user_app/providers/admin/admin_leave_provider.dart';
import 'package:daily_manage_user_app/providers/user_provider.dart';
import 'package:daily_manage_user_app/screens/common_screens/widgets/top_notification_widget.dart';
import 'package:daily_manage_user_app/services/sockets/leave_socket.dart';
import 'package:daily_manage_user_app/widgets/circular_loading_widget.dart';
import 'package:daily_manage_user_app/widgets/loading_status_bar_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../models/leave.dart';
import '../../../../providers/leave_provider.dart';
import '../../../../services/sockets/socket_service.dart';
import 'screens/leave_request_screen.dart';
import 'screens/detail_leave_request.dart';

class LeaveScreen extends ConsumerStatefulWidget {
  const LeaveScreen({super.key});

  @override
  _LeaveScreenState createState() => _LeaveScreenState();
}

class _LeaveScreenState extends ConsumerState<LeaveScreen>
    with TickerProviderStateMixin {
  String _selectedItemDate = 'Start Date desc';
  final List<String> _itemsDropdownDate = [
    'Start Date desc',
    'Start Date asc',
    'Sent Date desc',
    'Sent Date asc',
  ];
  final List<String> _list = ['Developer', 'Designer', 'Consultant', 'Student'];

  String _selectedItemStatus = 'Status All';
  final List<String> _itemsDropdownStatus = [
    'Status All',
    'Pending',
    'Approved',
    'Rejected',
  ];

  int selectedYear = DateTime.now().year;

  // List<Leave> leaves = [];
  // int page = 1;
  // final int limit = 10;
  // bool hasMore = true;
  RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  // Lưu trạng thái khi cuộn.
  final ScrollController _scrollController = ScrollController();
  final String _scrollPositionKey = 'leave_list_scroll_position';

  // Lưu vị trí cuộn vào Hive
  void _saveScrollPosition() async {
    final box = Hive.box('appSettingsBoxLeave'); // Box riêng để lưu cài đặt
    await box.put(_scrollPositionKey, _scrollController.offset);
  }

  // Khôi phục vị trí cuộn từ Hive
  void _restoreScrollPosition() async {
    final box = Hive.box('appSettingsBoxLeave');
    final double? savedPosition = box.get(_scrollPositionKey);
    if (savedPosition != null) {
      // Đảm bảo cuộn sau khi danh sách được hiển thị
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // _scrollController.jumpTo(savedPosition);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            savedPosition,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // LeaveSocket.listenUpdatedLeaveRequest((leaveData) {
    //   // print('Processing work_checkIn data: $workData');
    //   print('Processing leave_request_status_update data: $leaveData'); // Log toàn bộ dữ liệu
    //   final updatedLeave = Leave.fromMap(leaveData);
    //   if (!mounted) return;  // Kiểm tra widget còn tồn tại không
    //   print('Processed leave_request_status_update: $updatedLeave'); // Log đối tượng Work sau khi xử lý
    //   final currentList = ref.read(leaveProvider).value ?? [];
    //   final exists = currentList.any((w) => w.id == updatedLeave.id);
    //   if (exists) {
    //     ref.read(leaveProvider.notifier).updateLeaveItem(updatedLeave);
    //   } else {
    //     ref.read(leaveProvider.notifier).addLeaveToTop(updatedLeave);
    //   }
    // });
    // // Thêm listener để lưu vị trí cuộn khi cuộn
    //     _scrollController.addListener(_saveScrollPosition);
    //
    //     // Khôi phục vị trí cuộn sau khi widget được khởi tạo
    //     _restoreScrollPosition();
    _loadDataCache();

    // LeaveSocket.initSocketConnection();
    // LeaveSocket.listenUserUpdateLeave(() {
    //   // ref.read(leaveProvider.notifier).loadLeaves(); // Gọi lại khi có update
    //   ref.read(leaveProvider.notifier).loadLeavesByUserFirstPage(isRefresh: true); // Gọi lại khi có update
    // });

    // Gọi loadLeaves từ LeaveProvider
    // Future.microtask(() => ref.read(leaveProvider.notifier).loadLeaves());
    // Tải dữ liệu ban đầu thông qua provider
    Future.microtask(() async {});
    // _loadInitialLeaves();
    // Future.microtask(() => _loadInitialLeaves());
  }

  Future<void> _loadDataCache() async {
    final prefs = await SharedPreferences.getInstance();
    //
    // // Đọc các tham số lọc từ SharedPreferences
    // final filterYear = prefs.getInt('filterYear') ?? DateTime.now().year;
    // final sortField = prefs.getString('sortField') ?? 'startDate';
    // final sortOrder = prefs.getString('sortOrder') ?? 'desc';
    // final status = prefs.getString('status') ?? 'all';
    //
    // // Cập nhật trạng thái dropdown dựa trên SharedPreferences
    // setState(() {
    //   selectedYear = filterYear;
    //   _selectedItemDate = sortField == 'startDate'
    //       ? (sortOrder == 'asc' ? 'Start Date asc' : 'Start Date desc')
    //       : (sortOrder == 'asc' ? 'Sent Date asc' : 'Sent Date desc');
    //   _selectedItemStatus = status == 'all' ? 'Status All' : status;
    // });
    // Đọc các tham số lọc từ SharedPreferences
    final filterYear = prefs.getInt('filterYear') ?? DateTime.now().year;
    final sortField = prefs.getString('sortField') ?? 'startDate';
    final sortOrder = prefs.getString('sortOrder') ?? 'desc';
    final status = prefs.getString('status') ?? 'all';

    // Cập nhật trạng thái dropdown mà không cần setState ngay lập tức
    _selectedItemDate = sortField == 'startDate'
        ? (sortOrder == 'asc' ? 'Start Date asc' : 'Start Date desc')
        : (sortOrder == 'asc' ? 'Sent Date asc' : 'Sent Date desc');
    _selectedItemStatus = status == 'all' ? 'Status All' : status;
    selectedYear = filterYear;

    ref
        .read(leaveProvider.notifier)
        .loadLeavesByUserFirstPage(isRefresh: false);
  }

  // Future<void> _loadInitialLeaves() async {
  //   page = 1;
  //   final newLeaves = await LeaveController().loadLeavesByUserPagination(userId: ref.read(userProvider)!.id, page: page, limit: limit);
  //   if(newLeaves!=null){a
  //     showTopNotification(context: context, message: 'Data loaded', type: NotificationType.success);
  //   }
  //   setState(() {
  //     leaves = newLeaves;
  //     hasMore = newLeaves.length == limit;
  //   });
  //   _refreshController.refreshCompleted();
  // }
  //
  // Future<void> _loadMoreLeaves() async {
  //   if (!hasMore) {
  //     _refreshController.loadNoData();
  //     return;
  //   }
  //   page++;
  //   final newLeaves = await LeaveController().loadLeavesByUserPagination(userId: ref.read(userProvider)!.id, page: page, limit: limit);
  //   setState(() {
  //     leaves.addAll(newLeaves);
  //     hasMore = newLeaves.length == limit;
  //   });
  //
  //   if (newLeaves.length < limit) {
  //     _refreshController.loadNoData();
  //   } else {
  //     _refreshController.loadComplete();
  //   }
  // }

  // Future<void> _loadInitialLeaves() async {
  //   await ref
  //       .read(leaveProvider.notifier)
  //       .loadLeavesByUserFirstPage(isRefresh: true);
  //   // if (ref.read(leaveProvider).value?.isNotEmpty ?? false) {
  //   //   showTopNotification(context: context, message: 'Data loaded', type: NotificationType.success);
  //   // }
  //   _refreshController.refreshCompleted();
  //   // Đảm bảo rằng trạng thái kéo lên được kích hoạt lại
  //   _refreshController.loadComplete();
  // }
  Future<void> _loadInitialLeaves() async {
    // CẬP NHẬT: Truyền tham số lọc từ dropdown
    String sortField = _selectedItemDate.contains('Start Date')
        ? 'startDate'
        : 'dateCreated';
    String sortOrder = _selectedItemDate.contains('asc') ? 'asc' : 'desc';
    String status = _selectedItemStatus.toLowerCase() == 'status all'
        ? 'all'
        : _selectedItemStatus;

    await ref
        .read(leaveProvider.notifier)
        .loadLeavesByUserFirstPage(
          filterYear: selectedYear,
          sortField: sortField,
          sortOrder: sortOrder,
          status: status,
        );
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    // Khôi phục vị trí cuộn sau khi làm mới
    // _restoreScrollPosition();
  }

  Future<void> _loadMoreLeaves() async {
    await ref.read(leaveProvider.notifier).loadMoreLeaves();
    if (ref.read(leaveProvider.notifier).hasMore) {
      _refreshController.loadComplete();
    } else {
      _refreshController.loadNoData();
    }
  }

  //   // mỗi nhóm theo tháng-năm sẽ được sắp xếp mới nhất lên đầu:
  //   Map<String, List<Leave>> groupWorksByMonthYear(List<Leave> leaves) {
  //     final Map<String, List<Leave>> grouped = {};
  //     for (var leave in leaves) {
  //       // final createdDate = leave.startDate;
  //       final startDate = leave.startDate; // Sử dụng startDate
  //
  //       final key =
  //           '${startDate.month.toString().padLeft(2, '0')}-${startDate.year}';
  //       grouped.putIfAbsent(key, () => []);
  //       grouped[key]!.add(leave);
  //     }
  //
  //     // // ✅ Sắp xếp từng nhóm theo dateCreated giảm dần
  //     // for (var key in grouped.keys) {
  //     //   grouped[key]!.sort((a, b) => b.startDate.compareTo(a.startDate));
  //     // }
  // // ✅ Sắp xếp từng nhóm theo startDate giảm dần
  //     for (var key in grouped.keys) {
  //       grouped[key]!.sort((a, b) => b.startDate.compareTo(a.startDate));
  //     }
  //     return grouped;
  //   }
  Map<String, List<Leave>> groupWorksByMonthYear(
    List<Leave> leaves,
    String sortOrder,
  ) {
    final Map<String, List<Leave>> grouped = {};
    for (var leave in leaves) {
      // Chọn trường để nhóm dựa trên _selectedItemDate
      final dateToGroup = _selectedItemDate.contains('Start Date')
          ? leave.startDate
          : leave.dateCreated;
      final key =
          '${dateToGroup.month.toString().padLeft(2, '0')}/${dateToGroup.year}';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(leave);
    }

    // Sắp xếp từng nhóm theo trường được chọn và sortOrder
    for (var key in grouped.keys) {
      grouped[key]!.sort((a, b) {
        final aDate = _selectedItemDate.contains('Start Date')
            ? a.startDate
            : a.dateCreated;
        final bDate = _selectedItemDate.contains('Start Date')
            ? b.startDate
            : b.dateCreated;
        final dateCompare = sortOrder == 'asc'
            ? aDate.compareTo(bDate)
            : bDate.compareTo(aDate);
        if (dateCompare != 0) return dateCompare;
        // Nếu ngày bằng nhau, sắp xếp theo dateCreated
        return sortOrder == 'asc'
            ? a.dateCreated.compareTo(b.dateCreated)
            : b.dateCreated.compareTo(a.dateCreated);
      });
    }

    print('Grouped leaves by month-year: $grouped');
    return grouped;
  }

  // Widget _buildDropdownDate() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 12),
  //
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       border: Border.all(color: HelpersColors.itemPrimary),
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: SizedBox(
  //       height: 36,
  //       child: DropdownButton<String>(
  //         value: _selectedItemDate,
  //         isExpanded: true,
  //         icon: const Icon(Icons.keyboard_arrow_down),
  //         onChanged: (String? newValue) {
  //           setState(() {
  //             _selectedItemDate = newValue!;
  //
  //             // CẬP NHẬT: Gọi lại API với bộ lọc mới
  //             String sortField = newValue.contains('Start Date')
  //                 ? 'startDate'
  //                 : 'dateCreated';
  //             String sortOrder = newValue.contains('asc') ? 'asc' : 'desc';
  //             ref
  //                 .read(leaveProvider.notifier)
  //                 .loadLeavesByUserFirstPage(
  //                   isRefresh: true,
  //                   filterYear: selectedYear,
  //                   sortField: sortField,
  //                   sortOrder: sortOrder,
  //                   status: _selectedItemStatus.toLowerCase() == 'status all'
  //                       ? 'all'
  //                       : _selectedItemStatus,
  //                 );
  //             _refreshController.refreshCompleted();
  //             _refreshController.loadComplete();
  //           });
  //         },
  //         items: _itemsDropdownDate.map((String value) {
  //           return DropdownMenuItem<String>(
  //             value: value,
  //             child: Container(
  //               color: value == _selectedItemDate
  //                   ? HelpersColors
  //                         .itemTextField // Màu nền khi được chọn
  //                   : Colors.transparent, // Màu nền bình thường
  //               child: Padding(
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 8.0,
  //                   vertical: 8.0,
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     // const Icon(
  //                     //   Icons.calendar_today,
  //                     //   size: 18,
  //                     //   color: Colors.blue,
  //                     // ),
  //                     const SizedBox(width: 8),
  //                     Text(
  //                       value,
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         color: value == _selectedItemDate
  //                             ? Colors.white
  //                             : Colors.black.withOpacity(0.7),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             // child: Container(
  //             //   color: value == _selectedItemDate
  //             //       ? HelpersColors.itemTextField // Màu nền khi được chọn
  //             //       : Colors.transparent, // Màu nền bình thường
  //             //   child: Row(
  //             //     children: [
  //             //       // const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
  //             //       // const SizedBox(width: 8),
  //             //       Text(value, style: TextStyle(
  //             //       color: value == _selectedItemDate
  //             //           ? Colors.white : Colors.black.withOpacity(0.7)
  //             //       ),),
  //             //     ],
  //             //   ),
  //             // ),
  //           );
  //         }).toList(),
  //         selectedItemBuilder: (context) => _itemsDropdownDate.map((value) {
  //           return Row(
  //             children: [
  //               const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
  //               const SizedBox(width: 8),
  //               Text(value, style: TextStyle(fontSize: 14)),
  //             ],
  //           );
  //         }).toList(),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildDropdownDate(){
    return DropdownButtonHideUnderline(
      child: Container(
        decoration: BoxDecoration(
          color: HelpersColors.itemCard,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        // 👈 màu nền phẳng
        child: DropdownButton2(
          isExpanded: false,
          // Tùy chỉnh nút dropdown bọc ngoài
          buttonStyleData: ButtonStyleData(
            // padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
            padding: EdgeInsets.zero, // ❌ bỏ padding mặc định
            height: 45,
            // width: 250,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: HelpersColors.itemCard),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          // Custom Dropdown sau khi sổ ra.
          dropdownStyleData: DropdownStyleData(
            padding: EdgeInsets.zero,
            // 👈 bỏ padding top/bottom mặc định
            // maxHeight: 100
            // width: 180
            decoration: BoxDecoration(
              border: Border.all(color: HelpersColors.primaryColor),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            offset: Offset(0, -4),
          ),
          menuItemStyleData: MenuItemStyleData(
            // padding: EdgeInsets.symmetric(horizontal:12),
            padding: EdgeInsets.zero,
            // 👇 đây là key: màu nền khi item đang selected
            selectedMenuItemBuilder: (context, child) {
              return Container(
                color: HelpersColors.itemCard,
                // nền xanh mờ
                child: child,
              );
            },
          ),
          iconStyleData: IconStyleData(
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
              size: 28,
            ),
          ),
          // hint: Row(
          //   children: [
          //     Icon(Icons.calendar_today,color: HelpersColors.itemCard,),
          //     Text('Choose')
          //   ],
          // ),
          items: _itemsDropdownDate
              .map(
                (e) => DropdownMenuItem(
              value: e,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: Row(
                  // mainAxisAlignment:
                  //     MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: e == _selectedItemDate
                          ? Colors.white
                          : Colors.black,
                    ),
                    SizedBox(width: 10),
                    Text(
                      e,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: e == _selectedItemDate
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: e == _selectedItemDate
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              .toList(),
          value: _selectedItemDate,
          onChanged: (value) {
            setState(() {
              _selectedItemDate = value!;

              // CẬP NHẬT: Gọi lại API với bộ lọc mới
              String sortField = value.contains('Start Date')
                  ? 'startDate'
                  : 'dateCreated';
              String sortOrder = value.contains('asc') ? 'asc' : 'desc';
              ref
                  .read(leaveProvider.notifier)
                  .loadLeavesByUserFirstPage(
                isRefresh: true,
                filterYear: selectedYear,
                sortField: sortField,
                sortOrder: sortOrder,
                status: _selectedItemStatus.toLowerCase() == 'status all'
                    ? 'all'
                    : _selectedItemStatus,
              );
              _refreshController.refreshCompleted();
              _refreshController.loadComplete();
            });
          },
        ),
      ),
    );

  }
  Widget _buildDropdownStatus(){
    return DropdownButtonHideUnderline(
      child: Container(
        decoration: BoxDecoration(
          color: HelpersColors.itemCard,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        // 👈 màu nền phẳng
        child: DropdownButton2(
          isExpanded: false,
          // Tùy chỉnh nút dropdown bọc ngoài
          buttonStyleData: ButtonStyleData(
            // padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
            padding: EdgeInsets.zero, // ❌ bỏ padding mặc định
            height: 45,
            // width: 250,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: HelpersColors.itemCard),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          // Custom Dropdown sau khi sổ ra.
          dropdownStyleData: DropdownStyleData(
            padding: EdgeInsets.zero,
            // 👈 bỏ padding top/bottom mặc định
            // maxHeight: 100
            // width: 180
            decoration: BoxDecoration(
              border: Border.all(color: HelpersColors.primaryColor),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            offset: Offset(0, -4),
          ),
          menuItemStyleData: MenuItemStyleData(
            // padding: EdgeInsets.symmetric(horizontal:12),
            padding: EdgeInsets.zero,
            // 👇 đây là key: màu nền khi item đang selected
            selectedMenuItemBuilder: (context, child) {
              return Container(
                color: HelpersColors.itemCard,
                // nền xanh mờ
                child: child,
              );
            },
          ),
          iconStyleData: IconStyleData(
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
              size: 28,
            ),
          ),
          // hint: Row(
          //   children: [
          //     Icon(Icons.calendar_today,color: HelpersColors.itemCard,),
          //     Text('Choose')
          //   ],
          // ),
          items: _itemsDropdownStatus
              .map(
                (e) =>
                    DropdownMenuItem(
              value: e,
              child:
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: Row(
                  // mainAxisAlignment:
                  //     MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.pending_actions,
                      color: e == _selectedItemStatus
                          ? Colors.white
                          : Colors.black,
                    ),
                    SizedBox(width: 10),
                    Text(
                      e,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: e == _selectedItemStatus
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: e == _selectedItemStatus
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              .toList(),
          value: _selectedItemStatus,
          onChanged: (value) {
            setState(() {
              _selectedItemStatus = value!;

              // CẬP NHẬT: Gọi lại API với bộ lọc mới
              String sortField = _selectedItemDate.contains('Start Date')
                  ? 'startDate'
                  : 'dateCreated';
              String sortOrder = _selectedItemDate.contains('asc')
                  ? 'asc'
                  : 'desc';
              ref
                  .read(leaveProvider.notifier)
                  .loadLeavesByUserFirstPage(
                isRefresh: true,
                filterYear: selectedYear,
                sortField: sortField,
                sortOrder: sortOrder,
                status: value.toLowerCase() == 'status all'
                    ? 'all'
                    : value,
              );
              _refreshController.refreshCompleted();
              _refreshController.loadComplete();
            });
          },
        ),
      ),
    );

  }
  Widget _buildDropdownYear(){
    return DropdownButtonHideUnderline(
      child: Container(
        decoration: BoxDecoration(
          color: HelpersColors.itemCard,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        // 👈 màu nền phẳng
        child: DropdownButton2(
          isExpanded: false,
          // Tùy chỉnh nút dropdown bọc ngoài
          buttonStyleData: ButtonStyleData(
            // padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
            padding: EdgeInsets.zero, // ❌ bỏ padding mặc định
            height: 45,
            // width: 250,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: HelpersColors.itemCard),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          // Custom Dropdown sau khi sổ ra.
          dropdownStyleData: DropdownStyleData(
            padding: EdgeInsets.zero,
            // 👈 bỏ padding top/bottom mặc định
            // maxHeight: 100
            // width: 180
            decoration: BoxDecoration(
              border: Border.all(color: HelpersColors.primaryColor),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            offset: Offset(0, -4),
          ),
          menuItemStyleData: MenuItemStyleData(
            // padding: EdgeInsets.symmetric(horizontal:12),
            padding: EdgeInsets.zero,
            // 👇 đây là key: màu nền khi item đang selected
            selectedMenuItemBuilder: (context, child) {
              return Container(
                color: HelpersColors.itemCard,
                // nền xanh mờ
                child: child,
              );
            },
          ),
          iconStyleData: IconStyleData(
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
              size: 28,
            ),
          ),
          // hint: Row(
          //   children: [
          //     Icon(Icons.calendar_today,color: HelpersColors.itemCard,),
          //     Text('Choose')
          //   ],
          // ),
            items: List.generate(10, (index) {
              final year = DateTime.now().year + 1 - index;
              return DropdownMenuItem<int>(
                value: year,
                child:
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  child: Row(
                    // mainAxisAlignment:
                    //     MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.pending_actions,
                        color: year == selectedYear
                            ? Colors.white
                            : Colors.black,
                      ),
                      SizedBox(width: 10),
                      Text(
                        year.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: year == selectedYear
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: year == selectedYear
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          value: selectedYear,

          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() {
                selectedYear = newValue;

                // CẬP NHẬT: Gọi lại API với bộ lọc mới
                String sortField = _selectedItemDate.contains('Start Date')
                    ? 'startDate'
                    : 'dateCreated';
                String sortOrder = _selectedItemDate.contains('asc')
                    ? 'asc'
                    : 'desc';
                ref
                    .read(leaveProvider.notifier)
                    .loadLeavesByUserFirstPage(
                  isRefresh: true,
                  filterYear: newValue,
                  sortField: sortField,
                  sortOrder: sortOrder,
                  status:
                  _selectedItemStatus.toLowerCase() == 'status all'
                      ? 'all'
                      : _selectedItemStatus,
                );
                _refreshController.refreshCompleted();
                _refreshController.loadComplete();
              });
            }
          },
        ),
      ),
    );

  }

  // Biến trạng thái để kiểm soát việc hiển thị bộ lọc
  bool _isFilterVisible = false;

  @override
  Widget build(BuildContext context) {
    final leaveState = ref.watch(leaveProvider);
    // tạo 1 provider duy nhất để đọc dữ liệu tổng số ngày nghỉ.
    final leaveProviderNotifier = ref.read(leaveProvider.notifier);

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          // backgroundColor: Colors.transparent,
          backgroundColor: Colors.white,
          body: Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                // SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ScrollbarTheme(
                        data: ScrollbarThemeData(
                          thumbColor: MaterialStateProperty.all(HelpersColors.itemCard),   // màu thanh cuộn
                          trackBorderColor: MaterialStateProperty.all(Colors.black12),
                        ),
                        child: Scrollbar(
                          thumbVisibility: true, // 👈 luôn hiện thanh cuộn
                          // trackVisibility: true, // 👈 (tuỳ chọn) hiện cả track phía sau
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 12),
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                // Dropdown 1: _selectedItemDate
                                IntrinsicWidth(child: _buildDropdownDate()),
                                const SizedBox(width: 10),
                                // Dropdown 2: _selectedItemStatus
                                IntrinsicWidth(child: _buildDropdownStatus()),
                                const SizedBox(width: 10),
                                // Dropdown 3: selectedYear
                                IntrinsicWidth(child: _buildDropdownYear()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // SizedBox(width: 10),
                    // Container(
                    //   height: 40,
                    //   width: 40,
                    //   decoration: BoxDecoration(
                    //     color: HelpersColors.itemTextField.withOpacity(0.3),
                    //     borderRadius: BorderRadius.all(Radius.circular(10)),
                    //   ),
                    //   child: Icon(
                    //     Icons.filter_alt_rounded,
                    //     color: HelpersColors.itemPrimary,
                    //   ),
                    // ),
                  ],
                ),
                // Container(
                //   margin: EdgeInsets.only(top: 10),
                //   height: 2,
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //     gradient: LinearGradient(
                //       colors: [
                //         HelpersColors.primaryColor,
                //         HelpersColors.secondaryColor,
                //       ],
                //     ),
                //   ),
                // ),
                const SizedBox(height: 10),
                // CustomDropdown<String>(
                //   hintText: 'Select job role',
                //   items: _list,
                //   initialItem: _list[0],
                //
                //   onChanged: (value) {
                //     // log('changing value to: $value');
                //   },
                // ),

                // Leave history
                Expanded(
                  child: leaveState.when(
                    // loading: () => const Center(child: CircularProgressIndicator()),
                    loading: () => const Center(child: CircularLoadingWidget()),
                    error: (e, _) => Center(child: Text('Lỗi: $e')),
                    data: (leaves) {
                      if (leaves.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 20),
                              Text(
                                "No Leave Requests Yet",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                ),
                                child: Text(
                                  "You haven't submitted any leave requests. Tap the 'Leave Request' button below to request time off.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Lọc theo năm
                      // ✅ BƯỚC THÊM: Lọc dữ liệu theo selectedYear
                      // final filteredLeaves = leaves
                      //     .where(
                      //       (leave) =>
                      //           leave.startDate.toLocal().year == selectedYear,
                      //     )
                      //     .toList();
                      //
                      final filteredLeaves = leaves.where((leave) {
                        final dateToFilter =
                            _selectedItemDate.contains('Start Date')
                            ? leave.startDate
                            : leave.dateCreated;
                        return dateToFilter.toLocal().year == selectedYear;
                      }).toList();

                      if (filteredLeaves.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 20),
                              Text(
                                "No Leave Requests Yet",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                ),
                                child: Text(
                                  "You haven't submitted any leave requests. Tap the 'Leave Request' button below to request time off.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // final entries =
                      //     groupWorksByMonthYear(
                      //       filteredLeaves,
                      //     ).entries.toList()..sort((a, b) {
                      //       final aDate = DateTime.parse(
                      //         '${a.key.split('/')[1]}-${a.key.split('/')[0]}-01',
                      //       );
                      //       final bDate = DateTime.parse(
                      //         '${b.key.split('/')[1]}-${b.key.split('/')[0]}-01',
                      //       );
                      //       // return bDate.compareTo(aDate);
                      //
                      //       // CẬP NHẬT: Sắp xếp entries theo sortOrder từ dropdown
                      //       final sortOrder = _selectedItemDate.contains('asc') ? 'asc' : 'desc';
                      //       return sortOrder == 'asc' ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
                      //     });
                      final sortOrder = _selectedItemDate.contains('asc')
                          ? 'asc'
                          : 'desc';
                      final entries =
                          groupWorksByMonthYear(
                            filteredLeaves,
                            sortOrder,
                          ).entries.toList()..sort((a, b) {
                            final aDate = DateTime.parse(
                              '${a.key.split('/')[1]}-${a.key.split('/')[0]}-01',
                            );
                            final bDate = DateTime.parse(
                              '${b.key.split('/')[1]}-${b.key.split('/')[0]}-01',
                            );
                            return sortOrder == 'asc'
                                ? aDate.compareTo(bDate)
                                : bDate.compareTo(aDate);
                          });

                      return SmartRefresher(
                        controller: _refreshController,
                        enablePullDown: true,
                        // Kích hoạt kéo xuống để làm mới
                        enablePullUp: true,
                        // Kích hoạt kéo lên để tải thêm dữ liệu
                        onRefresh: _loadInitialLeaves,
                        // Hàm gọi khi kéo xuống làm mới
                        onLoading: _loadMoreLeaves,
                        // Hàm gọi khi kéo lên tải thêm
                        header: CustomHeader(
                          builder: (BuildContext context, RefreshStatus? status) {
                            Widget body;
                            // if (status == RefreshStatus.idle) {
                            //   body =  Container(
                            //     width: 40.0,
                            //     height: 40.0,
                            //     decoration: BoxDecoration(
                            //       color: Colors.white,
                            //       shape: BoxShape.circle,
                            //     ),
                            //     child:  Icon(Icons.arrow_downward, color: HelpersColors.itemPrimary, size: 24.0),
                            //   );
                            // }
                            // else
                            if (status == RefreshStatus.canRefresh) {
                              body = Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  color: HelpersColors.itemPrimary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_downward,
                                  color: Colors.white,
                                ),
                              );
                            } else if (status == RefreshStatus.refreshing) {
                              // Hiển thị biểu tượng tĩnh thay vì hoạt ảnh quay
                              body = const SizedBox.shrink();
                            } else if (status == RefreshStatus.failed) {
                              body = const Text("Refresh failed!");
                            } else if (status == RefreshStatus.completed) {
                              body = const SizedBox.shrink();
                            } else {
                              body = const SizedBox.shrink();
                            }
                            return Container(
                              height: 55.0,
                              child: Center(child: body),
                            );
                          },
                        ),

                        // header: const WaterDropHeader(), // Giao diện khi kéo xuống
                        footer: CustomFooter(
                          builder: (BuildContext context, LoadStatus? status) {
                            Widget body;
                            if (status == LoadStatus.idle) {
                              body = Text("See more.");
                            } else if (status == LoadStatus.loading) {
                              body = CircularLoadingWidget();
                            } else if (status == LoadStatus.failed) {
                              body = Text(
                                "Load more failed! Please try again.",
                              );
                            } else if (status == LoadStatus.canLoading) {
                              body = Text("Drop to load more data.");
                            } else {
                              body = Text("All items have been loaded.");
                            }
                            return Container(
                              height: 55.0,
                              child: Center(child: body),
                            );
                          },
                        ),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            final monthYear = entry.key;
                            final items = entry.value;

                            // Lấy tổng số từ leavesByMonthYear, fallback về items.length nếu không có
                            final totalLeaves =
                                leaveProviderNotifier
                                    .leavesByMonthYear[monthYear] ??
                                items.length;

                            // Kiểm tra nếu totalLeaves bằng items.length và có khả năng còn dữ liệu
                            final isPotentiallyIncomplete =
                                totalLeaves == items.length &&
                                leaveProviderNotifier.hasMore;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFEEEEEE),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      width: 2,
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        // color: Colors.deepOrange,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '$monthYear ($totalLeaves leave requests)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          // color: Colors.deepOrange.shade700,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...items.map(
                                  (leave) => InkWell(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return DetailLeaveRequest(
                                              leave: leave,
                                            );
                                          },
                                        ),
                                      );

                                      if (result == true) {
                                        ref
                                            .read(leaveProvider.notifier)
                                            .loadLeavesByUserFirstPage(
                                              isRefresh: true,
                                            ); // reload
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 20.0,
                                      ),
                                      child: LeaveHistoryItem(
                                        leave: leave,
                                        selectedItemDate: _selectedItemDate,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Floating Button
          floatingActionButton: Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white.withOpacity(0.1), Colors.white],
              ),
            ),
            child: Row(
              children: [
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 4),
                    gradient: LinearGradient(
                      colors: [
                        // HelpersColors.primaryColor.withOpacity(0.7),
                        // HelpersColors.secondaryColor.withOpacity(0.7),
                        HelpersColors.itemPrimary,
                        HelpersColors.itemPrimary,
                      ], // BoxShadow(
                      //   color: HelpersColors.secondaryColor.withOpacity(0.5),
                      //   blurRadius: 12,
                      //   offset: const Offset(0, 6),
                      //   spreadRadius: 1,
                      // ),
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [],
                  ),
                  child: RawMaterialButton(
                    onPressed: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaveRequestScreen()));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LeaveRequestScreen(),
                        ),
                      ).then((result) {
                        // ✅ Nếu result là true (nghĩa là vừa request thành công), thì load lại
                        if (result == true) {
                          ref
                              .read(leaveProvider.notifier)
                              .loadLeavesByUserFirstPage(isRefresh: true);
                        }
                      });
                    },
                    shape: const CircleBorder(),
                    constraints: const BoxConstraints.tightFor(
                      width: 50,
                      height: 50,
                    ), // 👈 Đảm bảo nút là hình tròn
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [Icon(Icons.add, color: Colors.white)],
                    ),
                  ),
                ),
              ],
            ),
          ),

          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      ),
    );
  }
}

// Widget hiển thị từng đơn nghỉ phép
class LeaveHistoryItem extends StatelessWidget {
  final Leave leave;
  final String selectedItemDate; // Thêm tham số này

  const LeaveHistoryItem({
    super.key,
    required this.leave,
    required this.selectedItemDate, // Thêm vào constructor
  });

  @override
  Widget build(BuildContext context) {
    final totalDaysLeaves =
        leave.endDate.difference(leave.startDate).inDays + 1;

    final color = leave.status == 'Pending'
        ? Colors.orange
        : leave.status == 'Approved'
        ? Color(0xFF00B2BF)
        : Colors.red;

    final icon = leave.status == 'Pending'
        ? Icons.timelapse_rounded
        : leave.status == 'Approved'
        ? Icons.check_circle
        : Icons.close_rounded;

    return IntrinsicHeight(
      child: Row(
        children: [
          Container(width: 2, color: Colors.black.withOpacity(0.3)),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 25, left: 5),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 2),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Row(
                          children: [
                            // Content 1: timer
                            Text(
                              selectedItemDate.contains('Start Date')
                                  ? 'Data sent: '
                                  : 'Time off: ',
                              style: const TextStyle(fontSize: 13),
                            ),

                            if (selectedItemDate.contains('Start Date'))
                              Row(
                                children: [
                                  Text(
                                    '${FormatHelper.formatDate_DD_MM(leave.dateCreated)}',
                                    style: const TextStyle(
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    ' (${FormatHelper.formatTimeHH_MM(leave.dateCreated)})',
                                    style: const TextStyle(
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            if (!selectedItemDate.contains('Start Date'))
                              Row(
                                children: [
                                  Text(
                                    FormatHelper.formatDate_DD_MM(
                                      leave.startDate,
                                    ),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const Text(' - '),
                                  Text(
                                    FormatHelper.formatDate_DD_MM(
                                      leave.endDate,
                                    ),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  // // const Spacer(),
                                  // const Icon(Icons.chevron_right_outlined),
                                ],
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Type: ',
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              '${leave.leaveType}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Duration: ', style: TextStyle(fontSize: 13)),
                            Text(
                              '$totalDaysLeaves day -  ${leave.leaveTimeType}',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -15,
                    left: 15,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        border: Border.all(width: 1, color: Colors.grey),
                        color: Color(0xFFEEEEEE),

                        // color: Color(0xFFDDDDDD).withOpacity(0.5),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 15,
                      ),
                      child: Column(
                        children: [
                          if (!selectedItemDate.contains('Start Date'))
                            Row(
                              children: [
                                Text(
                                  'Data sent: ${FormatHelper.formatDate_DD_MM(leave.dateCreated)}',
                                  style: const TextStyle(
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  ' (${FormatHelper.formatTimeHH_MM(leave.dateCreated)})',
                                  style: const TextStyle(
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          if (selectedItemDate.contains('Start Date'))
                            Row(
                              children: [
                                const Text('Time off: '),
                                Text(
                                  FormatHelper.formatDate_DD_MM(
                                    leave.startDate,
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const Text(' - '),
                                Text(
                                  FormatHelper.formatDate_DD_MM(leave.endDate),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                // // const Spacer(),
                                // const Icon(Icons.chevron_right_outlined),
                              ],
                            ),

                          // Row(
                          //   children: [
                          //     const Text('Time off: '),
                          //     Text(
                          //       FormatHelper.formatDate_DD_MM(leave.startDate),
                          //       style: const TextStyle(fontSize: 12),
                          //     ),
                          //     const Text(' - '),
                          //     Text(
                          //       FormatHelper.formatDate_DD_MM(leave.endDate),
                          //       style: const TextStyle(fontSize: 12),
                          //     ),
                          //     // // const Spacer(),
                          //     // const Icon(Icons.chevron_right_outlined),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(icon, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            leave.status,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (leave.isNew == true)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        // decoration: BoxDecoration(
                        //   color: color,
                        //   borderRadius: const BorderRadius.only(
                        //     topLeft: Radius.circular(10),
                        //   ),
                        // ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'New',
                              style: TextStyle(
                                color: HelpersColors.itemSelected,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: HelpersColors.itemSelected,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
