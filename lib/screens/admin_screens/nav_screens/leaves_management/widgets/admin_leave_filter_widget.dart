import 'package:daily_manage_user_app/providers/admin/admin_leave_filter_provider.dart';
import 'package:daily_manage_user_app/providers/admin/admin_leave_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../helpers/tools_colors.dart';
class AdminLeaveFilterWidget extends ConsumerStatefulWidget {
  const AdminLeaveFilterWidget( {super.key});

  @override
  _AdminLeaveFilterWidgetState createState() => _AdminLeaveFilterWidgetState();
}

class _AdminLeaveFilterWidgetState extends ConsumerState<AdminLeaveFilterWidget> {
  String _selectedItemDate = 'Start Date desc';
  final List<String> _itemsDropdownDate = [
    'Start Date desc',
    'Start Date asc',
    'Sent Date desc',
    'Sent Date asc',
  ];

  String _selectedItemStatus = 'Status All';
  final List<String> _itemsDropdownStatus = [
    'Status All',
    'Pending',
    'Approved',
    'Rejected',
  ];

  int selectedYear = DateTime.now().year;
  //
  // void _reloadData(WidgetRef ref) {
  //   final filter = ref.read(adminLeaveFilterProvider);
  //   ref.read(adminLeaveProvider.notifier).loadLeavesUserFirstPage(
  //     isRefresh: true,
  //     filterYear: filter.filterYear,
  //     sortField: filter.sortField,
  //     sortOrder: filter.sortOrder,
  //     status: filter.status,
  //   );
  // }

