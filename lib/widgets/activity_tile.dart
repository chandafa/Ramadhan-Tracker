import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_model.dart';
import '../providers/app_providers.dart';

import '../utils/app_strings.dart';

class ActivityTile extends ConsumerWidget {
  final Activity activity;
  final int day;

  const ActivityTile({super.key, required this.activity, required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = ref.watch(
      isActivityCompletedProvider((day: day, activityId: activity.id)),
    );
    final locale = ref.watch(localeProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCompleted
            ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
      ),
      child: CheckboxListTile(
        key: ValueKey('${activity.id}-$day'),
        value: isCompleted,
        onChanged: (value) {
          if (value == null) return;

          if (activity.id == '14' && value) {
            // "Read Quran" checked -> Show Dialog
            _showQuranDialog(context, ref, day);
          } else {
            ref
                .read(dailyRecordsProvider.notifier)
                .toggleActivity(day, activity.id, value);
          }
        },
        subtitle: (activity.id == '14' && isCompleted)
            ? _buildQuranSubtitle(ref, day)
            : null,
        title: Text(
          AppStrings.getActivityTitle(activity.id, activity.title, locale),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted
                ? Theme.of(context).textTheme.bodyMedium?.color
                : Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: isCompleted ? FontWeight.normal : FontWeight.w500,
          ),
        ),
        activeColor: Theme.of(context).primaryColor,
        checkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  Widget? _buildQuranSubtitle(WidgetRef ref, int day) {
    final record = ref.watch(dailyRecordProvider(day));
    if (record?.quranData == null) return null;

    final surah = record!.quranData!['surah'] ?? '-';
    final ayat = record.quranData!['ayat'] ?? '-';

    return Text(
      'Surah $surah : Ayat $ayat',
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    );
  }

  void _showQuranDialog(BuildContext context, WidgetRef ref, int day) {
    final surahController = TextEditingController();
    final ayatController = TextEditingController();

    // Pre-fill if exists
    final record = ref.read(dailyRecordProvider(day));
    if (record?.quranData != null) {
      surahController.text = record!.quranData!['surah'] ?? '';
      ayatController.text = record.quranData!['ayat'] ?? '';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quran Bookmark'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: surahController,
              decoration: const InputDecoration(
                labelText: 'Surah Name',
                hintText: 'e.g. Al-Baqarah',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ayatController,
              decoration: const InputDecoration(
                labelText: 'Ayat Number',
                hintText: 'e.g. 255',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(dailyRecordsProvider.notifier).saveQuranData(day, {
                'surah': surahController.text,
                'ayat': ayatController.text,
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
