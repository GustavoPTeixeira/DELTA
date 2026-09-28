import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String username;
  final String email;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'email': email,
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
      createdAt: parsedDate ?? DateTime.now(),
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? username,
    String? email,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
