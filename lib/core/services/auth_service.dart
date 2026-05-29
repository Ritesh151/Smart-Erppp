import 'package:SmartERP/core/constants/app_constants.dart';
import 'package:SmartERP/core/constants/storage_keys.dart';
import 'package:SmartERP/core/exceptions/app_exception.dart';
import 'package:SmartERP/core/models/user_model.dart';
import 'package:SmartERP/core/storage/preferences_service.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final PreferencesService _preferencesService;
  UserModel? _currentUser;

  AuthService(this._preferencesService);

  UserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    try {
      final isLoggedIn = _preferencesService.getBool(
        StorageKeys.isLoggedIn,
        defaultValue: false,
      );

      if (isLoggedIn == true) {
        final expiryTimeStr = _preferencesService.getString(StorageKeys.expiryTime);
        if (expiryTimeStr == null) {
          // Backward-compat / corrupted session: force logout to recover a stable state.
          await logout();
          return;
        }

        final expiryTime = DateTime.tryParse(expiryTimeStr);
        if (expiryTime == null || DateTime.now().isAfter(expiryTime)) {
          await logout();
          return;
        }

        final email = _preferencesService.getString(StorageKeys.userEmail);
        if (email != null) {
          _currentUser = UserModel(
            id: const Uuid().v4(),
            email: email,
            name: 'Ritesh',
            role: 'Administrator',
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
          Logger.info('User session restored: $email');
        }
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize auth service', e, stackTrace);
    }
  }

  Future<UserModel> login(String email, String password) async {
    try {
      Logger.info('Attempting login for: $email');

      if (email.trim().isEmpty) {
        throw ValidationException('Email is required');
      }

      if (password.trim().isEmpty) {
        throw ValidationException('Password is required');
      }

      if (email.trim() != AppConstants.fixedEmail) {
        throw AuthenticationException('Invalid email address');
      }

      if (password != AppConstants.fixedPassword) {
        throw AuthenticationException('Invalid password');
      }

      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = UserModel(
        id: const Uuid().v4(),
        email: email.trim(),
        name: 'Ritesh',
        role: 'Administrator',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      final now = DateTime.now();
      final expiry = now.add(const Duration(hours: 72));

      await _preferencesService.setBool(StorageKeys.isLoggedIn, true);
      await _preferencesService.setString(StorageKeys.userEmail, email.trim());
      await _preferencesService.setString(
        StorageKeys.lastLoginTime,
        now.toIso8601String(),
      );
      await _preferencesService.setString(StorageKeys.loginTime, now.toIso8601String());
      await _preferencesService.setString(StorageKeys.expiryTime, expiry.toIso8601String());
      await _preferencesService.setString(
        StorageKeys.sessionToken,
        const Uuid().v4(),
      );

      Logger.success('Login successful: $email');
      return _currentUser!;
    } catch (e) {
      Logger.error('Login failed', e);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      Logger.info('Logging out user: ${_currentUser?.email}');

      await _preferencesService.setBool(StorageKeys.isLoggedIn, false);
      await _preferencesService.remove(StorageKeys.userEmail);
      await _preferencesService.remove(StorageKeys.sessionToken);
      await _preferencesService.remove(StorageKeys.lastLoginTime);
      await _preferencesService.remove(StorageKeys.loginTime);
      await _preferencesService.remove(StorageKeys.expiryTime);

      _currentUser = null;

      Logger.success('Logout successful');
    } catch (e, stackTrace) {
      Logger.error('Logout failed', e, stackTrace);
      throw AuthenticationException('Failed to logout');
    }
  }

  Future<bool> validateSession() async {
    try {
      final isLoggedIn = _preferencesService.getBool(
        StorageKeys.isLoggedIn,
        defaultValue: false,
      );

      if (isLoggedIn != true) {
        return false;
      }

      final expiryTimeStr = _preferencesService.getString(StorageKeys.expiryTime);
      if (expiryTimeStr == null) return false;

      final expiryTime = DateTime.tryParse(expiryTimeStr);
      if (expiryTime == null) return false;

      if (DateTime.now().isAfter(expiryTime)) {
        await logout();
        return false;
      }

      return _currentUser != null;
    } catch (e, stackTrace) {
      Logger.error('Session validation failed', e, stackTrace);
      return false;
    }
  }

  bool validateSessionSync() {
    try {
      final isLoggedIn = _preferencesService.getBool(
        StorageKeys.isLoggedIn,
        defaultValue: false,
      );
      if (isLoggedIn != true) return false;

      final expiryTimeStr = _preferencesService.getString(StorageKeys.expiryTime);
      if (expiryTimeStr == null) return false;

      final expiryTime = DateTime.tryParse(expiryTimeStr);
      if (expiryTime == null) return false;

      return DateTime.now().isBefore(expiryTime);
    } catch (e) {
      return false;
    }
  }

  Future<void> updateLastLoginTime() async {
    try {
      await _preferencesService.setString(
        StorageKeys.lastLoginTime,
        DateTime.now().toIso8601String(),
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to update last login time', e, stackTrace);
    }
  }
}
