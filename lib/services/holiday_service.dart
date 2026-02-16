import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HolidayService {
  static const String _baseUrl = 'http://api.aladhan.com/v1/gToHCalendar';

  Future<Map<DateTime, List<String>>> getHolidays(int month, int year) async {
    final url = Uri.parse('$_baseUrl/$month/$year');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> days = data['data'];

        final Map<DateTime, List<String>> holidays = {};

        for (var dayData in days) {
          final hijri = dayData['hijri'];
          final gregorian = dayData['gregorian'];
          final dateStr = gregorian['date']; // DD-MM-YYYY
          final date = DateFormat('dd-MM-yyyy').parse(dateStr);

          final List<dynamic> holidayList = hijri['holidays'];
          if (holidayList.isNotEmpty) {
            holidays[date] = holidayList.cast<String>();
          }
        }
        return holidays;
      } else {
        throw Exception('Failed to load holidays');
      }
    } catch (e) {
      print('Error fetching holidays: $e');
      return {};
    }
  }
}
