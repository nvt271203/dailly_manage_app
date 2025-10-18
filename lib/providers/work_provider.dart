import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../controller/work_controller.dart';
import '../models/work.dart';
import 'user_provider.dart';

class WorkProvider extends StateNotifier<AsyncValue<List<Work>>> {

  final Ref ref;
  int page = 1;
  final int limit = 20;
  bool hasMore = true;

  // bool get hasMore => _hasMore;

  // Cờ đánh dấu dữ liệu khi tạo mới hay
  bool _isFirstLaunch = true;

  // WorkProvider(this.ref) : super([]);
  WorkProvider(this.ref) : super(const AsyncValue.loading()) {
    // Giữ provider sống để tránh khởi tạo lại
    // ref.keepAlive();
    // _initialize();
    ref.onDispose(() {
      page = 1; // Reset khi provider bị hủy
      hasMore = true;
    });
  }

// Khởi tạo ban đầu
  Future<void> _initialize() async {
    final user = ref.read(userProvider);
    if (user != null && state is AsyncLoading) {
      // await fetchWorksPageOne();
    }
  }


  /// Load danh sách Work từ backend theo user
  Future<void> fetchWorks() async {
    final user = ref.read(userProvider);
    if (user != null) {
      try {
        final works = await WorkController().loadWorkByUser(userId: user.id);
        // state = works.reversed.toList();
        // state = AsyncValue.data(works.reversed.toList());
        works.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
        // Sắp xếp giảm dần
        state = AsyncValue.data(works);
      } catch (e) {
        print("Error loading work list: $e");
        // Optionally: state = [];
      }
    }
  }

  // /// Load trang đầu tiên
  // Future<void> fetchWorksPageOne() async {
  //   final user = ref.read(userProvider);
  //   if (user != null) {
  //     try {
  //       state = const AsyncValue.loading();
  //       _currentPage = 1;
  //       final works = await WorkController().loadWorkByUser(userId: user.id);
  //       works.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
  //       _allWorks = works;
  //       final initialPage = _getPage(_currentPage);
  //       _hasMore = initialPage.length < _allWorks.length;
  //       state = AsyncValue.data(initialPage);
  //     } catch (e) {
  //       state = AsyncValue.error(e, StackTrace.current);
  //     }
  //   }
  // }
  //
  // /// Load thêm trang tiếp theo (gọi khi scroll tới cuối danh sách)
  // Future<void> loadMoreWorks() async {
  //   if (!_hasMore) return;
  //
  //   _currentPage += 1;
  //   final nextPage = _getPage(_currentPage);
  //   final currentList = state.value ?? [];
  //
  //   state = AsyncValue.data([...currentList, ...nextPage]);
  //   _hasMore = (currentList.length + nextPage.length) < _allWorks.length;
  // }
  //
  // /// Hàm chia trang từ danh sách tổng
  // List<Work> _getPage(int page) {
  //   final start = (page - 1) * _pageSize;
  //   final end = (_pageSize * page).clamp(0, _allWorks.length);
  //   return _allWorks.sublist(start, end);
  // }
  // Future<void> loadWorksByUserFirstPage({bool isRefresh = false}) async {
  //   try {
  //     final box = Hive.box<Work>('workCacheBox');
  //
  //     /// 👉 Ưu tiên hiển thị dữ liệu từ cache
  //     // final cached = box.values.toList();
  //     final cached = box.values.toList()
  //       ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime)); // 👈 Sắp xếp giảm dần
  //
  //     if (cached.isNotEmpty && !isRefresh) {
  //       debugPrint('⏳ Loading from cache...');
  //       state = AsyncValue.data(cached);
  //       return; // ✅ Không gọi API nữa
  //     }
  //
  //     // 👉 Nếu không có cache, GỌI API
  //   // / 👉 Nếu là lần mở app đầu tiên, luôn gọi API
  //     if (_isFirstLaunch || isRefresh) {
  //       page = 1;
  //       hasMore = true;
  //       state = const AsyncValue.loading();
  //
  //
  //     }
  //
  //
  //     state = const AsyncValue.loading();
  //     final userId = ref.read(userProvider)!.id;
  //     final result = await WorkController().loadWorksByUserPagination(
  //         userId: userId, page: page, limit: limit);
  //     final newWorks = result['works'] as List<Work>;
  //     state = AsyncValue.data(newWorks);
  //     hasMore = newWorks.length == limit;
  //
  //     // 👉 GHI CACHE nếu dữ liệu mới
  //     await box.clear();
  //     for (final work in newWorks) {
  //       if (!box.containsKey(work.id)) {
  //         await box.put(work.id, work);
  //       }
  //     }
  //
  //   } catch (e, stackTrace) {
  //     state = AsyncValue.error(e, stackTrace);
  //   }
  // }

