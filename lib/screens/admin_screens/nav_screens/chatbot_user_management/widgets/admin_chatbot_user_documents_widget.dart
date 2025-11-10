import 'package:daily_manage_user_app/models/document.dart';
import 'package:daily_manage_user_app/providers/admin/admin_document_provider.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/chatbot_user_management/widgets/admin_chatbot_user_item_document_widget.dart';
import 'package:daily_manage_user_app/screens/user_screens/nav_screens/home/dialogs/confirm_check_dialog.dart';
import 'package:daily_manage_user_app/widgets/dialog_confirm_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../helpers/tools_colors.dart';
import '../../../../../widgets/circular_loading_widget.dart';
import '../../../../user_screens/nav_screens/leave/dialogs/confirm_delete_dialog.dart';
enum Actions { train, delete }

class AdminChatbotUserDocumentsWidget extends ConsumerStatefulWidget {
  const AdminChatbotUserDocumentsWidget({super.key});

  @override
  _AdminChatbotUserDocumentsWidgetState createState() =>
      _AdminChatbotUserDocumentsWidgetState();
}

class _AdminChatbotUserDocumentsWidgetState
    extends ConsumerState<AdminChatbotUserDocumentsWidget> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  void _onDismissed(int index, Actions action, Document document) {
    switch (action) {
      case Actions.train:
        showDialog(
          context: context,
          builder: (context) =>
              DialogConfirmWidget(title: 'Confirm', content: 'Confirm training this file !', onConfirm: (){})
              // AdminOrgTabDepartmentAddDialog(departmentItem: department),
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
              'Are you sure you want to delete the\n" ${document.name}" file pdf?',
              onConfirm: () async{
                // _requestDeleteDepartment(department);
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



  Future<void> _onRefresh() async {
    try {
      await ref.watch(adminDocumentProvider);
      print("Starting refresh...");
      // ref.read(adminLeaveProvider.notifier).loadLeavesUserFirstPage(
      //   isRefresh: true,
      //   filterYear: filter.filterYear,
      //   sortField: filter.sortField,
      //   sortOrder: filter.sortOrder,
      //   status: filter.status,
      // );
      print("Refresh completed");
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    } catch (e, stackTrace) {
      print("Refresh failed: $e");
      _refreshController.refreshFailed();
    }
  }
  Future<void> _onLoading() async {
    final documentNotifier = ref.read(adminDocumentProvider.notifier);
    final documentAsync = ref.read(adminDocumentProvider);
    if (!documentNotifier.hasMore || documentAsync.isLoading) {
      print("No more data to load or already loading");
      _refreshController.loadNoData();
      return;
    }

    try {
      print("Starting to load more works...");
      await documentNotifier.loadMoreDocuments();
      print(
        "Load more completed. hasMore: ${documentNotifier.hasMore}, data length: ${documentAsync.value?.length}",
      );
      if (documentNotifier.hasMore) {
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
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final documentsState = ref.watch(adminDocumentProvider);

    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: true,
      onRefresh: _onRefresh,
      onLoading: _onLoading,

      child: documentsState.when(
        error: (error, stack) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularLoadingWidget()),
        data: (documents) => documents.isEmpty
            ? Center(child: Text('No document found'))
            : ListView.builder(
          // ---- THÊM 2 DÒNG NÀY VÀO ----
          //       shrinkWrap: true,
          //       physics: const NeverScrollableScrollPhysics(),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  // return Text(documents[index].name);
                  return Padding(
                    padding: EdgeInsets.only(top: 15, left: 15, right: 15),
                    child: Slidable(
                        endActionPane: ActionPane(
                          motion: BehindMotion(),
                          children: [
                            SlidableAction(
                              backgroundColor: HelpersColors.itemCard,
                              icon: Icons.model_training_outlined,
                              label: 'Train',
                              onPressed: (context) {
                                _onDismissed(
                                  index,
                                  Actions.train,
                                  documents[index],
                                );
                              },
                            ),
                            SlidableAction(
                              backgroundColor:
                              HelpersColors.itemSelected,
                              icon: FontAwesomeIcons.trash,
                              label: 'Delete',
                              onPressed: (context) {
                                // _onDismissed(
                                //   index,
                                //   Actions.delete,
                                //   departments[index],
                                // );
                              },
                            ),
                          ],
                        ),
                    
                    
                        child: AdminChatbotUserItemDocumentWidget(document: documents[index],)),
                  );
                },
              ),
      ),
    );
  }
}
