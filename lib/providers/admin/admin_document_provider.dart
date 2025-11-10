import 'package:daily_manage_user_app/controller/admin/admin_chatbot_controller.dart';
import 'package:daily_manage_user_app/models/document.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class AdminDocumentProvider extends StateNotifier<AsyncValue<List<Document>>>{
  final Ref ref; // Thêm ref để sử dụng trong provider
  int page = 1;
  final int limit = 10; // Đặt limit cố định
  bool hasMore = true;

  AdminDocumentProvider(this.ref) : super(const AsyncValue.loading()){
    loadDocumentsFirstPage();
  }
  Future<void> loadDocumentsFirstPage() async {
    // final box = Hive.box<Work>('workCacheBox');
    // final userId = ref.read(userProvider)?.id;
    // if (userId == null) return;

    try {
      // 👉 Nếu là lần mở app đầu tiên, luôn gọi API

        // debugPrint('🔁 Loading fresh data from API...');
        // _isFirstLaunch = false;
        page = 1;
        hasMore = true;
        state = const AsyncValue.loading();


        final result = await AdminChatbotController().fetchDocumentsPagination(
          page: page,
          limit: limit,
        );

        final newDocuments = result;
        state = AsyncValue.data(newDocuments);
        hasMore = newDocuments.length == limit;

    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  Future<void> loadMoreDocuments()async{
    if(!hasMore) return;
    try{
      page++;
      // final currentWorks = state.value ?? [];
      // final start = (page - 1) * limit;
      // final end = start + limit;
      final result = await AdminChatbotController().fetchDocumentsPagination(
        page: page,
        limit: limit,
      );
      final newDocuments = result;
      state = AsyncValue.data([...state.value ?? [], ...newDocuments]);
      hasMore = newDocuments.length == limit;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
//Hàm để thêm mới dữ liệu của 1 đối tượng realtime
  void addDocumentToTop(Document newDocument) {
    state.whenData((currentList) {
      final exists = currentList.any((w) => w.id == newDocument.id);
      if (!exists) {
        state = AsyncValue.data([newDocument, ...currentList]);
      }
    });
  }
}


final adminDocumentProvider =
StateNotifierProvider<AdminDocumentProvider, AsyncValue<List<Document>>>(
      (ref) => AdminDocumentProvider(ref),
);
