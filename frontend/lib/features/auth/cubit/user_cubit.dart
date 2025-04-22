import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_math_app/features/auth/cubit/user_state.dart';
import 'package:mental_math_app/features/auth/data/user_repository.dart';
import 'package:mental_math_app/shared/models/user.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository _repository;

  UserCubit(this._repository) : super(UserState.initial());

  /// Fetch the current user profile
  Future<void> getProfile() async {
    emit(UserState.loading());

    try {
      final user = await _repository.getUserProfile();
      if (user != null) {
        emit(UserState.loaded(user));
      } else {
        emit(UserState.error("Failed to load user profile"));
      }
    } catch (e) {
      emit(UserState.error(e.toString()));
    }
  }

  /// Update the user's profile information
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    emit(state.copyWith(status: UserStatus.loading));

    try {
      final response = await _repository.updateProfile(
        firstName: firstName,
        lastName: lastName,
      );

      if (response.success && response.data != null) {
        emit(UserState.loaded(response.data!));
      } else {
        emit(UserState.error(response.message ?? "Failed to update profile"));
      }
    } catch (e) {
      emit(UserState.error(e.toString()));
    }
  }

  /// Update the user's preferences
  Future<void> updatePreferences({
    required String difficultyPreference,
    required List<String> categories,
    required int dailyGoal,
    required bool notificationsEnabled,
    required String notificationTime,
  }) async {
    emit(state.copyWith(status: UserStatus.loading));

    try {
      final response = await _repository.updatePreferences(
        difficultyPreference: difficultyPreference,
        categories: categories,
        dailyGoal: dailyGoal,
        notificationsEnabled: notificationsEnabled,
        notificationTime: notificationTime,
      );

      if (response.success && response.data != null) {
        emit(UserState.loaded(response.data!));
      } else {
        emit(UserState.error(
            response.message ?? "Failed to update preferences"));
      }
    } catch (e) {
      emit(UserState.error(e.toString()));
    }
  }

  /// Update the user's password
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(state.copyWith(status: UserStatus.loading));

    try {
      final response = await _repository.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (response.success) {
        // Reload user data after successful password change
        await getProfile();
      } else {
        emit(UserState.error(response.message ?? "Failed to update password"));
      }
    } catch (e) {
      emit(UserState.error(e.toString()));
    }
  }

  /// Store updated user information in the state
  void updateUserData(User updatedUser) {
    emit(UserState.loaded(updatedUser));
  }

  /// Clear user data (for logout)
  void clearUser() {
    emit(UserState.initial());
  }
}
