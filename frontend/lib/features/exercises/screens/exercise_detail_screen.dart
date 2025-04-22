import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../../shared/models/exercise.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../cubit/exercise_cubit.dart';
import '../cubit/exercise_state.dart';

class ExerciseDetailScreen extends StatefulWidget {
  const ExerciseDetailScreen({super.key});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  int _questionIndex = 0;
  int _score = 0;
  int _timeRemaining = 30;
  bool _isAnswering = true;
  bool _isLoading = true;
  Timer? _timer;
  final TextEditingController _answerController = TextEditingController();
  String _feedbackMessage = '';
  Color _feedbackColor = Colors.black;
  bool _showFeedback = false;

  // Will hold exercises fetched from API
  List<Exercise> _exercises = [];

  @override
  void initState() {
    super.initState();
    // We'll load exercises after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExercises();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  // Load exercises based on route arguments or generate new ones
  void _loadExercises() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final exerciseCubit = context.read<ExerciseCubit>();

    if (args != null && args.containsKey('exercise')) {
      // Single exercise was passed directly
      setState(() {
        _exercises = [args['exercise'] as Exercise];
        _isLoading = false;
      });
      _startTimer();
    } else if (args != null && args.containsKey('category')) {
      // Category was specified, load exercises for that category
      final category = args['category'] as String;
      exerciseCubit.loadByCategory(category, refresh: true);
    } else {
      // No specific exercise or category, generate a batch
      exerciseCubit.generateExerciseBatch(
        category: 'mixed',
        difficulty: 'medium',
        count: 5,
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _checkAnswer(isTimeout: true);
        }
      });
    });
  }

  void _checkAnswer({bool isTimeout = false}) {
    _timer?.cancel();
    final currentExercise = _exercises[_questionIndex];

    setState(() {
      _isAnswering = false;

      if (isTimeout) {
        _feedbackMessage =
            'Time\'s up! The correct answer was ${currentExercise.content.correctAnswer}.';
        _feedbackColor = Colors.red;
      } else {
        if (_answerController.text.trim() ==
            currentExercise.content.correctAnswer) {
          _score++;
          _feedbackMessage = 'Correct! Great job!';
          _feedbackColor = Colors.green;
        } else {
          _feedbackMessage =
              'Incorrect. The right answer was ${currentExercise.content.correctAnswer}.';
          _feedbackColor = Colors.red;
        }
      }

      _showFeedback = true;
    });

    // Move to next question after a delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        if (_questionIndex < _exercises.length - 1) {
          _questionIndex++;
          _answerController.clear();
          _timeRemaining = 30;
          _isAnswering = true;
          _showFeedback = false;
          _startTimer();
        } else {
          // End of exercise reached
          _showFeedback = false;
          _showResults();
        }
      });
    });
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exercise Completed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _score >= (_exercises.length / 2)
                  ? Icons.emoji_events
                  : Icons.mood,
              color: _score >= (_exercises.length / 2)
                  ? Colors.amber
                  : AppTheme.primaryColor,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Your score: $_score/${_exercises.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _getPerformanceMessage(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.diamond_outlined,
                      color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    '+${_score * 10} XP',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back to Exercises'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetExercise();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  String _getPerformanceMessage() {
    final percentage = (_score / _exercises.length) * 100;

    if (percentage >= 80) {
      return 'Excellent! Your mental math skills are impressive!';
    } else if (percentage >= 60) {
      return 'Good job! Keep practicing to improve further.';
    } else if (percentage >= 40) {
      return 'Nice effort! Regular practice will help you get better.';
    } else {
      return 'Keep practicing! Mental math skills improve with time.';
    }
  }

  void _resetExercise() {
    setState(() {
      _questionIndex = 0;
      _score = 0;
      _timeRemaining = 30;
      _isAnswering = true;
      _answerController.clear();
      _showFeedback = false;
      _loadExercises(); // Load fresh exercises
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading
            ? 'Loading Exercise'
            : _exercises.isNotEmpty
                ? _exercises[0].type
                : 'Exercise'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _timer?.cancel();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: BlocConsumer<ExerciseCubit, ExerciseState>(
        listener: (context, state) {
          if (state.status == ExerciseStatus.loaded &&
              state.exercises.isNotEmpty) {
            setState(() {
              _exercises = state.exercises;
              _isLoading = false;
            });
            _startTimer();
          }
        },
        builder: (context, state) {
          if (_isLoading &&
              (state.status == ExerciseStatus.loading ||
                  state.status == ExerciseStatus.generating)) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingIndicator(),
                  SizedBox(height: 16),
                  Text('Loading exercises...'),
                ],
              ),
            );
          } else if (_isLoading && state.status == ExerciseStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.errorMessage ?? "Failed to load exercises"}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadExercises,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else if (_exercises.isEmpty) {
            return const Center(
              child: Text('No exercises available'),
            );
          }

          return _buildExerciseContent();
        },
      ),
    );
  }

  Widget _buildExerciseContent() {
    final currentExercise = _exercises[_questionIndex];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Progress indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_questionIndex + 1}/${_exercises.length}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimaryColor,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTimeColor(_timeRemaining).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: _getTimeColor(_timeRemaining),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_timeRemaining s',
                        style: TextStyle(
                          color: _getTimeColor(_timeRemaining),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar
            LinearProgressIndicator(
              value: (_questionIndex + 1) / _exercises.length,
              backgroundColor: Colors.grey[300],
              color: AppTheme.primaryColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 40),

            // Question card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(currentExercise.difficulty)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        currentExercise.difficulty,
                        style: TextStyle(
                          color:
                              _getDifficultyColor(currentExercise.difficulty),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      currentExercise.content.problem,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Answer input or feedback
                    _isAnswering
                        ? TextField(
                            controller: _answerController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 24),
                            decoration: InputDecoration(
                              hintText: 'Enter your answer',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                            onSubmitted: (_) => _checkAnswer(),
                            autofocus: true,
                          )
                        : _showFeedback
                            ? Column(
                                children: [
                                  Text(
                                    _feedbackMessage,
                                    style: TextStyle(
                                      color: _feedbackColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (currentExercise
                                      .content.explanation.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(top: 16),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Explanation:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(currentExercise
                                              .content.explanation),
                                        ],
                                      ),
                                    ),
                                ],
                              )
                            : const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Submit button
            if (_isAnswering)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _checkAnswer(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Answer',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getTimeColor(int timeRemaining) {
    if (timeRemaining > 15) {
      return Colors.green;
    } else if (timeRemaining > 5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
