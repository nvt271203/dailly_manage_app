// lib/models/room.dart

import 'dart:convert';
import 'package:daily_manage_user_app/models/user.dart';


class Room {
  final String id;
  final List<String> members; // <-- THAY ĐỔI: Bây giờ là một List<User>
  final DateTime createdAt;
  final DateTime updatedAt;

  Room({
    required this.id,
    required this.members,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'members': members.map((x) => x.toString()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['_id'] ?? '',
      // DÙNG HÀM User.fromMap ĐỂ PHÂN TÍCH TỪNG THÀNH VIÊN
      members: List<String>.from(map['members']?.map((x) => x)),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Room.fromJson(String source) => Room.fromMap(json.decode(source));
}