import 'package:daily_manage_user_app/models/leave_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class AdminLeaveFilterProvider extends StateNotifier<LeaveFilterState>{
  AdminLeaveFilterProvider() : super(const LeaveFilterState(
    sortField: 'startDate',
    sortOrder: 'desc',
    status: 'all',
    filterYear: 2025,

  ));

  void setSort(String sortField, String sortOrder) {
    state = state.copyWith(sortField: sortField, sortOrder: sortOrder);
  }

  void setStatus(String status) {
    state = state.copyWith(status: status);
  }

  void setYear(int year) {
    state = state.copyWith(filterYear: year);
  }

  // void reset() {
  //   state = const LeaveFilterState();
  // }
}
final adminLeaveFilterProvider =
StateNotifierProvider<AdminLeaveFilterProvider, LeaveFilterState>(
      (ref) => AdminLeaveFilterProvider(),
);