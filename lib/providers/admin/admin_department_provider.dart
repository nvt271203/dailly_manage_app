import 'package:daily_manage_user_app/controller/admin/admin_department_controller.dart';
import 'package:daily_manage_user_app/models/department.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminDepartmentProvider extends StateNotifier<AsyncValue<List<Department>>>{
  final Ref ref; // Thêm ref để sử dụng trong provider
  int page = 1;
  final int limit = 15;
  bool hasMore = true;
  AdminDepartmentProvider(this.ref) : super(const AsyncValue.loading());

  Future<void> fetchAllDepartments() async {
    try {
        state = const AsyncValue.loading();
        final result = await AdminDepartmentController().fetchDepartments(
          page: page,
          limit: limit,
        );
        final newLeaves = result['departments'] as List<Department>;
        // state = AsyncValue.data(newLeaves);
        state = AsyncValue.data(newLeaves.reversed.toList());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }

  }
  Future<void> fetchDepartmentsFirstPage({
    bool isRefresh = false,
  }) async {
    try {
      if (isRefresh) {
        page = 1;
        hasMore = true;
        state = const AsyncValue.loading();

        final result = await AdminDepartmentController().fetchDepartments(
          page: page,
          limit: limit,
        );

        final newLeaves = result['departments'] as List<Department>;
        // state = AsyncValue.data(newLeaves);
        state = AsyncValue.data(newLeaves.reversed.toList());
        hasMore = newLeaves.length == limit;
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }

  }
  Future<void> loadMoreDepartments()async{
    if(!hasMore) return;
    try{
      page++;
      final result = await AdminDepartmentController().fetchDepartments(
        page: page, limit: limit,
      );
      final newLeaves = result['department'] as List<Department>;
      state = AsyncValue.data([...state.value ?? [], ...newLeaves]);
      hasMore = newLeaves.length == limit;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addDepartment(Department department) async {
    final current = state.value ?? [];
    state = AsyncValue.data([department, ...current]);
  }
  Future<void> updateDepartment(Department updated) async {
    final current = state.value ?? [];
    final newList = current.map((dep) {
      if (dep.id == updated.id) {
        return updated;
      }
      return dep;
    }).toList();
    state = AsyncValue.data(newList);
  }
  Future<void> deleteDepartment(String id) async {
    final current = state.value ?? [];
    final newList = current.where((dep) => dep.id != id).toList();
    state = AsyncValue.data(newList);
  }

}
final adminDepartmentProvider =
StateNotifierProvider<AdminDepartmentProvider, AsyncValue<List<Department>>>(
      (ref) => AdminDepartmentProvider(ref),
);

