import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/hive_service.dart';
import 'services/haptic_service.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'screens/sahur_checklist_screen.dart';
import 'providers/app_providers.dart';
import 'utils/theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  final hapticService = HapticService();
  await hapticService.init();

  // Initialize notifications and set navigator key
  // Initialize notifications asynchronously to prevent blocking startup
  // We don't await this because notification permission/init failures should not crash the app
  final notificationService = NotificationService();
  NotificationService.navigatorKey = navigatorKey;

  // Fire and forget notification init, or await with timeout if critical
  notificationService.init().catchError((e) {
    debugPrint('Notification init failed: $e');
  });

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
        hapticServiceProvider.overrideWithValue(hapticService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Ramadhan Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
      routes: {'/sahur-checklist': (context) => const SahurChecklistScreen()},
      builder: (context, child) {
        final fontScale = ref.watch(fontScaleProvider);
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(fontScale)),
          child: child!,
        );
      },
    );
  }
}
