import 'package:flutter/foundation.dart';
import 'package:flag_referee_app/data/repositories/auth_repository.dart';
import 'package:flag_referee_app/data/services/auth_service.dart';
import 'package:flag_referee_app/src/api/repository_exception.dart';

/// ViewModel para a tela de Login do árbitro/mesa (ADR-001 / MVVM 1:1).
class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final VoidCallback? _onAuthStateChanged;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  LoginViewModel({
    required AuthRepository repository,
    VoidCallback? onAuthStateChanged,
  })  : _repository = repository,
        _onAuthStateChanged = onAuthStateChanged;

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.login(
        email: email.trim(),
        password: password,
      );
      _isLoading = false;
      _onAuthStateChanged?.call();
      notifyListeners();
      return true;
    } on AuthServiceException catch (e) {
      _errorMessage = e.message;
    } on RepositoryException catch (e) {
      _errorMessage = e.statusCode == 401
          ? 'E-mail ou senha incorretos'
          : 'Não foi possível entrar. Verifique sua conexão.';
    } catch (_) {
      _errorMessage = 'Sem conexão com o servidor. Tente novamente.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
