import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flag_referee_app/src/api/api_client.dart';
import 'package:flag_referee_app/src/domain/models/user.dart';

/// Exceção do serviço de autenticação do árbitro/mesa em português.
class AuthServiceException implements Exception {
  final String code;
  final String message;

  const AuthServiceException({required this.code, required this.message});

  @override
  String toString() => message;
}

/// Interface de serviço de autenticação para o Referee App (ADR-001).
abstract class AuthService {
  factory AuthService(ApiClient client, {fb.FirebaseAuth? firebaseAuth}) =
      ApiAuthService;

  Stream<fb.User?> get authStateChanges;
  fb.User? get currentFirebaseUser;
  Future<String?> getIdToken({bool forceRefresh = false});

  Future<fb.UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  Future<User> getMe();
}

/// Implementação padrão consumindo Firebase Auth SDK e API REST.
class ApiAuthService implements AuthService {
  final ApiClient _client;
  final fb.FirebaseAuth _firebaseAuth;

  ApiAuthService(
    this._client, {
    fb.FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  @override
  Stream<fb.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  fb.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return await _firebaseAuth.currentUser?.getIdToken(forceRefresh);
  }

  @override
  Future<fb.UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthServiceException(
        code: e.code,
        message: _mapFirebaseError(e.code),
      );
    } catch (e) {
      throw AuthServiceException(
        code: 'unknown',
        message: 'Erro de autenticação: ',
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthServiceException(
        code: e.code,
        message: _mapFirebaseError(e.code),
      );
    } catch (e) {
      throw AuthServiceException(
        code: 'unknown',
        message: 'Erro ao solicitar redefinição: ',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {}
  }

  @override
  Future<User> getMe() {
    return _client.getOne('/api/v1/auth/me', User.fromJson);
  }

  static String _mapFirebaseError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'O formato do e-mail é inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
        return 'Não existe conta cadastrada com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente em instantes.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      default:
        return 'Falha na autenticação. Verifique suas credenciais.';
    }
  }
}
