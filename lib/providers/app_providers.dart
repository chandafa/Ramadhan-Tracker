import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/daily_record.dart';
import '../models/activity_model.dart';

import '../services/hive_service.dart';
import '../services/haptic_service.dart';
import '../services/audio_service.dart'; // Added
import '../utils/app_data.dart';
import '../services/widget_service.dart';

// Service Provider
// Service Provider
final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());
final audioServiceProvider = Provider<AudioService>(
  (ref) => AudioService(),
); // Added

// Selected Day State
final selectedDayProvider = StateProvider<int>((ref) => 1);

// Navigation State
final navIndexProvider = StateProvider<int>((ref) => 0);

// Locale State
final localeProvider = StateProvider<Locale>((ref) => const Locale('id'));

// Haptic Service
final hapticServiceProvider = Provider<HapticService>((ref) => HapticService());

// Theme Mode State
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// Font Scale State
final fontScaleProvider = StateProvider<double>((ref) {
  final box = Hive.box('app_settings');
  return box.get('font_scale', defaultValue: 1.0) as double;
});

// Daily Records Management
class DailyRecordsNotifier extends StateNotifier<Map<int, DailyRecord>> {
  final HiveService _hiveService;
  final HapticService _hapticService;
  final AudioService _audioService; // Added

  DailyRecordsNotifier(
    this._hiveService,
    this._hapticService,
    this._audioService,
  ) // Modified
  : super({}) {
    _load();
  }

  void _load() {
    final records = _hiveService.getAllRecords();
    state = {for (var r in records) r.day: r};
  }

  Future<void> toggleActivity(
    int day,
    String activityId,
    bool isCompleted,
  ) async {
    final currentRecord =
        state[day] ?? DailyRecord(day: day, completedActivityIds: []);
    final currentIds = List<String>.from(currentRecord.completedActivityIds);

    if (isCompleted) {
      if (!currentIds.contains(activityId)) {
        currentIds.add(activityId);
        _hapticService.feedbackSuccess(); // Trigger feedback
        _audioService.playCompletionSound(); // Play sound
      }
    } else {
      currentIds.remove(activityId);
    }

    final newRecord = DailyRecord(day: day, completedActivityIds: currentIds);

    // Optimistic Update
    state = {...state, day: newRecord};

    // Persist
    // Persist
    await _hiveService.saveDailyRecord(newRecord);

    // Update Widget
    _updateWidgetProgress(day);
  }

  Future<void> _updateWidgetProgress(int day) async {
    // Only update if it's today (assuming generic tracker, or handle date logic)
    // For now, let's just update based on the modified day
    final record = state[day];
    if (record == null) return;

    final customActivities = _hiveService.getCustomActivities();
    final total = AppData.activities.length + customActivities.length;
    if (total == 0) return;

    final completed = record.completedActivityIds.length;
    final percent = ((completed / total) * 100).toInt();

    await WidgetService.saveProgress(percent);

    // Calculate Streak for Widget
    int streak = 0;
    final activeDays =
        state.values
            .where((r) => r.completedActivityIds.isNotEmpty)
            .map((r) => r.day)
            .toList()
          ..sort();

    if (activeDays.isNotEmpty) {
      int current = activeDays.last;
      streak = 1;
      for (int i = activeDays.length - 2; i >= 0; i--) {
        if (activeDays[i] == current - 1) {
          streak++;
          current = activeDays[i];
        } else {
          break;
        }
      }
    }

    await WidgetService.saveStreakAndDay(streak, day);
    await WidgetService.triggerUpdate();
  }

  void saveMood(int day, String mood) {
    final currentRecord =
        state[day] ?? DailyRecord(day: day, completedActivityIds: []);

    final newRecord = currentRecord.copyWith(mood: mood);
    state = {...state, day: newRecord};
    _hiveService.saveDailyRecord(newRecord);
  }

  void saveNote(int day, String note) {
    final currentRecord =
        state[day] ?? DailyRecord(day: day, completedActivityIds: [], note: '');

    final newRecord = currentRecord.copyWith(note: note);
    state = {...state, day: newRecord};
    _hiveService.saveDailyRecord(newRecord);
  }

