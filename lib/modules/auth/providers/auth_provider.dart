import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:SmartERP/core/exceptions/app_exception.dart';
import 'package:SmartERP/core/models/user_model.dart';
import 'package:SmartERP/core/services/auth_service.dart';
import 'package:SmartERP/core/utils/logger.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  Timer? _sessionTimer;

  AuthProvider(this._authService);

  UserModel? get currentUser => _authService.currentUser;

  bool get isAuthenticated => _authService.isAuthenticated;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _sessionExpiredMessage;
  String? get sessionExpiredMessage => _sessionExpiredMessage;

  void clearSessionExpiredMessage() {
    _sessionExpiredMessage = null;
  }

  Future<void> initialize() async {
    try {
      await _authService.initialize();
      _isInitialized = true;
      if (_authService.isAuthenticated) {
        _startSessionTimer();
      }
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize auth provider', e, stackTrace);
      _isInitialized = true;
    }
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _checkSessionExpiry(),
    );
  }

  void _checkSessionExpiry() {
    if (!_authService.isAuthenticated) return;

    final valid = _authService.validateSessionSync();
    if (!valid) {
      _sessionExpiredMessage = 'Your session has expired. Please login again.';
      Logger.warning('Session expired, auto-logging out');
      _performAutoLogout();
    }
  }

  Future<void> _performAutoLogout() async {
    try {
      _sessionTimer?.cancel();
      await _authService.logout();
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Auto-logout failed', e, stackTrace);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _sessionExpiredMessage = null;
      notifyListeners();

      await _authService.login(email, password);

      _isLoading = false;
      _startSessionTimer();
      notifyListeners();

      Logger.success('Login successful');
      return true;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      Logger.warning('Validation error during login', e.message);
      return false;
    } on AuthenticationException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      Logger.warning('Authentication error during login', e.message);
      return false;
    } catch (e, stackTrace) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      Logger.error('Unexpected error during login', e, stackTrace);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      _sessionTimer?.cancel();
      await _authService.logout();

      _isLoading = false;
      _errorMessage = null;
      _sessionExpiredMessage = null;
      notifyListeners();

      Logger.success('Logout successful');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to logout. Please try again.';
      notifyListeners();
      Logger.error('Error during logout', e, stackTrace);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> validateSession() async {
    try {
      return await _authService.validateSession();
    } catch (e, stackTrace) {
      Logger.error('Session validation failed', e, stackTrace);
      return false;
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}
