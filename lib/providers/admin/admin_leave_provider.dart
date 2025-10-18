import 'package:daily_manage_user_app/controller/admin/admin_leave_controller.dart';
import 'package:dio/dio.dart';

import '../../global_variables.dart';
import '../../models/leave.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'admin_leave_filter_provider.dart';
class AdminLeaveProvider extends StateNotifier<AsyncValue<List<Leave>>>{
  final Ref ref; // Thêm ref để sử dụng trong provider
  int page = 1;
  final int limit = 12;
  bool hasMore = true;
  // DateTime? _startDate; // Lưu startDate
  // DateTime? _endDate; // Lưu endDate
// CẬP NHẬT: Lưu trữ các tham số lọc
  int _filterYear = 2025;
  String _sortField = 'startDate';
  String _sortOrder = 'desc';
  String _status = 'all';


  AdminLeaveProvider(this.ref) : super(const AsyncValue.loading());
  Future<void> loadLeavesUserFirstPage({
    bool isRefresh = false,
    int filterYear = 2025,
    // String yearField = 'startDate',
    String sortField = 'startDate',
    String sortOrder = 'desc',
    String status = 'all',
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
//         _startDate = startDate;
//         _endDate = endDate;

        // CẬP NHẬT: Lưu các tham số lọc
        _filterYear = filterYear;
        _sortField = sortField;
        _sortOrder = sortOrder;
        _status = status;


        final result = await AdminLeaveController().fetchLeaves(
          page: page,
          limit: limit,
          filterYear: _filterYear, // CẬP NHẬT: Sử dụng giá trị đã lưu
          sortField: _sortField,
          sortOrder: _sortOrder,
          status: _status,

          // startDate: startDate,
          // endDate: endDate,
        );

        final newLeaves = result['leaves'] as List<Leave>;
        // newWorks.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

        state = AsyncValue.data(newLeaves);
        hasMore = newLeaves.length == limit;

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
  Future<void> loadMoreLeaves()async{
    if(!hasMore) return;
    try{
      page++;
      // final currentWorks = state.value ?? [];
      // final start = (page - 1) * limit;
      // final end = start + limit;
      final result = await AdminLeaveController().fetchLeaves(
        page: page, limit: limit,
        filterYear: _filterYear,
        sortField: _sortField,
        sortOrder: _sortOrder,
        status: _status,
      );
      final newLeaves = result['leaves'] as List<Leave>;
      state = AsyncValue.data([...state.value ?? [], ...newLeaves]);
      hasMore = newLeaves.length == limit;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void updateLeaveStatus(String leaveId, String newStatus) async{
    state.whenData((leaves) async {
      final updatedLeaves = leaves.map((leave) {
        if (leave.id == leaveId) {
          return leave.copyWith(status: newStatus);
        }
        return leave;
      }).toList();

      // Sau khi đã thay đổi trạng thái của dữ liệu, tiếp là cập  nhập lên bộ lọc
      // Lấy bộ lọc hiện tại
      final filter = ref.read(adminLeaveFilterProvider);

      // Nếu bộ lọc là "Status All", giữ nguyên danh sách
      if (filter.status.toLowerCase() == 'status all') {
        state = AsyncValue.data(updatedLeaves);
      } else {
        // Lọc danh sách dựa trên trạng thái
        final filteredLeaves = updatedLeaves.where((leave) {
          return leave.status.toLowerCase() == filter.status.toLowerCase();
        }).toList();
        state = AsyncValue.data(filteredLeaves);
      }

      print('Refreshing data from API...');
      try {
        final filter = ref.read(adminLeaveFilterProvider);
        await loadLeavesUserFirstPage(
        isRefresh: true,
        filterYear: filter.filterYear,
        sortField: filter.sortField,
        sortOrder: filter.sortOrder,
        status: filter.status,
        );
        state.whenData((leaves) => print('API returned ${leaves.length} leaves'));
      } catch (e) {
        print('Failed to refresh data: $e');
        state = AsyncValue.error(e, StackTrace.current);
      }

    });
  }
// Hàm mới để cập nhật isNew của một Leave cụ thể
  void updateLeaveIsNew(String leaveId, bool isNew) {
    state.whenData((leaves) {
      final updatedLeaves = leaves.map((leave) {
        if (leave.id == leaveId) {
          return leave.copyWith(isNew: isNew); // Cập nhật isNew
        }
        return leave;
      }).toList();
      state = AsyncValue.data(updatedLeaves); // Cập nhật state
    });
  }
  void updateLeaveItem(Leave updatedLeave) {
    state.whenData((leaves) {
      final index = leaves.indexWhere((w) => w.id == updatedLeave.id);
      if (index != -1) {
        final newList = [...leaves];
        newList[index] = updatedLeave;
        state = AsyncValue.data(newList);
      }
    });
  }
//Hàm để thêm mới dữ liệu của 1 đối tượng realtime

  void addLeaveToTop(Leave newLeave) {
    state.whenData((currentList) {
      final exists = currentList.any((w) => w.id == newLeave.id);
      if (!exists) {
        state = AsyncValue.data([newLeave, ...currentList]);
      }
    });
  }

}
final adminLeaveProvider =
StateNotifierProvider<AdminLeaveProvider, AsyncValue<List<Leave>>>(
      (ref) => AdminLeaveProvider(ref),
);
