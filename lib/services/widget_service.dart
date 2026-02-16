import 'package:home_widget/home_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class WidgetService {
  static const String androidWidgetName = 'ProgressWidgetProvider';

  static Future<void> saveProgress(int progressPercent) async {
    if (kIsWeb) return; // HomeWidget not supported on Web
    try {
      await HomeWidget.saveWidgetData<int>('progress', progressPercent);
    } catch (e) {
      debugPrint('Error saving widget progress: $e');
    }
  }

  static Future<void> saveNextPrayer(String name, String time) async {
    if (kIsWeb) return;
    try {
      await HomeWidget.saveWidgetData<String>('next_prayer', name);
      await HomeWidget.saveWidgetData<String>('next_prayer_time', time);
    } catch (e) {
      debugPrint('Error saving widget prayer: $e');
    }
  }

  static Future<void> saveStreakAndDay(int streak, int day) async {
    if (kIsWeb) return;
    try {
      await HomeWidget.saveWidgetData<int>('streak', streak);
      await HomeWidget.saveWidgetData<int>('ramadhan_day', day);
    } catch (e) {
      debugPrint('Error saving widget streak/day: $e');
    }
  }

  static Future<void> triggerUpdate() async {
    if (kIsWeb) return;
    try {
      await HomeWidget.updateWidget(androidName: androidWidgetName);
    } catch (e) {
      debugPrint('Error triggering widget update: $e');
    }
  }
}
