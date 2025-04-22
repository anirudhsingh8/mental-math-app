import 'package:mental_math_app/shared/models/api_response.dart';
import 'package:mental_math_app/shared/models/exercise.dart';
import 'package:mental_math_app/shared/services/api_client.dart';

class ExerciseService {
  final ApiClient _apiClient;

  ExerciseService(this._apiClient);

  Future<ApiResponse<Exercise>> getExercise(String id) async {
    return await _apiClient.get<Exercise>(
      '/exercises/$id',
      fromJson: (data) => Exercise.fromJson(data),
    );
  }

  Future<ApiResponse<List<Exercise>>> getByCategory(
    String category, {
    int page = 1,
    int limit = 10,
  }) async {
    return await _apiClient.get<List<Exercise>>(
      '/exercises/category/$category',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
      fromJson: (data) {
        final list = data['data'] as List;
        return list.map((item) => Exercise.fromJson(item)).toList();
      },
    );
  }

  Future<ApiResponse<List<Exercise>>> getByDifficulty(
    String difficulty, {
    int page = 1,
    int limit = 10,
  }) async {
    return await _apiClient.get<List<Exercise>>(
      '/exercises/difficulty/$difficulty',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
      fromJson: (data) {
        final list = data['data'] as List;
        return list.map((item) => Exercise.fromJson(item)).toList();
      },
    );
  }

  Future<ApiResponse<List<Exercise>>> getByTags(
    List<String> tags, {
    int page = 1,
    int limit = 10,
  }) async {
    return await _apiClient.get<List<Exercise>>(
      '/exercises/tags',
      queryParams: {
        'tags': tags.join(','),
        'page': page.toString(),
        'limit': limit.toString(),
      },
      fromJson: (data) {
        final list = data['data'] as List;
        return list.map((item) => Exercise.fromJson(item)).toList();
      },
    );
  }

  Future<ApiResponse<Exercise>> createExercise(Exercise exercise) async {
    return await _apiClient.post<Exercise>(
      '/exercises',
      body: exercise.toJson(),
      fromJson: (data) => Exercise.fromJson(data),
    );
  }

  Future<ApiResponse<Exercise>> updateExercise(Exercise exercise) async {
    return await _apiClient.put<Exercise>(
      '/exercises/${exercise.id}',
      body: exercise.toJson(),
      fromJson: (data) => Exercise.fromJson(data),
    );
  }

  Future<ApiResponse<void>> deleteExercise(String id) async {
    return await _apiClient.delete<void>(
      '/exercises/$id',
      fromJson: (_) {},
    );
  }

  // LLM-powered methods
  Future<ApiResponse<Exercise>> generateExercise({
    required String category,
    required String difficulty,
    bool saveToDb = false,
  }) async {
    return await _apiClient.post<Exercise>(
      '/exercises/generate',
      body: {
        'category': category,
        'difficulty': difficulty,
        'save_to_db': saveToDb,
      },
      fromJson: (data) => Exercise.fromJson(data),
    );
  }

  Future<ApiResponse<List<Exercise>>> generateExerciseBatch({
    required String category,
    required String difficulty,
    required int count,
    bool saveToDb = false,
  }) async {
    return await _apiClient.post<List<Exercise>>(
      '/exercises/generate-batch',
      body: {
        'category': category,
        'difficulty': difficulty,
        'count': count,
        'save_to_db': saveToDb,
      },
      fromJson: (data) {
        final list = data as List;
        return list.map((item) => Exercise.fromJson(item)).toList();
      },
    );
  }

  Future<ApiResponse<String>> enhanceExplanation({
    required String problem,
    required String answer,
  }) async {
    return await _apiClient.post<String>(
      '/exercises/enhance-explanation',
      body: {
        'problem': problem,
        'answer': answer,
      },
      fromJson: (data) => data['explanation'] as String,
    );
  }
}
