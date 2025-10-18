import 'package:daily_manage_user_app/models/leave.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/leaves_management/widgets/screens/admin_detail_leave_screen.dart';
import 'package:daily_manage_user_app/services/sockets/leave_socket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../helpers/tools_colors.dart';
import '../../../../../providers/admin/admin_leave_filter_provider.dart';
import '../../../../../providers/admin/admin_leave_provider.dart';
import '../../../../../providers/admin/admin_work_provider.dart';
import '../../../../../widgets/circular_loading_widget.dart';
import 'admin_leave_item_widget.dart';

class AdminLeavesWidget extends ConsumerStatefulWidget {
  const AdminLeavesWidget({super.key});

  @override
  _AdminLeavesWidgetState createState() => _AdminLeavesWidgetState();
}

class _AdminLeavesWidgetState extends ConsumerState<AdminLeavesWidget> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    LeaveSocket.listenNewLeaveRequest((leaveData) {
      // print('Processing work_checkIn data: $workData');
      print('Processing leave_request data: $leaveData'); // Log toàn bộ dữ liệu
      print('User data: ${leaveData['user']}'); // Log riêng trường user
      final newLeave = Leave.fromMap(leaveData);
      print('Processed Leave: $newLeave'); // Log đối tượng Work sau khi xử lý
      if (!mounted) return;  // Kiểm tra widget còn tồn tại không

      final currentList = ref.read(adminLeaveProvider).value ?? [];

      final exists = currentList.any((w) => w.id == newLeave.id);
      if (exists) {
        ref.read(adminLeaveProvider.notifier).updateLeaveItem(newLeave);
      } else {
        ref.read(adminLeaveProvider.notifier).addLeaveToTop(newLeave);
      }
    });

    Future.microtask(() {
      ref
          .read(adminLeaveProvider.notifier)
          .loadLeavesUserFirstPage(isRefresh: true);
    });

  }

  Future<void> _onRefresh() async {
    try {
      final filter = ref.watch(adminLeaveFilterProvider);
      print("Starting refresh...");
      // await ref.read(adminWorkProvider.notifier).loadWorksByUserFirstPage(isRefresh: true);

      // CẬP NHẬT: Truyền tham số lọc từ dropdown
      // String sortField = filter.sortField.contains('Start Date')
      //     ? 'startDate'
      //     : 'dateCreated';
      // String sortOrder = filter.sortOrder.contains('asc') ? 'asc' : 'desc';
      // int filterYear = filter.filterYear == DateTime.now().year
      //     ? DateTime.now().year
      //     : filter.filterYear;
      //
      // String status = filter.status.toLowerCase() == 'status all'
      //     ? 'all'
      //     : filter.status.toLowerCase();
      //
      // await ref
      //     .read(adminLeaveProvider.notifier)
      //     .loadLeavesUserFirstPage(
      //       isRefresh: true,
      //       filterYear: filterYear,
      //       sortField: sortField,
      //       sortOrder: sortOrder,
      //       status: status,
      //       // startDate: widget.startDate,
      //       // endDate: widget.endDate,
      //     );
      ref.read(adminLeaveProvider.notifier).loadLeavesUserFirstPage(
        isRefresh: true,
        filterYear: filter.filterYear,
        sortField: filter.sortField,
        sortOrder: filter.sortOrder,
        status: filter.status,
      );
      print("Refresh completed");
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    } catch (e, stackTrace) {
      print("Refresh failed: $e");
      _refreshController.refreshFailed();
    }
  }

  Future<void> _onLoading() async {
    final leaveNotifier = ref.read(adminLeaveProvider.notifier);
    final leaveAsync = ref.read(adminLeaveProvider);

    print(
      "Current hasMore: ${leaveNotifier.hasMore}, isLoading: ${leaveAsync.isLoading}",
    );
    if (!leaveNotifier.hasMore || leaveAsync.isLoading) {
      print("No more data to load or already loading");
      _refreshController.loadNoData();
      return;
    }

    try {
      print("Starting to load more works...");
      await leaveNotifier.loadMoreLeaves();
      print(
        "Load more completed. hasMore: ${leaveNotifier.hasMore}, data length: ${leaveAsync.value?.length}",
      );
      if (leaveNotifier.hasMore) {
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    } catch (e) {
      print("Error loading more works: $e");
      if (e.toString().contains('404')) {
        print(
          "API 404 error: Endpoint not found or no more data. Check pagination.",
        );
        _refreshController.loadFailed(); // Cho phép thử lại thay vì noMore
      } else {
        _refreshController.loadFailed();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaveState = ref.watch(adminLeaveProvider);
    ref.listen(adminLeaveFilterProvider, (previous, next) {
      // Mỗi lần filter đổi thì auto refresh
      _onRefresh();
    });
    return Expanded(
      child: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
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
                child: const Icon(Icons.arrow_downward, color: Colors.white),
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
            return Container(height: 55.0, child: Center(child: body));
          },
        ),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? status) {
            print("Footer status: $status");
            Widget body;
            if (status == LoadStatus.idle) {
              body = const Text("See more.");
            } else if (status == LoadStatus.loading) {
              body = CircularLoadingWidget();
            } else if (status == LoadStatus.failed) {
              body = GestureDetector(
                onTap: _onLoading,
                child: const Text("Load more failed! Please try again."),
              );
            } else if (status == LoadStatus.canLoading) {
              body = const Text("Drop to load more data.");
            } else {
              body = const Text("All items have been loaded.");
            }
            return Container(
              height: 55.0, // Tăng chiều cao để hiển thị tốt hơn
              // padding: const EdgeInsets.all(16.0),
              // margin: EdgeInsets.only(bottom: 40),
              child: Center(child: body),
            );
          },
        ),
        child: leaveState.when(
          loading: () => const Center(child: CircularLoadingWidget()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (leaves) => leaves.isEmpty
              ? const Center(child: Text('No leave found'))
              : ListView.builder(
                  // controller: _scrollController,
                  itemCount:
                      leaves.length, // +1 để hiển thị loading khi tải thêm
                  itemBuilder: (context, index) {
                    // print('length list works: ${works.length}');
                    // if (index == works.length) {
                    //   return ref.read(adminWorkProvider.notifier).hasMore
                    //       ? const Padding(
                    //     padding: EdgeInsets.all(8.0),
                    //     child: Center(child: CircularLoadingWidget()),
                    //   )
                    //       : const SizedBox.shrink();
                    // }
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return AdminDetailLeaveScreen(
                                    leave: leaves[index],
                                  );
                                },
                              ),
                            );
                          },
                          child: AdminLeaveItemWidget(leave: leaves[index]),
                        ),
                        SizedBox(height: 16),
                      ],
                    );
                  },
                ),
        ),
        // onLoading: _onLoading,
      ),
    );
  }
}
