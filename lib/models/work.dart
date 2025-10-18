import 'dart:async';
import 'dart:convert';
import 'package:daily_manage_user_app/models/user.dart';
import 'package:hive/hive.dart';

part 'work.g.dart'; // Adapter sẽ tự sinh

@HiveType(typeId: 1) // Đảm bảo ID là duy nhất (khác với Leave)
class Work {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final DateTime checkInTime;
  @HiveField(2)
  final DateTime? checkOutTime;
  @HiveField(3)
  final Duration? workTime;
  @HiveField(4)
  final String report;
  @HiveField(5)
  final String plan;
  @HiveField(6)
  final String note;
  @HiveField(7)
  final String userId;
  @HiveField(8)
  final User? user; // Thêm trường user từ API

  Work({
    required this.id,
    required this.checkInTime,
    required this.checkOutTime,
    required this.workTime,
    required this.report,
    required this.plan,
    this.note = 'Nothing',
    required this.userId,
    this.user
  });

  // factory Work.fromMap(Map<String, dynamic> json) {
  //   return Work(id: json["_id"] ?? '',
  //     //PHải có toLocal để nó convert từ giờ UTC về giờ địa phương
  //     checkInTime: DateTime.parse(json["checkInTime"]).toLocal(),
  //     checkOutTime: DateTime.parse(json["checkOutTime"]).toLocal(),
  //     // Dùng vầy tgian lưu bị về 0 - sẽ lưu về tổng số giây
  //     // workTime: DateTime.parse(json["workTime"]).difference(DateTime.utc(1970, 1, 1)),
  //     workTime: Duration(seconds: json["workTime"] ?? ''),
  //     report_management: json["report_management"] ?? '',
  //     plan: json["plan"] ?? '',
  //     note: json["note"] ?? 'Nothingg',
  //     userId: json["userId"] ?? '',);
  // }
  factory Work.fromMap(Map<String, dynamic> json) {
    return Work(
      id: json["_id"] ?? '',
      checkInTime:
          DateTime.tryParse(json["checkInTime"] ?? '')?.toLocal() ??
          DateTime.now(),
      checkOutTime:
          DateTime.tryParse(json["checkOutTime"] ?? '')?.toLocal() ?? null,
      // workTime: Duration(
      //   seconds: int.tryParse(json["workTime"]?.toString() ?? '') ?? 0,
      // ),
      workTime: json["workTime"] != null
          ? Duration(seconds: int.tryParse(json["workTime"].toString()) ?? 0)
          : null,
      report: json["report"] ?? '',
      plan: json["plan"] ?? '',
      note: json["note"] ?? '',
      userId: json["userId"] ?? '',
      user: json['user'] != null ? User.fromMap(json['user']) : null,

    );
  }

  factory Work.fromJson(String json) => Work.fromMap(jsonDecode(json));

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      // .toIso8601String() - sẽ bị trừ lui 7 tiếng;
      // "checkInTime": this.checkInTime.toIso8601String(),
      // "checkOutTime": this.checkOutTime.toIso8601String(),
      "checkInTime": this.checkInTime.toUtc().toIso8601String(),
      // 👈 thêm .toUtc()
      "checkOutTime": this.checkOutTime!.toUtc().toIso8601String(),
      // 👈 thêm .toUtc()
      // Dùng vầy tgian lưu bị về 0
      // "workTime": this.workTime.inSeconds,
      "workTime": this.workTime!.inSeconds,
      "report_management": this.report,
      "plan": this.plan,
      "note": this.note,
      "userId": this.userId,
    };
  }

  String toJson() => jsonEncode(toMap());

  @override
  String toString() {
    return 'Work(id=$id, checkIn=$checkInTime, checkOut=$checkOutTime, workTime=$workTime, report_management=$report, plan=$plan, note=$note, userId=$userId)';
  }
}
