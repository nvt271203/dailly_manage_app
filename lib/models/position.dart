import 'dart:convert';

class Position {
  final String id;
  final String departmentId;
  final String departmentName;
  final String positionName;

  Position({required this.id, required this.departmentId, required this.departmentName, required this.positionName});

  factory Position.fromMap(Map<String, dynamic> json) {
    return Position(id: json["_id"] ?? '',
      departmentId: json["departmentId"] ?? '',
      departmentName: json["departmentName"] ?? '',
      positionName: json["positionName"] ?? '',);
  }
  factory Position.fromJson(String json) {
    return Position.fromMap(jsonDecode(json));
  }

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "departmentId": this.departmentId,
      "departmentName": this.departmentName,
      "positionName": this.positionName,
    };
  }
  String toJson(){
    return jsonEncode(toMap());
  }


}