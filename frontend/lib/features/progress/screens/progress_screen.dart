import 'package:flutter/material.dart';

import '../../../config/theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for user progress
    final Map<String, dynamic> userStats = {
      'totalExercises': 84,
      'exercisesThisWeek': 12,
      'averageScore': 72,
      'totalXp': 720,
      'currentStreak': 5,
      'bestStreak': 14,
      'weeklyProgress': [
        {'day': 'Mon', 'exercises': 3},
        {'day': 'Tue', 'exercises': 5},
        {'day': 'Wed', 'exercises': 0},
        {'day': 'Thu', 'exercises': 2},
        {'day': 'Fri', 'exercises': 2},
        {'day': 'Sat', 'exercises': 0},
        {'day': 'Sun', 'exercises': 0},
      ],
      'categoryProgress': [
        {'category': 'Addition', 'progress': 0.85},
        {'category': 'Subtraction', 'progress': 0.70},
        {'category': 'Multiplication', 'progress': 0.40},
        {'category': 'Division', 'progress': 0.25},
        {'category': 'Mixed', 'progress': 0.15},
      ],
      'achievements': [
        {
          'title': 'First Steps',
          'description': 'Complete your first exercise',
          'isUnlocked': true,
          'progress': 1.0,
          'icon': Icons.emoji_events,
        },
        {
          'title': 'Quick Thinker',
          'description': 'Complete 5 exercises in under 2 minutes each',
          'isUnlocked': true,
          'progress': 1.0,
          'icon': Icons.bolt,
        },
        {
          'title': 'Math Wizard',
          'description': 'Get a perfect score on 3 exercises',
          'isUnlocked': false,
          'progress': 0.67,
          'icon': Icons.auto_awesome,
        },
        {
          'title': 'Consistency Master',
          'description': 'Practice for 7 days in a row',
          'isUnlocked': false,
          'progress': 0.71,
          'icon': Icons.calendar_today,
        },
        {
          'title': 'Mental Math Expert',
          'description': 'Complete all learning paths',
          'isUnlocked': false,
          'progress': 0.33,
          'icon': Icons.psychology,
        },
      ]
    };

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User stats summary
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.secondaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Progress',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Keep up the good work!',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                color: Colors.amber,
                                size: 24,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${userStats['currentStreak']} day streak',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.calculate_outlined,
                          '${userStats['totalExercises']}',
                          'Total Exercises',
                        ),
                        _buildStatItem(
                          Icons.trending_up,
                          '${userStats['averageScore']}%',
                          'Avg. Score',
                        ),
                        _buildStatItem(
                          Icons.diamond_outlined,
                          '${userStats['totalXp']} XP',
                          'Total XP',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Weekly activity
            Text(
              'Weekly Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${userStats['exercisesThisWeek']} exercises this week',
                          style: const TextStyle(
                            color: AppTheme.textPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'This Week',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(7, (index) {
                          final dayData = userStats['weeklyProgress'][index];
                          final double barHeight = dayData['exercises'] > 0
                              ? 60 + ((dayData['exercises'] as num) * 15)
                              : 20;
                          final bool isToday =
                              index == 3; // Thursday in our mock data

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${dayData['exercises']}',
                                style: TextStyle(
                                  color: dayData['exercises'] > 0
                                      ? AppTheme.textPrimaryColor
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                width: 30,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: dayData['exercises'] > 0
                                      ? isToday
                                          ? AppTheme.primaryColor
                                          : AppTheme.secondaryColor
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dayData['day'],
                                style: TextStyle(
                                  color: isToday
                                      ? AppTheme.primaryColor
                                      : AppTheme.textSecondaryColor,
                                  fontWeight: isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category progress
            Text(
              'Category Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: List.generate(
                    userStats['categoryProgress'].length,
                    (index) {
                      final category = userStats['categoryProgress'][index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  category['category'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textPrimaryColor,
                                  ),
                                ),
                                Text(
                                  '${(category['progress'] * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: category['progress'],
                                backgroundColor: Colors.grey[300],
                                color: _getCategoryColor(index),
                                minHeight: 10,
                              ),
                            ),
                            if (index <
                                userStats['categoryProgress'].length - 1)
                              const SizedBox(height: 12),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Achievements
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: userStats['achievements'].length,
              itemBuilder: (context, index) {
                final achievement = userStats['achievements'][index];
                final bool isUnlocked = achievement['isUnlocked'];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: isUnlocked ? 4 : 1,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isUnlocked ? null : Colors.grey[100],
                      gradient: isUnlocked
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.amber.shade300,
                                Colors.amber.shade700,
                              ],
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isUnlocked ? Colors.white : Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            achievement['icon'],
                            color: isUnlocked ? Colors.amber : Colors.grey[600],
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          achievement['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isUnlocked ? Colors.white : Colors.grey[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          achievement['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isUnlocked ? Colors.white70 : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        if (!isUnlocked)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: achievement['progress'],
                              backgroundColor: Colors.grey[300],
                              color: AppTheme.secondaryColor,
                              minHeight: 6,
                            ),
                          ),
                        if (!isUnlocked)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${(achievement['progress'] * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white30,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(int index) {
    final List<Color> colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
    ];
    return colors[index % colors.length];
  }
}
