import 'package:daily_manage_user_app/controller/admin/admin_department_controller.dart';
import 'package:daily_manage_user_app/controller/admin/admin_position_controller.dart';
import 'package:daily_manage_user_app/controller/admin/admin_user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user.dart';
class AdminUserProvider extends StateNotifier<AsyncValue<List<User>>>{
  String? _filterFullName; // Lưu endDate

  final Ref ref; // Thêm ref để sử dụng trong provider
  int page = 1;
  final int limit = 20;
  bool hasMore = true;
  AdminUserProvider(this.ref) : super(const AsyncValue.loading());
  Future<void> loadLeavesUserFirstPage({
    bool isRefresh = false,
    String filterFullName = ''
  }) async {
    try {
      if (isRefresh) {
        page = 1;
        hasMore = true;
        state = const AsyncValue.loading();

        _filterFullName = filterFullName;

        final result = await AdminUserController().fetchUsers(
          page: page,
          limit: limit,
            filterFullName: filterFullName
        );
        final newUsers = result['users'] as List<User>;
        // newWorks.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
        state = AsyncValue.data(newUsers);
        hasMore = newUsers.length == limit;
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  Future<void> loadMoreUsers()async{
    if(!hasMore) return;
    try{
      page++;
      // final currentWorks = state.value ?? [];
      // final start = (page - 1) * limit;
      // final end = start + limit;
      final result = await AdminUserController().fetchUsers(
        page: page, limit: limit,
        filterFullName: _filterFullName
      );
      final newUsers = result['users'] as List<User>;
      state = AsyncValue.data([...state.value ?? [], ...newUsers]);
      hasMore = newUsers.length == limit;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  Future<void> addUser(User newUser) async {
    final current = state.value ?? [];
    state = AsyncValue.data([newUser, ...current]);

  }

  Future<void> updateUser(User updatedUser) async {
    final current = state.value ?? [];
    // duyệt list hiện tại, nếu trùng id thì thay bằng updatedUser
    final newList = current.map((user) {
      return user.id == updatedUser.id ? updatedUser : user;
    }).toList();

    state = AsyncValue.data(newList);
  }
  Future<void> updateUserDepartment({
    required String userId,
    required String departmentId,
  }) async {
    try {
      // 1. Gọi API update user
      final updatedUser = await AdminUserController().requestUpdateUser(
        id: userId,
        departmentId: departmentId,
      );

      if (updatedUser != null) {
        // 2. Gọi API fetchOneDepartment để lấy object department đầy đủ
        final department =
        await AdminDepartmentController().fetchOneDepartment(id: departmentId);

        // 3. Nếu fetch được department thì patch vào user
        final userWithDepartment = updatedUser.copyWith(
          department: department,
          //------------------------------
          positionId: null,
          position: null, // reset luôn position
        );

        // 4. Update lại state list
        final current = state.value ?? [];
        final newList = current.map((user) {
          return user.id == userWithDepartment.id ? userWithDepartment : user;
        }).toList();

        state = AsyncValue.data(newList);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }


  Future<void> updateUserPosition({
    required String userId,
    required String departmentId,
    required String positionId,
  }) async {
    try {
      final updatedUser = await AdminUserController().requestUpdateUser(
        id: userId,
        departmentId: departmentId,
        positionId: positionId,
      );

      if (updatedUser != null) {
        final department =
        await AdminDepartmentController().fetchOneDepartment(id: departmentId);

        final position =
        await AdminPositionController().fetchOnePosition(id: positionId);

        final userWithOrg = updatedUser.copyWith(
          department: department,
          position: position,
        );

        final current = state.value ?? [];
        final newList = current.map((user) {
          return user.id == userWithOrg.id ? userWithOrg : user;
        }).toList();

        state = AsyncValue.data(newList);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }


// Xóa vị trí
  Future<void> deleteUser(String userId) async {

    final current = state.value ?? [];
    final newList = current.where((dep) => dep.id != userId).toList();
    state = AsyncValue.data(newList);
  }

}
final adminUserProvider =
StateNotifierProvider<AdminUserProvider, AsyncValue<List<User>>>(
      (ref) => AdminUserProvider(ref),
);
