import 'dart:convert';
import 'package:flag_referee_app/data/services/auth_service.dart';
import 'package:flag_referee_app/domain/models/auth_user.dart';
import 'package:flag_referee_app/src/core/session/session_manager.dart';
import 'package:flag_referee_app/src/domain/enums/user_role.dart';
import 'package:flutter/foundation.dart';

/// Repositório de Autenticação do Referee App (ADR-001 / Offline First).
///
/// Garante que árbitros e mesários mantenham a sessão ativa em campo
/// mesmo em caso de perda temporária de sinal de rede (3G/4G).
class AuthRepository {
  final AuthService _service;
  final SessionManager _session;

  AuthUser? _currentUser;
  bool _isOffline = false;

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isOffline => _isOffline;

  AuthRepository({
    required AuthService service,
    required SessionManager session,
  })  : _service = service,
        _session = session;

  /// Restaura a sessão ao inicializar o aplicativo.
  ///
  /// Resiliência Offline: Se a rede falhar durante a chamada ao backend,
  /// restaura os dados armazenados localmente no [SessionManager],
  /// evitando que o árbitro seja deslogado em campo durante a partida.
  Future<AuthUser?> restoreSession() async {
    try {
      final token = (await _service.getIdToken()) ?? (await _session.getToken());
      if (token == null) {
        _currentUser = null;
        _isOffline = false;
        return null;
      }

      try {
        // Tenta sincronizar os dados mais recentes do backend
        final user = await _service.getMe();
        final authUser = AuthUser.fromUser(user, token: token);
        _currentUser = authUser;
        _isOffline = false;

        // Atualiza o cache local seguro para uso offline
        await _session.saveSession(
          token: token,
          roles: [user.role.toJson()],
          userName: user.name,
          userId: user.id,
          email: user.email,
          cachedUserJson: jsonEncode(user.toJson()),
        );

        return authUser;
      } catch (e) {
        // Falha de rede: restaura a partir do cache local seguro
        final cachedJson = await _session.getCachedUserJson();
        if (cachedJson != null && cachedJson.isNotEmpty) {
          try {
            final Map<String, dynamic> data = jsonDecode(cachedJson);
            final cachedUser = AuthUser.fromJson(data, token: token);
            _currentUser = cachedUser;
            _isOffline = true;
            debugPrint('Referee App: Sessão offline restaurada com sucesso.');
            return cachedUser;
          } catch (_) {}
        }

        // Fallback mínimo a partir das chaves salvas no storage
        final userName = await _session.getUserName();
        final email = await _session.getEmail();
        final userId = await _session.getUserId();
        final roles = await _session.getRoles();

        if (userName != null && email != null) {
          final fallbackUser = AuthUser(
            id: userId ?? 'cached-user',
            name: userName,
            email: email,
            role: roles.isNotEmpty
                ? UserRole.fromJson(roles.first)
                : UserRole.referee,
            token: token,
          );
          _currentUser = fallbackUser;
          _isOffline = true;
          return fallbackUser;
        }

        // Se não houver nenhum dado em cache e a rede falhar, limpa
        _currentUser = null;
        _isOffline = false;
        return null;
      }
    } catch (_) {
      _currentUser = null;
      _isOffline = false;
      return null;
    }
  }

  /// Realiza o login com e-mail e senha.
  Future<AuthUser> login({
    required String email,
    required String password,
    bool keepConnected = true,
  }) async {
    final credential = await _service.signInWithEmailPassword(
      email: email,
      password: password,
    );

    final token = await credential.user?.getIdToken(true);
    final user = await _service.getMe();
    final authUser = AuthUser.fromUser(user, token: token);

    _currentUser = authUser;
    _isOffline = false;

    await _session.saveSession(
      token: token ?? '',
      roles: [user.role.toJson()],
      userName: user.name,
      userId: user.id,
      email: user.email,
      cachedUserJson: jsonEncode(user.toJson()),
    );
    await _session.saveKeepConnected(keepConnected);

    return authUser;
  }

  /// Encerra a sessão e limpa os dados locais.
  Future<void> logout() async {
    try {
      await _service.signOut();
    } catch (_) {}
    try {
      await _session.clear();
    } catch (_) {}
    _currentUser = null;
    _isOffline = false;
  }

  Future<void> sendPasswordReset(String email) async {
    await _service.sendPasswordResetEmail(email);
  }
}
