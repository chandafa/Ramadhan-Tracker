import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import '../providers/app_providers.dart';
import '../utils/app_strings.dart';
import '../utils/app_data.dart';
import '../widgets/countdown_widget.dart';

import '../services/holiday_service.dart';
import '../widgets/skeleton_widget.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final HolidayService _holidayService = HolidayService();
  Map<DateTime, List<String>> _holidays = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHolidays();
  }

  Future<void> _fetchHolidays() async {
    setState(() => _isLoading = true);
    final holidays = await _holidayService.getHolidays(
      _focusedDay.month,
      _focusedDay.year,
    );
    if (mounted) {
      setState(() {
        _holidays = holidays;
        _isLoading = false;
      });
    }
  }

  dynamic _getMoonPhaseIcon(int day) {
    if (day <= 3) return HugeIcons.strokeRoundedMoon02; // Crescent
    if (day <= 7) return HugeIcons.strokeRoundedMoon02;
    if (day <= 12) return HugeIcons.strokeRoundedMoon02;
    if (day <= 16) return HugeIcons.strokeRoundedMoon; // Full
    if (day <= 20) return HugeIcons.strokeRoundedMoon02;
    if (day <= 24) return HugeIcons.strokeRoundedMoon02;
    if (day <= 28) return HugeIcons.strokeRoundedMoon02;
    return HugeIcons.strokeRoundedMoon02;
  }

  @override
  Widget build(BuildContext context) {
    final ramadanStart = ref.watch(ramadanStartDateProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get(AppStrings.calendar, locale))),
      body: _isLoading
          ? SingleChildScrollView(
              child: Column(
                children: [const CountdownWidget(), const CalendarSkeleton()],
              ),
            )
          : ListView(
              children: [
                const CountdownWidget(),
                TableCalendar(
                      firstDay: DateTime.utc(2020, 10, 16),
                      lastDay: DateTime.utc(2030, 3, 14),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        }
                      },
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                        _fetchHolidays();
                      },
                      eventLoader: (day) {
                        final d = DateTime(day.year, day.month, day.day);
                        List<String> events = _holidays[d] ?? [];
                        if (ramadanStart != null &&
                            isSameDay(ramadanStart, d)) {
                          if (!events.any((e) => e.contains('Ramadan'))) {
                            events = [
                              ...events,
                              AppStrings.get(AppStrings.ramadanBegins, locale),
                            ];
                          }
                        }
                        return events;
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        weekendTextStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        outsideTextStyle: TextStyle(
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        leftChevronIcon: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowLeft01,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        rightChevronIcon: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight01,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          return _buildCalendarDay(context, day, ramadanStart);
                        },
                        selectedBuilder: (context, day, focusedDay) {
                          return _buildCalendarDay(
                            context,
                            day,
                            ramadanStart,
                            isSelected: true,
                          );
                        },
                        todayBuilder: (context, day, focusedDay) {
                          return _buildCalendarDay(
                            context,
                            day,
                            ramadanStart,
                            isToday: true,
                          );
                        },
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.1, end: 0, curve: Curves.easeOut),
                const SizedBox(height: 20),
                Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get(AppStrings.importantDates, locale),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (_selectedDay != null) ...[
                            _buildEventList(_selectedDay!, locale),
                          ] else ...[
                            const Text('Select a date to see details.'),
                            const SizedBox(height: 10),
                            if (ramadanStart != null)
                              ListTile(
                                leading: HugeIcon(
                                  icon: HugeIcons.strokeRoundedMoon02,
                                  color: Theme.of(context).primaryColor,
                                ),
                                title: Text(
                                  AppStrings.get(
                                    AppStrings.ramadanStartDate,
                                    locale,
                                  ),
                                ),
                                subtitle: Text(
                                  "${ramadanStart.day}/${ramadanStart.month}/${ramadanStart.year}",
                                ),
                              ),
                          ],
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
              ],
            ),
    );
  }

  Widget _buildEventList(DateTime day, Locale locale) {
    final d = DateTime(day.year, day.month, day.day);
    final events = _holidays[d] ?? [];
    final ramadanStart = ref.read(ramadanStartDateProvider);
    final isRamadanStart = ramadanStart != null && isSameDay(ramadanStart, d);

    if (events.isEmpty && !isRamadanStart) {
      return Text(AppStrings.get(AppStrings.noEvents, locale));
    }

    return Column(
      children: [
        if (isRamadanStart)
          ListTile(
            leading: HugeIcon(
              icon: HugeIcons.strokeRoundedMoon02,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(AppStrings.get(AppStrings.ramadanBegins, locale)),
          ),
        ...events.map(
          (e) => ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedStar,
              color: Colors.orange,
            ),
            title: Text(e),
          ),
        ),
      ],
    );
  }

  Widget? _buildCalendarDay(
    BuildContext context,
    DateTime day,
    DateTime? ramadanStart, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    if (ramadanStart == null) return null; // Default style

    final start = DateTime(
      ramadanStart.year,
      ramadanStart.month,
      ramadanStart.day,
    );
    final current = DateTime(day.year, day.month, day.day);
    final diff = current.difference(start).inDays + 1;

    if (diff < 1 || diff > 30) return null; // Outside Ramadan

    final records = ref.watch(dailyRecordsProvider);
    final record = records[diff];
    // Use fixed total 47 or dynamic from AppData. Assuming generic progress for visual
    final totalActivities = AppData.activities.length + 5;
    final completedCount = record?.completedActivityIds.length ?? 0;
    // Cap progress at 1.0
    final progress = (completedCount / totalActivities).clamp(0.0, 1.0);

    Color dayColor = Colors.transparent;
    Color textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    // GitHub-style coloring
    if (progress == 1.0) {
      dayColor = const Color(0xFF216E39); // Dark Green
      textColor = Colors.white;
    } else if (progress >= 0.5) {
      dayColor = const Color(0xFF30A14E); // Medium Green
      textColor = Colors.white;
    } else if (progress > 0) {
      dayColor = const Color(0xFF40C463); // Light Green
      textColor = Colors.white;
    } else {
      // Default plain or slight tint
      dayColor = Theme.of(context).disabledColor.withValues(alpha: 0.1);
    }

    // Moon Phase Icon
    final moonIcon = _getMoonPhaseIcon(diff);

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: dayColor,
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: Theme.of(context).primaryColor, width: 2)
            : isToday
            ? Border.all(color: Colors.blue, width: 2)
            : null,
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Optional: Show Moon Icon faintly in background or small
          Opacity(
            opacity: 0.2,
            child: HugeIcon(icon: moonIcon, size: 28, color: textColor),
          ),
          Text(
            '${day.day}',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
