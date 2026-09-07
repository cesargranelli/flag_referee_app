import 'auth_user.dart';

/// Estado de sessão do árbitro/mesa no Referee App (ADR-001).
class AuthSession {
  final bool isRestoring;
  final bool isAuthenticated;
  final bool isOffline;
  final AuthUser? user;
  final String? errorMessage;

  const AuthSession({
    this.isRestoring = false,
    this.isAuthenticated = false,
    this.isOffline = false,
    this.user,
    this.errorMessage,
  });

  const AuthSession.restoring()
      : isRestoring = true,
        isAuthenticated = false,
        isOffline = false,
        user = null,
        errorMessage = null;

  const AuthSession.unauthenticated({String? error})
      : isRestoring = false,
        isAuthenticated = false,
        isOffline = false,
        user = null,
        errorMessage = error;

  const AuthSession.authenticated(
    this.user, {
    this.isOffline = false,
  })  : isRestoring = false,
        isAuthenticated = true,
        errorMessage = null;

  AuthSession copyWith({
    bool? isRestoring,
    bool? isAuthenticated,
    bool? isOffline,
    AuthUser? user,
    String? errorMessage,
  }) {
    return AuthSession(
      isRestoring: isRestoring ?? this.isRestoring,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isOffline: isOffline ?? this.isOffline,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}
