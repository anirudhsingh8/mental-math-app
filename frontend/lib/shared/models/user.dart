class User {
  final String id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final UserStatistics? statistics;
  final UserPreferences? preferences;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.statistics,
    this.preferences,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      statistics: json['statistics'] != null
          ? UserStatistics.fromJson(json['statistics'])
          : null,
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'])
          : null,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'statistics': statistics?.toJson(),
      'preferences': preferences?.toJson(),
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class UserStatistics {
  final int exercisesCompleted;
  final int totalCorrect;
  final int totalAttempts;
  final double averageAccuracy;
  final int averageTimePerQuestion;

  UserStatistics({
    required this.exercisesCompleted,
    required this.totalCorrect,
    required this.totalAttempts,
    required this.averageAccuracy,
    required this.averageTimePerQuestion,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      exercisesCompleted: json['exercises_completed'] ?? 0,
      totalCorrect: json['total_correct'] ?? 0,
      totalAttempts: json['total_attempts'] ?? 0,
      averageAccuracy: (json['average_accuracy'] ?? 0.0).toDouble(),
      averageTimePerQuestion: json['average_time_per_question'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercises_completed': exercisesCompleted,
      'total_correct': totalCorrect,
      'total_attempts': totalAttempts,
      'average_accuracy': averageAccuracy,
      'average_time_per_question': averageTimePerQuestion,
    };
  }
}

class UserPreferences {
  final String difficulty;
  final List<String> favoriteCategories;
  final bool enableNotifications;
  final bool darkMode;
  final bool soundEnabled;

  UserPreferences({
    required this.difficulty,
    required this.favoriteCategories,
    required this.enableNotifications,
    required this.darkMode,
    required this.soundEnabled,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      difficulty: json['difficulty'] ?? 'medium',
      favoriteCategories: (json['favorite_categories'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      enableNotifications: json['enable_notifications'] ?? true,
      darkMode: json['dark_mode'] ?? false,
      soundEnabled: json['sound_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty,
      'favorite_categories': favoriteCategories,
      'enable_notifications': enableNotifications,
      'dark_mode': darkMode,
      'sound_enabled': soundEnabled,
    };
  }
}
