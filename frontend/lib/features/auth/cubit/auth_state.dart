import 'package:equatable/equatable.dart';
import 'package:mental_math_app/shared/models/user.dart';

/// Defines the possible authentication states
enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  error,
}

/// Represents the authentication state in the application
class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  /// Creates a copy of the current state with updated values
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];

  /// Check if the user is authenticated
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  /// Initial state - authentication not determined yet
  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  /// Process of authenticating is ongoing
  factory AuthState.authenticating() =>
      const AuthState(status: AuthStatus.authenticating);

  /// Successfully authenticated
  factory AuthState.authenticated(User user) => AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );

  /// User is not authenticated
  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);

  /// Error during authentication
  factory AuthState.error(String message) => AuthState(
        status: AuthStatus.error,
        errorMessage: message,
      );
}
