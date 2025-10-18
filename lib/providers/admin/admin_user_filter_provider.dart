import 'package:daily_manage_user_app/models/user_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class AdminUserFilterProvider extends StateNotifier<UserFilter>{
  AdminUserFilterProvider() : super(UserFilter(
    filterFullName: ''
  ));
  void setFullName(String fullName){
    state = state.copyWith(filterFullName: fullName);
  }
}
final adminUserFilterProvider =
StateNotifierProvider<AdminUserFilterProvider, UserFilter>(
      (ref) => AdminUserFilterProvider(),
);