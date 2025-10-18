import 'package:daily_manage_user_app/controller/admin/admin_chatbot_controller.dart';
import 'package:daily_manage_user_app/controller/admin/admin_leave_controller.dart';
import 'package:daily_manage_user_app/models/message.dart';
import 'package:dio/dio.dart';

import '../../global_variables.dart';
import '../../models/leave.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../family_provider/chat_paramaters.dart';
import 'admin_leave_filter_provider.dart';

class AdminMessagesProvider extends StateNotifier<AsyncValue<List<Message>>> {
  final Ref ref; // Thêm ref để sử dụng trong provider
  final ChatParameters params; // <-- Thêm dòng này để lưu trữ tham số
  int page = 1;
  final int limit = 20;
  bool hasMore = true;

  AdminMessagesProvider(this.ref, this.params)
    : super(const AsyncValue.loading()){
    loadMessagesFirstPage();
  }

  Future<void> loadMessagesFirstPage({bool isRefresh = false}) async {
    try {
      // if (isRefresh) {
      //   // page = 1;
      //   hasMore = true;
      //   state = const AsyncValue.loading();

        final result = await AdminChatbotController().fetchMessagesPagination(
          roomId: params.roomId,
          senderId: params.senderId,
          page: page,
          limit: limit
        );

        final newMessages = result;
        print('list messages res ${result}');
        // newWorks.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

        state = AsyncValue.data(newMessages);
        hasMore = newMessages.length == limit;
      // }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

    Future<void> loadMoreMessages()async{
      if(!hasMore) return;
      try{
        page++;
        // final currentWorks = state.value ?? [];
        // final start = (page - 1) * limit;
        // final end = start + limit;
        final result = await AdminChatbotController().fetchMessagesPagination(
            roomId: params.roomId,
            senderId: params.senderId,
            page: page,
            limit: limit
        );

        final newMessageOld = result;
        state = AsyncValue.data([ ...newMessageOld, ...state.value ?? []]);
        hasMore = newMessageOld.length == limit;
      } catch (e, stackTrace) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  //  Thêm vị trí mới
  Future<void> addMessage(Message newMessage) async {
    final current = state.value ?? [];
    state = AsyncValue.data([ ...current, newMessage]);

    // try {
    //   // Cập nhật state với vị trí mới
    //   state.whenData((positions) {
    //     final updatedPositions = [...positions, newPosition];
    //     state = AsyncValue.data(updatedPositions.reversed.toList());
    //   });
    // } catch (e, stackTrace) {
    //   state = AsyncValue.error(e, stackTrace);
    // }
  }
  //   }
}

// SỬA LẠI PROVIDER: Thêm .family và truyền vào ChatParameters
final adminMessagesProvider =
    StateNotifierProvider.family<
      AdminMessagesProvider,
      AsyncValue<List<Message>>,
      ChatParameters
    >((ref, params) {
      // Bây giờ chúng ta có thể truyền params (chứa roomId và senderId) vào Notifier
      return AdminMessagesProvider(ref, params);
    });
