import 'package:daily_manage_user_app/models/vector_store.dart';
import 'package:dio/dio.dart';

import '../../global_variables.dart';

class AdminDocumentController {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: uriChatbotUser,
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  Future<VectorStore> uploadVectorStoreSingle(){
    try {


      // 3. Gửi request POST bằng Dio
      Response response = await _dio.post(
        '/api/upload',
        data: formData,
        onSendProgress: (int sent, int total) {
          // Theo dõi tiến độ upload
          double progress = sent / total;
          print('Tiến độ upload: ${(progress * 100).toStringAsFixed(2)}%');
        },
      );

      // 4. Xử lý kết quả
      if (response.statusCode == 201) {
        print('Upload thành công!');
        print('URL của file: ${response.data['document']['pdfUrl']}');
        return response.data['document']['pdfUrl'];
      } else {
        print('Upload thất bại: ${response.data['message']}');
        return null;
      }
    } on DioException catch (e) {
      print('Lỗi Dio: $e');
      return null;
    }
  }
}