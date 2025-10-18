import 'package:daily_manage_user_app/providers/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'dart:io' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../controller/leave_controller.dart';
import '../models/leave.dart';
import '../services/sockets/leave_socket.dart';
import 'package:shared_preferences/shared_preferences.dart';
class LeaveProvider extends StateNotifier<AsyncValue<List<Leave>>> {
  final Ref ref;

  int page = 1;
  final int limit = 8;
  bool hasMore = true;

// CẬP NHẬT: Lưu trữ các tham số lọc
  int _filterYear = 2025;
  String _sortField = 'startDate';
  String _sortOrder = 'desc';
  String _status = 'all';

  // Cờ đánh dấu dữ liệu khi tạo mới hay
  bool _isFirstLaunch = true;
  IO.Socket? socket; // Thêm biến socket
  // LeaveProvider(this.ref) : super(const AsyncValue.loading());//====
  LeaveProvider(this.ref) : super(const AsyncValue.loading()) {
    _initSocket(); // Khởi tạo socket khi provider được tạo
    // loadLeaves(); // Tải dữ liệu ban đầu
    // loadLeavesByUserFirstPage(); // Tải dữ liệu ban đầu
  }
// Khởi tạo socket và lắng nghe sự kiện
  void _initSocket() {
    LeaveSocket.listenUpdatedLeaveRequest((leaveData) {
    //   // print('Processing work_checkIn data: $workData');
    //   print('Processing leave_request_status_update data: $leaveData'); // Log toàn bộ dữ liệu
      final updatedLeave = Leave.fromMap(leaveData);
    //   if (!mounted) return;  // Kiểm tra widget còn tồn tại không
    //   print('Processed leave_request_status_update: $updatedLeave'); // Log đối tượng Work sau khi xử lý
      state.whenData((currentList) {
        final exists = currentList.any((w) => w.id == updatedLeave.id);
        if (exists) {
          debugPrint('Updating existing leave: ${updatedLeave.id}');
          updateLeaveItem(updatedLeave);
        } else {
          debugPrint('Adding new leave: ${updatedLeave.id}');
          addLeaveToTop(updatedLeave);
        }
      });
    });
  }
  // Xử lý sự kiện leave_updated từ socket
  void _handleLeaveUpdated() async {
    debugPrint('📡 Socket: Leave updated event received, syncing with API...');
    final box = Hive.box<Leave>('leaveCacheBox');

    try {
      // Gọi API để lấy dữ liệu mới nhất
      final userId = ref.read(userProvider)!.id;
      final result = await LeaveController().loadFilterLeaves(
        userId: userId,
        page: 1, // Lấy trang đầu tiên để đồng bộ
        limit: limit,
        filterYear: _filterYear,
        sortField: _sortField,
        sortOrder: _sortOrder,
        status: _status,
      );

      final newLeaves = result['leaves'] as List<Leave>;
      final monthYearCounts = result['leavesByMonthYear'] as List<dynamic>;

      // Cập nhật leavesByMonthYear
      leavesByMonthYear.clear();
      for (var item in monthYearCounts) {
        leavesByMonthYear[item['monthYear']] = item['count'];
      }

      // Cập nhật cache (Hive)
      await box.clear(); // Xóa cache cũ
      for (final leave in newLeaves) {
        await box.put(leave.id, leave); // Lưu leave mới vào cache
      }

      // Cập nhật state
      state = AsyncValue.data(newLeaves);
      hasMore = newLeaves.length == limit;

      debugPrint('✅ Synced leaves from socket: ${newLeaves.length} leaves');
    } catch (e, stackTrace) {
      debugPrint('❌ Error syncing leaves from socket: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }
  // Future<void> loadLeavesByUserFirstPage({bool isRefresh = false}) async {
  //   try {
  //     if (isRefresh) {
  //       page = 1; // Đặt lại trang khi làm mới
  //     }
  //     state = const AsyncValue.loading();
  //     final userId = ref.read(userProvider)!.id;
  //     final newLeaves = await LeaveController().loadLeavesByUserPagination(
  //       userId: userId,
  //       page: page,
  //       limit: limit,
  //     );
  //     state = AsyncValue.data(newLeaves);
  //     hasMore = newLeaves.length == limit;
  //   } catch (e, stackTrace) {
  //     state = AsyncValue.error(e, stackTrace);
  //   }
  // }
  //
  // Future<void> loadMoreLeaves() async {
  //   if (!hasMore) return;
  //   try {
  //     page++;
  //     final userId = ref.read(userProvider)!.id;
  //     final newLeaves = await LeaveController().loadLeavesByUserPagination(
  //       userId: userId,
  //       page: page,
  //       limit: limit,
  //     );
  //     state = AsyncValue.data([...state.value ?? [], ...newLeaves]);
  //     hasMore = newLeaves.length == limit;
  //   } catch (e, stackTrace) {
  //     state = AsyncValue.error(e, stackTrace);
  //   }
  // }
  // Cấu trúc có thêm tổng số lịch nghỉ trong tháng đó.
  Map<String, int> leavesByMonthYear = {};
  Future<void> loadLeavesByUserFirstPage({
    bool isRefresh = false,

    int filterYear = 2025,
    // String yearField = 'startDate',
    String sortField = 'startDate',
    String sortOrder = 'desc',
    String status = 'all',
  }) async {
//Lưu shared choh bộ lọc.
    final prefs = await SharedPreferences.getInstance(); // Khởi tạo SharedPreferences
    // Tạo key duy nhất cho bộ lọc hiện tại
    final box = Hive.box<Leave>('leaveCacheBox');

    try {
      if ( _isFirstLaunch || isRefresh) {
        _isFirstLaunch = false;
        page = 1;
        hasMore = true; // Reset hasMore
        leavesByMonthYear.clear();
        state = const AsyncValue.loading();


        // CẬP NHẬT: Lưu các tham số lọc
        _filterYear = filterYear;
        _sortField = sortField;
        _sortOrder = sortOrder;
        _status = status;

// Lưu các tham số lọc vào SharedPreferences
        await prefs.setInt('filterYear', _filterYear);
        await prefs.setString('sortField', _sortField);
        await prefs.setString('sortOrder', _sortOrder);
        await prefs.setString('status', _status);


// Xóa cache nếu bộ lọc thay đổi
        if (filterYear != _filterYear || sortField != _sortField || sortOrder != _sortOrder || status != _status) {
          await box.clear();
        }
        // Nếu cache rỗng hoặc là refresh, mới gọi API


        // state = const AsyncValue.loading();

        final userId = ref.read(userProvider)!.id;

        // final result = await LeaveController().loadLeavesByUserPagination(
        //   userId: userId,
        //   page: page,
        //   limit: limit,
        // );

        final result = await LeaveController().loadFilterLeaves(
          userId: userId,
          page: page,
          limit: limit,
          filterYear: _filterYear, // CẬP NHẬT: Sử dụng giá trị đã lưu
          sortField: _sortField,
          sortOrder: _sortOrder,
          status: _status,
        );
        final newLeaves = result['leaves'] as List<Leave>;
        debugPrint('Number of leaves received: ${newLeaves.length}');
        newLeaves.forEach((leave) {
          debugPrint('Leave: ${leave.toJson()}'); // In chi tiết từng đối tượng
        });

        final monthYearCounts = result['leavesByMonthYear'] as List<dynamic>;
        for (var item in monthYearCounts) {
          leavesByMonthYear[item['monthYear']] = item['count'];
        }

        // ghi dữ liệu vào cục bộ.
        // 👉 Lưu vào Hive
        await box.clear();
        for (final leave in newLeaves) {
          await box.put(leave.id, leave);
        }


        // print('Leaves by month-year in provider: $leavesByMonthYear');
        state = AsyncValue.data(newLeaves);

        hasMore = newLeaves.length == limit;
      }
      else{
        // Khôi phục các tham số lọc từ SharedPreferences
        _filterYear = prefs.getInt('filterYear') ?? 2025;
        _sortField = prefs.getString('sortField') ?? 'startDate';
        _sortOrder = prefs.getString('sortOrder') ?? 'desc';
        _status = prefs.getString('status') ?? 'all';




        /// 👉 Ưu tiên hiển thị dữ liệu từ cache
        final cached = box.values.toList();
        debugPrint('⏳ Loading from cache...');
        state = AsyncValue.data(cached);

        // Đảm bảo hasMore được cập nhật dựa trên cache
        hasMore = cached.length == limit * page;

        return; // ✅ Không gọi API nữa
      }

    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> loadMoreLeaves() async {
    if (!hasMore) return;
    //
    final box = Hive.box<Leave>('leaveCacheBox');

    try {
      page++;

      // 📦 1. Đọc dữ liệu hiện tại từ state
      final currentLeaves = state.value ?? [];
      // 📦 2. Đọc dữ liệu cache từ Hive (nếu đã từng lưu đủ toàn bộ)
      final cachedLeaves = box.values.toList();
      final start = (page - 1) * limit;
      final end = start + limit;
      // Nếu cache có đủ dữ liệu cho trang tiếp theo
      if (cachedLeaves.length >= end) {
        final moreLeavesFromCache = cachedLeaves.sublist(start, end);
        state = AsyncValue.data([...currentLeaves, ...moreLeavesFromCache]);
        return;
      }

      // 📡 3. Nếu cache không đủ => gọi API


      final userId = ref.read(userProvider)!.id;
      final result = await LeaveController().loadFilterLeaves(
        userId: userId,
        page: page,
        limit: limit,

// CẬP NHẬT: Sử dụng các tham số lọc đã lưu
        filterYear: _filterYear,
        sortField: _sortField,
        sortOrder: _sortOrder,
        status: _status,
      );
      final newLeaves = result['leaves'] as List<Leave>;
      final monthYearCounts = result['leavesByMonthYear'] as List<dynamic>;
      for (var item in monthYearCounts) {
        leavesByMonthYear[item['monthYear']] = item['count'];
      }

      // 👉 Thêm vào Hive cache nếu chưa có
      for (final leave in newLeaves) {
        if (!box.containsKey(leave.id)) {
          await box.put(leave.id, leave);
        }
      }

      state = AsyncValue.data([...state.value ?? [], ...newLeaves]);
      hasMore = newLeaves.length == limit;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  void resetFirstLaunch() {
    _isFirstLaunch = true;
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

// Hàm mới để cập nhật leaveScreen của một Leave cụ thể
// Hàm mới để cập nhật toàn bộ thông tin của một Leave cụ thể
  void updateLeaveLeaveRequest(Leave updatedLeave) {
    state.whenData((leaves) {
      final updatedLeaves = leaves.map((leave) {
        if (leave.id == updatedLeave.id) {
          return Leave(
            id: updatedLeave.id,
            startDate: updatedLeave.startDate,
            endDate: updatedLeave.endDate,
            dateCreated: updatedLeave.dateCreated,
            leaveType: updatedLeave.leaveType,
            leaveTimeType: updatedLeave.leaveTimeType,
            status: updatedLeave.status,
            reason: updatedLeave.reason,
            isNew: updatedLeave.isNew, userId: ref.read(userProvider)!.id,
          );
        }
        return leave;
      }).toList();
      state = AsyncValue.data(updatedLeaves); // Cập nhật state với danh sách mới
    });
  }

  Future<void> loadLeaves() async {
    final user = ref.read(userProvider);
    if (user != null) {
      try {
        final leaves = await LeaveController().loadLeavesByUser(
          userId: user.id,
        );
        state = AsyncValue.data(leaves);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    }
  }


// Hàm mới để xử lý cập nhật từ socket
  Future<void> handleSocketLeaveUpdate(Map<String, dynamic> data) async {
    final box = Hive.box<Leave>('leaveCacheBox');
    final leaveId = data['leaveId'] as String?;
    if (leaveId == null) {
      debugPrint('⚠️ Socket update missing leaveId');
      return;
    }

    try {
      // Tạo Leave object từ dữ liệu socket
      final updatedLeave = Leave(
        id: leaveId,
        startDate: DateTime.parse(data['startDate'] as String),
        endDate: DateTime.parse(data['endDate'] as String),
        dateCreated: DateTime.parse(data['dateCreated'] as String? ?? DateTime.now().toIso8601String()),
        leaveType: data['leaveType'] as String,
        leaveTimeType: data['leaveTimeType'] as String,
        status: data['status'] as String,
        reason: data['reason'] as String,
        isNew: data['isNew'] as bool? ?? false,
        userId: data['userId'] as String,
      );

      // Kiểm tra xem leave có khớp với bộ lọc hiện tại không
      final leaveYear = updatedLeave.startDate.year;
      final leaveStatus = updatedLeave.status.toLowerCase();
      if (_filterYear == leaveYear && (_status == 'all' || _status.toLowerCase() == leaveStatus)) {
        // Cập nhật cache
        await box.put(leaveId, updatedLeave);

        // Cập nhật state
        state.whenData((leaves) {
          final updatedLeaves = leaves.map((leave) {
            if (leave.id == leaveId) {
              return updatedLeave;
            }
            return leave;
          }).toList();

          // Nếu leave chưa có trong danh sách, thêm vào (nếu phù hợp với bộ lọc)
          if (!leaves.any((leave) => leave.id == leaveId)) {
            updatedLeaves.add(updatedLeave);
            // Sắp xếp lại danh sách theo _sortField và _sortOrder
            updatedLeaves.sort((a, b) {
              final aValue = _sortField == 'startDate' ? a.startDate : a.dateCreated;
              final bValue = _sortField == 'startDate' ? b.startDate : b.dateCreated;
              return _sortOrder == 'desc' ? bValue.compareTo(aValue) : aValue.compareTo(bValue);
            });
          }

          state = AsyncValue.data(updatedLeaves);
        });

        // Cập nhật leavesByMonthYear
        final key = '${updatedLeave.startDate.month.toString().padLeft(2, '0')}/${updatedLeave.startDate.year}';
        leavesByMonthYear[key] = (leavesByMonthYear[key] ?? 0) + (leavesByMonthYear.containsKey(key) ? 0 : 1);
        debugPrint('Updated leavesByMonthYear: $leavesByMonthYear');
      } else {
        debugPrint('Socket update ignored due to filter mismatch: year=$leaveYear, status=$leaveStatus');
      }
    } catch (e, stackTrace) {
      debugPrint('Error handling socket update: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

//   Future<void> fetchLeavesByUserFirstPage({required String userId,
//     required void Function(List<Leave>) onFirstPageLoaded,
//     required void Function(List<Leave>) onMoreLeavesLoaded,
//   }) async {
//     bool isFirstPage = true;
//     int page = 1;
//     const int limit = 10;
//     while (true) {
//       try{
//         final List<Leave> pageLeaves = await LeaveController()
//             .loadLeavesByUserPagination(userId: userId, page: page,
//             limit: limit);
//
//
//         if (isFirstPage) {
//           onFirstPageLoaded(pageLeaves); // hiển thị trang đầu tiên ngay
//           isFirstPage = false;
//         } else {
//           onMoreLeavesLoaded(pageLeaves); // thêm dữ liệu vào danh sách hiện tại
//         }
//
//         if (pageLeaves.length < limit) {
//           break; // hết trang
//         }
//         page++;
//       }catch(e){
//         print('Lỗi tải trang $page: $e');
//         break;
//       }
//
//     }
//
//   }
// // **SỬA**: Thêm phương thức để tải thêm trang
//   // Ghi chú: Phương thức này cho phép tải một trang cụ thể khi người dùng cuộn hoặc nhấn nút tải thêm
//   Future<void> fetchMoreLeaves({
//     required String userId,
//     required int page,
//     required void Function(List<Leave>) onMoreLeavesLoaded,
//   }) async {
//     try {
//       const int limit = 10;
//       final List<Leave> pageLeaves = await LeaveController()
//           .loadLeavesByUserPagination(userId: userId, page: page, limit: limit);
//       onMoreLeavesLoaded(pageLeaves);
//     } catch (e) {
//       print('Lỗi tải trang $page: $e');
//     }
//   }

  /// Thêm một leave mới (ví dụ sau khi check-in hoặc thêm thủ công)
  void addLeave(Leave newLeave) {
    if (state is AsyncData) {
      final updated = [newLeave, ...state.value!];
      state = AsyncValue.data(updated);
    }
  }



  // Reatime
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


  Map<String, List<Leave>> get groupedByMonthYear {
    if (state is! AsyncData) return {};
    final leaves = state.value!;
    final Map<String, List<Leave>> grouped = {};
    for (var leave in leaves) {
      final key =
          '${leave.dateCreated.month.toString().padLeft(2, '0')}-${leave
          .dateCreated.year}';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(leave);
    }
    return grouped;
  }
}

// final leaveProvider = StateNotifierProvider<LeaveProvider, List<Leave>>((ref) => LeaveProvider(ref),);
final leaveProvider =
StateNotifierProvider<LeaveProvider, AsyncValue<List<Leave>>>(
      (ref) => LeaveProvider(ref),
);
final resetLeaveProviderFlagProvider = Provider<void>((ref) {
  ref.read(leaveProvider.notifier).resetFirstLaunch();
});