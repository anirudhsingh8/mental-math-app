import 'package:mental_math_app/shared/models/api_response.dart';
import 'package:mental_math_app/shared/models/user.dart';
import 'package:mental_math_app/shared/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  /// Login user with email and password
  Future<ApiResponse<User>> login(String email, String password) async {
    try {
      final response =
          await _authService.login(email: email, password: password);
      return ApiResponse(
          success: true, data: User.fromJson(response.data!['user']));
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
      final response = await _authService.register(
        email: email,
        username: username,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      return ApiResponse(
          success: true, data: User.fromJson(response.data!['user']));
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Registration failed: ${e.toString()}',
      );
    }
  }

  /// Logout the current user
  Future<bool> logout() async {
    try {
      await _authService.logout();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if the user is currently authenticated
  Future<bool> isAuthenticated() async {
    return await _authService.isAuthenticated();
  }
}
