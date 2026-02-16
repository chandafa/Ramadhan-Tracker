import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'add_activity_screen.dart';
import '../providers/app_providers.dart';
import '../services/gamification_service.dart'; // Added import
import '../utils/app_data.dart';
import '../utils/app_strings.dart';
import '../widgets/activity_tile.dart';
import '../widgets/day_selector.dart';
import '../widgets/quote_widget.dart';
import '../widgets/celebration_overlay.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _handleToday(BuildContext context, WidgetRef ref) {
    final locale = ref.read(localeProvider);
    final startDate = ref.read(ramadanStartDateProvider);
    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get(AppStrings.pleaseSetDate, locale)),
        ),
      );
      return;
    }

    final now = DateTime.now();
    // Reset time part for accurate day calc
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final today = DateTime(now.year, now.month, now.day);

    final diff = today.difference(start).inDays + 1;

    if (diff < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get(AppStrings.notStarted, locale))),
      );
    } else if (diff > 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get(AppStrings.ended, locale))),
      );
    } else {
      ref.read(selectedDayProvider.notifier).state = diff;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.get(AppStrings.jumpedTo, locale)} $diff'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    final progress = ref.watch(dailyProgressProvider(selectedDay));
    final overallProgress = ref.watch(overallProgressProvider);
    final streak = ref.watch(streakProvider);
    final locale = ref.watch(localeProvider);
    final levelData = ref.watch(gamificationProvider); // Added

    // Check if confetti should play
    WidgetsBinding.instance.addPostFrameCallback((_) {
      celebrationOverlayKey.currentState?.checkProgress(progress, selectedDay);
    });

    return CelebrationOverlay(
      key: celebrationOverlayKey,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _HeaderSection(
                  selectedDay: selectedDay,
                  overallProgress: overallProgress,
                  streak: streak,
                  dailyProgress: progress,
                  onJumpToToday: () => _handleToday(context, ref),
                  locale: locale,
                  levelData: levelData, // Added
                ).animate().slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
                const SizedBox(height: 10),

                // Day Selector
                const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: DaySelector(),
                    )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 600.ms)
                    .slideX(begin: 0.2, end: 0, curve: Curves.easeOut),

                const SizedBox(height: 10),

                // Daily Quote
                const QuoteWidget(),
                const SizedBox(height: 10),

                // Daily Activities Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.get(AppStrings.dailyActivities, locale),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddActivityScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        color: Theme.of(context).primaryColor,
                        tooltip: 'Add Activity',
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).moveY(begin: 10),
                const SizedBox(height: 10),

                // Activities List
                _ActivityList(day: selectedDay, locale: locale),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final int selectedDay;
  final double overallProgress;
  final int streak;
  final double dailyProgress;
  final VoidCallback onJumpToToday;
  final Locale locale;
  final Map<String, dynamic> levelData; // Added

  const _HeaderSection({
    required this.selectedDay,
    required this.overallProgress,
    required this.streak,
    required this.dailyProgress,
    required this.onJumpToToday,
    required this.locale,
    required this.levelData, // Added
  });

  @override
  Widget build(BuildContext context) {
    // levelData variables removed as they were moved to SettingsScreen
    // Logic for Streak is already independent

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Streak Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.yMMMMd().format(DateTime.now()),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Ramadhan Day $selectedDay',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedFire,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$streak Streak',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatWidget(
                label: AppStrings.get(AppStrings.completed, locale),
                value: '${(dailyProgress * 100).toStringAsFixed(0)}%',
                color: Colors.green,
                icon: HugeIcons.strokeRoundedTick02,
              ),
              const SizedBox(width: 10),
              _StatWidget(
                label: AppStrings.get(AppStrings.overall, locale),
                value: '${(overallProgress * 100).toStringAsFixed(0)}%',
                color: Colors.blue,
                icon: HugeIcons.strokeRoundedChartAverage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityList extends ConsumerWidget {
  final int day;
  final Locale locale;
  const _ActivityList({required this.day, required this.locale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyRecords = ref.watch(dailyRecordsProvider);
    final record = dailyRecords[day];
    final completedIds = record?.completedActivityIds.toSet() ?? <String>{};

    final allActivities = ref.watch(activitiesProvider);

    return Column(
      children: AppData.categories.asMap().entries.map((entry) {
        final catIndex = entry.key;
        final categoryKey = entry.value;
        final activities = allActivities
            .where((a) => a.category == categoryKey)
            .toList();

        if (activities.isEmpty) return const SizedBox.shrink();

        final totalCount = activities.length;
        final completedCount = activities
            .where((a) => completedIds.contains(a.id))
            .length;

        return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: catIndex < 2,
                  iconColor: Theme.of(context).primaryColor,
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  title: Row(
                    children: [
                      Text(
                        AppStrings.getCategory(categoryKey, locale),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$completedCount/$totalCount',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  children: activities.asMap().entries.map((actEntry) {
                    final index = actEntry.key;
                    final activity = actEntry.value;

                    return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ActivityTile(activity: activity, day: day),
                        )
                        .animate(delay: (50 * index).ms)
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: 0.05, end: 0);
                  }).toList(),
                ),
              ),
            )
            .animate(delay: (100 * catIndex).ms)
            .fadeIn()
            .slideY(begin: 0.1, end: 0);
      }).toList(),
    );
  }
}

class _StatWidget extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final dynamic icon; // Changed from IconData to dynamic to support HugeIcons

  const _StatWidget({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HugeIcon(
                  icon: icon,
                  size: 16,
                  color: color,
                ), // Changed to HugeIcon
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
