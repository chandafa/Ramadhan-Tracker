import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'widget_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Navigator key for deep-linking from notifications
  static GlobalKey<NavigatorState>? navigatorKey;

  Future<void> init() async {
    tz.initializeTimeZones();
    final dynamic timeZoneResult = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timeZoneResult.toString();

    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  void _onNotificationResponse(NotificationResponse response) {
    // If sahur notification tapped, navigate to checklist
    if (response.payload == 'sahur_checklist') {
      navigatorKey?.currentState?.pushNamed('/sahur-checklist');
    }
  }

  Future<bool> requestPermissions() async {
    bool granted = false;
    try {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        final bool? result = await androidImplementation
            .requestNotificationsPermission();
        granted = result ?? false;
      }

      // Also request notification permission from permission_handler for consistency across Android versions
      if (!granted) {
        final status = await Permission.notification.request();
        granted = status.isGranted;
      }

      // Location permission for prayer times
      // Location permission for prayer times
      await Permission.location.request();
      // We consider 'granted' if notification is granted, as location is secondary for just notifications (but needed for prayer times)
      // However, for the app to fully work, we need both.
      // Let's return true if Notification is granted, as that's the primary "Notification Permission"
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      granted = false; // Assume failed
    }
    return granted;
  }

  Future<void> scheduleDailyReminder() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 0,
      title: 'Ramadhan Tracker',
      body: 'Don\'t forget to track your worship today!',
      scheduledDate: _nextInstanceOfTime(21, 0), // 9 PM
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          channelDescription: 'Reminder to track daily activities',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> schedulePrayerTimes() async {
    // 1. Get Location
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    );

    final myCoordinates = Coordinates(position.latitude, position.longitude);

    // 2. Calculation Parameters
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;

    // 3. Calculate for today and tomorrow
    final now = DateTime.now();
    PrayerTimes prayerTimesToday = PrayerTimes(
      myCoordinates,
      DateComponents(now.year, now.month, now.day),
      params,
    );

    for (int i = 0; i < 3; i++) {
      // Schedule for next 3 days
      final date = now.add(Duration(days: i));
      final dateComponents = DateComponents(date.year, date.month, date.day);
      final prayerTimes = PrayerTimes(myCoordinates, dateComponents, params);

      // Schedule Sahur Interactive (30 mins before Fajr / Imsak)
      final sahurTime = prayerTimes.fajr.subtract(const Duration(minutes: 30));
      await _scheduleSahurInteractive(id: 100 + i, scheduledDate: sahurTime);

      // Schedule Iftar (Maghrib)
      await _scheduleOneOff(
        id: 200 + i,
        title: 'Iftar Time 🌙',
        body: 'Waktunya berbuka puasa. Selamat berbuka!',
        scheduledDate: prayerTimes.maghrib,
      );

      // Schedule Prayers
      await _scheduleOneOff(
        id: 300 + i,
        title: 'Adzan Subuh',
        body: 'Waktunya Sholat Subuh.',
        scheduledDate: prayerTimes.fajr,
      );

      await _scheduleOneOff(
        id: 400 + i,
        title: 'Adzan Dzuhur',
        body: 'Waktunya Sholat Dzuhur.',
        scheduledDate: prayerTimes.dhuhr,
      );

      await _scheduleOneOff(
        id: 500 + i,
        title: 'Adzan Ashar',
        body: 'Waktunya Sholat Ashar.',
        scheduledDate: prayerTimes.asr,
      );

      await _scheduleOneOff(
        id: 600 + i,
        title: 'Adzan Isya',
        body: 'Waktunya Sholat Isya.',
        scheduledDate: prayerTimes.isha,
      );
    }

    // Update Widget with Next Prayer
    await _updateWidgetNextPrayer(prayerTimesToday);
  }

  Future<void> _updateWidgetNextPrayer(PrayerTimes prayerTimes) async {
    final now = DateTime.now();
    String nextPrayerName = 'Fajr';
    DateTime nextPrayerTime = prayerTimes.fajr;

    if (now.isBefore(prayerTimes.fajr)) {
      nextPrayerName = 'Subuh';
      nextPrayerTime = prayerTimes.fajr;
    } else if (now.isBefore(prayerTimes.dhuhr)) {
      nextPrayerName = 'Dzuhur';
      nextPrayerTime = prayerTimes.dhuhr;
    } else if (now.isBefore(prayerTimes.asr)) {
      nextPrayerName = 'Ashar';
      nextPrayerTime = prayerTimes.asr;
    } else if (now.isBefore(prayerTimes.maghrib)) {
      nextPrayerName = 'Maghrib';
      nextPrayerTime = prayerTimes.maghrib;
    } else if (now.isBefore(prayerTimes.isha)) {
      nextPrayerName = 'Isya';
      nextPrayerTime = prayerTimes.isha;
    } else {
      // Tomorrows Fajr (approx, just use today's for display or handle logic)
      nextPrayerName = 'Subuh';
      nextPrayerTime = prayerTimes.fajr.add(const Duration(days: 1));
    }

    // Format Time HH:mm
    final timeString =
        "${nextPrayerTime.hour.toString().padLeft(2, '0')}:${nextPrayerTime.minute.toString().padLeft(2, '0')}";

    await WidgetService.saveNextPrayer(nextPrayerName, timeString);
    await WidgetService.triggerUpdate();
  }

  Future<void> _scheduleOneOff({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_times',
          'Prayer Times',
          channelDescription: 'Notifications for Prayer Times',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Schedule interactive Sahur notification with checklist prompt
  Future<void> _scheduleSahurInteractive({
    required int id,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: '🌙 Sahur Time!',
      body: '30 menit sebelum Imsak — Sudah makan? Sudah minum? Niat puasa?',
      payload: 'sahur_checklist',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'sahur_interactive',
          'Sahur Reminder',
          channelDescription: 'Interactive Sahur checklist reminder',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            'Checklist Sahur:\n✅ Sudah Makan?\n💧 Sudah Minum?\n🤲 Niat Puasa?\n\nTap untuk membuka checklist!',
          ),
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'open_checklist',
              'Buka Checklist 📋',
              showsUserInterface: true,
            ),
          ],
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
