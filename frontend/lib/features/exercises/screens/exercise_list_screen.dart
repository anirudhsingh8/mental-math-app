import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../shared/models/exercise.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../cubit/exercise_cubit.dart';
import '../cubit/exercise_state.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  // Exercise categories with their UI properties
  final List<Map<String, dynamic>> _exerciseCategories = [
    {
      'icon': Icons.add,
      'title': 'Addition',
      'category': 'addition',
      'description': 'Practice quick addition with various difficulty levels',
      'color': Colors.blue.shade700,
    },
    {
      'icon': Icons.remove,
      'title': 'Subtraction',
      'category': 'subtraction',
      'description': 'Master mental subtraction with strategic techniques',
      'color': Colors.green.shade700,
    },
    {
      'icon': Icons.close,
      'title': 'Multiplication',
      'category': 'multiplication',
      'description': 'Learn multiplication shortcuts for rapid calculation',
      'color': Colors.orange.shade700,
    },
    {
      'icon': Icons.percent,
      'title': 'Division',
      'category': 'division',
      'description': 'Divide numbers quickly and efficiently in your head',
      'color': Colors.purple.shade700,
    },
    {
      'icon': Icons.psychology,
      'title': 'Mixed Operations',
      'category': 'mixed',
      'description': 'Challenge yourself with combined operations',
      'color': Colors.red.shade700,
    },
    {
      'icon': Icons.timer,
      'title': 'Speed Challenges',
      'category': 'speed',
      'description': 'Test your mental math speed with timed exercises',
      'color': Colors.teal.shade700,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Generate the daily challenge when the screen loads
    _generateDailyChallenge();
  }

  // Generate a daily challenge exercise
  void _generateDailyChallenge() {
    final exerciseCubit = context.read<ExerciseCubit>();
    exerciseCubit.generateExercise(
      category: 'mixed',
      difficulty: 'medium',
    );
  }

  void _navigateToCategory(String category) {
    Navigator.of(context).pushNamed(
      AppRoutes.exerciseDetail,
      arguments: {'category': category},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Text(
                'Welcome back!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimaryColor,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'What would you like to practice today?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
              const SizedBox(height: 24),

              // Daily challenge card with state management
              BlocBuilder<ExerciseCubit, ExerciseState>(
                builder: (context, state) {
                  if (state.status == ExerciseStatus.generating ||
                      state.status == ExerciseStatus.loading) {
                    return _buildChallengeCardSkeleton(context);
                  } else if (state.status == ExerciseStatus.error) {
                    return _buildChallengeCardError(
                        context, state.errorMessage);
                  } else if (state.status == ExerciseStatus.loaded &&
                      state.currentExercise != null) {
                    return _buildChallengeCard(context, state.currentExercise!);
                  } else {
                    return _buildChallengeCardSkeleton(context);
                  }
                },
              ),
              const SizedBox(height: 24),

              // Exercise categories heading
              Text(
                'Exercise Categories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Exercise categories grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _exerciseCategories.length,
                  itemBuilder: (context, index) {
                    final category = _exerciseCategories[index];
                    return InkWell(
                      onTap: () {
                        _navigateToCategory(category['category']);
                      },
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: category['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  category['icon'],
                                  color: category['color'],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                category['title'],
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: Text(
                                  category['description'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Challenge card when data is loading
  Widget _buildChallengeCardSkeleton(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Challenge',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '50 XP',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const LoadingIndicator(color: Colors.white),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: null, // Disabled while loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.5),
                    foregroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Loading...'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Challenge card when there's an error
  Widget _buildChallengeCardError(BuildContext context, String? errorMessage) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Colors.redAccent,
              Colors.red,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Challenge',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to load challenge: ${errorMessage ?? "Unknown error"}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _generateDailyChallenge,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Try Again'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Challenge card with loaded exercise
  Widget _buildChallengeCard(BuildContext context, Exercise exercise) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Challenge',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '50 XP',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                exercise.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                exercise.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.exerciseDetail,
                      arguments: {'exercise': exercise},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Start Challenge'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
