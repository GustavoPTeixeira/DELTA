import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'models/user_model.dart';
import 'screens/login_screen.dart';
import 'screens/pending_approval_screen.dart';
import 'screens/subjects_screen.dart';
import 'screens/teacher_home_screen.dart';
import 'services/auth_service.dart';

/// Set with: flutter run --dart-define=USE_EMULATORS=true
const bool useEmulators = bool.fromEnvironment('USE_EMULATORS');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (useEmulators) await _connectToEmulators();

  runApp(const DeltaApp());
}

/// Points Auth and Firestore to the local Emulator Suite instead of production.
Future<void> _connectToEmulators() async {
  // The Android emulator reaches your computer through 10.0.2.2, not localhost.
  final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  final host = isAndroid ? '10.0.2.2' : 'localhost';

  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  debugPrint('DELTA is using the local Firebase emulators at $host');
}

class DeltaApp extends StatelessWidget {
  final AuthService? authService;
  const DeltaApp({super.key, this.authService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delta App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: AuthGate(authService: authService),
    );
  }
}

/// Decides the first screen from the signed-in user and their role.
class AuthGate extends StatefulWidget {
  final AuthService? authService;
  const AuthGate({super.key, this.authService});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthService _authService = widget.authService ?? AuthService();
  late final Stream<User?> _authState = _authService.authStateChanges;

  // Cached per uid so rebuilds don't resubscribe to Firestore.
  String? _profileUid;
  Stream<UserModel?>? _profileStream;

  Stream<UserModel?> _profileFor(String uid) {
    if (_profileUid != uid || _profileStream == null) {
      _profileUid = uid;
      _profileStream = _authService.watchUserProfile(uid);
    }
    return _profileStream!;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authState,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final user = authSnapshot.data;
        if (user == null) {
          return LoginScreen(authService: widget.authService);
        }

        return StreamBuilder<UserModel?>(
          stream: _profileFor(user.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.hasError) {
              return _ProfileErrorScreen(
                onRetry: () => setState(() => _profileStream = null),
                onLogout: _authService.logout,
              );
            }

            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            final profile = profileSnapshot.data;
            // Right after sign-up the profile document isn't written yet.
            if (profile == null) {
              return _LoadingScreen(
                message: 'Preparando sua conta…',
                onLogout: _authService.logout,
              );
            }

            if (profile.isTeacher) return const TeacherHomeScreen();
            if (profile.isPendingTeacher) {
              return PendingApprovalScreen(authService: widget.authService);
            }
            return const SubjectsScreen();
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  final String? message;
  final VoidCallback? onLogout;
  const _LoadingScreen({this.message, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message!, style: const TextStyle(fontSize: 16)),
            ],
            if (onLogout != null) ...[
              const SizedBox(height: 24),
              TextButton(onPressed: onLogout, child: const Text('Sair')),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onLogout;
  const _ProfileErrorScreen({required this.onRetry, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Não foi possível carregar seu perfil. Verifique sua conexão e tente novamente.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
              TextButton(onPressed: onLogout, child: const Text('Sair')),
            ],
          ),
        ),
      ),
    );
  }
}
