import 'package:equatable/equatable.dart';
import 'package:mental_math_app/shared/models/exercise.dart';

/// Possible states for exercise loading
enum ExerciseStatus {
  initial,
  loading,
  loaded,
  error,
  generating,
}

/// Represents the state of exercises in the application
class ExerciseState extends Equatable {
  final ExerciseStatus status;
  final List<Exercise> exercises;
  final Exercise? currentExercise;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;

  const ExerciseState({
    this.status = ExerciseStatus.initial,
    this.exercises = const [],
    this.currentExercise,
    this.errorMessage,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  /// Creates a copy of the current state with updated values
  ExerciseState copyWith({
    ExerciseStatus? status,
    List<Exercise>? exercises,
    Exercise? currentExercise,
    String? errorMessage,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return ExerciseState(
      status: status ?? this.status,
      exercises: exercises ?? this.exercises,
      currentExercise: currentExercise ?? this.currentExercise,
      errorMessage: errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        exercises,
        currentExercise,
        errorMessage,
        hasReachedMax,
        currentPage,
      ];

  /// Initial state - no exercises loaded
  factory ExerciseState.initial() =>
      const ExerciseState(status: ExerciseStatus.initial);

  /// Loading state - exercises are being fetched
  factory ExerciseState.loading() =>
      const ExerciseState(status: ExerciseStatus.loading);

  /// Loaded state - exercises have been loaded successfully
  factory ExerciseState.loaded(
    List<Exercise> exercises, {
    Exercise? currentExercise,
    bool hasReachedMax = false,
    int currentPage = 1,
  }) =>
      ExerciseState(
        status: ExerciseStatus.loaded,
        exercises: exercises,
        currentExercise: currentExercise,
        hasReachedMax: hasReachedMax,
        currentPage: currentPage,
      );

  /// Error state - failed to load exercises
  factory ExerciseState.error(String message) =>
      ExerciseState(status: ExerciseStatus.error, errorMessage: message);

  /// Generating state - AI is generating exercises
  factory ExerciseState.generating() =>
      const ExerciseState(status: ExerciseStatus.generating);
}
