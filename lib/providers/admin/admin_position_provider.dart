import 'package:daily_manage_user_app/controller/admin/admin_position_controller.dart';
import 'package:daily_manage_user_app/models/position.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Trong file admin_position_provider.dart
final adminPositionProvider = StateNotifierProvider.family<AdminPositionProvider, AsyncValue<List<Position>>, String>(
      (ref, departmentId) => AdminPositionProvider(departmentId),
);

class AdminPositionProvider extends StateNotifier<AsyncValue<List<Position>>> {
  final String departmentId;

  AdminPositionProvider(this.departmentId) : super(const AsyncValue.loading()) {
    // fetchPositionsFirstPage();
  }

  Future<void> fetchPositionsFirstPage() async {
    try {
        state = const AsyncValue.loading();
      final result = await AdminPositionController().fetchAllPositionsByDepartment(departmentId: departmentId);
      final newPositions = result['positions'] as List<Position>;
      // state = AsyncValue.data(newLeaves);
      state = AsyncValue.data(newPositions.reversed.toList());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  //  Thêm vị trí mới
  Future<void> addPosition(Position newPosition) async {
    final current = state.value ?? [];
    state = AsyncValue.data([newPosition, ...current]);

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
  // Cập nhật vị trí
  Future<void> updatePosition(Position updatedPosition) async {
    // try {
    //   // Cập nhật state với vị trí đã chỉnh sửa
    //   state.whenData((positions) {
    //     final updatedPositions = positions.map((pos) {
    //       return pos.id == updatedPosition.id ? updatedPosition : pos;
    //     }).toList();
    //     state = AsyncValue.data(updatedPositions.reversed.toList());
    //   });
    // } catch (e, stackTrace) {
    // } catch (e, stackTrace) {
    //   state = AsyncValue.error(e, stackTrace);
    // }
    final current = state.value ?? [];
    final newList = current.map((dep) {
      if (dep.id == updatedPosition.id) {
        return updatedPosition;
      }
      return dep;
    }).toList();
    state = AsyncValue.data(newList);
  }

  // Xóa vị trí
  Future<void> deletePosition(String positionId) async {
    // try {
    //   // Cập nhật state bằng cách xóa vị trí
    //   state.whenData((positions) {
    //     final updatedPositions = positions.where((pos) => pos.id != positionId).toList();
    //     state = AsyncValue.data(updatedPositions.reversed.toList());
    //   });
    // } catch (e, stackTrace) {
    //   state = AsyncValue.error(e, stackTrace);
    // }
    final current = state.value ?? [];
    final newList = current.where((dep) => dep.id != positionId).toList();
    state = AsyncValue.data(newList);
  }

}
