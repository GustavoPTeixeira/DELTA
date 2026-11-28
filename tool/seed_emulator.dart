// Seeds the local Firebase emulators with test users (BL-05).
//
// 1. Start the emulators:  firebase emulators:start --project delta-eae4d
// 2. In another terminal:  dart run tool/seed_emulator.dart
//
// It only talks to localhost, so it can never touch production.
// Running it again wipes the emulators and starts fresh.

import 'dart:convert';
import 'dart:io';

const projectId = 'delta-eae4d'; // must match lib/firebase_options.dart
const authHost = 'http://localhost:9099';
const firestoreHost = 'http://localhost:8080';
const password = 'delta123';

typedef TestUser = ({String name, String username, String email, String role});

const List<TestUser> testUsers = [
  (name: 'Aluno Teste', username: 'aluno', email: 'aluno@delta.test', role: 'student'),
  (name: 'Professor Pendente', username: 'pendente', email: 'pendente@delta.test', role: 'teacher_pending'),
  (name: 'Professor Teste', username: 'professor', email: 'professor@delta.test', role: 'teacher'),
];

Future<void> main() async {
  final client = HttpClient();
  try {
    await _clearEmulators(client);
    for (final user in testUsers) {
      final uid = await _createAuthUser(client, user.email);
      await _writeProfile(client, uid, user);
      stdout.writeln('✓ ${user.role.padRight(16)} ${user.username.padRight(10)} ${user.email}');
    }
    stdout.writeln('\nPassword for every user: $password');
    stdout.writeln('Emulator UI: http://localhost:4000');
  } on SocketException {
    stderr.writeln('Could not reach the emulators. Start them first:\n'
        '  firebase emulators:start --project $projectId');
    exitCode = 1;
  } finally {
    client.close();
  }
}

/// Deletes every account and document, so the script can run again.
Future<void> _clearEmulators(HttpClient client) async {
  await _send(client, 'DELETE', '$authHost/emulator/v1/projects/$projectId/accounts');
  await _send(client, 'DELETE',
      '$firestoreHost/emulator/v1/projects/$projectId/databases/(default)/documents');
}

/// Creates the login in the Auth emulator and returns its uid.
Future<String> _createAuthUser(HttpClient client, String email) async {
  final response = await _send(
    client,
    'POST',
    // The emulator accepts any API key.
    '$authHost/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key',
    body: {'email': email, 'password': password, 'returnSecureToken': true},
  );
  return response['localId'] as String;
}

/// Writes users/{uid} with the same fields as AuthService.register.
/// "Bearer owner" is an emulator-only token that skips the security rules,
/// like an admin editing in the console (that's how the teacher is "approved").
Future<void> _writeProfile(HttpClient client, String uid, TestUser user) async {
  await _send(
    client,
    'PATCH',
    '$firestoreHost/v1/projects/$projectId/databases/(default)/documents/users/$uid',
    headers: {'Authorization': 'Bearer owner'},
    body: {
      'fields': {
        'uid': {'stringValue': uid},
        'name': {'stringValue': user.name},
        'username': {'stringValue': user.username},
        'email': {'stringValue': user.email},
        'role': {'stringValue': user.role},
        'createdAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
      },
    },
  );
}

/// Sends a JSON request and returns the decoded JSON response.
Future<Map<String, dynamic>> _send(
  HttpClient client,
  String method,
  String url, {
  Map<String, Object?>? body,
  Map<String, String> headers = const {},
}) async {
  final request = await client.openUrl(method, Uri.parse(url));
  headers.forEach(request.headers.set);
  if (body != null) {
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));
  }
  final response = await request.close();
  final text = await response.transform(utf8.decoder).join();
  if (response.statusCode >= 300) {
    throw HttpException('$method $url failed (${response.statusCode}): $text');
  }
  return text.isEmpty ? {} : jsonDecode(text) as Map<String, dynamic>;
}
