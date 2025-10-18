import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:daily_manage_user_app/controller/admin/admin_position_controller.dart';
import 'package:daily_manage_user_app/helpers/tools_colors.dart';
import 'package:daily_manage_user_app/providers/admin/admin_position_provider.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/organizational_management/widgets/tab_bar/tab_position/diaglogs/admin_org_tab_position_add_dialog.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/organizational_management/widgets/tab_bar/tab_position/widgets/admin_org_tab_position_item_widget.dart';
import 'package:daily_manage_user_app/widgets/circular_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../../../controller/admin/admin_department_controller.dart';
import '../../../../../../../../models/department.dart';
import '../../../../../../../../models/position.dart';
import '../../../../../../../../widgets/loading_status_bar_widget.dart';
import '../../../../../../../auth_screens/nav_screens/leave/dialogs/confirm_delete_dialog.dart';
import '../../../../../../../common_screens/widgets/top_notification_widget.dart';

enum Actions { edit, delete }

class AdminOrgTabPositionsWidget extends ConsumerStatefulWidget {
  const AdminOrgTabPositionsWidget({super.key});

  @override
  _AdminOrgTabPositionsWidgetState createState() =>
      _AdminOrgTabPositionsWidgetState();
}

class _AdminOrgTabPositionsWidgetState
    extends ConsumerState<AdminOrgTabPositionsWidget>
    with TickerProviderStateMixin {
  List<Department> _departments = [];
  bool _isLoading = true;
  List<RefreshController> _refreshControllers = [];
  TabController? _tabController;
  bool _hasError = false; // Biến theo dõi trạng thái lỗi

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }
  Future<void> _requestDeletePosition(Position position) async {
    final statusDelete = await AdminPositionController()
        .requestDeletePosition(id: position.id);
    if (statusDelete != null) {

      ref.read(adminPositionProvider(position.departmentId).notifier).deletePosition(position.id);
      showTopNotification(
        context: context,
        message: '"${position.positionName}" position deleted successfully',
        type: NotificationType.success,
      );
    } else {
      showTopNotification(
        context: context,
        message: '${position.positionName} position deleted failed',
        type: NotificationType.error,
      );
    }
  }
  Future<void> _loadDepartments() async {
    try {
      final result = await AdminDepartmentController().fetchAllDepartments();
      final List<Department> departments = result['departments'] ?? [];

      if (!mounted) return; // Ngăn gọi setState nếu widget đã bị dispose

      setState(() {
        _departments = departments;
        _refreshControllers = List.generate(
          departments.length,
              (_) => RefreshController(initialRefresh: false),
        );
        _tabController = departments.isNotEmpty
            ? TabController(length: departments.length, vsync: this)
            : null;
        _isLoading = false;
      });

      if (departments.isNotEmpty) {
        ref
            .read(adminPositionProvider(departments[0].id).notifier)
            .fetchPositionsFirstPage();
      }

      if (_tabController != null) {
        _tabController!.addListener(() {
          if (!_tabController!.indexIsChanging && mounted) {
            final dep = _departments[_tabController!.index];
            print("Fetching positions for department: ${dep.name}");
            ref
                .read(adminPositionProvider(dep.id).notifier)
                .fetchPositionsFirstPage();
          }
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      print("Error loading departments: $e");
      // Hiển thị thông báo lỗi (nếu có)
      // showTopNotification(
      //   context: context,
      //   message: 'Failed to load departments: $e',
      //   type: NotificationType.error,
      // );
    }
  }

  Future<void> _onRefresh(int index) async {
    try {
      final dep = _departments[index];
      print("Refreshing positions for department: ${dep.name}");
      await ref
          .read(adminPositionProvider(dep.id).notifier)
          .fetchPositionsFirstPage();
      _refreshControllers[index].refreshCompleted();
    } catch (e) {
      print("Refresh failed: $e");
      _refreshControllers[index].refreshFailed();
      // showTopNotification(
      //   context: context,
      //   message: 'Refresh failed: $e',
      //   type: NotificationType.error,
      // );
    }
  }

  void _onDismissed(int index, Actions action, Position position) {
    switch (action) {
      case Actions.edit:
        showDialog(
          context: context,
          builder: (context) => AdminOrgTabPositionAddDialog(position: position),
        );
        break;
      case Actions.delete:
        showDialog(
          context: context,
          builder: (context) {
            return ConfirmDeleteDialog(
              title: 'Confirm deletion !',
              content:
              'Are you sure you want to delete the \n"${position.positionName}" position?',
              onConfirm: () async {
                _requestDeletePosition(position);

                // Thêm logic xóa position tại đây
                return true;
              },
            );
          },
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị loading nếu đang tải
    if (_isLoading) {
      return const Center(child: CircularLoadingWidget());
    }

    // Hiển thị lỗi nếu có
    if (_hasError) {
      return const Center(child: Text("Failed to load departments"));
    }

    // Hiển thị thông báo nếu không có phòng ban
    if (_departments.isEmpty || _tabController == null) {
      return const Center(child: Text("No departments found"));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ButtonsTabBar(
              controller: _tabController,
              backgroundColor: HelpersColors.itemCard,
              unselectedBackgroundColor: Colors.white,
              unselectedLabelStyle: TextStyle(
                color: HelpersColors.itemCard,
              ),
              labelStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              height: 50,
              tabs: _departments
                  .map(
                    (dep) => Tab(
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(
                      FontAwesomeIcons.buildingUser,
                      size: 16,
                    ),
                  ),
                  text: dep.name,
                ),
              )
                  .toList(),
            ),
            Expanded(
              child: IndexedStack(
                index: _tabController!.index,
                children: _departments.asMap().entries.map((entry) {
                  final index = entry.key;
                  final dep = entry.value;
                  final positionState = ref.watch(adminPositionProvider(dep.id));

                  return SmartRefresher(
                    controller: _refreshControllers[index],
                    enablePullDown: true,
                    // enablePullUp: true,
                    onRefresh: () => _onRefresh(index),
                    // onLoading: () => _onLoading(index), // Bỏ comment nếu kích hoạt lại
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
                          body = const Text("Load more failed! Please try again.");
                        } else if (status == LoadStatus.canLoading) {
                          body = const Text("Drop to load more data.");
                        } else {
                          body = const Text("All items have been loaded.");
                        }
                        return Container(
                          height: 55.0,
                          child: Center(child: body),
                        );
                      },
                    ),
                    child: positionState.when(
                      data: (positions) {
                        if (positions.isEmpty) {
                          return Center(child: Text("No positions in ${dep.name}"));
                        }
                        return ListView.builder(
                          itemCount: positions.length,
                          itemBuilder: (context, index) {
                            final pos = positions[index];
                            return Column(
                              children: [
                                const SizedBox(height: 15),

                                Slidable(
                                  endActionPane: ActionPane(
                                    motion: const BehindMotion(),
                                    children: [
                                      SlidableAction(
                                        backgroundColor: HelpersColors.itemCard,
                                        icon: Icons.edit,
                                        label: 'Edit',
                                        onPressed: (context) {
                                          _onDismissed(index, Actions.edit, pos);
                                        },
                                      ),
                                      SlidableAction(
                                        backgroundColor: HelpersColors.itemSelected,
                                        icon: FontAwesomeIcons.trash,
                                        label: 'Delete',
                                        onPressed: (context) {
                                          _onDismissed(index, Actions.delete, pos);
                                        },
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      AdminOrgTabPositionItemWidget(position: pos),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularLoadingWidget()),
                      error: (err, _) => Center(child: Text("Error: $err")),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    for (var controller in _refreshControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}