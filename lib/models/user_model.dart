import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student,
  teacher;

static UserRole fromString(String? value) {
  if (value?.trim().toLowerCase() == 'teacher'){
    return UserRole.teacher;
  }
  return UserRole.student;
}
}

class UserModel {
  final String uid;
  final String name;
  final String username;
  final String email;
  final UserRole role;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    this.role = UserRole.student,
    this.createdAt,
  });

  bool get isTeacher => role == UserRole.teacher;

   UserModel copyWith({
    String? uid,
    String? name,
    String? username,
    String? email,
    UserRole? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'email': email,
      'role': role.name,
      'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime? parsedDate;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedDate = (map['createdAt'] as Timestamp).toDate();
    }
  }

  return UserModel(
    uid: documentId,
    name: map['name'] ?? '',
    username: map['username'] as String? ?? '',
    email: map['email'] as String? ?? '',
    role: UserRole.fromString(map['role'] as String?),
    createdAt: parsedDate ?? DateTime.now(), 
  );
}
}