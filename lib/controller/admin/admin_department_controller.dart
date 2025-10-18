import 'package:daily_manage_user_app/models/department.dart';
import 'package:dio/dio.dart';

import '../../global_variables.dart';

class AdminDepartmentController {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: uri,
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  Future<Department?> fetchOneDepartment({
    required String id
  }) async {
    try {
      final response = await _dio.get(
        '/api/admin/department/$id',
      );
      final data = response.data;
      print('department_data - ${data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final dynamic list = data;
        final department =  Department.fromMap(list);
        return department;
      } else {
        throw Exception('Failed to load department: ${response.statusCode}');
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

      print("Lỗi khi lấy dữ liệu phân trang cho departments page: $e");
      return null;
    }
  }
  Future<Map<String, dynamic>> fetchDepartments({
    int page = 1,
    int limit = 12,
  }) async {
    try {
      final response = await _dio.get(
        '/api/admin/departments_pagination',
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );
      final data = response.data;
      print('departments_data - ${data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> list = data['data'];
        final departments = list.map((item) => Department.fromMap(item)).toList();
        return {'departments': departments};
      } else {
        throw Exception('Failed to load departments: ${response.statusCode}');
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

      print("Lỗi khi lấy dữ liệu phân trang cho departments page: $e");
      return {'departments': <Department>[]};
    }
  }

  Future<Map<String, dynamic>> fetchAllDepartments() async {
    try {
      final response = await _dio.get(
        '/api/admin/departments',
      );
      final data = response.data;
      print('departments_data - ${data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> list = data;
        final departments = list.map((item) => Department.fromMap(item)).toList();
        return {'departments': departments};
      } else {
        throw Exception('Failed to load departments: ${response.statusCode}');
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

      print("Lỗi khi lấy dữ liệu all cho departments page: $e");
      return {'departments': <Department>[]};
    }
  }

  Future<Department?> requestNewDepartment({
    required String nameDepartment,
    required String addressDepartment
})async{
    try{
      final response = await _dio.post(
        '/api/admin/department',
        data: {
          'name': nameDepartment,
          'address': addressDepartment
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final dynamic department = data;
        final departmentParse = Department.fromMap(department);
        return departmentParse;
      } else {
        throw Exception('Failed to load departmentParse: ${response.statusCode}');
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

      print("Lỗi departmentParse: $e");
      return null;
    }
  }

  Future<Department?> requestUpdateDepartment({
    required String idDepartment,
    required String nameUpdate,
    required String addressUpdate,
  })async{
    try{
      final response = await _dio.put(
        '/api/admin/department/$idDepartment',
        data: {
          "name" : nameUpdate,
          "address" : addressUpdate
        }
      );
      print('Data URL - $uri/api/admin/department/$idDepartment-$nameUpdate');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final dynamic department = data;
        final departmentParse = Department.fromMap(department);
        return departmentParse;
      } else {
        throw Exception('Failed to load departmentParse: ${response.statusCode}');
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

      print("Lỗi departmentParse: $e");
      return null;
    }
  }
  Future<Department?> requestDeleteDepartment({
    required String idDepartment,
  })async{
    try{
      final response = await _dio.delete(
          '/api/admin/department/$idDepartment',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final dynamic department = data;
        final departmentParse = Department.fromMap(department);
        return departmentParse;
      } else {
        throw Exception('Failed to delete departmentParse: ${response.statusCode}');
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

      print("Lỗi delete departmentParse: $e");
      return null;
    }
  }
}