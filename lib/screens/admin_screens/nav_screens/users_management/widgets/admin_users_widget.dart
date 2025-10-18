import 'package:daily_manage_user_app/controller/admin/admin_user_controller.dart';
import 'package:daily_manage_user_app/providers/admin/admin_user_provider.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/users_management/widgets/admin_user_item_widget.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/users_management/widgets/screens/admin_information_user_screen.dart';
import 'package:daily_manage_user_app/screens/common_screens/widgets/top_notification_widget.dart';
import 'package:daily_manage_user_app/widgets/dialog_confirm_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../../helpers/tools_colors.dart';
import '../../../../../models/user.dart';
import '../../../../../widgets/circular_loading_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../auth_screens/nav_screens/leave/dialogs/confirm_delete_dialog.dart';

enum Actions { detail, resigned, retained }

class AdminUsersWidget extends ConsumerStatefulWidget {
  const AdminUsersWidget({super.key});

  @override
  _AdminUsersWidgetState createState() => _AdminUsersWidgetState();
}

class _AdminUsersWidgetState extends ConsumerState<AdminUsersWidget> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      ref
          .read(adminUserProvider.notifier)
          .loadLeavesUserFirstPage(isRefresh: true);
    });
  }

  Future<void> _onRefresh() async {
    try {
      print("Starting refresh...");
      // await ref.read(adminWorkProvider.notifier).loadWorksByUserFirstPage(isRefresh: true);

      await ref
          .read(adminUserProvider.notifier)
          .loadLeavesUserFirstPage(
            isRefresh: true,
            // startDate: widget.startDate,
            // endDate: widget.endDate,
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
    final userNotifier = ref.read(adminUserProvider.notifier);
    final userAsync = ref.read(adminUserProvider);

    print(
      "Current hasMore: ${userNotifier.hasMore}, isLoading: ${userAsync.isLoading}",
    );
    if (!userNotifier.hasMore || userAsync.isLoading) {
      print("No more data to load or already loading");
      _refreshController.loadNoData();
      return;
    }

    try {
      print("Starting to load more works...");
      await userNotifier.loadMoreUsers();
      print(
        "Load more completed. hasMore: ${userNotifier.hasMore}, data length: ${userAsync.value?.length}",
      );
      if (userNotifier.hasMore) {
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
  Future<void> _requestUpdateUser(User user, bool statusUser) async {
    final statusUpdate = await AdminUserController()
        .requestUpdateStatusUser(id: user.id, status: statusUser);
    if (statusUpdate != null) {

      ref.read(adminUserProvider.notifier).updateUser(statusUpdate);
      showTopNotification(
        context: context,
        message: 'The user has been update successfully !',
        type: NotificationType.success,
      );
    } else {
      showTopNotification(
        context: context,
        message: 'The user has been deleted failed !',
        type: NotificationType.error,
      );
    }
  }
  void _onDismissed(int index, Actions action, User user) {
    switch (action) {
      case Actions.detail:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AdminInformationUserScreen(user: user);
            },
          ),
        );
        break;
      case Actions.resigned:
        showDialog(
          context: context,
          builder: (context) {
            return ConfirmDeleteDialog(
              title: 'Confirm resigned !',
              content:
                  user.fullName != null && user.fullName != '' ?
              'Are you sure you want to resigned the \n"${user.fullName}" user?' :
                  'Are you sure you want to \n delete the user with email "${user.email}"'
              ,
              onConfirm: () async {
                _requestUpdateUser(user, false);

                // Thêm logic xóa position tại đây
                return true;
              },
            );
          },
        );
        break;
      case Actions.retained:
        showDialog(
          context: context,
          builder: (context) {
            return DialogConfirmWidget(
              title: 'Confirm Retained !',
              content:
              user.fullName != null && user.fullName != '' ?
              'Are you sure you want to Retained the \n"${user.fullName}" user?' :
              'Are you sure you want to \n Retained the user with email "${user.email}"'
              ,
              onConfirm: () async {
                _requestUpdateUser(user, true);
                Navigator.pop(context);
                // Thêm logic xóa position tại đây
              },
            );
          },
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(adminUserProvider);

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
                  // onTap: _onLoading,
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
          child: usersState.when(
            loading: () => const Center(child: CircularLoadingWidget()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (users) => users.isEmpty
                ? const Center(child: Text('No user found'))
                : ListView.builder(
                    // controller: _scrollController,
                    itemCount:
                        users.length, // +1 để hiển thị loading khi tải thêm
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
                          Slidable(
                            // startActionPane: ActionPane(
                            //   motion: StretchMotion(),
                            //   children: [
                            //     SlidableAction(
                            //       backgroundColor: HelpersColors.itemCard,
                            //       icon: Icons.edit,
                            //       label: 'Edit',
                            //       onPressed: (context) {
                            //         _onDismissed();
                            //       },
                            //     ),
                            //     SlidableAction(
                            //       backgroundColor: HelpersColors.itemSelected,
                            //       icon: FontAwesomeIcons.trash,
                            //       label: 'Remove',
                            //       onPressed: (context) {
                            //         _onDismissed();
                            //       },
                            //     ),
                            //   ],
                            // ),
                            endActionPane: ActionPane(
                              motion: BehindMotion(),
                              // extentRatio: 0.6, // tăng tỉ lệ chiều rộng tổng
                              extentRatio: 0.3,
                              children: [
                                // SlidableAction(
                                //   backgroundColor: HelpersColors.itemCard,
                                //   icon: Icons.insert_drive_file_outlined,
                                //   label: 'Detail',
                                //   onPressed: (context) {
                                //     _onDismissed(
                                //       index,
                                //       Actions.detail,
                                //       users[index],
                                //     );
                                //   },
                                // ),
                                SlidableAction(
                                  backgroundColor: users[index].status  ? HelpersColors.itemSelected : HelpersColors.itemCard,
                                  icon: users[index].status ? FontAwesomeIcons.userSlash : FontAwesomeIcons.userCheck,
                                  label: users[index].status ? 'Resigned' : 'Retained',
                                  onPressed: (context) {
                                    _onDismissed(
                                      index,
                                      users[index].status ?
                                      Actions.resigned : Actions.retained,
                                      users[index],
                                    );
                                  },
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return AdminInformationUserScreen(
                                        user: users[index],
                                      );
                                    },
                                  ),
                                );
                              },
                              child: AbsorbPointer(child: AdminUserItemWidget(user: users[index])),
                            ),
                          ),

                          SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
          ),
          // onLoading: _onLoading
        ),
      ),
    );
  }
}
