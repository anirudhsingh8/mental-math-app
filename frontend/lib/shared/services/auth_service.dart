import 'package:mental_math_app/shared/models/api_response.dart';
import 'package:mental_math_app/shared/services/api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String email,
    required String username,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/users/register',
      body: {
        'email': email,
        'username': username,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
      },
      fromJson: (data) => data as Map<String, dynamic>,
      requiresAuth: false,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/users/login',
      body: {
        'email': email,
        'password': password,
      },
      fromJson: (data) => data as Map<String, dynamic>,
      requiresAuth: false,
    );

    if (response.success && response.data != null) {
      final token = response.data!['token'] as String;
      await _apiClient.saveToken(token);
    }

    return response;
  }

  Future<ApiResponse<void>> logout() async {
    final response = await _apiClient.delete<void>(
      '/users/logout',
      fromJson: (_) {},
    );

    if (response.success) {
      await _apiClient.clearToken();
    }

    return response;
  }

  Future<ApiResponse<void>> logoutAllDevices() async {
    final response = await _apiClient.delete<void>(
      '/users/logout-all',
      fromJson: (_) {},
    );

    if (response.success) {
      await _apiClient.clearToken();
    }

    return response;
  }

  Future<bool> isAuthenticated() async {
    final token = await _apiClient.getToken();
    return token != null;
  }
}
