abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

class AuthenticationException extends AppException {
  AuthenticationException(super.message, {super.code, super.details});
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.code, super.details});
}

class StorageException extends AppException {
  StorageException(super.message, {super.code, super.details});
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.details});
}

class NotFoundException extends AppException {
  NotFoundException(super.message, {super.code, super.details});
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message, {super.code, super.details});
}

class ServerException extends AppException {
  ServerException(super.message, {super.code, super.details});
}

class CacheException extends AppException {
  CacheException(super.message, {super.code, super.details});
}
