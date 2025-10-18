import 'dart:convert';

import 'package:daily_manage_user_app/models/user.dart';

class Message {
  final String id;
  final String roomId;
  final String text;
  DateTime? date;

  // Chúng ta giữ cả hai thuộc tính này
  String? senderId; // Sẽ chứa ID dạng String
  User? senderUser; // Sẽ chứa toàn bộ object User khi nhận về

  String? router;
  String? textRouter;

  Message({
    required this.id,
    required this.roomId,
    required this.text,
    this.date,
    this.senderId, // Cho phép khởi tạo chỉ với ID
    this.senderUser,
    this.router,
    this.textRouter,
  });

  // HÀM `fromMap` (Để nhận dữ liệu từ server)
  // Hàm này đã được thiết kế để xử lý object User lồng vào.
  factory Message.fromMap(Map<String, dynamic> json) {
    User? parsedSenderUser;
    String? parsedSenderId;

    if (json['senderId'] is Map<String, dynamic>) {
      // Trường hợp phổ biến: Nhận về danh sách tin nhắn với senderId là object
      parsedSenderUser = User.fromMap(json['senderId']);
      parsedSenderId = parsedSenderUser.id; // Lấy id từ object User
    } else if (json['senderId'] is String) {
      // Trường hợp dự phòng: Nếu server chỉ trả về ID
      parsedSenderId = json['senderId'];
    }

    return Message(
      id: json["_id"] ?? '',
      roomId: json["roomId"] ?? '',
      text: json["text"] ?? '',
      date: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      senderId: parsedSenderId,
      senderUser: parsedSenderUser,
      router: json["router"],
      textRouter: json["textRouter"],
    );
  }

  // HÀM `toMap` (Để gửi dữ liệu lên server)
  // Hàm này sẽ chỉ bao gồm những trường mà server cần khi TẠO mới tin nhắn.
  Map<String, dynamic> toMap() {
    // Khi gửi tin nhắn mới, server có thể không cần client gửi senderId,
    // vì nó có thể tự lấy ID người dùng từ token xác thực.
    // Chúng ta chỉ cần gửi những gì cần thiết để TẠO một tin nhắn.
    return {
      // "id" không cần gửi, server sẽ tự tạo
      "roomId": this.roomId,
      "text": this.text,
      // "date" không cần gửi, server sẽ tự tạo (createdAt)
      // "senderId" cũng không cần gửi, server sẽ lấy từ token.
      "router": this.router,
      "textRouter": this.textRouter,
    };
  }

  factory Message.fromJson(String json) => Message.fromMap(jsonDecode(json));
  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Message(id: $id, roomId: "$roomId", text: "$text", date: $date, senderId: "$senderId", senderUser: ${senderUser?.fullName})';
  }
}