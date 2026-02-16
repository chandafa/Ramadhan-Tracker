import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../providers/app_providers.dart';
import '../providers/background_provider.dart';
import '../utils/app_strings.dart';
import '../utils/theme.dart';
import 'calendar_screen.dart';
import 'home_screen.dart';
import 'journal_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

import '../services/notification_service.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  @override
  void initState() {
    super.initState();
    // Schedule notifications in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleNotifications();
    });
  }

  Future<void> _scheduleNotifications() async {
    final notificationService = NotificationService();
    await notificationService.scheduleDailyReminder();
    await notificationService.schedulePrayerTimes();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navIndexProvider);
    final locale = ref.watch(localeProvider);

    // Background Logic
    final bgDecoration = getBackgroundDecoration(ref);
    final isCustomBg = bgDecoration != null;

    final screens = [
      const HomeScreen(),
      const CalendarScreen(),
      const JournalScreen(),
      const StatsScreen(),
      const SettingsScreen(),
    ];

    // Determine Theme to use for children
    final currentTheme = Theme.of(context);
    final bgBrightness = ref.watch(backgroundBrightnessProvider);

    final childTheme = isCustomBg
        ? (bgBrightness == 'light'
              ? AppTheme.lightTheme.copyWith(
                  scaffoldBackgroundColor: Colors.transparent,
                  cardTheme: AppTheme.lightTheme.cardTheme.copyWith(
                    color: AppColors.lightSurface.withValues(alpha: 0.8),
                  ),
                )
              : AppTheme.darkTheme.copyWith(
                  scaffoldBackgroundColor: Colors.transparent,
                  cardTheme: AppTheme.darkTheme.cardTheme.copyWith(
                    color: AppColors.darkSurface.withValues(alpha: 0.8),
                  ),
                ))
        : currentTheme;

    return Container(
      decoration:
          bgDecoration ??
          BoxDecoration(color: currentTheme.scaffoldBackgroundColor),
      child: Theme(
        data: childTheme,
        child: Scaffold(
          backgroundColor:
              Colors.transparent, // Transparent to show Container bg
          body: screens[selectedIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            backgroundColor: isCustomBg
                ? (bgBrightness == 'dark'
                      ? AppColors.darkSurface.withValues(alpha: 0.9)
                      : AppColors.lightSurface.withValues(alpha: 0.9))
                : null,
            onDestinationSelected: (index) {
              ref.read(navIndexProvider.notifier).state = index;
            },
            destinations: [
              NavigationDestination(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedHome01,
                  color: childTheme.iconTheme.color,
                ),
                selectedIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedHome01,
                  color: childTheme.primaryColor,
                ),
                label: AppStrings.get(AppStrings.home, locale),
              ),
              NavigationDestination(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedCalendar03,
                  color: childTheme.iconTheme.color,
                ),
                selectedIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedCalendar03,
                  color: childTheme.primaryColor,
                ),
                label: AppStrings.get(AppStrings.calendar, locale),
              ),
              NavigationDestination(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedBookOpen01,
                  color: childTheme.iconTheme.color,
                ),
                selectedIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedBookOpen01,
                  color: childTheme.primaryColor,
                ),
                label: AppStrings.get(AppStrings.journal, locale),
              ),
              NavigationDestination(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedChartHistogram,
                  color: childTheme.iconTheme.color,
                ),
                selectedIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedChartHistogram,
                  color: childTheme.primaryColor,
                ),
                label: locale.languageCode == 'id' ? 'Statistik' : 'Stats',
              ),
              NavigationDestination(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedSettings01,
                  color: childTheme.iconTheme.color,
                ),
                selectedIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedSettings01,
                  color: childTheme.primaryColor,
                ),
                label: AppStrings.get(AppStrings.settings, locale),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
