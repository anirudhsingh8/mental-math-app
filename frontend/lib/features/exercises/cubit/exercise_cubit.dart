import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_math_app/features/exercises/cubit/exercise_state.dart';
import 'package:mental_math_app/features/exercises/data/exercise_repository.dart';
import 'package:mental_math_app/shared/models/exercise.dart';

class ExerciseCubit extends Cubit<ExerciseState> {
  final ExerciseRepository _repository;
  final int _pageSize = 10;

  ExerciseCubit(this._repository) : super(ExerciseState.initial());

  /// Load a single exercise by ID
  Future<void> loadExercise(String id) async {
    emit(ExerciseState.loading());

    try {
      final exercise = await _repository.getExercise(id);

      if (exercise != null) {
        emit(ExerciseState.loaded([exercise], currentExercise: exercise));
      } else {
        emit(ExerciseState.error('Exercise not found'));
      }
    } catch (e) {
      emit(ExerciseState.error(e.toString()));
    }
  }

  /// Load exercises by category
  Future<void> loadByCategory(String category, {bool refresh = false}) async {
    if (state.status == ExerciseStatus.loading) return;

    final currentState = state;
    final currentPage = refresh ? 1 : state.currentPage;

    if (refresh) {
      emit(ExerciseState.loading());
    } else {
      emit(state.copyWith(status: ExerciseStatus.loading));
    }

    try {
      final exercises = await _repository.getByCategory(
        category,
        page: currentPage,
        limit: _pageSize,
      );

      if (exercises.isEmpty) {
        emit(state.copyWith(
          status: ExerciseStatus.loaded,
          hasReachedMax: true,
        ));
        return;
      }

      if (refresh) {
        emit(ExerciseState.loaded(
          exercises,
          currentPage: currentPage + 1,
        ));
      } else {
        emit(ExerciseState.loaded(
          [...currentState.exercises, ...exercises],
          currentPage: currentPage + 1,
          currentExercise: currentState.currentExercise,
        ));
      }
    } catch (e) {
      emit(ExerciseState.error(e.toString()));
    }
  }

  /// Load exercises by difficulty
  Future<void> loadByDifficulty(String difficulty,
      {bool refresh = false}) async {
    if (state.status == ExerciseStatus.loading) return;

    final currentState = state;
    final currentPage = refresh ? 1 : state.currentPage;

    if (refresh) {
      emit(ExerciseState.loading());
    } else {
      emit(state.copyWith(status: ExerciseStatus.loading));
    }

    try {
      final exercises = await _repository.getByDifficulty(
        difficulty,
        page: currentPage,
        limit: _pageSize,
      );

      if (exercises.isEmpty) {
        emit(state.copyWith(
          status: ExerciseStatus.loaded,
          hasReachedMax: true,
        ));
        return;
      }

      if (refresh) {
        emit(ExerciseState.loaded(
          exercises,
          currentPage: currentPage + 1,
        ));
      } else {
        emit(ExerciseState.loaded(
          [...currentState.exercises, ...exercises],
          currentPage: currentPage + 1,
          currentExercise: currentState.currentExercise,
        ));
      }
    } catch (e) {
      emit(ExerciseState.error(e.toString()));
    }
  }

  /// Load exercises by tags
  Future<void> loadByTags(List<String> tags, {bool refresh = false}) async {
    if (state.status == ExerciseStatus.loading) return;

    final currentState = state;
    final currentPage = refresh ? 1 : state.currentPage;

    if (refresh) {
      emit(ExerciseState.loading());
    } else {
      emit(state.copyWith(status: ExerciseStatus.loading));
    }

    try {
      final exercises = await _repository.getByTags(
        tags,
        page: currentPage,
        limit: _pageSize,
      );

      if (exercises.isEmpty) {
        emit(state.copyWith(
          status: ExerciseStatus.loaded,
          hasReachedMax: true,
        ));
        return;
      }

      if (refresh) {
        emit(ExerciseState.loaded(
          exercises,
          currentPage: currentPage + 1,
        ));
      } else {
        emit(ExerciseState.loaded(
          [...currentState.exercises, ...exercises],
          currentPage: currentPage + 1,
          currentExercise: currentState.currentExercise,
        ));
      }
    } catch (e) {
      emit(ExerciseState.error(e.toString()));
    }
  }

  /// Generate an exercise with AI
  Future<void> generateExercise({
    required String category,
    required String difficulty,
  }) async {
    emit(ExerciseState.generating());

    try {
      final exercise = await _repository.generateExercise(
        category: category,
        difficulty: difficulty,
        saveToDb: true,
      );

      if (exercise != null) {
        emit(ExerciseState.loaded(
          [exercise],
          currentExercise: exercise,
        ));
      } else {
        emit(ExerciseState.error('Failed to generate exercise'));
      }
    } catch (e) {
      emit(ExerciseState.error(e.toString()));
    }
  }

  /// Generate multiple exercises with AI
  Future<void> generateExerciseBatch({
    required String category,
    required String difficulty,
    required int count,
  }) async {
    emit(ExerciseState.generating());

    try {
      final exercises = await _repository.generateExerciseBatch(
        category: category,
        difficulty: difficulty,
        count: count,
        saveToDb: true,
      );

      if (exercises.isNotEmpty) {
        emit(ExerciseState.loaded(exercises));
      } else {
        emit(ExerciseState.error('Failed to generate exercises'));
      }
    } catch (e) {
      emit(ExerciseState.error(e.toString()));
    }
  }

  /// Set current exercise
  void setCurrentExercise(Exercise exercise) {
    emit(state.copyWith(
      currentExercise: exercise,
    ));
  }

  /// Clear all loaded exercises
  void clearExercises() {
    emit(ExerciseState.initial());
  }
}
