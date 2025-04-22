import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_math_app/features/auth/cubit/auth_state.dart';
import 'package:mental_math_app/features/auth/data/auth_repository.dart';
import 'package:mental_math_app/features/auth/data/user_repository.dart';
import 'package:mental_math_app/shared/models/user.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthCubit(this._authRepository, this._userRepository)
      : super(AuthState.initial()) {
    checkAuthStatus();
  }

  /// Check if the user is currently authenticated
  Future<void> checkAuthStatus() async {
    emit(AuthState.authenticating());

    try {
      final isAuthenticated = await _authRepository.isAuthenticated();

      if (isAuthenticated) {
        final user = await _userRepository.getUserProfile();
        if (user != null) {
          emit(AuthState.authenticated(user));
        } else {
          // Token exists but failed to get user profile
          await _authRepository.logout();
          emit(AuthState.unauthenticated());
        }
      } else {
        emit(AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    emit(AuthState.authenticating());

    try {
      final response = await _authRepository.login(email, password);

      if (response.success && response.data != null) {
        emit(AuthState.authenticated(response.data!));
      } else {
        emit(AuthState.error(response.message ?? 'Login failed'));
      }
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  /// Register a new user
  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    emit(AuthState.authenticating());

    try {
      final response = await _authRepository.register(
        email: email,
        username: username,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      if (response.success && response.data != null) {
        emit(AuthState.authenticated(response.data!));
      } else {
        emit(AuthState.error(response.message ?? 'Registration failed'));
      }
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  /// Request password reset
  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await _authRepository.requestPasswordReset(email);
      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Reset password with token
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _authRepository.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    try {
      await _authRepository.logout();
      emit(AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  /// Update the current user information
  void updateUserData(User updatedUser) {
    if (state.isAuthenticated) {
      emit(AuthState.authenticated(updatedUser));
    }
  }
}