  Widget _buildDropdownDate() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: HelpersColors.itemPrimary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        height: 36,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedItemDate,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down),
            onChanged: (String? newValue) {
              setState(() {
                _selectedItemDate = newValue!;

                // CẬP NHẬT: Gọi lại API với bộ lọc mới
                String sortField = newValue.contains('Start Date')
                    ? 'startDate'
                    : 'dateCreated';
                String sortOrder = newValue.contains('asc') ? 'asc' : 'desc';

                ref.read(adminLeaveFilterProvider.notifier)
                    .setSort(sortField, sortOrder);
                // _reloadData(ref);
                // _refreshController.refreshCompleted();
                // _refreshController.loadComplete();
              });
            },
            items: _itemsDropdownDate.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Container(
                  color: value == _selectedItemDate
                      ? HelpersColors.itemTextField // Màu nền khi được chọn
                      : Colors.transparent, // Màu nền bình thường
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    child: Row(
                      children: [
                        // const Icon(
                        //   Icons.calendar_today,
                        //   size: 18,
                        //   color: Colors.blue,
                        // ),
                        const SizedBox(width: 8),
                        Text(value,style: TextStyle(
                            color: value == _selectedItemDate
                                ? Colors.white : Colors.black.withOpacity(0.7),
                          fontSize: 14
                        ),
                        ),
                      ],
                    ),
                  ),
                ),
                // child: Container(
                //   color: value == _selectedItemDate
                //       ? HelpersColors.itemTextField // Màu nền khi được chọn
                //       : Colors.transparent, // Màu nền bình thường
                //   child: Row(
                //     children: [
                //       // const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                //       // const SizedBox(width: 8),
                //       Text(value, style: TextStyle(
                //       color: value == _selectedItemDate
                //           ? Colors.white : Colors.black.withOpacity(0.7)
                //       ),),
                //     ],
                //   ),
                // ),
              );
            }).toList(),
            selectedItemBuilder: (context) => _itemsDropdownDate.map((value) {
              return Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(value, style: TextStyle(fontSize: 14),),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: HelpersColors.itemPrimary),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: SizedBox(
        height: 36,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedItemStatus,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down),
            onChanged: (String? newValue) {
              setState(() {
                _selectedItemStatus = newValue!;

                // // CẬP NHẬT: Gọi lại API với bộ lọc mới
                // String sortField = _selectedItemDate.contains('Start Date')
                //     ? 'startDate'
                //     : 'dateCreated';
                // String sortOrder = _selectedItemDate.contains('asc')
                //     ? 'asc'
                //     : 'desc';
                ref.read(adminLeaveFilterProvider.notifier)
                    .setStatus(newValue.toLowerCase() == 'status all' ? 'all' : newValue);
                // _reloadData(ref);
                // ref
                //     .read(adminLeaveProvider.notifier)
                //     .loadLeavesUserFirstPage(
                //   isRefresh: true,
                //   filterYear: selectedYear,
                //   sortField: sortField,
                //   sortOrder: sortOrder,
                //   status: newValue.toLowerCase() == 'status all'
                //       ? 'all'
                //       : newValue,
                // );
                // _refreshController.refreshCompleted();
                // _refreshController.loadComplete();
              });
            },
            items: _itemsDropdownStatus.map((String value) {
              Icon icon;

              switch (value.toLowerCase()) {
                case 'pending':
                  icon = const Icon(
                    Icons.hourglass_empty,
                    color: Colors.orange,
                    size: 18,
                  );
                  break;
                case 'approved':
                  icon = Icon(
                    Icons.check_circle,
                    // color: Color(0xFF00B2BF),
                    color: HelpersColors.itemCard,
                    size: 18,
                  );
                  break;
                case 'rejected':
                  icon = const Icon(Icons.cancel, color: Colors.red, size: 18);
                  break;
                default: // "Tất cả trạng thái" hoặc không khớp
                  icon = const Icon(
                    Icons.filter_list,
                    color: Colors.grey,
                    size: 18,
                  );
              }

              return DropdownMenuItem<String>(
                value: value,
                child: Container(
                  color: value == _selectedItemStatus
                      ? HelpersColors.itemTextField // Màu nền khi được chọn
                      : Colors.transparent, // Màu nền bình thường
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    child: Row(
                      children: [
                        // const Icon(
                        //   Icons.calendar_today,
                        //   size: 18,
                        //   color: Colors.blue,
                        // ),
                        const SizedBox(width: 8),
                        Text(value,style: TextStyle(
                            color: value == _selectedItemStatus
                                ? Colors.white : Colors.black.withOpacity(0.7),
                          fontSize: 14
                        ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            // selectedItemBuilder: (BuildContext context) {
            //   return _itemsDropdownStatus.map((String value) {
            //     return Row(
            //       children: [
            //         const Icon(
            //           Icons.calendar_today,
            //           size: 18,
            //           color: Colors.blue,
            //         ),
            //         const SizedBox(width: 8),
            //         Text(value),
            //       ],
            //     );
            //   }).toList();
            // },
            selectedItemBuilder: (BuildContext context) {
              return _itemsDropdownStatus.map((String value) {
                Icon icon;

                switch (value.toLowerCase()) {
                  case 'pending':
                    icon = const Icon(
                      Icons.hourglass_empty,
                      color: Colors.orange,
                      size: 18,
                    );
                    break;
                  case 'approved':
                    icon = Icon(
                      Icons.check_circle,
                      // color: Color(0xFF00B2BF),
                      color: HelpersColors.itemCard,
                      size: 18,
                    );
                    break;
                  case 'rejected':
                    icon = const Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 18,
                    );
                    break;
                  default:
                    icon = const Icon(
                      Icons.filter_list,
                      color: Colors.grey,
                      size: 18,
                    );
                }

                return Row(
                  children: [icon, const SizedBox(width: 8), Text(value, style: TextStyle(fontSize: 14),)],
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownYear() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: HelpersColors.itemPrimary),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: SizedBox(
        height: 36,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: selectedYear,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedYear = newValue;

                  // // CẬP NHẬT: Gọi lại API với bộ lọc mới
                  // String sortField = _selectedItemDate.contains('Start Date')
                  //     ? 'startDate'
                  //     : 'dateCreated';
                  // String sortOrder = _selectedItemDate.contains('asc')
                  //     ? 'asc'
                  //     : 'desc';
                  // ref
                  //     .read(adminLeaveProvider.notifier)
                  //     .loadLeavesUserFirstPage(
                  //   isRefresh: true,
                  //   filterYear: newValue,
                  //   sortField: sortField,
                  //   sortOrder: sortOrder,
                  //   status:
                  //   _selectedItemStatus.toLowerCase() == 'status all'
                  //       ? 'all'
                  //       : _selectedItemStatus,
                  // );
                  ref.read(adminLeaveFilterProvider.notifier).setYear(newValue);
                  // ref.read(adminLeaveFilterProvider.notifier).updateYear(value);

                  // _reloadData(ref);
                  // // Gọi API dùng filter từ provider
                  // final filter = ref.read(adminLeaveFilterProvider);
                  // ref.read(adminLeaveProvider.notifier).loadLeavesUserFirstPage(
                  //   isRefresh: true,
                  //   year: filter.year,
                  //   sortField: filter.sortField,
                  //   sortOrder: filter.sortOrder,
                  //   status: filter.status,
                  // );

                  // _refreshController.refreshCompleted();
                  // _refreshController.loadComplete();
                });
              }
            },
            items: List.generate(10, (index) {
              final year = DateTime.now().year + 1 - index;
              return DropdownMenuItem<int>(
                value: year,
                child: Container(
                  width: double.infinity,
                  color: year == selectedYear
                      ? HelpersColors.itemTextField // Màu nền khi được chọn
                      : Colors.transparent, // Màu nền bình thường
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // const Icon(
                        //   Icons.calendar_today,
                        //   size: 18,
                        //   color: Colors.blue,
                        // ),
                        // const SizedBox(width: 8),
                        Text('$year',style: TextStyle(
                            color: year == selectedYear
                                ? Colors.white : Colors.black.withOpacity(0.7)
                        ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            selectedItemBuilder: (BuildContext context) {
              return List.generate(10, (index) {
                final year = DateTime.now().year + 1 - index;
                return Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 18,
                      color: HelpersColors.itemPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text('$year', style: TextStyle(fontSize: 14)),
                  ],
                );
              });
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(adminLeaveFilterProvider);
    final notifier = ref.read(adminLeaveFilterProvider.notifier);

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: HelpersColors.bgFillTextField,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
          SizedBox(width: 10),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: HelpersColors.itemTextField.withOpacity(0.3),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Icon(
              Icons.filter_alt_rounded,
              color: HelpersColors.itemPrimary,
            ),
          ),
        ],
      ),
      // child: Row(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     // AnimatedContainer để điều khiển chiều rộng một cách linh hoạt
      //     Flexible(
      //       child: AnimatedContainer(
      //         duration: const Duration(milliseconds: 300),
      //         curve: Curves.easeOut,
      //         // Khi _isFilterVisible là false, width = 0.
      //         // Khi _isFilterVisible là true, width sẽ là chiều rộng tối đa còn lại.
      //         // Nếu không muốn dùng chiều rộng vô cực, bạn có thể đặt một giá trị cụ thể ở đây
      //         width: _isFilterVisible ? MediaQuery.of(context).size.width - 60 - 10 : 0, // 60 = 40 (icon) + 10 (SizedBox)
      //         child: SingleChildScrollView(
      //           scrollDirection: Axis.horizontal,
      //           reverse: true, // Đảm bảo cuộn từ phải sang
      //           child: Row(
      //             mainAxisAlignment: MainAxisAlignment.end,
      //             children: [
      //               IntrinsicWidth(child: _buildDropdownDate()),
      //               const SizedBox(width: 10),
      //               IntrinsicWidth(child: _buildDropdownStatus()),
      //               const SizedBox(width: 10),
      //               IntrinsicWidth(child: _buildDropdownYear()),
      //               const SizedBox(width: 10), // Thêm SizedBox để tạo khoảng cách
      //             ],
      //           ),
      //         ),
      //       ),
      //     ),
      //
      //     // Đảm bảo có một SizedBox giữa bộ lọc và icon
      //     const SizedBox(width: 10),
      //
      //     // Icon lọc, được bọc trong GestureDetector để bắt sự kiện chạm
      //     GestureDetector(
      //       onTap: () {
      //         setState(() {
      //           _isFilterVisible = !_isFilterVisible; // Đảo ngược trạng thái
      //         });
      //       },
      //       child: Container(
      //         height: 40,
      //         width: 40,
      //         decoration: BoxDecoration(
      //           color: HelpersColors.itemTextField.withOpacity(0.3),
      //           borderRadius: const BorderRadius.all(Radius.circular(10)),
      //         ),
      //         child: Icon(
      //           Icons.filter_alt_rounded,
      //           color: HelpersColors.itemPrimary,
      //         ),
      //       ),
      //     ),
      //   ],
      // )
    );
    ;
  }
}
