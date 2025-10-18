import 'dart:convert';

import 'package:dio/dio.dart';

import '../../global_variables.dart';
import '../../models/user.dart';
import 'package:http/http.dart' as http;

class AdminUserController {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: uri,
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  Future<User?> requestUpdateStatusUser({
    required String id,
    required bool status
  })async{
    try{
      final response = await _dio.put(
        '/api/admin/user/$id',
        data: {
          "status": status,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final dynamic user = data;
        final userParse = User.fromMap(user);
        return userParse;
      } else {
        throw Exception('Failed to delete userParse: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Có phản hồi từ server nhưng không phải 2xx
        print('Status code: ${e.response?.statusCode}');
        print('Error data: ${e.response?.data}');
      } else {
        // Lỗi không nhận được phản hồi (timeout, mạng,...)
        print('Request error: ${e.message}');
      }

      print("Lỗi delete userParse: $e");
      return null;
    }
  }
  Future<Map<String, dynamic>> fetchUsers({
    int page = 1,
    int limit = 20,
    String? filterFullName,
  }) async {
    try {
      final response = await _dio.get(
        '/api/admin/users_pagination',
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (filterFullName != null && filterFullName.isNotEmpty)
            'filterFullName': filterFullName,
          // Thêm tham số search nếu filter không rỗng
        },
      );
      final data = response.data;
      print('result users - ${data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> list = data['data'];
        final users = list.map((item) => User.fromMap(item)).toList();
        return {'users': users};
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Có phản hồi từ server nhưng không phải 2xx
        print('Status code: ${e.response?.statusCode}');
        print('Error data: ${e.response?.data}');
      } else {
        // Lỗi không nhận được phản hồi (timeout, mạng,...)
        print('Request error: ${e.message}');
      }

      print("Lỗi khi lấy dữ liệu load more cho users admin page: $e");
      return {'users': <User>[]};
    }
  }

  // Future<User?> requestUpdateUser({
  //   required String id,
  //   required String department,
  //   String? position,
  // }) async {
  //   try {
  //     final response = await _dio.put(
  //       '/api/admin/user/$id',
  //       data: {
  //         "department": department,
  //         if (position != null) "position": position,
  //       },
  //     );
  //     // print('Data URL - $uri/api/admin/department/$idDepartment-$nameUpdate');
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final data = response.data;
  //       final dynamic user = data;
  //       final userParse = User.fromMap(user);
  //       return userParse;
  //     } else {
  //       throw Exception('Failed to load userParse: ${response.statusCode}');
  //     }
  //   } on DioException catch (e) {
  //     if (e.response != null) {
  //       // Có phản hồi từ server nhưng không phải 2xx
  //       print('Status code: ${e.response?.statusCode}');
  //       print('Error data: ${e.response?.data}');
  //     } else {
  //       // Lỗi không nhận được phản hồi (timeout, mạng,...)
  //       print('Request error: ${e.message}');
  //     }
  //
  //     print("Lỗi userParse: $e");
  //     return null;
  //   }
  // }
  Future<User?> requestUpdateUser({
    required String id,
    required String departmentId,
    String? positionId,
  }) async {
    try {
      final response = await _dio.put(
        '/api/admin/organization_user/$id',
        data: {
          "departmentId": departmentId,
          if (positionId != null) "positionId": positionId,
        },
      );
      // print('Data URL - $uri/api/admin/department/$idDepartment-$nameUpdate');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final dynamic user = data;
        final userParse = User.fromMap(user);
        return userParse;
      } else {
        throw Exception('Failed to load requestUpdateUser: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Có phản hồi từ server nhưng không phải 2xx
        print('Status code: ${e.response?.statusCode}');
        print('Error data: ${e.response?.data}');
      } else {
        // Lỗi không nhận được phản hồi (timeout, mạng,...)
        print('Request error: ${e.message}');
      }

      print("Lỗi userParse: $e");
      return null;
    }
  }}
