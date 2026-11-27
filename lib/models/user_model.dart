import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student('student'),
  // Signed up as "Professor"; waits for an admin to set role to 'teacher'.
  teacherPending('teacher_pending'),
  teacher('teacher');

  const UserRole(this.value);

  /// Value stored in Firestore.
  final String value;

  static UserRole fromString(String? value) {
    final normalized = value?.trim().toLowerCase();
    return UserRole.values.firstWhere(
      (role) => role.value == normalized,
      orElse: () => UserRole.student,
    );
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
  bool get isPendingTeacher => role == UserRole.teacherPending;

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
      'role': role.value,
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