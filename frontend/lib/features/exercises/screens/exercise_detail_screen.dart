import 'dart:async';
import 'package:flutter/material.dart';
import '../../../config/theme.dart';

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
  Timer? _timer;
  final TextEditingController _answerController = TextEditingController();
  String _feedbackMessage = '';
  Color _feedbackColor = Colors.black;
  bool _showFeedback = false;

  // Mock exercise questions (in a real app, these would come from the backend API)
  final List<Map<String, dynamic>> _exercises = [
    {
      'question': '37 + 29',
      'answer': '66',
      'difficulty': 'Easy',
      'type': 'Addition'
    },
    {
      'question': '143 - 68',
      'answer': '75',
      'difficulty': 'Medium',
      'type': 'Subtraction'
    },
    {
      'question': '18 × 7',
      'answer': '126',
      'difficulty': 'Medium',
      'type': 'Multiplication'
    },
    {
      'question': '212 ÷ 4',
      'answer': '53',
      'difficulty': 'Hard',
      'type': 'Division'
    },
    {
      'question': '(25 × 4) + 13',
      'answer': '113',
      'difficulty': 'Hard',
      'type': 'Mixed'
    }
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    super.dispose();
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
            'Time\'s up! The correct answer was ${currentExercise['answer']}.';
        _feedbackColor = Colors.red;
      } else {
        if (_answerController.text.trim() == currentExercise['answer']) {
          _score++;
          _feedbackMessage = 'Correct! Great job!';
          _feedbackColor = Colors.green;
        } else {
          _feedbackMessage =
              'Incorrect. The right answer was ${currentExercise['answer']}.';
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
      _startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = _exercises[_questionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentExercise['type']} Exercise'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _timer?.cancel();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
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
                          color:
                              _getDifficultyColor(currentExercise['difficulty'])
                                  .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentExercise['difficulty'],
                          style: TextStyle(
                            color: _getDifficultyColor(
                                currentExercise['difficulty']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        currentExercise['question'],
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
                              ? Text(
                                  _feedbackMessage,
                                  style: TextStyle(
                                    color: _feedbackColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
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
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
