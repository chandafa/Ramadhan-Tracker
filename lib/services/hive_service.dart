import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/daily_record.dart';
import '../models/custom_activity.dart';

class HiveService {
  static const String _boxName = 'daily_records';

  late Box<DailyRecord> _box;
  late Box _settingsBox;
  late Box<CustomActivity> _customActivityBox;

  Box<DailyRecord> get box => _box;
  Box<CustomActivity> get customActivityBox => _customActivityBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DailyRecordAdapter());
    Hive.registerAdapter(
      CustomActivityAdapter(),
    ); // Now this should be valid after build_runner
    _box = await Hive.openBox<DailyRecord>(_boxName);
    _settingsBox = await Hive.openBox('app_settings');
    _customActivityBox = await Hive.openBox<CustomActivity>(
      'custom_activities',
    );
  }

  bool get onboardingSeen =>
      _settingsBox.get('onboarding_seen', defaultValue: false);

  DateTime? get ramadanStartDate => _settingsBox.get('ramadan_start_date');

  Future<void> setOnboardingSeen() async {
    await _settingsBox.put('onboarding_seen', true);
  }

  bool get notificationsEnabled =>
      _settingsBox.get('notifications_enabled', defaultValue: false);

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _settingsBox.put('notifications_enabled', enabled);
  }

  // Custom Activities Methods
  List<CustomActivity> getCustomActivities() {
    return _customActivityBox.values.toList();
  }

  Future<void> addCustomActivity(CustomActivity activity) async {
    await _customActivityBox.put(activity.id, activity);
  }

  Future<void> deleteCustomActivity(String id) async {
    await _customActivityBox.delete(id);
  }

  Future<void> setRamadanStartDate(DateTime date) async {
    await _settingsBox.put('ramadan_start_date', date);
  }

  DailyRecord? getDailyRecord(int day) {
    // Hive keys can be anything, let's use day as key for O(1) access
    return _box.get(day);
  }

  Future<void> saveDailyRecord(DailyRecord record) async {
    await _box.put(record.day, record);
  }

  List<DailyRecord> getAllRecords() {
    return _box.values.toList();
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  // Backup & Restore
  int get hijriYear => _settingsBox.get('hijri_year', defaultValue: 1446);

  Future<void> setHijriYear(int year) async {
    await _settingsBox.put('hijri_year', year);
  }

  // Backup & Restore
  String exportData() {
    final Map<String, dynamic> data = {
      'records': {},
      'settings': {
        'hijri_year': hijriYear,
        'ramadan_start_date': ramadanStartDate?.toIso8601String(),
        'onboarding_seen': onboardingSeen,
        // Add other settings as needed
      },
    };

    for (var i = 0; i < _box.length; i++) {
      final key = _box.keyAt(i);
      final value = _box.getAt(i);
      if (value != null) {
        (data['records'] as Map)[key.toString()] = value.toJson();
      }
    }
    return jsonEncode(data);
  }

  Future<void> importData(String jsonString) async {
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);

      // Restore records
      if (decoded.containsKey('records')) {
        await _box.clear();
        final records = decoded['records'] as Map<String, dynamic>;
        for (var entry in records.entries) {
          final key = int.tryParse(entry.key);
          if (key != null) {
            final record = DailyRecord.fromJson(entry.value);
            await _box.put(key, record);
          }
        }
      }

      // Restore settings
      if (decoded.containsKey('settings')) {
        final settings = decoded['settings'] as Map<String, dynamic>;
        if (settings['hijri_year'] != null) {
          await setHijriYear(settings['hijri_year']);
        }
        if (settings['ramadan_start_date'] != null) {
          await setRamadanStartDate(
            DateTime.parse(settings['ramadan_start_date']),
          );
        }
        if (settings['onboarding_seen'] != null) {
          await setOnboardingSeen(); // Or set specifically if we had a setter taking bool
        }
      }
    } catch (e) {
      throw Exception('Invalid backup file');
    }
  }
}
