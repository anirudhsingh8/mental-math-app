class LearningPath {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final List<String> categories;
  final List<PathStage> stages;
  final DateTime createdAt;
  final DateTime updatedAt;

  LearningPath({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.categories,
    required this.stages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LearningPath.fromJson(Map<String, dynamic> json) {
    return LearningPath(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      difficulty: json['difficulty'] ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      stages: (json['stages'] as List?)
              ?.map((stage) => PathStage.fromJson(stage))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'categories': categories,
      'stages': stages.map((stage) => stage.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class PathStage {
  final int stageNumber;
  final String title;
  final String description;
  final List<String> exerciseIDs;
  final CompletionCriteria completionCriteria;

  PathStage({
    required this.stageNumber,
    required this.title,
    required this.description,
    required this.exerciseIDs,
    required this.completionCriteria,
  });

  factory PathStage.fromJson(Map<String, dynamic> json) {
    return PathStage(
      stageNumber: json['stage_number'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      exerciseIDs: List<String>.from(json['exercise_ids'] ?? []),
      completionCriteria:
          CompletionCriteria.fromJson(json['completion_criteria'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stage_number': stageNumber,
      'title': title,
      'description': description,
      'exercise_ids': exerciseIDs,
      'completion_criteria': completionCriteria.toJson(),
    };
  }
}

class CompletionCriteria {
  final double minAccuracy;
  final int minExercises;

  CompletionCriteria({
    required this.minAccuracy,
    required this.minExercises,
  });

  factory CompletionCriteria.fromJson(Map<String, dynamic> json) {
    return CompletionCriteria(
      minAccuracy: (json['min_accuracy'] ?? 0.0).toDouble(),
      minExercises: json['min_exercises'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min_accuracy': minAccuracy,
      'min_exercises': minExercises,
    };
  }
}
