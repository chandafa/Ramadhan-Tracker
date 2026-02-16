import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../models/achievement.dart';
import '../providers/app_providers.dart';
import '../services/gamification_service.dart'; // Added import

import 'package:confetti/confetti.dart';
import '../utils/app_strings.dart';

// Provider to calculate achievements
final achievementsProvider = Provider<List<Achievement>>((ref) {
  final records = ref.watch(dailyRecordsProvider);
  final locale = ref.watch(localeProvider);

  // Logic calculations
  int totalSedekah = 0;
  int totalQuran = 0;
  int totalTahajjud = 0;
  int totalTarawih = 0;
  int currentStreak = ref.watch(streakProvider);

  for (var record in records.values) {
    if (record.completedActivityIds.contains('15')) totalSedekah++;
    if (record.completedActivityIds.contains('14')) totalQuran++;
    if (record.completedActivityIds.contains('3')) totalTahajjud++;
    if (record.completedActivityIds.contains('41')) totalTarawih++;
  }

  return [
    Achievement(
      id: 'streak_7',
      title: AppStrings.get('streak_7_title', locale),
      description: AppStrings.get('streak_7_desc', locale),
      icon: HugeIcons.strokeRoundedFire,
      isUnlocked: currentStreak >= 7,
    ),
    Achievement(
      id: 'sedekah_10',
      title: AppStrings.get('sedekah_10_title', locale),
      description: AppStrings.get('sedekah_10_desc', locale),
      icon: HugeIcons.strokeRoundedGift,
      isUnlocked: totalSedekah >= 10,
    ),
    Achievement(
      id: 'quran_30',
      title: AppStrings.get('quran_30_title', locale),
      description: AppStrings.get('quran_30_desc', locale),
      icon: HugeIcons.strokeRoundedBookOpen01,
      isUnlocked: totalQuran >= 30,
    ),
    Achievement(
      id: 'tahajjud_7',
      title: AppStrings.get('tahajjud_7_title', locale),
      description: AppStrings.get('tahajjud_7_desc', locale),
      icon: HugeIcons.strokeRoundedMoon02,
      isUnlocked: totalTahajjud >= 7,
    ),
    Achievement(
      id: 'tarawih_20',
      title: AppStrings.get('tarawih_20_title', locale),
      description: AppStrings.get('tarawih_20_desc', locale),
      icon: HugeIcons.strokeRoundedMosque02,
      isUnlocked: totalTarawih >= 20,
    ),
  ];
});

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    // Check if we should play confetti (e.g., if there are unlocked achievements)
    // For now, just play on enter if any are unlocked to celebrate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final achievements = ref.read(achievementsProvider);
      if (achievements.any((a) => a.isUnlocked)) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievements = ref.watch(achievementsProvider);
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final levelData = ref.watch(gamificationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements & Level')),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _confettiController.play(),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedChampion,
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Level ${levelData['level']}: ${levelData['title']}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${levelData['currentXp']} XP',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$unlockedCount / ${achievements.length} Achievements',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    return _buildAchievementCard(context, achievement);
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(BuildContext context, Achievement achievement) {
    return Card(
      elevation: achievement.isUnlocked ? 4 : 0,
      color: achievement.isUnlocked
          ? Theme.of(context).cardColor
          : Theme.of(context).cardColor.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: achievement.isUnlocked
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
              ),
              child: HugeIcon(
                icon: achievement.icon,
                size: 32,
                color: achievement.isUnlocked
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: achievement.isUnlocked
                    ? null // Default text color
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: achievement.isUnlocked
                    ? Colors.grey[600]
                    : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
