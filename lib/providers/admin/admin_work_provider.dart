import 'package:daily_manage_user_app/controller/admin/admin_work_controller.dart';
import 'package:daily_manage_user_app/models/work.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminWorkProvider extends StateNotifier<AsyncValue<List<Work>>> {
  final Ref ref; // Thêm ref để sử dụng trong provider
  int page = 1;
  final int limit = 12;
  bool hasMore = true;
  DateTime? _startDate; // Lưu startDate
  DateTime? _endDate; // Lưu endDate


  AdminWorkProvider(this.ref) : super(const AsyncValue.loading());
  /// Load danh sách Work từ backend theo user
  // Future<void> fetchWorks() async {
  //     try {
  //       final works = await AdminWorkController().getAllWorks();
  //       // state = works.reversed.toList();
  //       // state = AsyncValue.data(works.reversed.toList());
  //       // works.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
  //       // Sắp xếp giảm dần
  //       state = AsyncValue.data(works);
  //     } catch (e) {
  //       print("Error loading work list: $e");
  //       // Optionally: state = [];
  //     }
  //
  // }
  Future<void> loadWorksByUserFirstPage({
    bool isRefresh = false,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // final box = Hive.box<Work>('workCacheBox');
    // final userId = ref.read(userProvider)?.id;
    // if (userId == null) return;

    try {
      // 👉 Nếu là lần mở app đầu tiên, luôn gọi API
      // if (_isFirstLaunch || isRefresh) {
      if (isRefresh) {
        // debugPrint('🔁 Loading fresh data from API...');
        // _isFirstLaunch = false;
        page = 1;
        hasMore = true;
        state = const AsyncValue.loading();

// Lưu startDate và endDate
        _startDate = startDate;
        _endDate = endDate;
        final result = await AdminWorkController().fetchAllWorks(
          page: page,
          limit: limit,
          startDate: startDate,
          endDate: endDate,
        );

        final newWorks = result['works'] as List<Work>;
        // newWorks.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

        state = AsyncValue.data(newWorks);
        hasMore = newWorks.length == limit;

        // // Ghi cache
        // await box.clear();
        // for (final work in newWorks) {
        //   await box.put(work.id, work);
        // }
        // } else {
        //   // 👉 Nếu không phải lần đầu (quay lại màn), dùng cache
        //   final cached = box.values.toList()
        //     ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
        //
        //   debugPrint('📦 Loading from cache...');
        //   state = AsyncValue.data(cached);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  Future<void> loadMoreWorks()async{
    if(!hasMore) return;
    try{
      page++;
      // final currentWorks = state.value ?? [];
      // final start = (page - 1) * limit;
      // final end = start + limit;
      final result = await AdminWorkController().fetchAllWorks(
          page: page, limit: limit,
        startDate: _startDate, // Sử dụng _startDate
        endDate: _endDate, // Sử dụng _endDate
      );
      final newWorks = result['works'] as List<Work>;
      state = AsyncValue.data([...state.value ?? [], ...newWorks]);
      hasMore = newWorks.length == limit;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
//Hàm để cập nhập dữ liệu của 1 đối tượng realtime
  void updateWorkItem(Work updatedWork) {
    state.whenData((works) {
      final index = works.indexWhere((w) => w.id == updatedWork.id);
      if (index != -1) {
        final newList = [...works];
        newList[index] = updatedWork;
        state = AsyncValue.data(newList);
      }
    });
  }
//Hàm để thêm mới dữ liệu của 1 đối tượng realtime

  void addWorkToTop(Work newWork) {
    state.whenData((currentList) {
      final exists = currentList.any((w) => w.id == newWork.id);
      if (!exists) {
        state = AsyncValue.data([newWork, ...currentList]);
      }
    });
  }
}

final adminWorkProvider =
    StateNotifierProvider<AdminWorkProvider, AsyncValue<List<Work>>>(
      (ref) => AdminWorkProvider(ref),
    );