  void saveQuranData(int day, Map<String, dynamic> data) {
    final currentRecord =
        state[day] ?? DailyRecord(day: day, completedActivityIds: []);

    // Ensure Quran is marked as completed if saving data
    final currentIds = List<String>.from(currentRecord.completedActivityIds);
    if (!currentIds.contains('14')) {
      currentIds.add('14'); // ID 14 is Read Quran
    }

    final newRecord = currentRecord.copyWith(
      quranData: data,
      completedActivityIds: currentIds,
    );
    state = {...state, day: newRecord};
    _hiveService.saveDailyRecord(newRecord);
  }
}

// Providers
final dailyRecordsProvider =
    StateNotifierProvider<DailyRecordsNotifier, Map<int, DailyRecord>>((ref) {
      final hiveService = ref.watch(hiveServiceProvider);
      final hapticService = ref.watch(hapticServiceProvider);
      final audioService = ref.watch(audioServiceProvider); // Added
      return DailyRecordsNotifier(
        hiveService,
        hapticService,
        audioService,
      ); // Modified
    });

final customActivitiesProvider = StateProvider<List<Activity>>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final customs = hiveService.getCustomActivities();

  return customs
      .map(
        (c) => Activity(
          id: c.id,
          title: c.title,
          category: c.category,
          order: 999, // Custom activities go last or sort manually
        ),
      )
      .toList();
});

final activitiesProvider = Provider<List<Activity>>((ref) {
  final custom = ref.watch(customActivitiesProvider);
  return [...AppData.activities, ...custom];
});

// Helper: Get record for a specific day
final dailyRecordProvider = Provider.family<DailyRecord?, int>((ref, day) {
  final records = ref.watch(dailyRecordsProvider);
  return records[day];
});

// Helper: Check if specific activity is completed
final isActivityCompletedProvider =
    Provider.family<bool, ({int day, String activityId})>((ref, params) {
      final record = ref.watch(dailyRecordProvider(params.day));
      if (record == null) return false;
      return record.completedActivityIds.contains(params.activityId);
    });

// Progress Calculation
final dailyProgressProvider = Provider.family<double, int>((ref, day) {
  final record = ref.watch(dailyRecordProvider(day));
  final total = AppData.activities.length;
  if (total == 0) return 0.0;

  final completed = record?.completedActivityIds.length ?? 0;
  return completed / total;
});

final overallProgressProvider = Provider<double>((ref) {
  final records = ref.watch(dailyRecordsProvider);
  final totalPossible = AppData.activities.length * 30;
  if (totalPossible == 0) return 0.0;

  int totalCompleted = 0;
  for (var record in records.values) {
    totalCompleted += record.completedActivityIds.length;
  }

  return totalCompleted / totalPossible;
});

// Settings Providers
final ramadanStartDateProvider = StateProvider<DateTime?>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return hiveService.ramadanStartDate;
});

final hijriYearProvider = StateProvider<int>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return hiveService.hijriYear;
});

final notificationsEnabledProvider = StateProvider<bool>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return hiveService.notificationsEnabled;
});

// Streak Logic
final streakProvider = Provider<int>((ref) {
  final records = ref.watch(dailyRecordsProvider);
  // final startDate = ref.watch(ramadanStartDateProvider); // Not used in simple logic yet

  // If no start date, we can't accurately calculate "current" streak relative to real time,
  // but we can calculate "longest consecutive streak" or just "current streak based on last active day".
  // Let's assume standard streak: consecutive days with at least 1 activity.

  if (records.isEmpty) return 0;

  // Get list of days with activity
  final activeDays =
      records.values
          .where((r) => r.completedActivityIds.isNotEmpty)
          .map((r) => r.day)
          .toList()
        ..sort(); // 1, 2, 4, 5...

  if (activeDays.isEmpty) return 0;

  int streak = 0;
  // Calculate backwards from the last active day
  // If we want "Current Streak", we usually check from Today backwards.
  // But since days are generic 1-30, let's just count the latest consecutive block.

  int current = activeDays.last;
  streak = 1;

  for (int i = activeDays.length - 2; i >= 0; i--) {
    if (activeDays[i] == current - 1) {
      streak++;
      current = activeDays[i];
    } else {
      break;
    }
  }

  // Optional: If the last active day is NOT today or yesterday, is the streak broken?
  // Since this is a 30-day generic tracker, maybe we just show the "latest run".
  // Let's Stick to that for simplicity unless we bind to real dates.

  return streak;
});
