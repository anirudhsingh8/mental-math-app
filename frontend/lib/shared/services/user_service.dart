import 'package:mental_math_app/shared/models/api_response.dart';
import 'package:mental_math_app/shared/models/user.dart';
import 'package:mental_math_app/shared/services/api_client.dart';

class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  Future<ApiResponse<User>> getProfile() async {
    return await _apiClient.get<User>(
      '/users/profile',
      fromJson: (data) => User.fromJson(data),
    );
  }

  Future<ApiResponse<User>> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    return await _apiClient.put<User>(
      '/users/profile',
      body: {
        'first_name': firstName,
        'last_name': lastName,
      },
      fromJson: (data) => User.fromJson(data),
    );
  }

  Future<ApiResponse<User>> updatePreferences({
    required String difficultyPreference,
    required List<String> categories,
    required int dailyGoal,
    required bool notificationsEnabled,
    required String notificationTime,
  }) async {
    return await _apiClient.put<User>(
      '/users/preferences',
      body: {
        'difficulty_preference': difficultyPreference,
        'categories': categories,
        'daily_goal': dailyGoal,
        'notification_settings': {
          'enabled': notificationsEnabled,
          'time': notificationTime,
        },
      },
      fromJson: (data) => User.fromJson(data),
    );
  }

  Future<ApiResponse<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _apiClient.put<void>(
      '/users/password',
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
      fromJson: (_) {},
    );
  }
}
