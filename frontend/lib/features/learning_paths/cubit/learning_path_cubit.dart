import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_math_app/features/learning_paths/cubit/learning_path_state.dart';
import 'package:mental_math_app/features/learning_paths/data/learning_path_repository.dart';
import 'package:mental_math_app/shared/models/learning_path.dart';

class LearningPathCubit extends Cubit<LearningPathState> {
  final LearningPathRepository _repository;
  final int _pageSize = 10;

  LearningPathCubit(this._repository) : super(LearningPathState.initial());

  /// Load all learning paths with pagination
  Future<void> loadLearningPaths({bool refresh = false}) async {
    if (state.status == LearningPathStatus.loading) return;

    final currentOffset = refresh ? 0 : state.offset;

    if (refresh) {
      emit(LearningPathState.loading());
    } else {
      emit(state.copyWith(status: LearningPathStatus.loading));
    }

    try {
      final paths = await _repository.getAllPaths(
        limit: _pageSize,
        offset: currentOffset,
      );

      final hasReachedEnd = paths.length < _pageSize;
      final newOffset = currentOffset + paths.length;

      if (refresh) {
        emit(LearningPathState.loaded(
          paths,
          offset: newOffset,
          hasReachedEnd: hasReachedEnd,
        ));
      } else {
        emit(state.copyWith(
          status: LearningPathStatus.loaded,
          paths: [...state.paths, ...paths],
          offset: newOffset,
          hasReachedEnd: hasReachedEnd,
        ));
      }
    } catch (e) {
      emit(LearningPathState.error(e.toString()));
    }
  }

  /// Load a specific learning path by ID
  Future<void> loadLearningPath(String id) async {
    emit(LearningPathState.loading());

    try {
      final path = await _repository.getPath(id);

      if (path != null) {
        emit(LearningPathState.loaded([path], selectedPath: path));
      } else {
        emit(LearningPathState.error('Learning path not found'));
      }
    } catch (e) {
      emit(LearningPathState.error(e.toString()));
    }
  }

  /// Load learning paths by difficulty
  Future<void> loadByDifficulty(String difficulty,
      {bool refresh = false}) async {
    if (state.status == LearningPathStatus.loading) return;

    final currentOffset = refresh ? 0 : state.offset;

    if (refresh) {
      emit(LearningPathState.loading());
    } else {
      emit(state.copyWith(status: LearningPathStatus.loading));
    }

    try {
      final paths = await _repository.getPathsByDifficulty(
        difficulty,
        limit: _pageSize,
        offset: currentOffset,
      );

      final hasReachedEnd = paths.length < _pageSize;
      final newOffset = currentOffset + paths.length;

      if (refresh) {
        emit(LearningPathState.loaded(
          paths,
          offset: newOffset,
          hasReachedEnd: hasReachedEnd,
          filterDifficulty: difficulty,
        ));
      } else {
        emit(state.copyWith(
          status: LearningPathStatus.loaded,
          paths: [...state.paths, ...paths],
          offset: newOffset,
          hasReachedEnd: hasReachedEnd,
          filterDifficulty: difficulty,
        ));
      }
    } catch (e) {
      emit(LearningPathState.error(e.toString()));
    }
  }

  /// Load learning paths by category
  Future<void> loadByCategory(String category, {bool refresh = false}) async {
    if (state.status == LearningPathStatus.loading) return;

    final currentOffset = refresh ? 0 : state.offset;

    if (refresh) {
      emit(LearningPathState.loading());
    } else {
      emit(state.copyWith(status: LearningPathStatus.loading));
    }

    try {
      final paths = await _repository.getPathsByCategory(
        category,
        limit: _pageSize,
        offset: currentOffset,
      );

      final hasReachedEnd = paths.length < _pageSize;
      final newOffset = currentOffset + paths.length;

      if (refresh) {
        emit(LearningPathState.loaded(
          paths,
          offset: newOffset,
          hasReachedEnd: hasReachedEnd,
          filterCategory: category,
        ));
      } else {
        emit(state.copyWith(
          status: LearningPathStatus.loaded,
          paths: [...state.paths, ...paths],
          offset: newOffset,
          hasReachedEnd: hasReachedEnd,
          filterCategory: category,
        ));
      }
    } catch (e) {
      emit(LearningPathState.error(e.toString()));
    }
  }

