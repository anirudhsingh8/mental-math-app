import 'package:mental_math_app/shared/models/api_response.dart';
import 'package:mental_math_app/shared/models/user.dart';
import 'package:mental_math_app/shared/services/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  /// Login user with email and password
  Future<ApiResponse<User>> login(String email, String password) async {
    try {
      final response = await _apiClient.post<User>(
        '/auth/login',
        body: {
          'email': email,
          'password': password,
        },
        fromJson: (data) {
          // Save the token if it's included in the response
          if (data['token'] != null) {
            _apiClient.saveToken(data['token']);
          }
          return User.fromJson(data['user'] ?? data);
        },
        requiresAuth: false,
      );
      return response;
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

  /// Register a new user
  Future<ApiResponse<User>> register({
    required String email,
    required String username,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _apiClient.post<User>(
        '/auth/register',
        body: {
          'email': email,
          'username': username,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        },
        fromJson: (data) {
          // Save the token if it's included in the response
          if (data['token'] != null) {
            _apiClient.saveToken(data['token']);
          }
          return User.fromJson(data['user'] ?? data);
        },
        requiresAuth: false,
      );
      return response;
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Registration failed: ${e.toString()}',
      );
    }
  }

  /// Request password reset
  Future<ApiResponse<void>> requestPasswordReset(String email) async {
    try {
      final response = await _apiClient.post<void>(
        '/auth/forgot-password',
        body: {
          'email': email,
        },
        fromJson: (_) {},
        requiresAuth: false,
      );
      return response;
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Password reset request failed: ${e.toString()}',
      );
    }
  }

  /// Reset password with token
  Future<ApiResponse<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post<void>(
        '/auth/reset-password',
        body: {
          'token': token,
          'password': newPassword,
        },
        fromJson: (_) {},
        requiresAuth: false,
      );
      return response;
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Password reset failed: ${e.toString()}',
      );
    }
  }

  /// Logout the current user
  Future<bool> logout() async {
    try {
      await _apiClient.post<void>(
        '/auth/logout',
        fromJson: (_) {},
      );
      await _apiClient.clearToken();
      return true;
    } catch (e) {
      // Even if the API call fails, we clear the token
      await _apiClient.clearToken();
      return false;
    }
  }

  /// Check if the user is currently authenticated
  Future<bool> isAuthenticated() async {
    final token = await _apiClient.getToken();
    return token != null && token.isNotEmpty;
  }
}
