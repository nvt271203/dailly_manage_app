import 'package:daily_manage_user_app/models/position.dart';
import 'package:dio/dio.dart';

import '../../global_variables.dart';

class AdminPositionController {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: uri,
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<Position?> requestNewPosition({
    required String departmentId,
    required String departmentName,
    required String positionName,
  }) async {
    try {
      Position position = Position(
        id: '',
        departmentId: departmentId,
        departmentName: departmentName,
        positionName: positionName,
      );
      final response = await _dio.post(
        '/api/admin/position',
        data: position.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final dynamic position = data;
        final positionParse = Position.fromMap(position);
        return positionParse;
      } else {
        throw Exception('Failed to load positionParse: ${response.statusCode}');
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

      print("Lỗi positionParse: $e");
      return null;
    }
  }
  Future<Position?> requestUpdatePosition({
    required String id,
    required String departmentName,
    required String positionName,
  })async{
    try{

      final response = await _dio.put(
          '/api/admin/position/$id',
          data: {
            "departmentName" : departmentName,
            "positionName" : positionName
          }
      );
      // print('Data URL - $uri/api/admin/department/$idDepartment-$nameUpdate');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final dynamic position = data;
        final positionParse = Position.fromMap(position);
        return positionParse;
      } else {
        throw Exception('Failed to load positionParse: ${response.statusCode}');
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

      print("Lỗi positionParse: $e");
      return null;
    }
  }
  Future<Position?> requestDeletePosition({
    required String id,
  })async{
    try{
      final response = await _dio.delete(
        '/api/admin/position/$id',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final dynamic position = data;
        final positionParse = Position.fromMap(position);
        return positionParse;
      } else {
        throw Exception('Failed to delete positionParse: ${response.statusCode}');
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

      print("Lỗi delete positionParse: $e");
      return null;
    }
  }
  Future<Position?> fetchOnePosition({
    required String id
  }) async {
    try {
      final response = await _dio.get(
        '/api/admin/position/$id',
      );
      final data = response.data;
      print('position_data - ${data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final dynamic list = data;
        final position =  Position.fromMap(list);
        return position;
      } else {
        throw Exception('Failed to load position: ${response.statusCode}');
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

      print("Lỗi khi lấy dữ liệu phân trang cho position page: $e");
      return null;
    }
  }
  Future<Map<String, dynamic>> fetchAllPositionsByDepartment({
    required String departmentId,
  }) async {
    try {
      final response = await _dio.get('/api/admin/positions/$departmentId');
      final data = response.data;
      print('positions_data - ${data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> list = data;
        final positions = list
            .map((item) => Position.fromMap(item))
            .toList();
        return {'positions': positions};
      } else {
        throw Exception('Failed to load positions: ${response.statusCode}');
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

      print("Lỗi khi lấy dữ liệu all cho positions page: $e");
      return {'positions': <Position>[]};
    }
  }
}
