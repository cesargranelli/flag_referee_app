import 'package:flutter/foundation.dart';
import 'package:flag_referee_app/data/repositories/auth_repository.dart';
import 'package:flag_referee_app/domain/models/auth_user.dart';
import 'package:flag_referee_app/src/domain/models/user.dart';

/// Estado de autenticação do Referee App (compatibilidade com AppRouter).
class AuthState {
  final bool restoring;
  final bool authenticated;
  final bool isOffline;
  final User? user;
  final AuthUser? authUser;

  const AuthState({
    this.restoring = false,
    this.authenticated = false,
    this.isOffline = false,
    this.user,
    this.authUser,
  });
}

/// Controlador de autenticação para proteção de rotas e ciclo de vida da sessão da mesa.
class AuthController extends ChangeNotifier {
  final AuthRepository _repository;

  AuthState _state = const AuthState(restoring: true);
  AuthState get state => _state;

  AuthController({required AuthRepository repository})
      : _repository = repository;

  Future<void> restore() async {
    try {
      final authUser = await _repository.restoreSession();
      if (authUser != null) {
        _state = AuthState(
          restoring: false,
          authenticated: true,
          isOffline: _repository.isOffline,
          user: authUser.toLegacyUser(),
          authUser: authUser,
        );
      } else {
        _state = const AuthState(restoring: false, authenticated: false);
      }
    } catch (_) {
      _state = const AuthState(restoring: false, authenticated: false);
    }
    notifyListeners();
  }

  void syncFromRepository() {
    final authUser = _repository.currentUser;
    if (authUser != null) {
      _state = AuthState(
        restoring: false,
        authenticated: true,
        isOffline: _repository.isOffline,
        user: authUser.toLegacyUser(),
        authUser: authUser,
      );
    } else {
      _state = const AuthState(restoring: false, authenticated: false);
    }
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final authUser = await _repository.login(
      email: email,
      password: password,
    );
    _state = AuthState(
      restoring: false,
      authenticated: true,
      isOffline: _repository.isOffline,
      user: authUser.toLegacyUser(),
      authUser: authUser,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await _repository.logout();
    _state = const AuthState(restoring: false, authenticated: false);
    notifyListeners();
  }
}