  Future<void> loadWorksByUserFirstPage({bool isRefresh = false}) async {
    final box = Hive.box<Work>('workCacheBox');
    final userId = ref.read(userProvider)?.id;
    if (userId == null) return;

    try {
      // 👉 Nếu là lần mở app đầu tiên, luôn gọi API
      if (_isFirstLaunch || isRefresh) {
        debugPrint('🔁 Loading fresh data from API...');
        _isFirstLaunch = false;
        page = 1;
        hasMore = true;
        state = const AsyncValue.loading();

        final result = await WorkController().loadWorksByUserPagination(
          userId: userId,
          page: page,
          limit: limit,
        );
        final newWorks = result['works'] as List<Work>;
        newWorks.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

        state = AsyncValue.data(newWorks);
        hasMore = newWorks.length == limit;

        // Ghi cache
        await box.clear();
        for (final work in newWorks) {
          await box.put(work.id, work);
        }
      } else {
        // 👉 Nếu không phải lần đầu (quay lại màn), dùng cache
        final cached = box.values.toList()
          ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

        debugPrint('📦 Loading from cache...');
        state = AsyncValue.data(cached);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadMoreWorks() async {

    if (!hasMore) return;
    final box = Hive.box<Work>('workCacheBox');
    try {
      page++;

      // 📦 1. Đọc dữ liệu hiện tại từ state
      final currentWorks = state.value ?? [];
      // 📦 2. Đọc dữ liệu cache từ Hive (nếu đã từng lưu đủ toàn bộ)
      final start = (page - 1) * limit;
      final end = start + limit;
      final cachedWorks = box.values.toList();

      // 👉 1. Nếu đã đủ dữ liệu trong Hive cache
      if (cachedWorks.length >= end) {
        final moreWorksFromCache = cachedWorks.sublist(start, end);
        state = AsyncValue.data([...currentWorks, ...moreWorksFromCache]);
        // hasMore = moreWorksFromCache.length == limit;
        return;
      }

      // 👉 2. Gọi API nếu không đủ trong cache
      final userId = ref.read(userProvider)!.id;
      final result = await WorkController().loadWorksByUserPagination(
          userId: userId, page: page, limit: limit);
      final newWorks = result['works'] as List<Work>;

      // 👉 3. Ghi dữ liệu mới vào Hive nếu chưa có
      for (final work in newWorks) {
        if (!box.containsKey(work.id)) {
          await box.put(work.id, work);
        }
      }

      // 👉 4. Cập nhật states

      state = AsyncValue.data([...state.value ?? [], ...newWorks]);
      hasMore = newWorks.length == limit;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  void resetFirstLaunch() {
    _isFirstLaunch = true;
  }

  /// Thêm một work mới (ví dụ sau khi check-in hoặc thêm thủ công)
  void addWork(Work work) {
    // state = [...state, work];
    if (state is AsyncData) {
      final updated = [work, ...state.value!];
      state = AsyncValue.data(updated);
    }
  }

// /// Xoá một work (nếu bạn cần)
// void removeWork(String workId) {
//   state = state.where((w) => w.id != workId).toList();
// }
//
// /// Cập nhật một work (nếu có edit)
// void updateWork(Work updatedWork) {
//   state = [
//     for (final w in state)
//       if (w.id == updatedWork.id) updatedWork else w
//   ];
// }
}

final workProvider = StateNotifierProvider<WorkProvider,
    AsyncValue<List<Work>>>((ref) => WorkProvider(ref),);

final resetWorkProviderFlagProvider = Provider<void>((ref) {
  ref.read(workProvider.notifier).resetFirstLaunch();
});