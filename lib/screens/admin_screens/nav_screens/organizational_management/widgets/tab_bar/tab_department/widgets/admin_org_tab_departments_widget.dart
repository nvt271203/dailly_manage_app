import 'package:daily_manage_user_app/controller/admin/admin_department_controller.dart';
import 'package:daily_manage_user_app/models/department.dart';
import 'package:daily_manage_user_app/providers/admin/admin_department_provider.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/organizational_management/widgets/tab_bar/widgets/admin_org_title_center_widget.dart';
import 'package:daily_manage_user_app/screens/auth_screens/nav_screens/leave/dialogs/confirm_delete_dialog.dart';
import 'package:daily_manage_user_app/screens/common_screens/widgets/loading_circle_white_default_widget.dart';
import 'package:daily_manage_user_app/screens/common_screens/widgets/top_notification_widget.dart';
import 'package:daily_manage_user_app/widgets/loading_status_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../../../../../helpers/tools_colors.dart';
import '../../../../../../../../widgets/circular_loading_widget.dart';
import '../dialogs/admin_org_tab_department_add_diaglog.dart';
import 'admin_org_tab_department_item_widget.dart';

enum Actions { edit, delete }

class AdminOrgTabDepartmentsWidget extends ConsumerStatefulWidget {
  const AdminOrgTabDepartmentsWidget({super.key});

  @override
  _AdminOrgTabDepartmentsWidgetState createState() =>
      _AdminOrgTabDepartmentsWidgetState();
}

class _AdminOrgTabDepartmentsWidgetState
    extends ConsumerState<AdminOrgTabDepartmentsWidget> {
  int? editingIndex; // 🔑 lưu index đang edit
  String? originalContent;
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      ref
          .read(adminDepartmentProvider.notifier)
          .fetchDepartmentsFirstPage(isRefresh: true);
    });
  }

  void _onDismissed(int index, Actions action, Department department) {
    switch (action) {
      case Actions.edit:
        showDialog(
          context: context,
          builder: (context) =>
              AdminOrgTabDepartmentAddDialog(departmentItem: department),
        );
        // showDialog(
        //   context: context,
        //   barrierDismissible: false, // có thể true nếu muốn bấm ra ngoài để thoát
        //   builder: (context) {
        //     return Dialog(
        //       child: AdminOrgTabDepartmentAddDialog(
        //         department: department,
        //       ),
        //     );
        //   },
        // );
        ;
        break;
      case Actions.delete:
        showDialog(
          context: context,
          builder: (context) {
            return ConfirmDeleteDialog(
              title: 'Confirm deletion !',
              content:
                  'Are you sure you want to delete the\n" ${department.name}" department?',
              onConfirm: () async{
                _requestDeleteDepartment(department);
                return true;
              },
            );
          },
        );

        // showTopNotification(
        //   context: context,
        //   message: 'User ${user.fullName} has been deleted',
        //   type: NotificationType.success,
        // );
        break;
    }
  }

  Future<void> _requestDeleteDepartment(Department department) async {
    final statusDelete = await AdminDepartmentController()
        .requestDeleteDepartment(idDepartment: department.id);
    if (statusDelete != null) {
      ref
          .read(adminDepartmentProvider.notifier)
          .deleteDepartment(department.id);
      showTopNotification(
        context: context,
        message: '${department.name} department deleted successfully',
        type: NotificationType.success,
      );
    } else {
      showTopNotification(
        context: context,
        message: '${department.name} department deleted failed',
        type: NotificationType.error,
      );
    }
  }

  Future<void> _onRefresh() async {
    try {
      print("Starting refresh...");
      ref
          .read(adminDepartmentProvider.notifier)
          .fetchDepartmentsFirstPage(isRefresh: true);
      print("Refresh completed");
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    } catch (e, stackTrace) {
      print("Refresh failed: $e");
      _refreshController.refreshFailed();
    }
  }

  Future<void> _onLoading() async {
    final departmentNotifier = ref.read(adminDepartmentProvider.notifier);
    final departmentAsync = ref.read(adminDepartmentProvider);

    print(
      "Current hasMore: ${departmentNotifier.hasMore}, isLoading: ${departmentAsync.isLoading}",
    );
    if (!departmentNotifier.hasMore || departmentAsync.isLoading) {
      print("No more data to load or already loading");
      _refreshController.loadNoData();
      return;
    }

    try {
      print("Starting to load more departments...");
      await departmentNotifier.loadMoreDepartments();
      print(
        "Load more completed. hasMore: ${departmentNotifier.hasMore}, data length: ${departmentAsync.value?.length}",
      );
      if (departmentNotifier.hasMore) {
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
    final departmentState = ref.watch(adminDepartmentProvider);

    return Expanded(
      child: Column(
        children: [
          SizedBox(height: 20),
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
                    body = LoadingStatusBarWidget();
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
              child: departmentState.when(
                loading: () => const Center(child: CircularLoadingWidget()),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (departments) => departments.isEmpty
                    ? const Center(child: Text('No department found'))
                    : ListView.builder(
                        // controller: _scrollController,
                        itemCount: departments
                            .length, // +1 để hiển thị loading khi tải thêm
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Slidable(
                                endActionPane: ActionPane(
                                  motion: BehindMotion(),
                                  children: [
                                    SlidableAction(
                                      backgroundColor: HelpersColors.itemCard,
                                      icon: Icons.edit,
                                      label: 'Edit',
                                      onPressed: (context) {
                                        _onDismissed(
                                          index,
                                          Actions.edit,
                                          departments[index],
                                        );
                                      },
                                    ),
                                    SlidableAction(
                                      backgroundColor:
                                          HelpersColors.itemSelected,
                                      icon: FontAwesomeIcons.trash,
                                      label: 'Delete',
                                      onPressed: (context) {
                                        _onDismissed(
                                          index,
                                          Actions.delete,
                                          departments[index],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                child: AdminOrgTabDepartmentItemWidget(
                                  department: departments[index],
                                ),
                              ),
                              SizedBox(height: 15),
                            ],
                          );
                          // return Column(
                          //   children: [
                          //     InkWell(
                          //       onTap: () {
                          //         Navigator.push(
                          //           context,
                          //           MaterialPageRoute(
                          //             builder: (context) {
                          //               return AdminDetailLeaveScreen(
                          //                 leave: leaves[index],
                          //               );
                          //             },
                          //           ),
                          //         );
                          //       },
                          //       child: AdminLeaveItemWidget(leave: leaves[index]),
                          //     ),
                          //     SizedBox(height: 16),
                          //   ],
                          // );
                        },
                      ),
              ),
              // onLoading: _onLoading,
            ),
          ),
        ],
      ),
    );
  }
}
