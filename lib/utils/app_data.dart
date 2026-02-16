import '../models/activity_model.dart';

class AppData {
  static const List<String> categories = [
    'Last Third of the Night',
    'Fajr',
    'Dhuha',
    'Dhuhr',
    'Asr',
    'Iftar',
    'Maghrib',
    'Isha',
    'Before Sleep',
  ];

  static const List<Activity> activities = [
    // Last Third of the Night
    Activity(
      id: '1',
      title: 'Doa Bangun Tidur',
      category: 'Last Third of the Night',
      order: 1,
    ),
    Activity(
      id: '2',
      title: 'Wudhu',
      category: 'Last Third of the Night',
      order: 2,
    ),
    Activity(
      id: '3',
      title: 'Tahajjud',
      category: 'Last Third of the Night',
      order: 3,
    ),
    Activity(
      id: '4',
      title: 'Berdoa',
      category: 'Last Third of the Night',
      order: 4,
    ),
    Activity(
      id: '5',
      title: 'Sahur',
      category: 'Last Third of the Night',
      order: 5,
    ),
    Activity(
      id: '6',
      title: 'Istighfar',
      category: 'Last Third of the Night',
      order: 6,
    ),

    // Fajr
    Activity(id: '7', title: 'Menjawab Adzan', category: 'Fajr', order: 7),
    Activity(id: '8', title: 'Doa Setelah Adzan', category: 'Fajr', order: 8),
    Activity(id: '9', title: 'Sholawat', category: 'Fajr', order: 9),
    Activity(
      id: '10',
      title: 'Berdoa Sesuai Keinginan',
      category: 'Fajr',
      order: 10,
    ),
    Activity(
      id: '11',
      title: 'Shalat Sunnah Fajr',
      category: 'Fajr',
      order: 11,
    ),
    Activity(id: '12', title: 'Shalat Subuh', category: 'Fajr', order: 12),
    Activity(
      id: '13',
      title: 'Dzikir Setelah Shalat',
      category: 'Fajr',
      order: 13,
    ),
    Activity(id: '14', title: 'Baca Al-Quran', category: 'Fajr', order: 14),
    Activity(id: '15', title: 'Sedekah', category: 'Fajr', order: 15),
    Activity(id: '16', title: 'Dzikir Pagi', category: 'Fajr', order: 16),
    Activity(id: '17', title: 'Majelis Ilmu', category: 'Fajr', order: 17),
    Activity(id: '18', title: 'Shalat Isyraq', category: 'Fajr', order: 18),

    // Dhuha
    Activity(
      id: '19',
      title: 'Aktivitas Bersama Anak',
      category: 'Dhuha',
      order: 19,
    ),
    Activity(id: '20', title: 'Shalat Dhuha', category: 'Dhuha', order: 20),
    Activity(
      id: '21',
      title: 'Hafalan Bersama Anak',
      category: 'Dhuha',
      order: 21,
    ),
    Activity(
      id: '22',
      title: 'Tidur Siang Sebelum Dzuhur',
      category: 'Dhuha',
      order: 22,
    ),

    // Dhuhr
    Activity(
      id: '23',
      title: 'Qabliyah 2 atau 4 Rekaat',
      category: 'Dhuhr',
      order: 23,
    ),
    Activity(id: '24', title: 'Shalat Dzuhur', category: 'Dhuhr', order: 24),
    Activity(
      id: '25',
      title: 'Ba\'diyah 2 Rekaat',
      category: 'Dhuhr',
      order: 25,
    ),

    // Asr
    Activity(
      id: '26',
      title: 'Sholat Sunnah 4 Rekaat',
      category: 'Asr',
      order: 26,
    ),
    Activity(id: '27', title: 'Shalat Ashar', category: 'Asr', order: 27),
    Activity(
      id: '28',
      title: 'Persiapan Buka Puasa',
      category: 'Asr',
      order: 28,
    ),
    Activity(
      id: '29',
      title: 'Sedekah Makanan Berbuka',
      category: 'Asr',
      order: 29,
    ),

    // Iftar
    Activity(
      id: '30',
      title: 'Menyegerakan Berbuka',
      category: 'Iftar',
      order: 30,
    ),
    Activity(
      id: '31',
      title: 'Membaca Doa Berbuka',
      category: 'Iftar',
      order: 31,
    ),
    Activity(
      id: '32',
      title: 'Membaca Bismillah',
      category: 'Iftar',
      order: 32,
    ),
    Activity(
      id: '33',
      title: 'Berbuka Dengan Kurma',
      category: 'Iftar',
      order: 33,
    ),
    Activity(
      id: '34',
      title: 'Mendoakan Orang yang Memberi Makanan Berbuka',
      category: 'Iftar',
      order: 34,
    ),
    Activity(
      id: '35',
      title: 'Minum Dengan 3 Nafas',
      category: 'Iftar',
      order: 35,
    ),
    Activity(
      id: '36',
      title: 'Doa Setelah Makan',
      category: 'Iftar',
      order: 36,
    ),

    // Maghrib
    Activity(id: '37', title: 'Shalat Maghrib', category: 'Maghrib', order: 37),
    Activity(id: '38', title: 'Dzikir Petang', category: 'Maghrib', order: 38),
    Activity(
      id: '39',
      title: 'Ifthar',
      category: 'Maghrib',
      order: 39,
    ), // Assuming generic Ifthar/Dinner
    // Isha
    Activity(id: '40', title: 'Shalat Isya', category: 'Isha', order: 40),
    Activity(id: '41', title: 'Tarawih Berjamaah', category: 'Isha', order: 41),
    Activity(id: '42', title: 'Doa Setelah Witir', category: 'Isha', order: 42),
    Activity(
      id: '43',
      title: 'Kisah Dari Al-Quran',
      category: 'Isha',
      order: 43,
    ),

    // Before Sleep
    Activity(
      id: '44',
      title: 'Ayat Kursi',
      category: 'Before Sleep',
      order: 44,
    ),
    Activity(
      id: '45',
      title: 'Al-Ikhlas, Al-Falaq, An-Naas @3x',
      category: 'Before Sleep',
      order: 45,
    ),
    Activity(
      id: '46',
      title: 'Doa Sebelum Tidur',
      category: 'Before Sleep',
      order: 46,
    ),
    Activity(
      id: '47',
      title: 'Niat Puasa Esok Hari',
      category: 'Before Sleep',
      order: 47,
    ),
  ];
}
