import 'dart:convert';

class Department {
  final String id;
  final String name;
  final String address;

  Department({required this.id, required this.name, required this.address});

  factory Department.newDepartment() {
    return Department(
        id: '',
        name: '',
        address: ''
    );
  }

  Map<String, dynamic> toMap() {
    return {"id": this.id, "name": this.name, "address": this.address};
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  factory Department.fromMap(Map<String, dynamic> json) {
    return Department(id: json["_id"] ?? ''
        , name: json["name"] ?? '',
        address: json["address"] ?? ''
    );
  }

  factory Department.fromJson(String json){
    return Department.fromMap(jsonDecode(json));
  }

  String? departmentNameValidate(String? value) {
    if (value == null || value
        .trim()
        .isEmpty) {
      return '"Department Name" is not empty !';
    }
    return null;
  }

  String? departmentAddressValidate(String? value) {
    if (value == null || value
        .trim()
        .isEmpty) {
      return '"Department Address" is not empty !';
    }
    return null;
  }
}
