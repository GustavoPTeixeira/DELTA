import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({
    FirebaseAuth? auth, FirebaseFirestore? firestore
    }) : _auth = auth ?? FirebaseAuth.instance,
         _firestore = firestore ?? FirebaseFirestore.instance;

  Stream <User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<bool> isUsernameAvailable(String username) async {
    final normalized = username.trim().toLowerCase();

    final userQuery = await _firestore
        .collection('users')
        .where('username', isEqualTo: normalized)
        .limit(1)
        .get();

    if(userQuery.docs.isNotEmpty) return false;

    final legacyQuery = await _firestore
        .collection('usuarios')
        .where('nome_usuario', isEqualTo: normalized)
        .limit(1)
        .get();

    return legacyQuery.docs.isEmpty;
  }

  Future<UserModel> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    final cleanUsername = username.trim().toLowerCase();
    final cleanEmail = email.trim().toLowerCase();

    final isAvailable = await isUsernameAvailable(cleanUsername);
    if(!isAvailable) {
      throw AuthException('Username is already taken. Tente Outro!');
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password.trim(),
      );

      final uid = userCredential.user!.uid;

      final userModel = UserModel(
        uid: uid,
        name: name.trim(),
        username: cleanUsername,
        email: cleanEmail,
      );

      await _firestore.collection('users').doc(uid).set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  Future<UserCredential> login({
    required String identifier,
    required String password,
  }) async {
    final cleanInput = identifier.trim();
    final cleanPassword = password.trim();

    String resolvedEmail = cleanInput;

    try{
      if(!cleanInput.contains('@')) {
        final normalizedUsername = cleanInput.toLowerCase();

        final userQuery = await _firestore
            .collection('users')
            .where('username', isEqualTo: normalizedUsername)
            .limit(1)
            .get();

        final legacyQuery = userQuery.docs.isEmpty
            ? await _firestore
                .collection('usuarios')
                .where('nome_usuario', isEqualTo: normalizedUsername)
                .limit(1)
                .get()
            : null;

        final matchedDocs = userQuery.docs.isNotEmpty ? userQuery.docs : legacyQuery?.docs ?? [];

        if(matchedDocs.isEmpty) {
          throw AuthException('No user found with the provided username.');
        }

        resolvedEmail = matchedDocs.first.data()['email'] as String;
    }

    return await _auth.signInWithEmailAndPassword(
      email: resolvedEmail,
      password: cleanPassword,
    );
  } on FirebaseAuthException catch (e) {
    throw AuthException(_mapFirebaseAuthError(e));
  } on AuthException {
    rethrow;
  } catch (e) {
    throw AuthException('An unexpected error occurred: $e');
  }
}
  
  Future<void> sendPasswordResetEmail(String email) async {
    try{
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code){
      case 'user-not-found':
        return 'Usuário não encontrado. Verifique suas credenciais.';
      case 'wrong-password':
      case 'invalid-credentials':
        return 'E-mail/usuário ou senha incorretos. Tente novamente.';
      case 'email-already-in-use':
        return 'O e-mail fornecido já está em uso. Tente outro.';
      case 'weak-password':
        return 'A senha fornecida é muito fraca. Tente uma senha mais forte.';
      case 'user-disabled':
        return 'Esta conta de usuário foi desativada.';
      case 'too-many-requests':
        return 'Muitas tentativas de login falharam. Tente novamente mais tarde.';
      default:
        return e.message ?? 'Ocorreu um erro desconhecido. Tente novamente.';
    }
}
}