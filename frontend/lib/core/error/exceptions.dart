// lib/core/error/exceptions.dart

/// Base class for all custom exceptions in the application.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() {
    return 'AppException: $message' + (statusCode != null ? ' (Status: $statusCode)' : '');
  }
}

/// Exception thrown for server-related errors (e.g., 4xx, 5xx responses).
class ServerException extends AppException {
  ServerException(String message, {int? statusCode}) : super(message, statusCode: statusCode);

  @override
  String toString() {
    return 'ServerException: $message' + (statusCode != null ? ' (Status: $statusCode)' : '');
  }
}

/// Exception thrown for cache-related errors (e.g., failed to read/write cache).
class CacheException extends AppException {
  CacheException(String message) : super(message);

  @override
  String toString() {
    return 'CacheException: $message';
  }
}

/// Exception thrown for network connectivity issues.
class NetworkException extends AppException {
  NetworkException(String message) : super(message);

  @override
  String toString() {
    return 'NetworkException: $message';
  }
}

// You might also want to define your TimeoutException here if it's custom.
// However, Dart's `dart:async` already provides a `TimeoutException` class,
// which is often sufficient if you just need to re-throw it.
// If you want to wrap it or add more context, you could:
// class CustomTimeoutException extends AppException {
//   CustomTimeoutException(String message) : super(message);
//
//   @override
//   String toString() {
//     return 'CustomTimeoutException: $message';
//   }
// }