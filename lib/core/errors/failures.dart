/// Base class for all failures in the application
/// Used with Either type for functional error handling
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure: $message${code != null ? ' (code: $code)' : ''}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

/// Failure for server/API errors
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Failure for cache/local storage errors
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Failure for network connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// Failure for authentication errors
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

/// Failure for validation errors
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}
