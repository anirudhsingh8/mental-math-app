import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_math_app/features/auth/cubit/auth_cubit.dart';
import 'package:mental_math_app/features/auth/cubit/user_cubit.dart';
import 'package:mental_math_app/features/auth/data/auth_repository.dart';
import 'package:mental_math_app/features/auth/data/user_repository.dart';
import 'package:mental_math_app/features/exercises/cubit/exercise_cubit.dart';
import 'package:mental_math_app/features/exercises/data/exercise_repository.dart';
import 'package:mental_math_app/features/learning_paths/cubit/learning_path_cubit.dart';
import 'package:mental_math_app/features/learning_paths/data/learning_path_repository.dart';
import 'package:mental_math_app/shared/services/api_client.dart';
import 'package:mental_math_app/shared/services/auth_service.dart';
import 'package:mental_math_app/shared/services/exercise_service.dart';
import 'package:mental_math_app/shared/services/learning_path_service.dart';
import 'package:mental_math_app/shared/services/user_service.dart';

/// Service provider class for setting up dependency injection
class ServiceProvider extends StatelessWidget {
  final Widget child;

  const ServiceProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: _buildRepositoryProviders(),
      child: MultiBlocProvider(
        providers: _buildBlocProviders(),
        child: child,
      ),
    );
  }

  /// Build repository providers
  List<RepositoryProvider> _buildRepositoryProviders() {
    // Create API client
    final apiClient = ApiClient();

    // Create services
    final userService = UserService(apiClient);
    final authService = AuthService(apiClient);
    final exerciseService = ExerciseService(apiClient);
    final learningPathService = LearningPathService(apiClient);

    return [
      // Register API client
      RepositoryProvider<ApiClient>(create: (_) => apiClient),

      // Register services
      RepositoryProvider<AuthService>(create: (_) => authService),
      RepositoryProvider<UserService>(create: (_) => userService),
      RepositoryProvider<ExerciseService>(create: (_) => exerciseService),
      RepositoryProvider<LearningPathService>(
          create: (_) => learningPathService),

      // Register repositories
      RepositoryProvider<AuthRepository>(
        create: (_) => AuthRepository(authService),
      ),
      RepositoryProvider<UserRepository>(
        create: (_) => UserRepository(userService),
      ),
      RepositoryProvider<ExerciseRepository>(
        create: (_) => ExerciseRepository(exerciseService),
      ),
      RepositoryProvider<LearningPathRepository>(
        create: (_) => LearningPathRepository(learningPathService),
      ),
    ];
  }

  /// Build BLoC providers
  List<BlocProvider> _buildBlocProviders() {
    return [
      BlocProvider<AuthCubit>(
        create: (context) => AuthCubit(
          context.read<AuthRepository>(),
          context.read<UserRepository>(),
        ),
      ),
      BlocProvider<UserCubit>(
        create: (context) => UserCubit(context.read<UserRepository>()),
      ),
      BlocProvider<ExerciseCubit>(
        create: (context) => ExerciseCubit(context.read<ExerciseRepository>()),
      ),
      BlocProvider<LearningPathCubit>(
        create: (context) =>
            LearningPathCubit(context.read<LearningPathRepository>()),
      ),
    ];
  }
}
