import 'package:dio/dio.dart';

import '../../global_variables.dart';
import '../../models/leave.dart';

class AdminLeaveController {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: uri,
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  Future<Map<String, dynamic>> fetchLeaves({
    int page = 1,
    int limit = 12,
    int filterYear = 2025,
    String yearField = 'startDate',
    String sortField = 'startDate',
    String sortOrder = 'desc',
    String status = 'all',
  }) async {
    try {
      final response = await _dio.get(
      '/api/admin/leaves_user_pagination',
      queryParameters: {
      'page': page.toString(),
          'limit': limit.toString(),
          'filterYear': filterYear,
          // 'yearField': yearField,
          'sortField': sortField,
          'sortOrder': sortOrder,
          'status': status,
        },
      );
      final data = response.data;
      print('leaves_user_pagination - ${data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> list = data['data'];
        final leaves = list.map((item) => Leave.fromMap(item)).toList();
        return {'leaves': leaves};
      } else {
        throw Exception('Failed to load work hours: ${response.statusCode}');
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

      print("Lỗi khi lấy dữ liệu phân trang cho leaves admin page: $e");
      return {'leaves': <Leave>[]};
    }
  }
  Future<Leave?> leaveRemoveIsNew({
    required String id
})async{
    try{
      final response = await _dio.put(
        '/api/admin/leave_remove_isnew/${id}',
        data: {
          'status': status, // Gửi status trong body
        },
      );

      final dynamic leave = response.data;
      final leaveParse = Leave.fromMap(leave);
      return leaveParse;

    } on DioException catch (e) {
      if (e.response != null) {
        // Có phản hồi từ server nhưng không phải 2xx
        print('Status code: ${e.response?.statusCode}');
        print('Error data: ${e.response?.data}');
      } else {
        // Lỗi không nhận được phản hồi (timeout, mạng,...)
        print('Request error: ${e.message}');
      }

      print("Lỗi khi cập nhập trạng thái đơn nghỉ phép cho user: $e");
      return null;
    }
  }
  Future<Leave?> leaveRequestHandel({
    required String id,
    required String status,
    String? rejectionReason
})async{
    try{
      final response = await _dio.put(
        '/api/admin/leave_request_handle/${id}',
        data: {
          'status': status, // Gửi status trong body
          if(rejectionReason != null)
          'rejectionReason': rejectionReason
        },
      );
      final data = response.data;
      print('Request sent: id=$id, status=$status');
      print('leaves-request-handle - ${data}');
      if (response.statusCode == 200) {
        final data = response.data;
        final dynamic leave = data;
        final leaveParse = Leave.fromMap(leave);
        return leaveParse;
      } else {
        throw Exception('Failed to load work hours: ${response.statusCode}');
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

      print("Lỗi khi cập nhập trạng thái đơn nghỉ phép cho user: $e");
      return null;
    }
  }
}
