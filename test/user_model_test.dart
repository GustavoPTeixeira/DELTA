import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('UserModel Tests', () {
    final testDate = DateTime(2026, 9, 28, 12, 0);

    test('should properly serialize to Map', () {
      final user = UserModel(
        uid: 'user123',
        name: 'Aluno Teste',
        username: 'alunoteste',
        email: 'aluno@teste.com',
        createdAt: testDate,
      );

      final map = user.toMap();

      expect(map['uid'], 'user123');
      expect(map['name'], 'Aluno Teste');
      expect(map['username'], 'alunoteste');
      expect(map['email'], 'aluno@teste.com');
      expect(map['createdAt'], isA<Timestamp>());
    });

    test('should properly deserialize from Map', () {
      final map = {
        'name': 'Estudante Delta',
        'username': 'estudante_delta',
        'email': 'estudante@delta.edu',
        'createdAt': Timestamp.fromDate(testDate),
      };

      final user = UserModel.fromMap(map, 'doc_abc');

      expect(user.uid, 'doc_abc');
      expect(user.name, 'Estudante Delta');
      expect(user.username, 'estudante_delta');
      expect(user.email, 'estudante@delta.edu');
      expect(user.createdAt, testDate);
    });

    test('copyWith should update specified fields only', () {
      final user = UserModel(
        uid: 'user123',
        name: 'Nome Original',
        username: 'user_orig',
        email: 'user@delta.com',
        createdAt: testDate,
      );

      final updated = user.copyWith(
        name: 'Nome Atualizado',
        username: 'user_novo',
      );

      expect(updated.uid, 'user123');
      expect(updated.name, 'Nome Atualizado');
      expect(updated.username, 'user_novo');
      expect(updated.email, 'user@delta.com');
      expect(updated.createdAt, testDate);
    });
  });
}
