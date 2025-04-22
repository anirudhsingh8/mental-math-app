import 'package:mental_math_app/shared/models/api_response.dart';
import 'package:mental_math_app/shared/models/progress.dart';
import 'package:mental_math_app/shared/services/api_client.dart';

class ProgressService {
  final ApiClient _apiClient;

  ProgressService(this._apiClient);

  Future<ApiResponse<List<UserProgress>>> getUserProgress() async {
    return await _apiClient.get<List<UserProgress>>(
      '/progress',
      fromJson: (data) {
        final list = data as List;
        return list.map((item) => UserProgress.fromJson(item)).toList();
      },
    );
  }

  Future<ApiResponse<UserProgress>> getProgressForExercise(
      String exerciseId) async {
    return await _apiClient.get<UserProgress>(
      '/progress/exercise/$exerciseId',
      fromJson: (data) => UserProgress.fromJson(data),
    );
  }

  Future<ApiResponse<void>> recordAttempt({
    required String exerciseId,
    required String userAnswer,
    required bool isCorrect,
    required int timeTaken,
  }) async {
    return await _apiClient.post<void>(
      '/progress/record',
      body: {
        'exercise_id': exerciseId,
        'user_answer': userAnswer,
        'is_correct': isCorrect,
        'time_taken': timeTaken,
      },
      fromJson: (_) {},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getRecentPerformance(
      {int days = 7}) async {
    return await _apiClient.get<Map<String, dynamic>>(
      '/progress/performance',
      queryParams: {
        'days': days.toString(),
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}
