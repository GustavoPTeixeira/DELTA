import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/user_model.dart';
void main() {
  group('UserModel Unit Tests', () {
    test('should instantiate UserModel correctly with all fields', () {
      final now = DateTime.now();
      final user = UserModel(
        uid: 'user123',
        name: 'Student Delta',
        username: 'delta_student',
        email: 'student@delta.edu',
        createdAt: now,
      );
      expect(user.uid, 'user123');
      expect(user.name, 'Student Delta');
      expect(user.username, 'delta_student');
      expect(user.email, 'student@delta.edu');
      expect(user.createdAt, now);
    });
    test('should serialize UserModel to Map correctly (toMap)', () {
      final fixedDate = DateTime(2026, 10, 20, 10, 0);
      final user = UserModel(
        uid: 'user456',
        name: 'Maria Silva',
        username: 'mariasilva',
        email: 'maria@delta.edu',
        createdAt: fixedDate,
      );
      final map = user.toMap();
      expect(map['uid'], 'user456');
      expect(map['name'], 'Maria Silva');
      expect(map['username'], 'mariasilva');
      expect(map['email'], 'maria@delta.edu');
      expect(map['createdAt'], isA<Timestamp>());
    });
    test('should deserialize Firestore Map to UserModel correctly (fromMap)', () {
      final now = DateTime(2026, 9, 15);
      final map = {
        'name': 'John Doe',
        'username': 'johndoe',
        'email': 'john@delta.edu',
        'createdAt': Timestamp.fromDate(now),
      };
      final user = UserModel.fromMap(map, 'doc_abc_789');
      expect(user.uid, 'doc_abc_789');
      expect(user.name, 'John Doe');
      expect(user.username, 'johndoe');
      expect(user.email, 'john@delta.edu');
      expect(user.createdAt?.day, now.day);
      expect(user.createdAt?.month, now.month);
      expect(user.createdAt?.year, now.year);
    });
    test('should handle missing fields in fromMap using safe fallback defaults', () {
      final emptyMap = <String, dynamic>{};
      final user = UserModel.fromMap(emptyMap, 'fallback_id');
      expect(user.uid, 'fallback_id');
      expect(user.name, '');
      expect(user.username, '');
      expect(user.email, '');
      expect(user.createdAt, isNotNull);
    });
    test('copyWith should update only specified fields and preserve existing ones', () {
      final original = UserModel(
        uid: 'uid_original',
        name: 'Original Name',
        username: 'original_username',
        email: 'original@delta.edu',
        createdAt: DateTime(2026, 1, 1),
      );
      final updated = original.copyWith(
        name: 'Updated Name',
        username: 'new_username',
      );
      expect(updated.uid, 'uid_original');
      expect(updated.name, 'Updated Name');
      expect(updated.username, 'new_username');
      expect(updated.email, 'original@delta.edu');
      expect(updated.createdAt, original.createdAt);
    });
  });
}