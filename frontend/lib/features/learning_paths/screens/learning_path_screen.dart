import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../shared/models/learning_path.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../cubit/learning_path_cubit.dart';
import '../cubit/learning_path_state.dart';

class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({super.key});

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  @override
  void initState() {
    super.initState();
    // Load learning paths when the screen initializes
    _loadLearningPath();
  }

  void _loadLearningPath() {
    // Get the arguments from navigation if any
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final learningPathCubit = context.read<LearningPathCubit>();

    if (args != null && args.containsKey('pathId')) {
      // Load a specific learning path by ID
      learningPathCubit.loadLearningPath(args['pathId'] as String);
    } else if (args != null && args.containsKey('difficulty')) {
      // Load learning paths by difficulty
      learningPathCubit.loadByDifficulty(args['difficulty'] as String,
          refresh: true);
    } else if (args != null && args.containsKey('category')) {
      // Load learning paths by category
      learningPathCubit.loadByCategory(args['category'] as String,
          refresh: true);
    } else {
      // Load all learning paths
      learningPathCubit.loadLearningPaths(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LearningPathCubit, LearningPathState>(
        builder: (context, state) {
          if (state.status == LearningPathStatus.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your learning path...'),
                ],
              ),
            );
          } else if (state.status == LearningPathStatus.error) {
            return ErrorView(
              message: state.errorMessage ?? 'Failed to load learning path',
              onRetry: _loadLearningPath,
            );
          } else if (state.status == LearningPathStatus.loaded) {
            // If no paths are available, show an empty state
            if (state.paths.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school_outlined,
                        size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No learning paths available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back later for new content',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _loadLearningPath(),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }

            // Select the first path if none is selected
            final selectedPath = state.selectedPath ?? state.paths.first;

            return _buildLearningPathContent(selectedPath);
          }

          return const Center(child: Text('Select a learning path to begin'));
        },
      ),
    );
  }

  Widget _buildLearningPathContent(LearningPath learningPath) {
    // Calculate overall progress based on stages (for demo purposes)
    final completedStages =
        learningPath.stages.where((stage) => _isStageCompleted(stage)).length;
    final totalStages = learningPath.stages.length;
    final progress = totalStages > 0 ? completedStages / totalStages : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Overview card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.school_outlined,
                          color: AppTheme.primaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              learningPath.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Complete path: ${learningPath.stages.length} stages',
                              style: const TextStyle(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Overall progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey[300],
                                color: AppTheme.primaryColor,
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${(progress * 100).toInt()}% completed',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.diamond_outlined,
                                      size: 14,
                                      color: AppTheme.secondaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${completedStages * 100} XP earned',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Learning path stages
          Text(
            'Your Learning Journey',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Learning path stages list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: learningPath.stages.length,
            itemBuilder: (context, index) {
              final stage = learningPath.stages[index];
              final bool isActive = index == 0 ||
                  (index > 0 &&
                      _isStageCompleted(learningPath.stages[index - 1]));

              // Calculate stage progress for UI
              final stageProgress = _calculateStageProgress(stage);

              return Column(
                children: [
                  if (index > 0)
                    Container(
                      margin: const EdgeInsets.only(left: 24),
                      height: 30,
                      width: 2,
                      color:
                          isActive ? AppTheme.primaryColor : Colors.grey[300],
                    ),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        // Stage indicator
                        Column(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? (_isStageCompleted(stage)
                                        ? AppTheme.primaryColor
                                        : AppTheme.secondaryColor)
                                    : Colors.grey[300],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: _isStageCompleted(stage)
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      )
                                    : Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            if (index < learningPath.stages.length - 1)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: isActive && _isStageCompleted(stage)
                                      ? AppTheme.primaryColor
                                      : Colors.grey[300],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        // Stage content
                        Expanded(
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: isActive ? Colors.white : Colors.grey[100],
                            elevation: isActive ? 2 : 0,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Stage header
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        stage.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isActive
                                              ? AppTheme.textPrimaryColor
                                              : Colors.grey[600],
                                        ),
                                      ),
                                      if (_isStageCompleted(stage))
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.successColor
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                size: 14,
                                                color: AppTheme.successColor,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Completed',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.successColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    stage.description,
                                    style: TextStyle(
                                      color: isActive
                                          ? AppTheme.textSecondaryColor
                                          : Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Progress bar
                                  if (stageProgress < 1.0)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: LinearProgressIndicator(
                                            value: stageProgress,
                                            backgroundColor: Colors.grey[300],
                                            color: AppTheme.secondaryColor,
                                            minHeight: 6,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${(stageProgress * 100).toInt()}% complete',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isActive
                                                ? AppTheme.secondaryColor
                                                : Colors.grey[600],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),

                                  // If not active, don't show modules
                                  if (!isActive)
                                    Container(
                                      margin: const EdgeInsets.only(top: 16),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.lock_outline,
                                            size: 16,
                                            color: Colors.grey[700],
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Complete previous stages to unlock',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Exercise list (only for active stages)
                                  if (isActive) const SizedBox(height: 16),
                                  if (isActive && stage.exerciseIDs.isNotEmpty)
                                    ...List.generate(
                                      stage.exerciseIDs.length,
                                      (exerciseIndex) {
                                        final exerciseId =
                                            stage.exerciseIDs[exerciseIndex];
                                        // For demo purposes, we'll consider first exercise as completed in active stages
                                        final bool isExerciseCompleted =
                                            exerciseIndex == 0;

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 12.0),
                                          child: InkWell(
                                            onTap: () {
                                              if (!isExerciseCompleted) {
                                                Navigator.of(context).pushNamed(
                                                  AppRoutes.exerciseDetail,
                                                  arguments: {
                                                    'exerciseId': exerciseId
                                                  },
                                                );
                                              }
                                            },
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: isExerciseCompleted
                                                    ? Colors.grey[100]
                                                    : AppTheme.accentColor
                                                        .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: isExerciseCompleted
                                                      ? Colors.grey[300]!
                                                      : AppTheme.accentColor,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 32,
                                                    height: 32,
                                                    decoration: BoxDecoration(
                                                      color: isExerciseCompleted
                                                          ? Colors.grey[300]
                                                          : AppTheme
                                                              .secondaryColor,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: isExerciseCompleted
                                                          ? const Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors.white,
                                                              size: 16,
                                                            )
                                                          : const Icon(
                                                              Icons.play_arrow,
                                                              color:
                                                                  Colors.white,
                                                              size: 16,
                                                            ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Exercise ${exerciseIndex + 1}',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: isExerciseCompleted
                                                                ? Colors
                                                                    .grey[600]
                                                                : AppTheme
                                                                    .textPrimaryColor,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 2),
                                                        Text(
                                                          isExerciseCompleted
                                                              ? 'Completed exercise'
                                                              : 'Tap to start exercise',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: isExerciseCompleted
                                                                ? Colors
                                                                    .grey[500]
                                                                : AppTheme
                                                                    .textSecondaryColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Mock function to check if a stage is completed (this would normally come from the API)
  bool _isStageCompleted(PathStage stage) {
    // For demo purposes, we'll consider the first stage as completed
    return stage.stageNumber == 1;
  }

  // Mock function to calculate stage progress (this would normally come from the API)
  double _calculateStageProgress(PathStage stage) {
    // For demo purposes, we'll use stage number to determine progress
    if (stage.stageNumber == 1) return 1.0;
    if (stage.stageNumber == 2) return 0.33;
    return 0.0;
  }
}
