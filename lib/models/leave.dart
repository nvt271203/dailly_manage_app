import 'dart:convert';
import 'package:daily_manage_user_app/models/user.dart';
import 'package:hive/hive.dart';

part 'leave.g.dart'; // Adapter sẽ tự sinh

const leaveType = ['Sick', 'Personal', 'Other'];
const leaveTimeType = ['Full Time', 'Part Time'];
const status = ['Pending', 'Approved', 'Rejected'];

@HiveType(typeId: 0)
class Leave extends HiveObject {

  @HiveField(0)
  final String id;
  @HiveField(1)
  final DateTime dateCreated;
  @HiveField(2)
  final DateTime startDate;
  @HiveField(3)
  final DateTime endDate;
  @HiveField(4)
  final String leaveType;
  @HiveField(5)
  final String leaveTimeType;
  @HiveField(6)
  final String reason;
  @HiveField(7)
  String status;
  @HiveField(8)
  String? rejectionReason;
  @HiveField(9)
  final String userId;
  @HiveField(10)
  bool isNew;
  @HiveField(11)
  final User? user; // Thêm trường user từ API

  Leave({
    required this.id,
    required this.dateCreated,
    required this.startDate,
    required this.endDate,
    required this.leaveType,
    required this.leaveTimeType,
    required this.reason,
    required this.status,
    required this.userId,
    this.isNew = true,
    this.rejectionReason,
    this.user,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "dateCreated": this.dateCreated.toUtc().toIso8601String(),
      "startDate": this.startDate.toUtc().toIso8601String(),
      "endDate": this.endDate.toUtc().toIso8601String(),
      "leaveType": this.leaveType,
      "leaveTimeType": this.leaveTimeType,
      "reason": this.reason,
      "status": this.status,
      "userId": this.userId,
    };
  }

  String toJson() => jsonEncode(toMap());
  Leave copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? dateCreated,
    String? leaveType,
    String? leaveTimeType,
    String? status,
    String? reason,
    bool? isNew,
    User? user, // Thêm tham số user
  }) {
    return Leave(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dateCreated: dateCreated ?? this.dateCreated,
      leaveType: leaveType ?? this.leaveType,
      leaveTimeType: leaveTimeType ?? this.leaveTimeType,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      isNew: isNew ?? this.isNew,
      userId: userId ?? this.userId,
      user: user ?? this.user, // Giữ lại user nếu không được truyền
    );
  }
  // factory Leave.fromMap(Map<String, dynamic> json) {
  //   return Leave(
  //     id: json["_id"],
  //     dateCreated: DateTime.parse(json["dateCreated"]).toLocal(),
  //     startDate: DateTime.parse(json["startDate"]).toLocal(),
  //     endDate: DateTime.parse(json["endDate"]).toLocal(),
  //     leaveType: json["leaveType"],
  //     leaveTimeType: json["leaveTimeType"],
  //     reason: json["reason"],
  //     status: json["status"],
  //     userId: json["userId"],
  //     // isNew: true, // Khi load lần đầu, coi là "mới"
  //     isNew : json['isNew'] as bool, // Đảm bảo ánh xạ đúng
  //     user: json['user'] != null ? Map<String, dynamic>.from(json['user']) : null,
  //
  //   );
  // }
  factory Leave.fromMap(Map<String, dynamic> json) {
    return Leave(
      id: json["_id"] ?? '',
      dateCreated: DateTime.tryParse(json["dateCreated"] ?? '')?.toLocal() ?? DateTime.now(),
      startDate: DateTime.tryParse(json["startDate"] ?? '')?.toLocal() ?? DateTime.now(),
      endDate: DateTime.tryParse(json["endDate"] ?? '')?.toLocal() ?? DateTime.now(),
      leaveType: json["leaveType"] ?? '',
      leaveTimeType: json["leaveTimeType"] ?? '',
      reason: json["reason"] ?? '', // có thể null
      status: json["status"] ?? '',
      userId: json["userId"] ?? '',
      isNew: json['isNew'] ?? true,
      rejectionReason: json['rejectionReason'] ?? null,
      user: json['user'] != null ? User.fromMap(json['user']) : null,
    );
  }
  factory Leave.fromJson(String json) => Leave.fromMap(jsonDecode(json));
  @override
  String toString() {
    return 'Leave(id: $id, dateCreated: $dateCreated, startDate: $startDate, endDate: $endDate, leaveType: $leaveType, status: $status, user: ${user.toString()})';
  }
}
