import 'package:daily_manage_user_app/helpers/format_helper.dart';
import 'package:daily_manage_user_app/helpers/tools_colors.dart';
import 'package:daily_manage_user_app/providers/user_provider.dart';
import 'package:daily_manage_user_app/providers/work_provider.dart';
import 'package:daily_manage_user_app/screens/auth_screens/nav_screens/home/screens/detail_work_screen.dart';
import 'package:daily_manage_user_app/widgets/circular_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TodoListTableWidget extends ConsumerStatefulWidget {
  const TodoListTableWidget({super.key});

  @override
  _TodoListTableWidgetState createState() => _TodoListTableWidgetState();
}

class _TodoListTableWidgetState extends ConsumerState<TodoListTableWidget> {
  String _filterValue = '';
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  // Lưu trạng thái khi cuộn.
  final ScrollController _scrollController = ScrollController();
  final String _scrollPositionKey = 'work_list_scroll_position';
  // Lưu vị trí cuộn vào Hive
  void _saveScrollPosition() async {
    final box = Hive.box('appSettingsBoxWork'); // Box riêng để lưu cài đặt
    await box.put(_scrollPositionKey, _scrollController.offset);
  }

  // Khôi phục vị trí cuộn từ Hive
  void _restoreScrollPosition() async {
    final box = Hive.box('appSettingsBoxWork');
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



  Future<void> _onRefresh() async {
    try {
      print("Starting refresh...");
      await ref.read(workProvider.notifier).loadWorksByUserFirstPage(isRefresh: true);
      print("Refresh completed");
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    } catch (e, stackTrace) {
      print("Refresh failed: $e");
      _refreshController.refreshFailed();
    }
  }

  // Future<void> _onLoading() async {
  //   final workNotifier = ref.read(workProvider.notifier);
  //   final workAsync = ref.read(workProvider);
  //
  //   if (!workNotifier.hasMore || workAsync.isLoading) {
  //     print("No more data to load or already loading. hasMore: ${workNotifier.hasMore}");
  //     _refreshController.loadNoData();
  //     return;
  //   }
  //
  //   try {
  //     print("Starting to load more works...");
  //     await workNotifier.loadMoreWorks();
  //     // print("Load more completed. hasMore: ${workNotifier.hasMore}, LoadStatus: ${_refreshController.loadStatus}");
  //     if (workNotifier.hasMore) {
  //       _refreshController.loadComplete();
  //     } else {
  //       _refreshController.loadNoData();
  //     }
  //   } catch (e, stackTrace) {
  //     print("Error loading more works: $e");
  //     _refreshController.loadFailed();
  //   }
  // }
  Future<void> _onLoading() async {
    final workNotifier = ref.read(workProvider.notifier);
    final workAsync = ref.read(workProvider);

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
  void initState() {
    // // Thêm listener để lưu vị trí cuộn khi cuộn
    // _scrollController.addListener(_saveScrollPosition);
    //
    // // Khôi phục vị trí cuộn sau khi widget được khởi tạo
    // _restoreScrollPosition();

    super.initState();Future.microtask(() {
      print("Initializing data load...");
      ref.read(workProvider.notifier).loadWorksByUserFirstPage(isRefresh: false);
    });
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final workAsync = ref.watch(workProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
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
                // padding: const EdgeInsets.only(bottom: 16.0), // Thêm padding dưới để cách xa mép
                child: workAsync.when(
                  loading: () => const Center(child: CircularLoadingWidget()),
                  error: (err, _) => Center(child: Text('Error loading data: $err')),
                  data: (workList) {
                    if (workList.isEmpty) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.75 - 32, // Điều chỉnh để phù hợp
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
                                const SizedBox(height: 20),
                                Text(
                                  "No Work Yet",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 30),
                                  child: Text(
                                    _filterValue == 'All'
                                        ? "You have no work record."
                                        : "You have not joined any job yet.",
                                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final filteredWorkList = workList;

                    return ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      itemCount: filteredWorkList.length + 1, // Chỉ bao gồm header
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            children: [
                              if (filteredWorkList.isNotEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [HelpersColors.primaryColor, HelpersColors.secondaryColor],
                                    ),
                                    border: Border.all(color: Colors.white),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  child: const Row(
                                    children: [
                                      Expanded(flex: 1, child: Center(child: Text("No.", style: _headerStyle))),
                                      Expanded(flex: 2, child: Center(child: Text("Date", style: _headerStyle))),
                                      Expanded(flex: 4, child: Center(child: Text("Working Time", style: _headerStyle))),
                                      Expanded(flex: 2, child: Center(child: Text("Hours", style: _headerStyle))),
                                      Expanded(flex: 2, child: Center(child: Text("Details", style: _headerStyle))),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        }

                        final item = filteredWorkList[index - 1];
                        final checkIn = item.checkInTime.toLocal();
                        final checkOut = item.checkOutTime!.toLocal();
                        final duration = item.workTime;

                        String formatDate(DateTime date) =>
                            "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
                        String formatTimeRange(DateTime start, DateTime end) {
                          String f(DateTime d) => "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
                          return "${f(start)} – ${f(end)}";
                        }
                        String formatDuration(Duration d) {
                          String twoDigits(int n) => n.toString().padLeft(2, '0');
                          return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}";
                        }

                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              child: Row(
                                children: [
                                  Expanded(flex: 1, child: Center(child: Text("${index}."))),
                                  Expanded(
                                    flex: 2,
                                    child: Center(child: Text(formatDate(checkIn), style: const TextStyle(fontSize: 12))),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Center(
                                      child: Text(formatTimeRange(checkIn, checkOut), style: const TextStyle(fontSize: 12)),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: Text(
                                        formatDuration(duration!),
                                        style: TextStyle(
                                          color: HelpersColors.itemSelected,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DetailWorkScreen(
                                                onConfirm: () {},
                                                work: item,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "View",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: HelpersColors.itemPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 0),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
);