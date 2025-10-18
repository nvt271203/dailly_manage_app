import 'dart:convert';

import 'position.dart';

import 'department.dart';

const sex = ['Female', 'Male'];

class User {
  final String id;
  final String role;
  final String fullName;
  final DateTime? birthDay;
  final String? sex;
  final String email;
  final String password;
  final String image;
  final String phoneNumber;
  Department? department;
  Position? position;
  String? departmentId;
  String? positionId;
  bool status;
  final String token;
  final DateTime? createdAt;

  User copyWith({
    String? id,
    String? role,
    String? fullName,
    DateTime? birthDay,
    String? sex,
    String? email,
    String? password,
    String? image,
    String? phoneNumber,
    String? token,
    bool? status,
    Department? department,
    Position? position,
    String? departmentId,
    String? positionId,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      birthDay: birthDay ?? this.birthDay,
      sex: sex ?? this.sex,
      email: email ?? this.email,
      password: password ?? this.password,
      image: image ?? this.image,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      token: token ?? this.token,
      status: status ?? this.status,
      department: department ?? this.department,
      position: position ?? this.position,
      departmentId: departmentId ?? this.departmentId,
      positionId: positionId ?? this.positionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "role": this.role,
      "fullName": this.fullName,
      "birthDay": birthDay != null ? birthDay!.toIso8601String() : null,
      "sex": this.sex,
      "email": this.email,
      "password": this.password,
      "image": this.image,
      "phoneNumber": this.phoneNumber,
    };
  }

  String toJson() => json.encode(toMap());

  factory User.fromMap(Map<String, dynamic> json) {
    return User(
      id: json["_id"] ?? "",
      role: json["role"] ?? "",
      fullName: json["fullName"] ?? "",
      birthDay: json["birthDay"] != null
          ? DateTime.parse(json["birthDay"])
          : null,
      sex: json["sex"] ?? null,
      email: json["email"] ?? "",
      password: json["password"] ?? "",
      image: json["image"] ?? "",
      // department: json["department"] ?? null,
      department: json['department'] != null ? Department.fromMap(json['department']) : null,
      position: json['position'] != null ? Position.fromMap(json['position']) : null,

      status: json["status"] ?? null,
      departmentId: json["departmentId"] ?? null,
      positionId: json["positionId"] ?? null,
      phoneNumber: json["phoneNumber"] ?? "",
      token: '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json["createdAt"])
          : null,
    );
  }

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  factory User.newUser() {
    return User(
      id: '',
      role: '',
      fullName: '',
      birthDay: null,
      sex: '',
      email: '',
      password: '',
      status: true,
      image: '',
      phoneNumber: '',
      token: '',
    );
  }

  User({
    required this.id,
    required this.role,
    required this.fullName,
    required this.birthDay,
    required this.sex,
    required this.email,
    required this.password,
    required this.image,
    required this.phoneNumber,
    required this.token,
    required this.status,
    this.position,
    this.department,
    this.departmentId,
    this.positionId,
    this.createdAt,
  });

  // Hàm tính tuổi hiện tại dựa trên birthDay
  int? calculateAge() {
    if (birthDay == null) {
      return null; // Trả về null nếu birthDay không được cung cấp
    }

    final now = DateTime.now();
    int age = now.year - birthDay!.year;

    // Kiểm tra xem ngày sinh nhật trong năm nay đã qua hay chưa
    if (now.month < birthDay!.month ||
        (now.month == birthDay!.month && now.day < birthDay!.day)) {
      age--; // Giảm tuổi đi 1 nếu sinh nhật năm nay chưa đến
    }

    return age;
  }

  String? fullNameValidate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '"Full name" is not empty !';
    }
    return null;
  }

  String? phoneNumberValidate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '"Full name" is not empty !';
    }
    // Kiểm tra nếu có ký tự không phải là số
    final isNumeric = RegExp(r'^\d+$');
    if (!isNumeric.hasMatch(value.trim())) {
      return '"Phone number" is not string type !';
    }
    if (value.length < 9 || value.length > 12) {
      return '"Phone Number" must be 9 to 12 digits long !';
    }
    return null;
  }

  String? birthDayValidate(DateTime? value) {
    if (value == null) {
      return 'Please choose birthday';
    }
    return null;
  }

  String? sexValidate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please choose sex';
    }
    return null;
  }

  String? emailValidate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '"Email" cannot be blank !';
    }
    // Biểu thức chính quy để kiểm tra định dạng email
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

    if (!emailRegex.hasMatch(value.trim())) {
      return '"EMAIL" must be a valid email !';
    }
    return null;
  }

  String? passwordValidate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '"Password" cannot be blank !';
    }
    if (value.trim().length < 8) {
      return '"Password" must be at least 8 characters!';
    }
    return null;
  }

  String? confirmPasswordValidateMatch(
    String? value,
    String? originalPassword,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '"Confirm Password" cannot be blank!';
    }
    if (originalPassword == null || originalPassword.trim().isEmpty) {
      return '"Password" must be entered before confirming!';
    }
    if (value.trim() != originalPassword.trim()) {
      return '"Confirm Password" does not match!';
    }
    return null;
  }

  @override
  String toString() {
    return 'User('
        'id: $id, '
        'role: $role, '
        'fullName: $fullName, '
        'birthDay: $birthDay, '
        'sex: $sex, '
        'email: $email, '
        'password: $password, '
        'image: $image, '
        'phoneNumber: $phoneNumber, '
        'position: $position, '
        'department: $department, '
        'token: $token, '
        'createdAt: $createdAt'
        ')';
  }
}
