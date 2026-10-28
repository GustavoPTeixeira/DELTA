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
    UserRole role = UserRole.student,
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
        role: role,
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
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } on FirebaseException catch (e) {
      throw AuthException('Erro ao carregar dados do perfil: ${e.message}');
    } catch (e) {
      throw AuthException('Ocorreu um erro inesperado ao carregar o perfil: $e');
    }
  }

  Future<UserModel> updateUserProfile({
    required String uid,
    required String name,
    required String username,
    String? currentUsername,
  }) async {
    final cleanName = name.trim();
    final cleanUsername = username.trim().toLowerCase();
    // 1. Validações básicas de preenchimento
    if (cleanName.isEmpty) {
      throw AuthException('O nome não pode ficar vazio.');
    }
    if (cleanUsername.isEmpty) {
      throw AuthException('O nome de usuário não pode ficar vazio.');
    }
    // 2. Se o username foi alterado, valida disponibilidade no Firestore (Regra da Issue #1)
    final normalizedCurrent = currentUsername?.trim().toLowerCase();
    if (normalizedCurrent != cleanUsername) {
      final isAvailable = await isUsernameAvailable(cleanUsername);
      if (!isAvailable) {
        throw AuthException('O nome de usuário "@$cleanUsername" já está em uso. Tente outro!');
      }
    }
    try {
      // 3. Salva no Firestore mesclando com os dados já existentes
      final userDocRef = _firestore.collection('users').doc(uid);
      await userDocRef.set({
        'name': cleanName,
        'username': cleanUsername,
      }, SetOptions(merge: true));
      // 4. Sincroniza o displayName no Firebase Auth
      await _auth.currentUser?.updateDisplayName(cleanName);
      // 5. Retorna o perfil atualizado
      final updatedProfile = await getUserProfile(uid);
      if (updatedProfile != null) {
        return updatedProfile;
      }
      return UserModel(
        uid: uid,
        name: cleanName,
        username: cleanUsername,
        email: _auth.currentUser?.email ?? '',
        createdAt: DateTime.now(),
      );
    } on AuthException {
      rethrow;
    } on FirebaseException catch (e) {
      throw AuthException('Erro ao salvar no banco de dados: ${e.message}');
    } catch (e) {
      throw AuthException('Ocorreu um erro inesperado ao atualizar: $e');
    }
  }
}