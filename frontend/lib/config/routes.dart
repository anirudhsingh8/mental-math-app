import 'package:flutter/material.dart';

// Feature screens (we'll create these next)
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/exercises/screens/exercise_list_screen.dart';
import '../features/exercises/screens/exercise_detail_screen.dart';
import '../features/learning_paths/screens/learning_path_screen.dart';
import '../features/progress/screens/progress_screen.dart';
import '../features/exercises/screens/home_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String exerciseList = '/exercises';
  static const String exerciseDetail = '/exercises/detail';
  static const String learningPath = '/learning-path';
  static const String progress = '/progress';

  // Route map
  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    exerciseList: (context) => const ExerciseListScreen(),
    exerciseDetail: (context) => const ExerciseDetailScreen(),
    learningPath: (context) => const LearningPathScreen(),
    progress: (context) => const ProgressScreen(),
  };
}
