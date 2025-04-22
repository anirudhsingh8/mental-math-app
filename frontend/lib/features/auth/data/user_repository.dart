import 'package:mental_math_app/shared/models/api_response.dart';
import 'package:mental_math_app/shared/models/user.dart';
import 'package:mental_math_app/shared/services/user_service.dart';

class UserRepository {
  final UserService _userService;

  UserRepository(this._userService);

  /// Fetch the current user's profile
  Future<User?> getUserProfile() async {
    final response = await _userService.getProfile();
    if (response.success && response.data != null) {
      return response.data;
    }
    return null;
  }

  /// Update the user's profile information
  Future<ApiResponse<User>> updateProfile({
    required String firstName,
    required String lastName,
  }) {
    return _userService.updateProfile(
      firstName: firstName,
      lastName: lastName,
    );
  }

  /// Update the user's preferences
  Future<ApiResponse<User>> updatePreferences({
    required String difficultyPreference,
    required List<String> categories,
    required int dailyGoal,
    required bool notificationsEnabled,
    required String notificationTime,
  }) {
    return _userService.updatePreferences(
      difficultyPreference: difficultyPreference,
      categories: categories,
      dailyGoal: dailyGoal,
      notificationsEnabled: notificationsEnabled,
      notificationTime: notificationTime,
    );
  }

  /// Update the user's password
  Future<ApiResponse<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _userService.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
