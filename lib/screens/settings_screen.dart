import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../providers/app_providers.dart';
import '../utils/app_strings.dart';
import 'background_picker_screen.dart';
import 'achievements_screen.dart';
import '../services/notification_service.dart';
import '../services/gamification_service.dart';
// import '../services/haptic_service.dart'; // Exposed via provider

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ramadanStart = ref.watch(ramadanStartDateProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final levelData = ref.watch(gamificationProvider); // Added

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get(AppStrings.settings, locale))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Level Card
          Card(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedChampion,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level ${levelData['level']}: ${levelData['title']}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: levelData['progress'],
                                backgroundColor: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                                valueColor: AlwaysStoppedAnimation(
                                  Theme.of(context).primaryColor,
                                ),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${levelData['currentXp']} / ${levelData['nextLevelXp']} XP',
                              style: Theme.of(context).textTheme.bodySmall,
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

          // Appearance Section
          Text(
            AppStrings.get(AppStrings.appearance, locale),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(AppStrings.get(AppStrings.darkMode, locale)),
                  secondary: HugeIcon(
                    icon: HugeIcons.strokeRoundedMoon02,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  value: themeMode == ThemeMode.dark,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (val) {
                    ref.read(themeModeProvider.notifier).state = val
                        ? ThemeMode.dark
                        : ThemeMode.light;
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedGlobal,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: Text(AppStrings.get(AppStrings.language, locale)),
                  trailing: DropdownButton<String>(
                    value: locale.languageCode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(
                        value: 'id',
                        child: Text('Bahasa Indonesia'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(localeProvider.notifier).state = Locale(val);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedTextFont,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: const Text('Font Size'),
                  subtitle: Slider(
                    value: ref.watch(fontScaleProvider),
                    min: 0.8,
                    max: 1.2,
                    divisions: 4,
                    label: ref.watch(fontScaleProvider).toString(),
                    onChanged: (val) {
                      ref.read(fontScaleProvider.notifier).state = val;
                      Hive.box('app_settings').put('font_scale', val);
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedPaintBoard,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: const Text('Background'),
                  subtitle: const Text('Customize app background'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BackgroundPickerScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Configuration Section
          Text(
            AppStrings.get(AppStrings.configuration, locale),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedCalendar03,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: Text(
                    AppStrings.get(AppStrings.ramadanStartDate, locale),
                  ),
                  subtitle: Text(
                    ramadanStart != null
                        ? DateFormat('dd MMMM yyyy').format(ramadanStart)
                        : 'Not Set',
                  ),
                  trailing: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: ramadanStart ?? DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      final hiveService = ref.read(hiveServiceProvider);
                      await hiveService.setRamadanStartDate(picked);
                      ref.invalidate(ramadanStartDateProvider);
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedCalendar01,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: const Text('Year'),
                  trailing: DropdownButton<int>(
                    value: ref.watch(hijriYearProvider),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 1445,
                        child: Text('1445H (2024)'),
                      ),
                      DropdownMenuItem(
                        value: 1446,
                        child: Text('1446H (2025)'),
                      ),
                      DropdownMenuItem(
                        value: 1447,
                        child: Text('1447H (2026)'),
                      ),
                    ],
                    onChanged: (val) async {
                      if (val != null) {
                        final hiveService = ref.read(hiveServiceProvider);
                        await hiveService.setHijriYear(val);
                        ref.invalidate(hijriYearProvider);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(
                    AppStrings.get(AppStrings.enableNotifications, locale),
                  ),
                  secondary: HugeIcon(
                    icon: HugeIcons.strokeRoundedNotification01,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  value: ref.watch(notificationsEnabledProvider),
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (val) async {
                    await ref
                        .read(hiveServiceProvider)
                        .setNotificationsEnabled(val);
                    ref.invalidate(notificationsEnabledProvider);

                    if (val) {
                      final service = NotificationService();
                      final granted = await service.requestPermissions();
                      if (granted) {
                        await service.schedulePrayerTimes();
                      } else {
                        // Revert switch if permission denied and user cancelled
                        ref.read(notificationsEnabledProvider.notifier).state =
                            false;
                        await ref
                            .read(hiveServiceProvider)
                            .setNotificationsEnabled(false);

                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Permission Required'),
                              content: const Text(
                                'Notifications are needed for prayer times and reminders. Please enable them in settings.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    openAppSettings();
                                  },
                                  child: const Text('Open Settings'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    } else {
                      await NotificationService().cancelAllNotifications();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Feedback Section
          Text(
            'Feedback',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Haptic Vibration'),
                  secondary: HugeIcon(
                    icon: HugeIcons.strokeRoundedSmartPhone01,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  value: ref.watch(hapticServiceProvider).hapticEnabled,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (val) async {
                    // Request permission logic if needed, but standard haptic doesn't need it.
                    // However, user requested permission prompt. We'll simulate or ask notification.
                    if (val) {
                      // Ensure we have notification permissions as proxy for "System interaction"
                      final notificationService = NotificationService();
                      await notificationService.requestPermissions();
                    }
                    await ref.read(hapticServiceProvider).setHaptic(val);
                    (context as Element).markNeedsBuild();
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Sound Effects'),
                  subtitle: const Text('Requires Notification Permission'),
                  secondary: HugeIcon(
                    icon: HugeIcons.strokeRoundedMusicNote01,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  value: ref.watch(hapticServiceProvider).soundEnabled,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (val) async {
                    if (val) {
                      final notificationService = NotificationService();
                      await notificationService.requestPermissions();
                    }
                    await ref.read(hapticServiceProvider).setSound(val);
                    (context as Element).markNeedsBuild();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data & Account Section
          Text(
            'Data & Account',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedUserGroup,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: const Text('Profiles'),
                  subtitle: const Text('Default User'),
                  trailing: const Chip(
                    label: Text('Coming Soon', style: TextStyle(fontSize: 10)),
                    visualDensity: VisualDensity.compact,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Multi-profile support coming soon!'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedChampion,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: const Text('Achievements'),
                  trailing: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AchievementsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedDatabase02,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: const Text('Backup & Restore'),
                  subtitle: const Text('Export/Import data'),
                  onTap: () => _showBackupDialog(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildUsageInfo(context, locale),
        ],
      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _buildUsageInfo(BuildContext context, Locale locale) {
    return Column(
      children: [
        HugeIcon(
          icon: HugeIcons.strokeRoundedInformationCircle,
          color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          locale.languageCode == 'id'
              ? 'Aplikasi ini membantu memantau ibadah harianmu selama Ramadan.'
              : 'This app helps track your daily worship during Ramadan.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        ListTile(
          title: Center(
            child: Text(
              'Made with 💚 by Candra Kirana',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          subtitle: const Text(
            'Ramadhan Tracker v1.0.0',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  void _showBackupDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup & Restore'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text('Export Data'),
              subtitle: const Text('Save your progress to a file'),
              onTap: () async {
                Navigator.pop(context); // Close dialog
                try {
                  final hiveService = ref.read(hiveServiceProvider);
                  final jsonString = hiveService.exportData();

                  final directory = await getApplicationDocumentsDirectory();
                  final path = '${directory.path}/ramadhan_backup.json';
                  final file = File(path);
                  await file.writeAsString(jsonString);

                  await Share.shareXFiles([
                    XFile(path),
                  ], text: 'My Ramadhan Checklists Backup');
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export Failed: $e')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Import Data'),
              subtitle: const Text('Restore from backup string'),
              onTap: () {
                Navigator.pop(context); // Close main dialog
                _showImportDialog(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Paste your backup JSON string here:'),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final hiveService = ref.read(hiveServiceProvider);
                await hiveService.importData(controller.text);
                ref.invalidate(dailyRecordsProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data Restored Successfully!'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid JSON Data')),
                  );
                }
              }
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }
}
