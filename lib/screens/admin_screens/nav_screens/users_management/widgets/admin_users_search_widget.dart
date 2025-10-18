import 'package:daily_manage_user_app/helpers/tools_colors.dart';
import 'package:daily_manage_user_app/providers/admin/admin_user_filter_provider.dart';
import 'package:daily_manage_user_app/providers/admin/admin_user_provider.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/users_management/widgets/admin_users_filter_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminUsersSearchWidget extends ConsumerStatefulWidget {
  const AdminUsersSearchWidget({super.key});

  @override
  _AdminUsersSearchWidgetState createState() => _AdminUsersSearchWidgetState();
}

class _AdminUsersSearchWidgetState
    extends ConsumerState<AdminUsersSearchWidget> {
  final TextEditingController _controllerSearch = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controllerSearch.addListener(() {
      setState(() {
        _hasText = _controllerSearch.text.isNotEmpty;

        ref
            .read(adminUserFilterProvider.notifier)
            .setFullName(_controllerSearch.text);
        _reloadData(ref);
      });
    });
  }

  @override
  void dispose() {
    _controllerSearch.dispose();
    super.dispose();
  }

  void _reloadData(WidgetRef ref) {
    final filter = ref.read(adminUserFilterProvider);
    ref
        .read(adminUserProvider.notifier)
        .loadLeavesUserFirstPage(
          isRefresh: true,
          filterFullName: filter.filterFullName,
        );
  }

  // void _showBottomSheetFilter() {
  //   showModalBottomSheet(
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent, // rất quan trọng để không bị viền xám xấu
  //     context: context,
  //     builder: (context) => AdminUsersFilterWidget(),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: HelpersColors.bgFillTextField,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: HelpersColors.itemCard,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Icon(Icons.search, color: Colors.white, size: 20),
                    decoration: BoxDecoration(
                      color: HelpersColors.itemCard,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _controllerSearch,
                      style: TextStyle(color: HelpersColors.itemCard),
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        filled: true,
                        // bật màu nền
                        fillColor: Colors.white,
                        // màu nền trắng
                        hintStyle: TextStyle(color: Colors.grey),
                        isDense: true,
                        // gọn hơn
                        // border: OutlineInputBorder(
                        //   borderRadius: BorderRadius.circular(10),
                        // ),
                        focusedBorder: OutlineInputBorder(
                          // borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: HelpersColors.itemCard),
                        ),
                        enabledBorder: OutlineInputBorder(
                          // borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: HelpersColors.itemCard,
                            width: 1.0,
                          ),
                        ),
                        // prefixIcon: Icon(
                        //   Icons.email,
                        //   color: HelpersColors.itemCard,
                        // ),
                        suffixIcon: _hasText
                            ? IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 25,
                                  color: HelpersColors.itemSelected,
                                ),
                                onPressed: () {
                                  _controllerSearch.clear();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // SizedBox(width: 20),
          // InkWell(
          //   onTap: () {
          //     _showBottomSheetFilter();
          //   },
          //   child: Icon(
          //     Icons.filter_alt_rounded,
          //     color: HelpersColors.itemCard,
          //   ),
          // ),
          // SizedBox(width: 10,)
        ],
      ),
    );
  }
}
