import 'package:mental_math_app/shared/models/exercise.dart';
import 'package:mental_math_app/shared/services/exercise_service.dart';

class ExerciseRepository {
  final ExerciseService _exerciseService;

  ExerciseRepository(this._exerciseService);

  /// Fetch a single exercise by ID
  Future<Exercise?> getExercise(String id) async {
    final response = await _exerciseService.getExercise(id);
    if (response.success && response.data != null) {
      return response.data;
    }
    return null;
  }

  /// Fetch exercises by category
  Future<List<Exercise>> getByCategory(
    String category, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _exerciseService.getByCategory(
      category,
      page: page,
      limit: limit,
    );
    if (response.success && response.data != null) {
      return response.data!;
    }
    return [];
  }

  /// Fetch exercises by difficulty
  Future<List<Exercise>> getByDifficulty(
    String difficulty, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _exerciseService.getByDifficulty(
      difficulty,
      page: page,
      limit: limit,
    );
    if (response.success && response.data != null) {
      return response.data!;
    }
    return [];
  }

  /// Fetch exercises by tags
  Future<List<Exercise>> getByTags(
    List<String> tags, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _exerciseService.getByTags(
      tags,
      page: page,
      limit: limit,
    );
    if (response.success && response.data != null) {
      return response.data!;
    }
    return [];
  }

  /// Generate a single exercise with AI
  Future<Exercise?> generateExercise({
    required String category,
    required String difficulty,
    bool saveToDb = false,
  }) async {
    final response = await _exerciseService.generateExercise(
      category: category,
      difficulty: difficulty,
      saveToDb: saveToDb,
    );
    if (response.success && response.data != null) {
      return response.data;
    }
    return null;
  }

  /// Generate multiple exercises with AI
  Future<List<Exercise>> generateExerciseBatch({
    required String category,
    required String difficulty,
    required int count,
    bool saveToDb = false,
  }) async {
    final response = await _exerciseService.generateExerciseBatch(
      category: category,
      difficulty: difficulty,
      count: count,
      saveToDb: saveToDb,
    );
    if (response.success && response.data != null) {
      return response.data!;
    }
    return [];
  }
}
