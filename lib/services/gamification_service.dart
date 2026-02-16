import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

class GamificationService {
  static const int xpPerActivity = 10;

  // Level thresholds
  static const Map<int, String> levels = {
    1: 'Muslim Pemula',
    2: 'Pejuang Subuh',
    3: 'Pencari Ilmu',
    4: 'Ahli Sedekah',
    5: 'Ahli Ibadah',
    6: 'Generasi Rabbani',
    7: 'Penduduk Surga (Insya Allah)',
  };

  static const List<int> levelXp = [
    0, // Level 1
    500, // Level 2
    1500, // Level 3
    3000, // Level 4
    5000, // Level 5
    8000, // Level 6
    12000, // Level 7
  ];

  static int calculateTotalXp(Map<int, dynamic> dailyRecords) {
    int totalActivities = 0;
    dailyRecords.forEach((key, value) {
      totalActivities += (value.completedActivityIds as List).length;
    });
    return totalActivities * xpPerActivity;
  }

  static Map<String, dynamic> getLevelData(int currentXp) {
    int currentLevel = 1;
    for (int i = 0; i < levelXp.length; i++) {
      if (currentXp >= levelXp[i]) {
        currentLevel = i + 1;
      } else {
        break;
      }
    }

    // Cap at max level
    if (currentLevel > levels.length) currentLevel = levels.length;

    final title = levels[currentLevel] ?? 'Hamba Allah';

    // Next level progress
    int nextLevelXp = 0;
    if (currentLevel < levelXp.length) {
      nextLevelXp =
          levelXp[currentLevel]; // This is index for NEXT level start (currentLevel is 1-based)
      // Oops, levelXp 0 is L1 start. levelXp 1 is L2 start.
      // If I am L1, next is levelXp[1].
      // So nextLevelXp = levelXp[currentLevel]. Correct.
    } else {
      nextLevelXp = currentXp; // Max level
    }

    int currentLevelStartXp = levelXp[currentLevel - 1];

    double progress = 0.0;
    if (nextLevelXp > currentLevelStartXp) {
      progress =
          (currentXp - currentLevelStartXp) /
          (nextLevelXp - currentLevelStartXp);
    }
    if (progress > 1.0) progress = 1.0;

    return {
      'level': currentLevel,
      'title': title,
      'currentXp': currentXp,
      'nextLevelXp': nextLevelXp,
      'progress': progress,
    };
  }
}

final gamificationProvider = Provider<Map<String, dynamic>>((ref) {
  final records = ref.watch(dailyRecordsProvider);
  final xp = GamificationService.calculateTotalXp(records);
  return GamificationService.getLevelData(xp);
});
