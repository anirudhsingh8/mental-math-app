import 'package:mental_math_app/shared/models/learning_path.dart';
import 'package:mental_math_app/shared/services/learning_path_service.dart';

class LearningPathRepository {
  final LearningPathService _learningPathService;

  LearningPathRepository(this._learningPathService);

  /// Get all learning paths with pagination
  Future<List<LearningPath>> getAllPaths({
    int limit = 10,
    int offset = 0,
  }) async {
    final response = await _learningPathService.getAllPaths(
      limit: limit,
      offset: offset,
    );
    if (response.success && response.data != null) {
      return response.data!;
    }
    return [];
  }

  /// Get a single learning path by ID
  Future<LearningPath?> getPath(String id) async {
    final response = await _learningPathService.getPath(id);
    if (response.success && response.data != null) {
      return response.data;
    }
    return null;
  }

  /// Get learning paths by difficulty
  Future<List<LearningPath>> getPathsByDifficulty(
    String difficulty, {
    int limit = 10,
    int offset = 0,
  }) async {
    final response = await _learningPathService.getPathsByDifficulty(
      difficulty,
      limit: limit,
      offset: offset,
    );
    if (response.success && response.data != null) {
      return response.data!;
    }
    return [];
  }

  /// Get learning paths by category
  Future<List<LearningPath>> getPathsByCategory(
    String category, {
    int limit = 10,
    int offset = 0,
  }) async {
    final response = await _learningPathService.getPathsByCategory(
      category,
      limit: limit,
      offset: offset,
    );
    if (response.success && response.data != null) {
      return response.data!;
    }
    return [];
  }

  /// Create a new learning path
  Future<LearningPath?> createPath(LearningPath path) async {
    final response = await _learningPathService.createPath(path);
    if (response.success && response.data != null) {
      return response.data;
    }
    return null;
  }

  /// Update an existing learning path
  Future<LearningPath?> updatePath(LearningPath path) async {
    final response = await _learningPathService.updatePath(path);
    if (response.success && response.data != null) {
      return response.data;
    }
    return null;
  }

  /// Delete a learning path
  Future<bool> deletePath(String id) async {
    final response = await _learningPathService.deletePath(id);
    return response.success;
  }

  /// Add a stage to a learning path
  Future<LearningPath?> addStage(
    String pathId, {
    required String title,
    required String description,
    required List<String> exerciseIds,
    required double minAccuracy,
    required int minExercises,
  }) async {
    final response = await _learningPathService.addStage(
      pathId,
      title: title,
      description: description,
      exerciseIds: exerciseIds,
      minAccuracy: minAccuracy,
      minExercises: minExercises,
    );
    if (response.success && response.data != null) {
      return response.data;
    }
    return null;
  }

  /// Update a stage in a learning path
  Future<LearningPath?> updateStage(
    String pathId,
    int stageNumber, {
    required String title,
    required String description,
    required List<String> exerciseIds,
    required double minAccuracy,
    required int minExercises,
  }) async {
    final response = await _learningPathService.updateStage(
      pathId,
      stageNumber,
      title: title,
      description: description,
      exerciseIds: exerciseIds,
      minAccuracy: minAccuracy,
      minExercises: minExercises,
    );
    if (response.success && response.data != null) {
      return response.data;
    }
    return null;
  }

  /// Remove a stage from a learning path
  Future<LearningPath?> removeStage(String pathId, int stageNumber) async {
    final response =
        await _learningPathService.removeStage(pathId, stageNumber);
    if (response.success && response.data != null) {
      return response.data;
    }
    return null;
  }
}
