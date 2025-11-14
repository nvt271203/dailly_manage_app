import 'dart:convert';
import 'dart:io';

import 'package:daily_manage_user_app/models/message.dart';
import 'package:daily_manage_user_app/screens/common_screens/widgets/top_notification_widget.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global_variables.dart';
import '../../models/document.dart';
import '../../models/room.dart';

class AdminChatbotController {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: uri,
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final String _tokenKey = 'auth_token';

  // HÀM TÌM HOẶC TẠO PHÒNG CHAT
  Future<Room?> findOrCreateRoom({required String receiverId}) async {
    try {
      // --- THAY ĐỔI Ở ĐÂY ---
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(_tokenKey);
      if (token == null || token.isEmpty) return null;
      // -----------------------

      final res = await _dio.post(
        '/api/rooms/find-or-create',
        data: {'receiverId': receiverId},
        options: Options(
          headers: {
            'x-auth-token': token, // Gửi token trong header để xác thực
          },
        ),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        // PHÂN TÍCH TOÀN BỘ RESPONSE BODY THÀNH ĐỐI TƯỢNG ROOM
        final room = Room.fromMap(res.data);
        return room;
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<List<Message>> fetchMessagesPagination({
    required String roomId,
    required String senderId,
    int page = 1,
    int limit = 20,
  }) async {
    List<Message> messages = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(_tokenKey);
      if (token == null || token.isEmpty) {
        print('Lỗi: Không tìm thấy token xác thực.');
        return messages; // Trả về danh sách rỗng
      }
      final res = await _dio.get(
        '/api/messages/$roomId',
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
        options: Options(
          headers: {
            'x-auth-token': token, // Gửi token trong header để xác thực
          },
        ),
      );
      print('list messages data controller:  ${res.data}');

      if (res.statusCode == 200 && res.data != null) {
        // PHÂN TÍCH TOÀN BỘ RESPONSE BODY THÀNH ĐỐI TƯỢNG ROOM
        messages = (res.data['messages'] as List)
            .map((item) => Message.fromMap(item as Map<String, dynamic>))
            .toList();
        return messages;
      }
    } on DioException catch (e) {
      print('Lỗi Dio khi lấy tin nhắn: ${e.message}');
      if (e.response != null) {
        print('Data lỗi từ server: ${e.response?.data}');
      }
    } catch (e) {
      print('Lỗi không xác định khi lấy tin nhắn: $e');
    }
    return messages;
  }

  Future<Message?> requestMessage({
    required String roomId,
    required String text,
    // required DateTime date,
    // required String senderId,
    String? router,
    String? textRouter,
  }) async {
    try {
      Message message;
      // 1. Lấy token từ bộ nhớ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(_tokenKey);
      if (token == null || token.isEmpty) {
        print('Lỗi: Không tìm thấy token xác thực. Người dùng chưa đăng nhập.');
        return null;
      }

      message = Message(
        id: '',
        roomId: roomId,
        text: text,
        // date: date,
        // senderId: senderId,
      );

      print("Chuẩn bị gửi object message: $message");
      final response = await _dio.post(
        '/api/messages',
        data: message.toJson(),
        options: Options(
          headers: {
            'x-auth-token': token, // Gửi token trong header để xác thực
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final dynamic message = data;
        final messageParse = Message.fromMap(message);
        return messageParse;
      } else {
        throw Exception('Failed to load messageParse: ${response.statusCode}');
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

  // Trong class AdminChatbotController

  Future<Message?> askChatbot({
    required String roomId,
    required String text,
    String? router,
    String? textRouter,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(_tokenKey);
      if (token == null || token.isEmpty) return null;

      // Gọi đến endpoint mới của chatbot
      final response = await _dio.post(
        '/api/chatbot/ask', // <-- ENDPOINT MỚI
        data: {
          'roomId': roomId,
          'text': text,
          'router': router ?? null,
          'textRouter': textRouter ?? null,
        },
        options: Options(headers: {'x-auth-token': token}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Server trả về tin nhắn của chatbot, parse nó và hiển thị
        return Message.fromMap(response.data);
      }
    } catch (e) {
      print("Lỗi khi hỏi chatbot: $e");
      return null;
    }
    return null;
  }

  // // SỬA LẠI HÀM NÀY
  // Future<void> pickAndUploadFiles() async {
  //   // 1. CHỌN FILE
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['pdf'],
  //     allowMultiple: true,
  //   );
  //
  //   if (result == null || result.files.isEmpty) {
  //     // Người dùng hủy, chỉ cần return, không làm gì cả
  //     return;
  //   }
  //
  //   // 2. TẠO FORM-DATA
  //   try {
  //     List<MultipartFile> filesToUpload = [];
  //     for (PlatformFile file in result.files) {
  //       filesToUpload.add(
  //         await MultipartFile.fromFile(file.path!, filename: file.name),
  //       );
  //     }
  //
  //     FormData formData = FormData.fromMap({"files": filesToUpload});
  //
  //     // 3. GỬI YÊU CẦU
  //     Response response = await _dio.post(
  //       '$uriChatbotUser/upload',
  //       data: formData,
  //       onSendProgress: (int sent, int total) {
  //         print("Đang tải: ${((sent / total) * 100).toStringAsFixed(0)}%");
  //       },
  //     );
  //
  //     // 4. XỬ LÝ KẾT QUẢ
  //     if (response.statusCode != 200) {
  //       // Nếu server trả về lỗi (nhưng không phải 500)
  //       throw Exception("Server báo lỗi: ${response.data}");
  //     }
  //
  //     // Thành công, không cần làm gì, hàm sẽ tự kết thúc
  //   } on DioException catch (e) {
  //     // Ném lỗi Dio ra cho UI bắt
  //     throw Exception("Lỗi kết nối: ${e.message}");
  //   } catch (e) {
  //     // Ném lỗi chung ra cho UI bắt
  //     throw Exception("Đã xảy ra lỗi: $e");
  //   }
  // }
  //
  // // code logic upload pdf  chỉ 1 file
  // Future<String?> pickAndUploadPdfSingle() async {
  //   // 1. Chọn file PDF
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['pdf'],
  //   );
  //
  //   if (result != null && result.files.single.path != null) {
  //     File file = File(result.files.single.path!);
  //     String fileName = file.path.split('/').last;
  //
  //     // 2. Tạo FormData
  //     // Đây là cách để gửi file và text (nếu cần)
  //     FormData formData = FormData.fromMap({
  //       'name': 'Hợp đồng lao động $fileName', // Gửi thêm 1 trường 'name'
  //       'pdfFile': await MultipartFile.fromFile(file.path, filename: fileName),
  //     });
  //
  //     try {
  //       // 3. Gửi request POST bằng Dio
  //       Response response = await _dio.post(
  //         '/api/upload',
  //         data: formData,
  //         onSendProgress: (int sent, int total) {
  //           // Theo dõi tiến độ upload
  //           double progress = sent / total;
  //           print('Tiến độ upload: ${(progress * 100).toStringAsFixed(2)}%');
  //         },
  //       );
  //
  //       // 4. Xử lý kết quả
  //       if (response.statusCode == 201) {
  //         print('Upload thành công!');
  //         print('URL của file: ${response.data['document']['pdfUrl']}');
  //         return response.data['document']['pdfUrl'];
  //       } else {
  //         print('Upload thất bại: ${response.data['message']}');
  //         return null;
  //       }
  //     } on DioException catch (e) {
  //       print('Lỗi Dio: $e');
  //       return null;
  //     }
  //   } else {
  //     // Người dùng không chọn file
  //     print('Người dùng đã huỷ chọn file.');
  //     return null;
  //   }
  // }

  Future<List<Document>?> pickAndUploadPdfMulti() async {
    // 1. Chọn file PDF
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true, // <-- Cho phép upload nhiều file PDF
    );

    if (result != null && result.files.isNotEmpty) {
      // 2. Tạo FormData
      FormData formData = FormData(); // Tạo FormData rỗng

      // Lặp qua tất cả các file đã chọn
      for (var file in result.files) {
        if (file.path != null) {
          String fileName = file.name; // Dùng file.name cho đơn giản

          // Thêm từng file vào FormData với CÙNG MỘT KEY
          formData.files.add(
            MapEntry(
              'pdfFiles', // <-- Đặt tên key (ví dụ: 'pdfFiles')
              await MultipartFile.fromFile(file.path!, filename: fileName),
            ),
          );
        }
      }

      try {
        // 3. Gửi request POST bằng Dio
        Response response = await _dio.post(
          '/api/upload-multiple',
          data: formData,
          onSendProgress: (int sent, int total) {
            // Theo dõi tiến độ upload
            double progress = sent / total;
            print('Tiến độ upload: ${(progress * 100).toStringAsFixed(2)}%');
          },
          // ---- THÊM VÀO ĐÂY ----
          options: Options(
            // Đặt thời gian chờ nhận phản hồi (vd: 2 phút)
            receiveTimeout: Duration(minutes: 2),
          ),
          // ---------------------
        );

        // 4. Xử lý kết quả
        if (response.statusCode == 201) {
          print('Upload thành công!');

          List<Document> documents = (response.data['documents'] as List)
              .map((item) => Document.fromMap(item))
              .toList();

          print('Các URL của file: ${documents.length}');
          return documents;
        } else {
          print('Upload thất bại: ${response.data['message']}');
          return null;
        }
      } on DioException catch (e) {
        print('Lỗi Dio: $e');
        return null;
      }
    } else {
      // Người dùng không chọn file
      print('Người dùng đã huỷ chọn file.');
      return null;
    }
  }

  Future<List<Document>> fetchDocumentsPagination({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/documents_pagination',
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      );
      final documentsData = response.data;
      print('documents_pagination - ${documentsData}');
      if (response.statusCode == 200) {
        final List<dynamic> list = documentsData['documents'];
        print('body_raw: $list');
        final documents = list.map((item) => Document.fromMap(item)).toList();
        return documents;
      } else {
        throw Exception('Fail to load documents: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Ném lỗi Dio ra cho UI bắt
      throw Exception("Lỗi kết nối: ${e.message}");
    } catch (e) {
      // Ném lỗi chung ra cho UI bắt
      throw Exception("Đã xảy ra lỗi: $e");
    }
  }
}
