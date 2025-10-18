import 'package:daily_manage_user_app/services/sockets/socket_service.dart';
import 'package:daily_manage_user_app/services/sockets/work_socket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../helpers/tools_colors.dart';
import '../../../../../models/work.dart';
import '../../../../../providers/admin/admin_work_provider.dart';
import '../../../../../widgets/circular_loading_widget.dart';
import 'admin_work_hours_item_widget.dart';
class AdminWorkHoursListWidget extends ConsumerStatefulWidget {
  const AdminWorkHoursListWidget({
    super.key,
    this.startDate,
    this.endDate,
  });
  final DateTime? startDate;
  final DateTime? endDate;
  @override
  _AdminWorkHoursListWidgetState createState() => _AdminWorkHoursListWidgetState();
}

class _AdminWorkHoursListWidgetState extends ConsumerState<AdminWorkHoursListWidget> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  late WorkSocket _workSocket;
  @override
  void initState() {
    super.initState();
    // Tải dữ liệu lần đầu
    // WorkSocket.initSocketConnection();
    // WorkSocket.listenUserUpdateWork((){
    //   ref.read(adminWorkProvider.notifier).loadWorksByUserFirstPage(isRefresh: true);
    // });
    // WorkSocket.listenUserUpdateWork((updatedWorkMap) {
    //   final updatedWork = Work.fromMap(updatedWorkMap);
    //
    //   final works = ref.read(adminWorkProvider).value;
    //   if (works != null && works.any((w) => w.id == updatedWork.id)) {
    //     ref.read(adminWorkProvider.notifier).updateWorkItem(updatedWork);
    //   } else {
    //     // Tuỳ bạn: có thể load lại trang 1 hoặc bỏ qua.
    //     // ref.read(adminWorkProvider.notifier).loadWorksByUserFirstPage(isRefresh: true);
    //   }
    // });
    WorkSocket.listenUserUpdateCheckInWork((workData) {
      // print('Processing work_checkIn data: $workData');
      print('Processing work_checkIn data: $workData'); // Log toàn bộ dữ liệu
      print('User data: ${workData['user']}'); // Log riêng trường user
      final updatedWork = Work.fromMap(workData);
      print('Processed Work: $updatedWork'); // Log đối tượng Work sau khi xử lý
      if (!mounted) return;  // Kiểm tra widget còn tồn tại không
      final currentList = ref.read(adminWorkProvider).value ?? [];
      final exists = currentList.any((w) => w.id == updatedWork.id);
      if (exists) {
        ref.read(adminWorkProvider.notifier).updateWorkItem(updatedWork);
      } else {
        ref.read(adminWorkProvider.notifier).addWorkToTop(updatedWork);
      }
    });
    WorkSocket.listenUserUpdateCheckOutWork((workData) {
      // print('Processing work_checkIn data: $workData');
      print('Processing work_checkOut data: $workData'); // Log toàn bộ dữ liệu
      final updatedWork = Work.fromMap(workData);
      if (!mounted) return;  // Kiểm tra widget còn tồn tại không
      print('Processed Work: $updatedWork'); // Log đối tượng Work sau khi xử lý
      final currentList = ref.read(adminWorkProvider).value ?? [];
      final exists = currentList.any((w) => w.id == updatedWork.id);
      if (exists) {
        ref.read(adminWorkProvider.notifier).updateWorkItem(updatedWork);
      } else {
        ref.read(adminWorkProvider.notifier).addWorkToTop(updatedWork);
      }
    });

    Future.microtask(() {
      ref.read(adminWorkProvider.notifier).loadWorksByUserFirstPage(isRefresh: true);
    });
  }
  // nếu chỉ một ngày được chọn thì không load dữ liệu:
  @override
  void didUpdateWidget(covariant AdminWorkHoursListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Nếu clear filter (cả 2 null)
    final isClearFilter = widget.startDate == null && widget.endDate == null;
    final oldIsClearFilter = oldWidget.startDate == null && oldWidget.endDate == null;

    if (isClearFilter && !oldIsClearFilter) {
      // Load tất cả dữ liệu
      Future.microtask(() {
        ref.read(adminWorkProvider.notifier).loadWorksByUserFirstPage(
          isRefresh: true,
          startDate: null,
          endDate: null,
        );
      });
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
      return;
    }

    // Nếu đã chọn đủ cả start và end date
    final hasBothDates = widget.startDate != null && widget.endDate != null;
    final oldHasBothDates = oldWidget.startDate != null && oldWidget.endDate != null;

    if (hasBothDates &&
        (widget.startDate != oldWidget.startDate || widget.endDate != oldWidget.endDate)) {
      Future.microtask(() {
        ref.read(adminWorkProvider.notifier).loadWorksByUserFirstPage(
          isRefresh: true,
          startDate: widget.startDate,
          endDate: widget.endDate,
        );
      });
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    }
  }

  // @override
  // void didUpdateWidget(covariant AdminWorkHoursListWidget oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.startDate != oldWidget.startDate || widget.endDate != oldWidget.endDate) {
  //     Future.microtask(() {
  //       ref.read(adminWorkProvider.notifier).loadWorksByUserFirstPage(
  //         isRefresh: true,
  //         startDate: widget.startDate,
  //         endDate: widget.endDate,
  //       );
  //     });
  //     _refreshController.refreshCompleted();
  //     _refreshController.loadComplete();
  //   }
  // }

  Future<void> _onRefresh() async {
    try {
      print("Starting refresh...");
      // await ref.read(adminWorkProvider.notifier).loadWorksByUserFirstPage(isRefresh: true);

      await ref.read(adminWorkProvider.notifier).loadWorksByUserFirstPage(
        isRefresh: true,
        startDate: widget.startDate,
        endDate: widget.endDate,
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
    final workNotifier = ref.read(adminWorkProvider.notifier);
    final workAsync = ref.read(adminWorkProvider);

    print("Current hasMore: ${workNotifier.hasMore}, isLoading: ${workAsync.isLoading}");
    if (!workNotifier.hasMore || workAsync.isLoading) {
      print("No more data to load or already loading");
      _refreshController.loadNoData();
      return;
    }

    try {
      print("Starting to load more works...");
      await workNotifier.loadMoreWorks();
      print("Load more completed. hasMore: ${workNotifier.hasMore}, data length: ${workAsync.value?.length}");
      if (workNotifier.hasMore) {
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    } catch (e) {
      print("Error loading more works: $e");
      if (e.toString().contains('404')) {
        print("API 404 error: Endpoint not found or no more data. Check pagination.");
        _refreshController.loadFailed(); // Cho phép thử lại thay vì noMore
      } else {
        _refreshController.loadFailed();
      }
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final workState = ref.watch(adminWorkProvider);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    child: const Icon(Icons.arrow_downward, color: Colors.white));
              } else

              if (status == RefreshStatus.refreshing) {
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
          child: workState.when(
            loading: () => const Center(child: CircularLoadingWidget()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (works) => works.isEmpty
                ? const Center(child: Text('No work hours found'))
                : ListView.builder(
                          // controller: _scrollController,
                          itemCount: works.length, // +1 để hiển thị loading khi tải thêm
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
                    AdminWorkHoursItemWidget(work: works[index]),
                    SizedBox(height: 16,)
                  ],
                );
                          },
                        ),
          ),
        ),
      ),
    );
  }
}
