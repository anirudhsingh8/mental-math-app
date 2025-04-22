import 'package:mental_math_app/shared/services/api_client.dart';
import 'package:mental_math_app/shared/services/auth_service.dart';
import 'package:mental_math_app/shared/services/exercise_service.dart';
import 'package:mental_math_app/shared/services/learning_path_service.dart';
import 'package:mental_math_app/shared/services/progress_service.dart';
import 'package:mental_math_app/shared/services/user_service.dart';

/// A simple service locator for dependency injection.
///
/// This provides a centralized way to access all services in the application.
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() => _instance;

  ServiceLocator._internal();

  late final ApiClient _apiClient;
  late final AuthService _authService;
  late final UserService _userService;
  late final ExerciseService _exerciseService;
  late final ProgressService _progressService;
  late final LearningPathService _learningPathService;

  /// Initialize all services.
  ///
  /// This should be called once at app startup.
  void initialize() {
    _apiClient = ApiClient();
    _authService = AuthService(_apiClient);
    _userService = UserService(_apiClient);
    _exerciseService = ExerciseService(_apiClient);
    _progressService = ProgressService(_apiClient);
    _learningPathService = LearningPathService(_apiClient);
  }

  /// Get the auth service.
  AuthService get authService => _authService;

  /// Get the user service.
  UserService get userService => _userService;

  /// Get the exercise service.
  ExerciseService get exerciseService => _exerciseService;

  /// Get the progress service.
  ProgressService get progressService => _progressService;

  /// Get the learning path service.
  LearningPathService get learningPathService => _learningPathService;
}
