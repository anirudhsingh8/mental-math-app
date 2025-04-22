class Exercise {
  final String id;
  final String title;
  final String description;
  final String type;
  final String category;
  final String difficulty;
  final ExerciseContent content;
  final ExerciseMetadata metadata;
  final List<String> tags;

  Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.difficulty,
    required this.content,
    required this.metadata,
    required this.tags,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? '',
      content: ExerciseContent.fromJson(json['content'] ?? {}),
      metadata: ExerciseMetadata.fromJson(json['metadata'] ?? {}),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'category': category,
      'difficulty': difficulty,
      'content': content.toJson(),
      'metadata': metadata.toJson(),
      'tags': tags,
    };
  }
}

class ExerciseContent {
  final String problem;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  ExerciseContent({
    required this.problem,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory ExerciseContent.fromJson(Map<String, dynamic> json) {
    return ExerciseContent(
      problem: json['problem'] ?? '',
      options:
          (json['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
      correctAnswer: json['correct_answer'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'problem': problem,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
    };
  }
}

class ExerciseMetadata {
  final String generatedBy;
  final String templateId;
  final DateTime? createdAt;

  ExerciseMetadata({
    required this.generatedBy,
    required this.templateId,
    this.createdAt,
  });

  factory ExerciseMetadata.fromJson(Map<String, dynamic> json) {
    return ExerciseMetadata(
      generatedBy: json['generated_by'] ?? '',
      templateId: json['template_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generated_by': generatedBy,
      'template_id': templateId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
