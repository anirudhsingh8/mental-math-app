import 'package:mental_math_app/shared/models/api_response.dart';
import 'package:mental_math_app/shared/models/learning_path.dart';
import 'package:mental_math_app/shared/services/api_client.dart';

class LearningPathService {
  final ApiClient _apiClient;

  LearningPathService(this._apiClient);

  Future<ApiResponse<List<LearningPath>>> getAllPaths({
    int limit = 10,
    int offset = 0,
  }) async {
    return await _apiClient.get<List<LearningPath>>(
      '/learning-paths',
      queryParams: {
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
      fromJson: (data) {
        final list = data as List;
        return list.map((item) => LearningPath.fromJson(item)).toList();
      },
    );
  }

  Future<ApiResponse<LearningPath>> getPath(String id) async {
    return await _apiClient.get<LearningPath>(
      '/learning-paths/$id',
      fromJson: (data) => LearningPath.fromJson(data),
    );
  }

  Future<ApiResponse<List<LearningPath>>> getPathsByDifficulty(
    String difficulty, {
    int limit = 10,
    int offset = 0,
  }) async {
    return await _apiClient.get<List<LearningPath>>(
      '/learning-paths/difficulty/$difficulty',
      queryParams: {
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
      fromJson: (data) {
        final list = data as List;
        return list.map((item) => LearningPath.fromJson(item)).toList();
      },
    );
  }

  Future<ApiResponse<List<LearningPath>>> getPathsByCategory(
    String category, {
    int limit = 10,
    int offset = 0,
  }) async {
    return await _apiClient.get<List<LearningPath>>(
      '/learning-paths/category/$category',
      queryParams: {
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
      fromJson: (data) {
        final list = data as List;
        return list.map((item) => LearningPath.fromJson(item)).toList();
      },
    );
  }

  // Methods below require authentication
  Future<ApiResponse<LearningPath>> createPath(LearningPath path) async {
    return await _apiClient.post<LearningPath>(
      '/learning-paths',
      body: path.toJson(),
      fromJson: (data) => LearningPath.fromJson(data),
    );
  }

  Future<ApiResponse<LearningPath>> updatePath(LearningPath path) async {
    return await _apiClient.put<LearningPath>(
      '/learning-paths/${path.id}',
      body: path.toJson(),
      fromJson: (data) => LearningPath.fromJson(data),
    );
  }

  Future<ApiResponse<void>> deletePath(String id) async {
    return await _apiClient.delete<void>(
      '/learning-paths/$id',
      fromJson: (_) {},
    );
  }

  // Path stage management
  Future<ApiResponse<LearningPath>> addStage(
    String pathId, {
    required String title,
    required String description,
    required List<String> exerciseIds,
    required double minAccuracy,
    required int minExercises,
  }) async {
    return await _apiClient.post<LearningPath>(
      '/learning-paths/$pathId/stages',
      body: {
        'title': title,
        'description': description,
        'exercise_ids': exerciseIds,
        'completion_criteria': {
          'min_accuracy': minAccuracy,
          'min_exercises': minExercises,
        },
      },
      fromJson: (data) => LearningPath.fromJson(data),
    );
  }

  Future<ApiResponse<LearningPath>> updateStage(
    String pathId,
    int stageNumber, {
    required String title,
    required String description,
    required List<String> exerciseIds,
    required double minAccuracy,
    required int minExercises,
  }) async {
    return await _apiClient.put<LearningPath>(
      '/learning-paths/$pathId/stages/$stageNumber',
      body: {
        'title': title,
        'description': description,
        'exercise_ids': exerciseIds,
        'completion_criteria': {
          'min_accuracy': minAccuracy,
          'min_exercises': minExercises,
        },
      },
      fromJson: (data) => LearningPath.fromJson(data),
    );
  }

  Future<ApiResponse<LearningPath>> removeStage(
    String pathId,
    int stageNumber,
  ) async {
    return await _apiClient.delete<LearningPath>(
      '/learning-paths/$pathId/stages/$stageNumber',
      fromJson: (data) => LearningPath.fromJson(data),
    );
  }
}
