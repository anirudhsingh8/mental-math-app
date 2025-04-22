class UserProgress {
  final String id;
  final String userId;
  final String exerciseId;
  final double masteryLevel;
  final List<Attempt> attempts;
  final DateTime lastAttempted;

  UserProgress({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.masteryLevel,
    required this.attempts,
    required this.lastAttempted,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      exerciseId: json['exercise_id'] ?? '',
      masteryLevel: (json['mastery_level'] ?? 0.0).toDouble(),
      attempts: (json['attempts'] as List?)
              ?.map((attempt) => Attempt.fromJson(attempt))
              .toList() ??
          [],
      lastAttempted: json['last_attempted'] != null
          ? DateTime.parse(json['last_attempted'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'exercise_id': exerciseId,
      'mastery_level': masteryLevel,
      'attempts': attempts.map((attempt) => attempt.toJson()).toList(),
      'last_attempted': lastAttempted.toIso8601String(),
    };
  }
}

class Attempt {
  final String userAnswer;
  final bool isCorrect;
  final int timeTaken;
  final DateTime timestamp;

  Attempt({
    required this.userAnswer,
    required this.isCorrect,
    required this.timeTaken,
    required this.timestamp,
  });

  factory Attempt.fromJson(Map<String, dynamic> json) {
    return Attempt(
      userAnswer: json['user_answer'] ?? '',
      isCorrect: json['is_correct'] ?? false,
      timeTaken: json['time_taken'] ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_answer': userAnswer,
      'is_correct': isCorrect,
      'time_taken': timeTaken,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