  /// Create a new learning path
  Future<bool> createLearningPath(LearningPath path) async {
    try {
      final createdPath = await _repository.createPath(path);

      if (createdPath != null) {
        emit(state.copyWith(
          paths: [...state.paths, createdPath],
          selectedPath: createdPath,
        ));
        return true;
      }
      return false;
    } catch (e) {
      emit(LearningPathState.error(e.toString()));
      return false;
    }
  }

  /// Update an existing learning path
  Future<bool> updateLearningPath(LearningPath path) async {
    try {
      final updatedPath = await _repository.updatePath(path);

      if (updatedPath != null) {
        final updatedPaths = state.paths
            .map((p) => p.id == updatedPath.id ? updatedPath : p)
            .toList();

        emit(state.copyWith(
          paths: updatedPaths,
          selectedPath: updatedPath,
        ));
        return true;
      }
      return false;
    } catch (e) {
      emit(LearningPathState.error(e.toString()));
      return false;
    }
  }

  /// Delete a learning path
  Future<bool> deleteLearningPath(String id) async {
    try {
      final success = await _repository.deletePath(id);

      if (success) {
        final updatedPaths = state.paths.where((p) => p.id != id).toList();
        final selectedPath =
            state.selectedPath?.id == id ? null : state.selectedPath;

        emit(state.copyWith(
          paths: updatedPaths,
          selectedPath: selectedPath,
        ));
        return true;
      }
      return false;
    } catch (e) {
      emit(LearningPathState.error(e.toString()));
      return false;
    }
  }

  /// Add a stage to a learning path
  Future<bool> addStage(
    String pathId, {
    required String title,
    required String description,
    required List<String> exerciseIds,
    required double minAccuracy,
    required int minExercises,
  }) async {
    try {
      final updatedPath = await _repository.addStage(
        pathId,
        title: title,
        description: description,
        exerciseIds: exerciseIds,
        minAccuracy: minAccuracy,
        minExercises: minExercises,
      );

      if (updatedPath != null) {
        final updatedPaths = state.paths
            .map((p) => p.id == updatedPath.id ? updatedPath : p)
            .toList();

        emit(state.copyWith(
          paths: updatedPaths,
          selectedPath: updatedPath,
        ));
        return true;
      }
      return false;
    } catch (e) {
      emit(LearningPathState.error(e.toString()));
      return false;
    }
  }

  /// Update a stage in a learning path
  Future<bool> updateStage(
    String pathId,
    int stageNumber, {
    required String title,
    required String description,
    required List<String> exerciseIds,
    required double minAccuracy,
    required int minExercises,
  }) async {
    try {
      final updatedPath = await _repository.updateStage(
        pathId,
        stageNumber,
        title: title,
        description: description,
        exerciseIds: exerciseIds,
        minAccuracy: minAccuracy,
        minExercises: minExercises,
      );

      if (updatedPath != null) {
        final updatedPaths = state.paths
            .map((p) => p.id == updatedPath.id ? updatedPath : p)
            .toList();

        emit(state.copyWith(
          paths: updatedPaths,
          selectedPath: updatedPath,
        ));
        return true;
      }
      return false;
    } catch (e) {
      emit(LearningPathState.error(e.toString()));
      return false;
    }
  }

  /// Remove a stage from a learning path
  Future<bool> removeStage(String pathId, int stageNumber) async {
    try {
      final updatedPath = await _repository.removeStage(pathId, stageNumber);

      if (updatedPath != null) {
        final updatedPaths = state.paths
            .map((p) => p.id == updatedPath.id ? updatedPath : p)
            .toList();

        emit(state.copyWith(
          paths: updatedPaths,
          selectedPath: updatedPath,
        ));
        return true;
      }
      return false;
    } catch (e) {
      emit(LearningPathState.error(e.toString()));
      return false;
    }
  }

  /// Set the selected learning path
  void selectLearningPath(LearningPath path) {
    emit(state.copyWith(selectedPath: path));
  }

  /// Clear all filters
  void clearFilters() {
    emit(state.copyWith(
      filterCategory: null,
      filterDifficulty: null,
    ));
    loadLearningPaths(refresh: true);
  }

  /// Reset the state
  void reset() {
    emit(LearningPathState.initial());
  }
}
