import 'dart:convert';

import 'package:daily_manage_user_app/models/message.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global_variables.dart';
import '../../models/room.dart';

class UserChatbotController {
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
        queryParameters:{
          'page': page.toString(),
          'limit': limit.toString(),
        },
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
}
