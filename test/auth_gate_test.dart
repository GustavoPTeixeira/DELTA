import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/pending_approval_screen.dart';
import 'package:flutter_application_1/screens/subjects_screen.dart';
import 'package:flutter_application_1/screens/teacher_home_screen.dart';
import 'package:flutter_application_1/services/auth_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() => firestore = FakeFirebaseFirestore());

  AuthService signedInAs(String uid) => AuthService(
        auth: MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: uid)),
        firestore: firestore,
      );

  Future<void> saveProfile(String uid, String role) {
    return firestore.collection('users').doc(uid).set({
      'name': 'Test User',
      'username': 'test_$uid',
      'email': '$uid@delta.edu',
      'role': role,
    });
  }

  // The loading spinner never settles, so pump a few frames instead of pumpAndSettle.
  Future<void> pumpFrames(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  group('AuthGate role routing (DEL-4 / BL-19)', () {
    testWidgets('AC1: a teacher lands on the teacher area', (tester) async {
      await saveProfile('t1', 'teacher');
      await tester.pumpWidget(DeltaApp(authService: signedInAs('t1')));
      await pumpFrames(tester);

      expect(find.byType(TeacherHomeScreen), findsOneWidget);
      expect(find.byType(SubjectsScreen), findsNothing);
    });

    testWidgets('AC2: a student lands on Matérias', (tester) async {
      await saveProfile('s1', 'student');
      await tester.pumpWidget(DeltaApp(authService: signedInAs('s1')));
      await pumpFrames(tester);

      expect(find.byType(SubjectsScreen), findsOneWidget);
      expect(find.byType(TeacherHomeScreen), findsNothing);
    });

    testWidgets('AC2: a legacy profile without role is treated as a student', (tester) async {
      await firestore.collection('users').doc('legacy').set({'name': 'Legacy'});
      await tester.pumpWidget(DeltaApp(authService: signedInAs('legacy')));
      await pumpFrames(tester);

      expect(find.byType(SubjectsScreen), findsOneWidget);
    });

    testWidgets('AC4: a pending teacher sees "Aguardando aprovação", not the teacher area',
        (tester) async {
      await saveProfile('p1', 'teacher_pending');
      await tester.pumpWidget(DeltaApp(authService: signedInAs('p1')));
      await pumpFrames(tester);

      expect(find.byType(PendingApprovalScreen), findsOneWidget);
      expect(find.text('Aguardando aprovação'), findsOneWidget);
      expect(find.byType(TeacherHomeScreen), findsNothing);
    });

    testWidgets('an admin promotion moves a pending teacher to the teacher area live',
        (tester) async {
      await saveProfile('p2', 'teacher_pending');
      await tester.pumpWidget(DeltaApp(authService: signedInAs('p2')));
      await pumpFrames(tester);
      expect(find.byType(PendingApprovalScreen), findsOneWidget);

      await firestore.collection('users').doc('p2').update({'role': 'teacher'});
      await pumpFrames(tester);

      expect(find.byType(TeacherHomeScreen), findsOneWidget);
    });

    testWidgets('sign-up race: waits for the profile instead of showing the student area',
        (tester) async {
      await tester.pumpWidget(DeltaApp(authService: signedInAs('new')));
      await pumpFrames(tester);

      expect(find.text('Preparando sua conta…'), findsOneWidget);
      expect(find.byType(SubjectsScreen), findsNothing);

      await saveProfile('new', 'teacher');
      await pumpFrames(tester);

      expect(find.byType(TeacherHomeScreen), findsOneWidget);
    });

    testWidgets('a signed-out user sees the login screen', (tester) async {
      final service = AuthService(auth: MockFirebaseAuth(), firestore: firestore);
      await tester.pumpWidget(DeltaApp(authService: service));
      await pumpFrames(tester);

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
