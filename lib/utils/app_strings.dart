import 'package:flutter/material.dart';

class AppStrings {
  static const String appTitle = 'appTitle';
  static const String day = 'day';
  static const String of = 'of';
  static const String streak = 'streak';
  static const String jumpToToday = 'jumpToToday';
  static const String selectDay = 'selectDay';
  static const String dailyActivities = 'dailyActivities';
  static const String dailyProgress = 'dailyProgress';
  static const String total = 'total';
  static const String home = 'home';
  static const String journal = 'journal';
  static const String calendar = 'calendar';
  static const String settings = 'settings';
  static const String appearance = 'appearance';
  static const String darkMode = 'darkMode';
  static const String lightMode = 'lightMode';
  static const String language = 'language';
  static const String configuration = 'configuration';
  static const String ramadanStartDate = 'ramadanStartDate';
  static const String importantDates = 'importantDates';
  static const String noEvents = 'noEvents';
  static const String ramadanBegins = 'ramadanBegins';
  static const String saveJournal = 'saveJournal';
  static const String journalSaved = 'journalSaved';
  static const String journalHint = 'journalHint';
  static const String dayReflections = 'dayReflections';
  static const String pleaseSetDate = 'pleaseSetDate';
  static const String notStarted = 'notStarted';
  static const String ended = 'ended';
  static const String jumpedTo = 'jumpedTo';
  static const String completed = 'completed'; // Added
  static const String overall = 'overall'; // Added
  static const String notifications = 'notifications';
  static const String enableNotifications = 'enableNotifications';

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      appTitle: 'Ramadhan Tracker',
      day: 'Day',
      of: 'of',
      streak: 'Streak',
      jumpToToday: 'Jump into Today',
      selectDay: 'Select Day',
      dailyActivities: 'Daily Activities',
      dailyProgress: 'Daily Progress',
      total: 'Total',
      home: 'Home',
      journal: 'Journal',
      calendar: 'Calendar',
      settings: 'Settings',
      appearance: 'Appearance',
      darkMode: 'Dark Mode',
      lightMode: 'Light Mode',
      language: 'Language',
      configuration: 'Configuration',
      ramadanStartDate: 'Ramadan Start Date',
      importantDates: 'Important Dates',
      noEvents: 'No events for this day.',
      ramadanBegins: 'Ramadan Begins',
      saveJournal: 'Save',
      journalSaved: 'Journal saved!',
      journalHint: 'Write your thoughts, prayers, and reflections here...',
      dayReflections: 'Reflections',
      pleaseSetDate: 'Please set Ramadan Start Date in Settings',
      notStarted: 'Ramadan has not started yet!',
      ended: 'Ramadan has ended!',
      jumpedTo: 'Jumped to Day',
      completed: 'Completed', // Added
      overall: 'Overall', // Added
      notifications: 'Notifications',
      enableNotifications: 'Enable Notifications',
      'streak_7_title': '7 Day Streak',
      'streak_7_desc': 'Consistency is key! 7 days in a row.',
      'sedekah_10_title': 'Charity Champion',
      'sedekah_10_desc': 'Performed charity 10 times.',
      'quran_30_title': 'Khatam Reader',
      'quran_30_desc': 'Read Quran 30 times.',
      'tahajjud_7_title': 'Night Warrior',
      'tahajjud_7_desc': 'Prayed Tahajjud 7 times.',
      'tarawih_20_title': 'Tarawih Dedicated',
      'tarawih_20_desc': 'Prayed Tarawih 20 times.',
    },
    'id': {
      appTitle: 'Pelacak Ramadan',
      day: 'Hari',
      of: 'dari',
      streak: 'Runtunan',
      jumpToToday: 'Lompat ke Hari Ini',
      selectDay: 'Pilih Hari',
      dailyActivities: 'Aktivitas Harian',
      dailyProgress: 'Progres Harian',
      total: 'Total',
      home: 'Beranda',
      journal: 'Jurnal',
      calendar: 'Kalender',
      settings: 'Pengaturan',
      appearance: 'Tampilan',
      darkMode: 'Mode Gelap',
      lightMode: 'Mode Terang',
      language: 'Bahasa',
      configuration: 'Konfigurasi',
      ramadanStartDate: 'Tanggal Mulai Ramadan',
      importantDates: 'Tanggal Penting',
      noEvents: 'Tidak ada acara untuk hari ini.',
      ramadanBegins: 'Awal Ramadan',
      saveJournal: 'Simpan',
      journalSaved: 'Jurnal tersimpan!',
      journalHint: 'Tulis pikiran, doa, dan renunganmu di sini...',
      dayReflections: 'Renungan',
      pleaseSetDate: 'Mohon atur Tanggal Mulai Ramadan di Pengaturan',
      notStarted: 'Ramadan belum dimulai!',
      ended: 'Ramadan telah berakhir!',
      jumpedTo: 'Lompat ke Hari',
      completed: 'Selesai', // Added
      overall: 'Total', // Added
      notifications: 'Notifikasi',
      enableNotifications: 'Aktifkan Notifikasi',
      'streak_7_title': 'Runtunan 7 Hari',
      'streak_7_desc': 'Konsistensi adalah kunci! 7 hari berturut-turut.',
      'sedekah_10_title': 'Ahli Sedekah',
      'sedekah_10_desc': 'Melakukan sedekah 10 kali.',
      'quran_30_title': 'Pembaca Khatam',
      'quran_30_desc': 'Membaca Al-Quran 30 kali.',
      'tahajjud_7_title': 'Pejuang Malam',
      'tahajjud_7_desc': 'Shalat Tahajjud 7 kali.',
      'tarawih_20_title': 'Jamaah Tarawih',
      'tarawih_20_desc': 'Shalat Tarawih 20 kali.',
    },
  };

  static final Map<String, Map<String, String>> _categories = {
    'en': {
      'Last Third of the Night': 'Last Third of the Night',
      'Fajr': 'Fajr',
      'Dhuha': 'Dhuha',
      'Dhuhr': 'Dhuhr',
      'Asr': 'Asr',
      'Iftar': 'Iftar',
      'Maghrib': 'Maghrib',
      'Isha': 'Isha',
      'Before Sleep': 'Before Sleep',
    },
    'id': {
      'Last Third of the Night': 'Sepertiga Malam Terakhir',
      'Fajr': 'Subuh',
      'Dhuha': 'Dhuha',
      'Dhuhr': 'Dzuhur',
      'Asr': 'Ashar',
      'Iftar': 'Buka Puasa',
      'Maghrib': 'Maghrib',
      'Isha': 'Isya',
      'Before Sleep': 'Sebelum Tidur',
    },
  };

  // Map Activity ID to [English Title, Indonesian Title]
  // Ideally this would be fully separated, but for simplicity/speed we map ID -> Strings
  static final Map<String, Map<String, String>> _activityTitles = {
    '1': {'en': 'Dua Upon Waking', 'id': 'Doa Bangun Tidur'},
    '2': {'en': 'Wudu', 'id': 'Wudhu'},
    '3': {'en': 'Tahajjud Prayer', 'id': 'Tahajjud'},
    '4': {'en': 'Make Dua', 'id': 'Berdoa'},
    '5': {'en': 'Suhoor', 'id': 'Sahur'},
    '6': {'en': 'Istighfar', 'id': 'Istighfar'},
    '7': {'en': 'Answer Adhan', 'id': 'Menjawab Adzan'},
    '8': {'en': 'Dua After Adhan', 'id': 'Doa Setelah Adzan'},
    '9': {'en': 'Salawat', 'id': 'Sholawat'},
    '10': {'en': 'Personal Dua', 'id': 'Berdoa Sesuai Keinginan'},
    '11': {'en': 'Sunnah Fajr Prayer', 'id': 'Shalat Sunnah Fajr'},
    '12': {'en': 'Fajr Prayer', 'id': 'Shalat Subuh'},
    '13': {'en': 'Dhikr After Prayer', 'id': 'Dzikir Setelah Shalat'},
    '14': {'en': 'Read Quran', 'id': 'Baca Al-Quran'},
    '15': {'en': 'Charity (Sadaqah)', 'id': 'Sedekah'},
    '16': {'en': 'Morning Dhikr', 'id': 'Dzikir Pagi'},
    '17': {'en': 'Islamic Study', 'id': 'Majelis Ilmu'},
    '18': {'en': 'Ishraq Prayer', 'id': 'Shalat Isyraq'},
    '19': {'en': 'Activity with Kids', 'id': 'Aktivitas Bersama Anak'},
    '20': {'en': 'Duha Prayer', 'id': 'Shalat Dhuha'},
    '21': {'en': 'Memorizing with Kids', 'id': 'Hafalan Bersama Anak'},
    '22': {'en': 'Nap (Qailulah)', 'id': 'Tidur Siang Sebelum Dzuhur'},
    '23': {'en': 'Sunnah Qabliyah', 'id': 'Qabliyah 2 atau 4 Rekaat'},
    '24': {'en': 'Dhuhr Prayer', 'id': 'Shalat Dzuhur'},
    '25': {'en': 'Sunnah Ba\'diyah', 'id': 'Ba\'diyah 2 Rekaat'},
    '26': {'en': 'Sunnah 4 Rekaat', 'id': 'Sholat Sunnah 4 Rekaat'},
    '27': {'en': 'Asr Prayer', 'id': 'Shalat Ashar'},
    '28': {'en': 'Prep for Iftar', 'id': 'Persiapan Buka Puasa'},
    '29': {'en': 'Feed Fasting Person', 'id': 'Sedekah Makanan Berbuka'},
    '30': {'en': 'Hasten Iftar', 'id': 'Menyegerakan Berbuka'},
    '31': {'en': 'Dua for Iftar', 'id': 'Membaca Doa Berbuka'},
    '32': {'en': 'Say Bismillah', 'id': 'Membaca Bismillah'},
    '33': {'en': 'Break fast with Dates', 'id': 'Berbuka Dengan Kurma'},
    '34': {'en': 'Dua for Host', 'id': 'Mendoakan Pemberi Makanan'},
    '35': {'en': 'Drink in 3 Breaths', 'id': 'Minum Dengan 3 Nafas'},
    '36': {'en': 'Dua After Eating', 'id': 'Doa Setelah Makan'},
    '37': {'en': 'Maghrib Prayer', 'id': 'Shalat Maghrib'},
    '38': {'en': 'Evening Dhikr', 'id': 'Dzikir Petang'},
    '39': {'en': 'Dinner', 'id': 'Makan Malam / Ifthar'},
    '40': {'en': 'Isha Prayer', 'id': 'Shalat Isya'},
    '41': {'en': 'Tarawih Prayer', 'id': 'Tarawih Berjamaah'},
    '42': {'en': 'Dua After Witr', 'id': 'Doa Setelah Witir'},
    '43': {'en': 'Quran Stories', 'id': 'Kisah Dari Al-Quran'},
    '44': {'en': 'Ayat Kursi', 'id': 'Ayat Kursi'},
    '45': {'en': '3 Quls (3x)', 'id': 'Al-Ikhlas, Al-Falaq, An-Naas @3x'},
    '46': {'en': 'Dua Before Sleep', 'id': 'Doa Sebelum Tidur'},
    '47': {'en': 'Intention for Fasting', 'id': 'Niat Puasa Esok Hari'},
  };

  static String get(String key, Locale locale) {
    String langCode = locale.languageCode;
    if (!_localizedValues.containsKey(langCode)) {
      langCode = 'en'; // Fallback
    }
    return _localizedValues[langCode]?[key] ?? key;
  }

  static String getCategory(String categoryKey, Locale locale) {
    String langCode = locale.languageCode;
    if (!_categories.containsKey(langCode)) langCode = 'en';
    return _categories[langCode]?[categoryKey] ?? categoryKey;
  }

  static String getActivityTitle(
    String activityId,
    String fallbackTitle,
    Locale locale,
  ) {
    String langCode = locale.languageCode;
    if (_activityTitles.containsKey(activityId) &&
        _activityTitles[activityId] != null) {
      return _activityTitles[activityId]?[langCode] ?? fallbackTitle;
    }
    return fallbackTitle;
  }
}
