import 'package:equatable/equatable.dart';
import 'package:mental_math_app/shared/models/learning_path.dart';

/// Defines the possible states for the LearningPathCubit
enum LearningPathStatus { initial, loading, loaded, error }

/// Represents the state of learning paths in the application
class LearningPathState extends Equatable {
  final LearningPathStatus status;
  final List<LearningPath> paths;
  final LearningPath? selectedPath;
  final String? errorMessage;
  final int offset;
  final bool hasReachedEnd;
  final String? filterCategory;
  final String? filterDifficulty;

  const LearningPathState({
    this.status = LearningPathStatus.initial,
    this.paths = const [],
    this.selectedPath,
    this.errorMessage,
    this.offset = 0,
    this.hasReachedEnd = false,
    this.filterCategory,
    this.filterDifficulty,
  });

  /// Creates a copy of the current state with updated values
  LearningPathState copyWith({
    LearningPathStatus? status,
    List<LearningPath>? paths,
    LearningPath? selectedPath,
    String? errorMessage,
    int? offset,
    bool? hasReachedEnd,
    String? filterCategory,
    String? filterDifficulty,
  }) {
    return LearningPathState(
      status: status ?? this.status,
      paths: paths ?? this.paths,
      selectedPath: selectedPath ?? this.selectedPath,
      errorMessage: errorMessage,
      offset: offset ?? this.offset,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      filterCategory: filterCategory ?? this.filterCategory,
      filterDifficulty: filterDifficulty ?? this.filterDifficulty,
    );
  }

  @override
  List<Object?> get props => [
        status,
        paths,
        selectedPath,
        errorMessage,
        offset,
        hasReachedEnd,
        filterCategory,
        filterDifficulty,
      ];

  /// Initial state - no learning paths loaded
  factory LearningPathState.initial() =>
      const LearningPathState(status: LearningPathStatus.initial);

  /// Loading state - learning paths are being fetched
  factory LearningPathState.loading() =>
      const LearningPathState(status: LearningPathStatus.loading);

  /// Loaded state - learning paths have been loaded successfully
  factory LearningPathState.loaded(
    List<LearningPath> paths, {
    LearningPath? selectedPath,
    int offset = 0,
    bool hasReachedEnd = false,
    String? filterCategory,
    String? filterDifficulty,
  }) =>
      LearningPathState(
        status: LearningPathStatus.loaded,
        paths: paths,
        selectedPath: selectedPath,
        offset: offset,
        hasReachedEnd: hasReachedEnd,
        filterCategory: filterCategory,
        filterDifficulty: filterDifficulty,
      );

  /// Error state - failed to load learning paths
  factory LearningPathState.error(String message) => LearningPathState(
      status: LearningPathStatus.error, errorMessage: message);
}
