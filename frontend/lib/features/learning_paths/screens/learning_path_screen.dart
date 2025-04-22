import 'package:flutter/material.dart';

import '../../../config/routes.dart';
import '../../../config/theme.dart';

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for learning paths
    final List<Map<String, dynamic>> stages = [
      {
        'title': 'Basics of Mental Math',
        'subtitle': 'Foundation skills',
        'isCompleted': true,
        'progress': 1.0,
        'modules': [
          {
            'title': 'Introduction to Mental Math',
            'description': 'Learn why mental math is important',
            'isCompleted': true,
          },
          {
            'title': 'Basic Addition Strategies',
            'description': 'Simple techniques for quick addition',
            'isCompleted': true,
          },
          {
            'title': 'Basic Subtraction Strategies',
            'description': 'Methods for mental subtraction',
            'isCompleted': true,
          }
        ]
      },
      {
        'title': 'Intermediate Techniques',
        'subtitle': 'Build your skills',
        'isCompleted': false,
        'progress': 0.33,
        'modules': [
          {
            'title': 'Multiplication Shortcuts',
            'description': 'Learn tricks for faster multiplication',
            'isCompleted': true,
          },
          {
            'title': 'Division Strategies',
            'description': 'Simplify division in your head',
            'isCompleted': false,
          },
          {
            'title': 'Working with Decimals',
            'description': 'Mental math with decimal numbers',
            'isCompleted': false,
          }
        ]
      },
      {
        'title': 'Advanced Methods',
        'subtitle': 'Master mental math',
        'isCompleted': false,
        'progress': 0.0,
        'modules': [
          {
            'title': 'Squaring Numbers',
            'description': 'Quick techniques for squaring',
            'isCompleted': false,
          },
          {
            'title': 'Calculating Percentages',
            'description': 'Mental percentage calculations',
            'isCompleted': false,
          },
          {
            'title': 'Speed Math Techniques',
            'description': 'Advanced methods for rapid calculation',
            'isCompleted': false,
          }
        ]
      },
    ];

    return Scaffold(
      body: SingleChildScrollView(
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
                              const Text(
                                'Mathematics Mastery',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Complete path: 3 stages, 9 modules',
                                style: TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Overall progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value:
                                      0.44, // Calculated from stages completion
                                  backgroundColor: Colors.grey[300],
                                  color: AppTheme.primaryColor,
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '44% completed',
                                    style: TextStyle(
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
                                        '340 XP earned',
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
              itemCount: stages.length,
              itemBuilder: (context, index) {
                final stage = stages[index];
                final bool isActive = index == 0 ||
                    (index > 0 && stages[index - 1]['isCompleted'] == true);

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
                                      ? (stage['isCompleted'] == true
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
                                  child: stage['isCompleted'] == true
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
                              if (index < stages.length - 1)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color:
                                        isActive && stage['isCompleted'] == true
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
                                          stage['title'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isActive
                                                ? AppTheme.textPrimaryColor
                                                : Colors.grey[600],
                                          ),
                                        ),
                                        if (stage['isCompleted'] == true)
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
                                                    color:
                                                        AppTheme.successColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      stage['subtitle'],
                                      style: TextStyle(
                                        color: isActive
                                            ? AppTheme.textSecondaryColor
                                            : Colors.grey[500],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Progress bar
                                    if (stage['progress'] < 1.0)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: LinearProgressIndicator(
                                              value: stage['progress'],
                                              backgroundColor: Colors.grey[300],
                                              color: AppTheme.secondaryColor,
                                              minHeight: 6,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${(stage['progress'] * 100).toInt()}% complete',
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
                                          borderRadius:
                                              BorderRadius.circular(8),
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

                                    // Module list (only for active stages)
                                    if (isActive) const SizedBox(height: 16),
                                    if (isActive)
                                      ...List.generate(
                                        (stage['modules'] as List).length,
                                        (moduleIndex) {
                                          final module =
                                              stage['modules'][moduleIndex];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12.0),
                                            child: InkWell(
                                              onTap: () {
                                                if (module['isCompleted'] ==
                                                    false) {
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                    AppRoutes.exerciseDetail,
                                                  );
                                                }
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color:
                                                      module['isCompleted'] ==
                                                              true
                                                          ? Colors.grey[100]
                                                          : AppTheme.accentColor
                                                              .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color:
                                                        module['isCompleted'] ==
                                                                true
                                                            ? Colors.grey[300]!
                                                            : AppTheme
                                                                .accentColor,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 32,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        color: module[
                                                                    'isCompleted'] ==
                                                                true
                                                            ? Colors.grey[300]
                                                            : AppTheme
                                                                .secondaryColor,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child:
                                                            module['isCompleted'] ==
                                                                    true
                                                                ? const Icon(
                                                                    Icons.check,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 16,
                                                                  )
                                                                : const Icon(
                                                                    Icons
                                                                        .play_arrow,
                                                                    color: Colors
                                                                        .white,
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
                                                            module['title'],
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: module[
                                                                          'isCompleted'] ==
                                                                      true
                                                                  ? Colors
                                                                      .grey[600]
                                                                  : AppTheme
                                                                      .textPrimaryColor,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 2),
                                                          Text(
                                                            module[
                                                                'description'],
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: module[
                                                                          'isCompleted'] ==
                                                                      true
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
      ),
    );
  }
}
