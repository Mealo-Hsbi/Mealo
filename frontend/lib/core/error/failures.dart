// lib/core/error/failures.dart

import 'package:equatable/equatable.dart'; // Falls Sie equatable für Wertgleichheit verwenden

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({String message = 'Server Error'}) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure({String message = 'Cache Error'}) : super(message);
}

class GeneralFailure extends Failure {
  const GeneralFailure({String message = 'An unexpected error occurred'}) : super(message);
}

// NEU: TimeoutFailure
class TimeoutFailure extends Failure {
  const TimeoutFailure({String message = 'The operation timed out. Please try again later.'}) : super(message);
}

// NEU: NetworkFailure (wenn Sie DioExceptionType.other fangen und es als Netzwerkproblem interpretieren)
class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'No internet connection. Please check your network settings.'}) : super(message);
}