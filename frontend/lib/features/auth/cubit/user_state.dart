import 'package:equatable/equatable.dart';
import 'package:mental_math_app/shared/models/user.dart';

/// Defines the possible states for the UserCubit
enum UserStatus { initial, loading, loaded, error }

/// Represents the state of the user in the application
class UserState extends Equatable {
  final UserStatus status;
  final User? user;
  final String? errorMessage;

  const UserState({
    this.status = UserStatus.initial,
    this.user,
    this.errorMessage,
  });

  /// Creates a copy of the current state with updated values
  UserState copyWith({
    UserStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return UserState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  /// Check if the user is authenticated
  bool get isAuthenticated => user != null;

  @override
  List<Object?> get props => [status, user, errorMessage];

  /// Initial state - no user data is loaded
  factory UserState.initial() => const UserState(status: UserStatus.initial);

  /// Loading state - user data is being fetched
  factory UserState.loading() => const UserState(status: UserStatus.loading);

  /// Loaded state - user data has been loaded successfully
  factory UserState.loaded(User user) => UserState(
        status: UserStatus.loaded,
        user: user,
      );

  /// Error state - an error occurred while loading user data
  factory UserState.error(String message) => UserState(
        status: UserStatus.error,
        errorMessage: message,
      );
}
