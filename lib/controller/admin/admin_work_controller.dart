import 'dart:convert';

import 'package:daily_manage_user_app/models/work.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../../global_variables.dart';

class AdminWorkController {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: uri,
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );


  // Future<List<Work>> getAllWorks()async{
  //   try{
  //     http.Response response = await http.get(Uri.parse('$uri/api/works'),
  //       headers: <String, String>{
  //         "Content-Type": "application/json; charset=UTF-8",
  //       },
  //     );
  //     print('response result works: ${response.body}');
  //     if(response.statusCode == 200){
  //       List<dynamic> works = jsonDecode(response.body);
  //       if(works.isNotEmpty){
  //         return works.map((work) => Work.fromMap(work)).toList();
  //       }else{
  //         print('wok not found');
  //         return [];
  //       }
  //     }else if(response.statusCode == 404){
  //       print('work not found');
  //       return [];
  //     } else {
  //       throw Exception('Failed to load woks');
  //       return [];
  //     }    } catch (e) {
  //     print('Error request-response loadWorks: $e');
  //     return [];
  //   }
  // }

  Future<Map<String, dynamic>> fetchAllWorks({
    int page = 1,
    int limit = 12,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // http.Response response = await http.get(
      //   Uri.parse('$uri/api/admin/work_hours').replace(
      //     queryParameters: {
      //       'page': page.toString(),
      //       'limit': limit.toString(),
      //       if (startDate != null) 'startDate': startDate.toIso8601String(),
      //       if (endDate != null) 'endDate': endDate.toIso8601String(),
      //     }
      //   ),
      //   headers: <String, String>{
      //     "Content-Type": "application/json; charset=UTF-8",
      //   },
      // );
      final response = await _dio.get(
        '/api/admin/work_hours',
            queryParameters: {
              'page': page.toString(),
              'limit': limit.toString(),
              if (startDate != null) 'startDate': startDate.toIso8601String(),
              if (endDate != null) 'endDate': endDate.toIso8601String(),
            }

        ,
      );

      print('Request works: ${response.data}'); // Log URL
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> list = data['data'];
        final works = list.map((item) => Work.fromMap(item)).toList();
        return {
          'works': works,
        };

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

      print("Lỗi khi lấy dữ liệu phân trang cho works admin page: $e");
      return {'works': <Work>[]};
    }
  }
}
