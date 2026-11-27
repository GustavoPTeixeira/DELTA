import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/services/auth_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late AuthService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth();
    service = AuthService(auth: auth, firestore: firestore);
  });

  group('AuthService.register roles (BL-19)', () {
    test('a sign-up as Professor is stored as teacher_pending, never teacher', () async {
      final created = await service.register(
        name: 'Rita Lopes',
        username: 'rita',
        email: 'rita@delta.edu',
        password: 'segredo123',
        role: UserRole.teacher,
      );

      final doc = await firestore.collection('users').doc(created.uid).get();
      expect(doc.data()!['role'], 'teacher_pending');
      expect(created.isPendingTeacher, isTrue);
      expect(created.isTeacher, isFalse);
    });

    test('a student sign-up is stored as student', () async {
      final created = await service.register(
        name: 'Maria Souza',
        username: 'maria',
        email: 'maria@delta.edu',
        password: 'segredo123',
      );

      final doc = await firestore.collection('users').doc(created.uid).get();
      expect(doc.data()!['role'], 'student');
    });
  });

  group('AuthService.watchUserProfile (BL-19)', () {
    test('emits null until the profile exists, then the profile', () async {
      final emissions = <UserModel?>[];
      final subscription = service.watchUserProfile('u1').listen(emissions.add);

      await pumpEventQueue();
      expect(emissions, [isNull]);

      await firestore.collection('users').doc('u1').set({
        'name': 'Rita Lopes',
        'username': 'rita',
        'email': 'rita@delta.edu',
        'role': 'teacher',
      });
      await pumpEventQueue();

      expect(emissions.last?.isTeacher, isTrue);
      await subscription.cancel();
    });

    test('reflects an admin promotion from teacher_pending to teacher', () async {
      final users = firestore.collection('users');
      await users.doc('u2').set({'name': 'Rita', 'role': 'teacher_pending'});

      final emissions = <UserModel?>[];
      final subscription = service.watchUserProfile('u2').listen(emissions.add);
      await pumpEventQueue();
      expect(emissions.last?.isPendingTeacher, isTrue);

      await users.doc('u2').update({'role': 'teacher'});
      await pumpEventQueue();
      expect(emissions.last?.isTeacher, isTrue);

      await subscription.cancel();
    });
  });
}
